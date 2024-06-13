import AppKit
import Papyrus
import RxSwift
import RxCocoa
import RxSwiftPlus
import RxDefaultsPlus
import NeteaseCloudMusicModel

@MainActor
public final class NeteaseCloudMusicService {
    private let baseURL: String

    private var api: NeteaseCloudMusicAPI

    @Observed
    public private(set) var isLogined: Bool = false

    @Observed
    public private(set) var isLoginOperating: Bool = false

    private var qrcodeKey: String?

    @UserDefault(key: "com-JH-NeteaseCloudMusicService-Cookie", defaultValue: nil)
    private var cookie: String? {
        didSet {
            buildAPI(for: cookie)
            isLogined = cookie != nil
        }
    }

    @UserDefault(key: "com-JH-NeteaseCloudMusicService-PersonalInfo", defaultValue: nil)
    public private(set) var personalInfo: PersonalInfo?

    public init(baseURL: String) {
        self.baseURL = baseURL
        self.api = NeteaseCloudMusicAPI(provider: .init(baseURL: baseURL))
        buildAPI(for: cookie)
        _isLogined = .init(wrappedValue: cookie != nil)
    }

    private func buildAPI(for cookie: String?) {
        if let cookie {
            let provider = Provider(baseURL: baseURL).modifyRequests {
                $0.addQuery("timestamp", value: Date().timeIntervalSince1970)
                $0.addQuery("cookie", value: cookie)
                $0.addQuery("realIP", value: "116.25.146.177")
            }
            api = NeteaseCloudMusicAPI(provider: provider)
        }
    }

    public enum ServiceError: Error {
        case performLoginOperating
    }

    private func performLoginOperation<T>(_ block: () async throws -> T) async throws -> T {
        guard !isLoginOperating else { throw ServiceError.performLoginOperating }
        isLoginOperating = true
        defer { isLoginOperating = false }
        return try await block()
    }

    public func mobileLogin(_ phone: String, password: String) async throws {
        try await performLoginOperation {
            cookie = try await api.mobileLogin(phone: phone, password: password, countrycode: nil, captcha: nil).cookie
            try await recordPersonalInfo()
        }
    }

    public func mobileLogin(_ phone: String, captcha: String) async throws {
        try await performLoginOperation {
            cookie = try await api.mobileLogin(phone: phone, password: "", countrycode: nil, captcha: captcha).cookie
            try await recordPersonalInfo()
        }
    }

    public func sentCaptcha(_ phone: String) async throws {
        try await performLoginOperation {
            try await api.sentCaptcha(phone: phone, ctcode: nil)
        }
    }

    public func mailLogin(_ email: String, password: String) async throws {
        try await performLoginOperation {
            cookie = try await api.mailLogin(email: email, password: password).cookie
            try await recordPersonalInfo()
        }
    }

    public func qrcodeLoginImage(for size: CGSize) async throws -> NSImage? {
        try await performLoginOperation {
            let qrcodeKey = try await api.qrcodeLoginKey().data.unikey
            let qrcodeURL = try await api.qrcodeLoginCreate(key: qrcodeKey).data.qrurl
            if let nsImage = generateQRCode(from: qrcodeURL) {
                self.qrcodeKey = qrcodeKey
                return nsImage
            } else {
                return nil
            }
        }
    }

    private func generateQRCode(from url: String) -> NSImage? {
        let data = url.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                let rep = NSCIImageRep(ciImage: output)
                let nsImage = NSImage(size: rep.size)
                nsImage.addRepresentation(rep)
                return nsImage
            }
        }
        return nil
    }

    public func qrcodeLoginCheck() async throws -> QRCodeState {
        guard let qrcodeKey else { return .fail }
        let check = try await api.qrcodeLoginCheck(key: qrcodeKey)
        let qrcodeState = QRCodeState(rawValue: check.code) ?? .fail
        if let cookie = check.cookie, qrcodeState == .success {
            self.cookie = cookie
            try await recordPersonalInfo()
        }
        return qrcodeState
    }

    public func logout() async throws {
        try await api.logout()
        cookie = nil
        personalInfo = nil
    }

    public func uploadCloudSongFile(at fileURL: URL, mimeType: String?) async throws {
        let data = try Data(contentsOf: fileURL)
        let part = Part(data: data, name: "songFile", fileName: fileURL.lastPathComponent, mimeType: mimeType)
        try await api.uploadCloudSongFile(part)
    }

    public func matchCloudSong(_ song: CloudSong, matchSongID: Int?) async throws {
        let loginStatus = try await api.loginStatus()
        try await api.cloudSongMatch(uid: loginStatus.data.account.id, sid: song.songID, asid: matchSongID ?? 0)
    }

    public func fetchCloudSongs() async throws -> [CloudSong] {
        var offset = 0
        var cloudSongs: [CloudSong] = []
        while true {
            let cloudSongList = try await api.cloudSongList(limit: 100, offset: offset)
            cloudSongs.append(contentsOf: cloudSongList.songs)
            guard cloudSongList.hasMore else { break }
            offset += 1
        }
        return cloudSongs
    }

    public func fetchPersonalInfo() async throws -> PersonalInfo {
        let loginStatus = try await api.loginStatus()
        let personalInfo = PersonalInfo(avatarURL: loginStatus.data.profile.avatarURL, nickname: loginStatus.data.profile.nickname)
        return personalInfo
    }

    public func recordPersonalInfo() async throws {
        personalInfo = try await fetchPersonalInfo()
    }
}
