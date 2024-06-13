//
//  CloudSongsTableController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/28.
//

import AppKit
import Combine
import RxSwift
import RxCocoa
import RxSwiftPlus
import NeteaseCloudMusicModel
import NeteaseCloudMusicService

@MainActor
class CloudSongsTableViewModel: ViewModel<MainRoute> {
    @Observed
    public private(set) var cloudSongs: [CloudSong] = []

    @Observed
    public private(set) var errorMessage: String?

    @Observed
    public private(set) var unavailableType: CloudSongsTableUnavailableView.UnavailableType = .loading

    func fetchCloudSongs() {
        Task {
            unavailableType = .loading
            defer {
                unavailableType = cloudSongs.isEmpty ? .isEmpty : .none
            }
            do {
                cloudSongs = try await appServices.neteaseService.fetchCloudSongs()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
