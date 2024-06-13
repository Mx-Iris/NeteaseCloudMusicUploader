//
//  PersonalViewController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/29.
//

import AppKit
import Combine
import CocoaCoordinator
import UIFoundation
import NeteaseCloudMusicModel
import NeteaseCloudMusicService
import Kingfisher
import RxKingfisherPlus
import RxSwift
import RxCocoa
import RxAppKit
import RxSwiftExt
import RxSwiftPlus

@MainActor
class PersonalViewController: ViewController<PersonalViewModel> {
    @MagicViewLoading
    @IBOutlet var avatarImageView: AvatarImageView
    
    @MagicViewLoading
    @IBOutlet var nicknameLabel: NSTextField
    
    @MagicViewLoading
    @IBOutlet var logoutButton: NSButton
    
    @MagicViewLoading
    @IBOutlet var dismissButton: NSButton

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupBindings(for viewModel: PersonalViewModel) {
        super.setupBindings(for: viewModel)

        let input = PersonalViewModel.Input(clickDismiss: dismissButton.rx.click.asObservable(), clickLogout: logoutButton.rx.click.asObservable())

        let output = viewModel.transform(input)
        
        output.avatarURL.map { $0 }.drive(avatarImageView.kf.rx.image()).disposed(by: rx.disposeBag)
        
        output.nickname.compactMap { $0 }.drive(nicknameLabel.rx.stringValue).disposed(by: rx.disposeBag)
        
    }
}

// @available(macOS 14.0, *)
// #Preview(traits: .fixedLayout(width: 600, height: 250)) {
//    PreviewWrapperViewController {
//        PersonalViewController.create(with: .testAppServices)
//    }
// }
