//
//  PreviewWrapperView.swift
//  CodeOrganizer
//
//  Created by JH on 2024/2/11.
//

import AppKit

open class PreviewWrapperView<View: NSView>: NSView {
    public private(set) var wrappedView: View

    public convenience init(_ builder: () -> View) {
        self.init(wrappedView: builder())
    }
    
    public init(wrappedView: View) {
        self.wrappedView = wrappedView
        super.init(frame: wrappedView.bounds)
        addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrappedView.topAnchor.constraint(equalTo: topAnchor),
            wrappedView.leftAnchor.constraint(equalTo: leftAnchor),
            wrappedView.rightAnchor.constraint(equalTo: rightAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _intrinsicContentSize: NSSize?

    public func setIntrinsicContentSize(_ intrinsicContentSize: NSSize) {
        _intrinsicContentSize = intrinsicContentSize
    }

    open override var intrinsicContentSize: NSSize {
        return _intrinsicContentSize ?? wrappedView.intrinsicContentSize
    }
    
    open override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        
        if let newWindow {
            newWindow.styleMask.remove(.titled)
        }
    }
}
