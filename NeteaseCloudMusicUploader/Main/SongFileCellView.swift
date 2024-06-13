//
//  SongFileCellView.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/28.
//

import AppKit
import RxSwift
import RxCocoa
import RxSwiftPlus
import SnapKit
import SFSymbol
import UIFoundation
import ViewHierarchyBuilder

@MainActor
class SongFileCellView: TableCellView {
    let iconImageView = ImageView()

    let fileNameLabel = Label()

    let filePathLabel = Label()

    let uploadStateImageView = ImageView()

    let uploadingIndicator: MaterialLoadingIndicator = .init(radius: 15, color: .controlAccentColor)

    func configure(for songFile: SongFile) {
        rx.disposeBag = DisposeBag()
        iconImageView.image = songFile.icon
        fileNameLabel.stringValue = songFile.url.lastPathComponent.deletingPathExtension
        filePathLabel.stringValue = songFile.url.path
        updateUploadState(songFile.uploadState)
        songFile.$uploadState
            .asDriver()
            .driveOnNext { [weak self] uploadState in
                guard let self else { return }
                updateUploadState(uploadState)
            }
            .disposed(by: rx.disposeBag)
    }

    private func updateUploadState(_ uploadState: SongFile.UploadState) {
        uploadingIndicator.isHidden = uploadState != .uploading
        uploadStateImageView.isHidden = uploadState == .uploading
        uploadStateImageView.image = uploadState.image
        uploadStateImageView.contentTintColor = uploadState.color

        switch uploadState {
        case .uploading:
            uploadingIndicator.startAnimating()
        case .ready,
             .failure,
             .success:
            uploadingIndicator.stopAnimating()
        }
    }

    override func setup() {
        super.setup()

        hierarchy {
            iconImageView
            fileNameLabel
            filePathLabel
            uploadStateImageView
            uploadingIndicator
        }

        fileNameLabel.do {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .labelColor
            $0.maximumNumberOfLines = 1
        }

        filePathLabel.do {
            $0.font = .systemFont(ofSize: 11)
            $0.textColor = .secondaryLabelColor
            $0.maximumNumberOfLines = 1
        }

        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(35)
        }

        fileNameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.right.equalTo(uploadingIndicator.snp.left).offset(-10)
        }

        filePathLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconImageView)
            make.left.equalTo(fileNameLabel)
            make.right.equalTo(uploadingIndicator.snp.left).offset(-10)
        }

        uploadingIndicator.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.size.equalTo(35)
        }

        uploadStateImageView.snp.makeConstraints { make in
            make.edges.equalTo(uploadingIndicator)
        }
    }
}

// @available(macOS 14.0, *)
// #Preview(traits: .fixedLayout(width: 500, height: 60)) {
//    PreviewWrapperView {
//        SongFileCellView().then {
//            $0.configure(for: .testFailureSongFile)
//        }
//    }
// }
//
