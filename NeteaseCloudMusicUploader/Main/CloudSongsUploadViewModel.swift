//
//  CloudSongsUploadController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/28.
//

import AppKit
import DSFDropFilesView
import FZSwiftUtils
import OSLog
import Sandbox
import RxSwift
import RxCocoa
import RxSwiftPlus
import FrameworkToolbox

class CloudSongsUploadViewModel: ViewModel<MainRoute> {
    private let logger = Logger(subsystem: "com.JH.NeteaseCloudMusicUploader", category: "CloudSongsUpload")

    @Observed
    public private(set) var songFiles: [SongFile] = []

    @Observed
    public private(set) var comlpetionSongFiles: [SongFile] = []

    @Observed
    public private(set) var isUploading: Bool = false

    public func clearSongFiles() {
        songFiles = []
        comlpetionSongFiles = []
    }

    public func uploadSongFiles() {
        comlpetionSongFiles = []
        Task {
            await MainActor.run {
                isUploading = true
            }

            for songFile in songFiles.filter({ $0.uploadState != .success }) {
                let newUploadState: SongFile.UploadState
                logger.log("开始上传:\(songFile.url.path)")

                songFile.uploadState = .uploading

                do {
                    try await appServices.neteaseService.uploadCloudSongFile(at: songFile.url, mimeType: songFile.url.contentType?.preferredMIMEType)
                    newUploadState = .success
                    logger.log("上传成功:\(songFile.url.path)")
                } catch {
                    newUploadState = .failure
                    logger.log("上传失败:\(songFile.url.path) \(error)")
                }

                songFile.uploadState = newUploadState
                comlpetionSongFiles.append(songFile)

                logger.log("上传进度: \(self.comlpetionSongFiles.count.box.double.divide(by: self.songFiles.count.box.double).multiply(by: 100))")
            }

            isUploading = false
        }
    }
}

extension CloudSongsUploadViewModel: DSFDropFilesViewProtocol {
    func dropFilesView(_ sender: DSFDropFilesView, validateFiles: [URL]) -> NSDragOperation {
        guard songFiles.isEmpty else { return [] }
        let allowsDropFiles = validateFiles.allSatisfy {
            $0.contentType?.isSupportType ?? false
        }
        logger.debug("\(validateFiles.map { $0.path.lastPathComponent })")
        return allowsDropFiles ? .copy : []
    }

    func dropFilesView(_ sender: DSFDropFilesView, didDropFiles files: [URL]) -> Bool {
        logger.debug("\(files.map { $0.path.lastPathComponent })")
        songFiles = files.map { .init(url: $0) }
        return (try? files.allSatisfy { try PermissionManager.default.accessAndIfNeededAskUserForSecurityScope(fileURL: $0, {}) }) ?? false
    }
}

extension Double {
    
    func divide(by num: Double) -> Double {
        self / num
    }
    
    func multiply(by num: Double) -> Double {
        self * num
    }
}
