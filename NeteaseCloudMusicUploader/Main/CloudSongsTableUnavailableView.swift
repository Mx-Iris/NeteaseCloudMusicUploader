//
//  CloudSongsTableUnavailableView.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/28.
//

import AppKit
import UIFoundation

@MainActor
class CloudSongsTableUnavailableView: XiblessView {
    enum UnavailableType {
        case none
        case isEmpty
        case loading
    }

    var type: UnavailableType = .isEmpty {
        didSet {
            changeHiddenState()
        }
    }

    let titleLabel = Label("暂无云盘歌曲")

    let loadingIndicator: MaterialLoadingIndicator = .init(radius: 30, color: .controlAccentColor)

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        super.updateLayer()

        layer?.backgroundColor = NSColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1).cgColor
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(titleLabel)
        addSubview(loadingIndicator)
        wantsLayer = true

        titleLabel.do {
            $0.font = .systemFont(ofSize: 25)
            $0.textColor = .secondaryLabelColor
        }

        loadingIndicator.do {
            $0.lineWidth = 5
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(60)
        }

        changeHiddenState()
    }

    func changeHiddenState() {
        switch type {
        case .none:
            isHidden = true
        case .isEmpty:
            isHidden = false
            titleLabel.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        case .loading:
            isHidden = false
            titleLabel.isHidden = true
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        }
    }
}

// @available(macOS 14.0, *)
// #Preview {
//    CloudSongsTableUnavailableView().then {
//        $0.type = .isEmpty
//    }
// }
