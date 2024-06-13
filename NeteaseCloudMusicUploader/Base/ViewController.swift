//
//  BaseViewController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/26.
//

import AppKit
import UIFoundation

@MainActor
class ViewController<ViewModel>: NSViewController, StoryboardViewController {
    var viewModel: ViewModel?

    func setupBindings(for viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}
