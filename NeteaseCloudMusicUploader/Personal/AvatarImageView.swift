//
//  AvatarImageView.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/6/1.
//

import AppKit

class AvatarImageView: NSImageView {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
    }

    open override var wantsUpdateLayer: Bool { true }

    open override func updateLayer() {
        super.updateLayer()

        layer?.cornerRadius = max(bounds.midX, bounds.midY)
    }
}
