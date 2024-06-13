//
//  MainSplitViewController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import UIFoundation

class MainSplitViewController: NSSplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = .init(x: 0, y: 0, width: 1280, height: 800)
    }

    var viewModel: MainViewModel?

    func setupBindings(for viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
}
