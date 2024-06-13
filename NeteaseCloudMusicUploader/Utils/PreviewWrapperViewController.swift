//
//  PreviewWrapperViewController.swift
//  CodeOrganizer
//
//  Created by JH on 2023/12/2.
//

import AppKit

@MainActor
class PreviewWrapperViewController<WrappedViewController: NSViewController>: NSViewController {
    let wrapperViewController: WrappedViewController

    convenience init(_ builder: () -> WrappedViewController) {
        self.init(wrapperViewController: builder())
    }
    
    init(wrapperViewController: WrappedViewController) {
        self.wrapperViewController = wrapperViewController
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        view = wrapperViewController.view
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.styleMask.remove(.titled)
    }
}
