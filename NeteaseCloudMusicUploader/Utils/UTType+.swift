//
//  UTType+.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/28.
//

import AppKit
import UniformTypeIdentifiers

extension UTType {
    static let flac = Self("org.xiph.flac")!
    static let m4a = Self("com.apple.m4a-audio")!
    static let aac = Self("public.aac-audio")!
}

extension UTType {
    static let supportedTypes: [UTType] = [
        .mp3, .flac, .m4a, .aac,
    ]

    var isSupportType: Bool {
        Self.supportedTypes.contains(self)
    }
}
