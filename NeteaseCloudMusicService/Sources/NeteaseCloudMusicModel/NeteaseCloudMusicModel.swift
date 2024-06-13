import Foundation
import MetaCodable
import HelperCoders

@Codable
public struct CloudSong: Hashable, Identifiable {
    @CodedBy(Since1970DateCoder(intervalType: .milliseconds))
    public let addTime: Date
    public let songName: String
    public let album: String
    public let artist: String
    public let bitrate: Int
    @CodedAt("songId")
    public let songID: Int
    public let cover: Date
    @CodedAt("coverId")
    public let coverID: String
    @CodedAt("lyricId")
    public let lyricID: String
    public let version: Int
    public let fileSize: Int
    public let fileName: String

    public var id: Self { self }
}

@Codable
public struct CloudSongList {
    @CodedAt("data")
    public let songs: [CloudSong]
    public let count: Int
    public let size: String
    public let maxSize: String
    public let upgradeSign: Int
    public let hasMore: Bool
    public let code: Int
}

public struct Account: Codable {
    public let id: Int
    public let userName: String
    public let type: Int
    public let status: Int
    public let whitelistAuthority: Int
    public let createTime: Date
    public let anonimousUser: Bool
}

@Codable
public struct Profile {
    @CodedAt("userId")
    public let userID: Int
    public let userType: Int
    @CodedAt("avatarUrl")
    public let avatarURL: URL?
    public let authStatus: Int
    public let accountStatus: Int
    public let nickname: String
    @CodedAt("avatarImgId")
    public let avatarImgID: Int
    public let defaultAvatar: Bool
    public let signature: String?
    public let authority: Int
}

public struct LoginResponse: Codable {
    @Codable
    public struct Binding {
        public let bindingTime: Date
        public let refreshTime: Date
        public let tokenJsonStr: String
        public let expiresIn: Date
        public let url: String
        public let expired: Bool
        @CodedAt("userId")
        public let userID: Int
        public let id: Int
        public let type: Int
    }

    public let loginType: Int
    public let code: Int
    public let account: Account
    public let token: String
    public let profile: Profile
    public let bindings: [Binding]
    public let cookie: String
}

@Codable
@MemberInit
public struct PersonalInfo {
    public let avatarURL: URL?
    public let nickname: String
}

public struct LoginStatus: Codable {
    public struct Data: Codable {
        public let code: Int
        public let account: Account
        public let profile: Profile
    }

    public let data: Data
}

@Codable
public struct QRCodeCreateResponse {
    @Codable
    public struct Data {
        public let qrurl: String
    }

    public let data: Data
    public let code: Int
}

@Codable
public struct QRCodeKeyResponse {
    @Codable
    public struct Data {
        public let code: Int
        public let unikey: String
    }

    public let data: Data
    public let code: Int
}

@Codable
public struct QRCodeCheckResponse {
    public let code: Int
    public let message: String
    public let cookie: String?
}

public enum QRCodeState: Int {
    case success = 803
    case fail
    case expire = 800
    case waiting = 801
}
