//
//  MainWindowController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import UIFoundation

class MainWindowController: WindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.identifier = "com.JH.NeteaseCloudMusicUploader.MainWindowController"
        window?.setFrameAutosaveName("com.JH.NeteaseCloudMusicUploader.MainWindowController.frameAutosaveName")
    }

    var viewModel: MainViewModel?

    @IBAction func refetchCloudSongs(_ sender: NSButton) {
        viewModel?.refreshCloudSongs()
    }

    @IBAction func presentPersonalInfo(_ sender: NSButton) {
        viewModel?.presentPersonalInfo()
    }
    
    func setupBindings(for viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
}
