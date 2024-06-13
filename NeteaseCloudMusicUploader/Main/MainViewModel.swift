//
//  MainViewModel.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/31.
//

import AppKit

class MainViewModel: ViewModel<MainRoute> {
    lazy var tableViewModel = CloudSongsTableViewModel(appServices: appServices, router: router)

    lazy var uploadViewModel = CloudSongsUploadViewModel(appServices: appServices, router: router)
    
    
    func refreshCloudSongs() {
        tableViewModel.fetchCloudSongs()
    }
    
    func presentPersonalInfo() {
        router.trigger(.personal)
    }
}
