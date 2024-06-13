//
//  CloudSongsTableViewController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import UIFoundation
import NeteaseCloudMusicModel
import NeteaseCloudMusicService
import SnapKit
import RxSwift
import RxCocoa
import RxSwiftPlus

enum TableViewSection: CaseIterable, Hashable, Identifiable {
    case main
    var id: Self { self }
}

@MainActor
class CloudSongsTableViewController: ViewController<CloudSongsTableViewModel> {
    enum TableColumn: String, CaseIterable {
        case songName
        case artist
        case album
        case format
        case size
        case addTime
    }

    @MagicViewLoading
    @IBOutlet var tableView: NSTableView

    let unavailableView = CloudSongsTableUnavailableView()

    lazy var fileSizeFormatter = ByteCountFormatter().then {
        $0.allowedUnits = [.useGB, .useKB, .useMB]
        $0.includesUnit = true
        $0.includesCount = true
        $0.countStyle = .file
    }

    lazy var dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }

    typealias DataSource = NSTableViewDiffableDataSource<TableViewSection, CloudSong>

    typealias Snapshot = NSDiffableDataSourceSnapshot<TableViewSection, CloudSong>

    lazy var dataSource: DataSource = {
        let dataSource = DataSource(tableView: tableView) { [weak self] tableView, tableColumn, row, cloudSong in
            guard let self, let tableColumn = TableColumn(rawValue: tableColumn.identifier.rawValue) else { return NSView() }
            let cellView = tableView.box.makeView(ofClass: TextTableCellView.self, owner: nil)
            switch tableColumn {
            case .songName:
                cellView.textField?.stringValue = cloudSong.songName
            case .artist:
                cellView.textField?.stringValue = cloudSong.artist
            case .album:
                cellView.textField?.stringValue = cloudSong.album
            case .format:
                cellView.textField?.stringValue = cloudSong.fileName.box.pathExtension.uppercased()
            case .size:
                cellView.textField?.formatter = fileSizeFormatter
                cellView.textField?.integerValue = cloudSong.fileSize
            case .addTime:
                cellView.textField?.formatter = dateFormatter
                cellView.textField?.objectValue = cloudSong.addTime
            }
            return cellView
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(unavailableView)

        unavailableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func setupBindings(for viewModel: CloudSongsTableViewModel) {
        super.setupBindings(for: viewModel)

        viewModel.$unavailableType
            .asDriver()
            .driveOnNext { [weak self] unavailableType in
                guard let self else { return }
                unavailableView.type = unavailableType
            }
            .disposed(by: rx.disposeBag)

        viewModel.$cloudSongs
            .asDriver()
            .driveOnNext { [weak self] cloudSongs in
                guard let self else { return }
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems(cloudSongs, toSection: .main)
                dataSource.apply(snapshot, animatingDifferences: false)
            }
            .disposed(by: rx.disposeBag)

        viewModel.$errorMessage
            .asDriver()
            .driveOnNext { message in
                guard let message else { return }
                NSAlert().do {
                    $0.messageText = "提示"
                    $0.informativeText = message
                    $0.runModal()
                }
            }
            .disposed(by: rx.disposeBag)

        fetchCloudSongs()
    }

    func fetchCloudSongs() {
        viewModel?.fetchCloudSongs()
    }
}

extension CloudSongsTableViewController: CloudSongsUploadViewController.Delegate {
    func uploadViewControllerSongFilesDidUpload(_ controller: CloudSongsUploadViewController) {
        fetchCloudSongs()
    }
}



