//
//  AppSettings.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/29.
//

import AppKit
import RxDefaultsPlus

@MainActor
class AppSettings {
    public static let shared = AppSettings()

    private init() {}

    @UserDefault(key: "baseURL", defaultValue: "http://localhost:3000")
    var baseURL: String
}
