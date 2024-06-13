//
//  AppServices.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import Foundation
import NeteaseCloudMusicService

@MainActor
class AppServices {
    lazy var neteaseService: NeteaseCloudMusicService = .init(baseURL: AppSettings.shared.baseURL)
    
    lazy var settingsService: AppSettings = .shared
    
    static let testAppServices: AppServices = .init()
}
