//
//  SongFile.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/28.
//

import AppKit
import RxSwift
import RxCocoa
import RxSwiftPlus
import AVFoundation
import FoundationToolbox
import SFSymbol

@MainActor
class SongFile {
    enum UploadState {
        case ready
        case uploading
        case failure
        case success
    }

    let url: URL

    @Observed
    var uploadState: UploadState

    lazy var icon: NSImage = url.albumImage ?? NSWorkspace.shared.icon(forFile: url.path)

    init(url: URL, initialUploadState: UploadState = .ready) {
        self.url = url
        self.uploadState = initialUploadState
    }
}

extension SongFile: Hashable, Identifiable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }

    static func == (lhs: SongFile, rhs: SongFile) -> Bool {
        lhs.url == rhs.url
    }
}

extension SongFile.UploadState {
    var image: NSImage? {
        switch self {
        case .ready:
            SFSymbol(systemName: .plusCircle, pointSize: 22, weight: .regular).nsImage
        case .uploading:
            nil
        case .failure:
            SFSymbol(systemName: .xmarkCircle, pointSize: 22, weight: .regular).nsImage
        case .success:
            SFSymbol(systemName: .checkmarkCircle, pointSize: 22, weight: .regular).nsImage
        }
    }

    var color: NSColor? {
        switch self {
        case .ready:
            .systemOrange
        case .uploading:
            nil
        case .failure:
            .systemRed
        case .success:
            .systemGreen
        }
    }
}

extension URL {
    var albumImage: NSImage? {
        AVURLAsset(url: self).metadata
            .first {
                $0.commonKey == .commonKeyArtwork || $0.key.map { $0.isEqual("artworkData".nsString) }.asFalseIfNone
            }.flatMap {
                $0.dataValue.flatMap { NSImage(data: $0) }
            }
    }
}

extension Bool? {
    var asTrueIfNone: Bool {
        self ?? true
    }

    var asFalseIfNone: Bool {
        self ?? false
    }
}
