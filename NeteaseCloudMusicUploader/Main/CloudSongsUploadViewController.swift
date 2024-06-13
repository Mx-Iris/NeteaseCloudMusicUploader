//
//  CloudSongsUploadViewController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import SnapKit
import UIFoundation
import DSFDropFilesView
import RxSwift
import RxCocoa
import RxSwiftPlus

@MainActor
class CloudSongsUploadViewController: ViewController<CloudSongsUploadViewModel> {
    protocol Delegate: AnyObject {
        func uploadViewControllerSongFilesDidUpload(_ controller: CloudSongsUploadViewController)
    }

    public weak var delegate: Delegate?

    @MagicViewLoading
    @IBOutlet private var dropSongsView: DSFDropFilesView

    @MagicViewLoading
    @IBOutlet private var uploadProgressIndicator: NSProgressIndicator

    @MagicViewLoading
    @IBOutlet private var clearSongsButton: NSButton

    @MagicViewLoading
    @IBOutlet private var uploadSongsButton: NSButton

    @MagicViewLoading
    @IBOutlet private var uploadSongsTableView: NSTableView

    @MagicViewLoading
    @IBOutlet private var uploadSongsScrollView: NSScrollView

    private typealias DataSource = NSTableViewDiffableDataSource<TableViewSection, SongFile>

    private typealias Snapshot = NSDiffableDataSourceSnapshot<TableViewSection, SongFile>

    private lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: uploadSongsTableView) { [weak self] tableView, tableColumn, row, songFile in
            guard let self else { return NSView() }
            let cellView = tableView.box.makeView(ofClass: SongFileCellView.self, owner: nil)
            cellView.configure(for: songFile)
            return cellView
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadSongsScrollView.do {
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 10
        }

        uploadSongsTableView.do {
            $0.wantsLayer = true
            $0.rowHeight = 60
            $0.layer?.cornerRadius = 10
        }

        dropSongsView.dropDelegate = viewModel
    }

    override func setupBindings(for viewModel: CloudSongsUploadViewModel) {
        super.setupBindings(for: viewModel)

        viewModel.$songFiles
            .asDriver()
            .driveOnNext { [weak self] songFiles in
                guard let self else { return }
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(songFiles, toSection: .main)
                dataSource.apply(snapshot, animatingDifferences: false)
            }
            .disposed(by: rx.disposeBag)

        viewModel.$isUploading
            .asDriver()
            .skip(1)
            .driveOnNext { [weak self] isUploading in
                guard let self else { return }
                if isUploading {
                    uploadProgressIndicator.startAnimation(nil)
                } else {
                    uploadProgressIndicator.stopAnimation(nil)
                    delegate?.uploadViewControllerSongFilesDidUpload(self)
                }
            }
            .disposed(by: rx.disposeBag)

        viewModel.$comlpetionSongFiles
            .asDriver()
            .driveOnNext { [weak self, weak viewModel] songFiles in
                guard let self, let viewModel else { return }
                if songFiles.isEmpty, viewModel.songFiles.isEmpty {
                    uploadProgressIndicator.doubleValue = 0.0
                } else {
                    uploadProgressIndicator.doubleValue = Double(songFiles.count) / Double(viewModel.songFiles.count)
                }
            }
            .disposed(by: rx.disposeBag)

        Driver.combineLatest(viewModel.$songFiles.asDriver(), viewModel.$isUploading.asDriver(), viewModel.$comlpetionSongFiles.asDriver())
            .driveOnNext { [weak self] songFiles, isUploading, completionSongFiles in
                guard let self else { return }
                dropSongsView.isHidden = !songFiles.isEmpty
                uploadSongsScrollView.isHidden = songFiles.isEmpty
                let hasNeedsUploadSongFiles = !songFiles.isEmpty && songFiles.contains { $0.uploadState == .ready || $0.uploadState == .failure }
                uploadSongsButton.isEnabled = hasNeedsUploadSongFiles && !isUploading
                clearSongsButton.isEnabled = !songFiles.isEmpty && !isUploading
            }
            .disposed(by: rx.disposeBag)
    }

    @IBAction func uploadSongsButtonAction(_ sender: NSButton) {
        viewModel?.uploadSongFiles()
    }

    @IBAction func clearSongsButtonAction(_ sender: NSButton) {
        viewModel?.clearSongFiles()
    }
}
