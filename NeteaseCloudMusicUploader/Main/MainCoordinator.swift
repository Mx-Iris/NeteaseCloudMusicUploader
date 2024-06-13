//
//  MainCoordinator.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/30.
//

import AppKit
import CocoaCoordinator

enum MainRoute: Routable {
    case root
    case logout
    case personal
    case dismiss
}

typealias MainTransition = SceneTransition<MainWindowController, MainSplitViewController>

extension MainCoordinator {
    protocol Delegate: AnyObject {
        func mainCoordinator(_ coordinator: MainCoordinator, didCompleteTransition route: MainRoute)
    }
}

@MainActor
class MainCoordinator: SceneCoordinator<MainRoute, MainTransition> {
    let appServices: AppServices

    weak var delegate: Delegate?

    init(appServices: AppServices) {
        self.appServices = appServices
        super.init(windowController: .create(), initialRoute: .root)
    }

    override func prepareTransition(for route: MainRoute) -> MainTransition {
        switch route {
        case .root:
            let mainViewController = MainSplitViewController()
            let mainViewModel = MainViewModel(appServices: appServices, router: unownedRouter)
            mainViewController.setupBindings(for: mainViewModel)
            windowController.setupBindings(for: mainViewModel)
            let tableViewController = CloudSongsTableViewController.create()
            tableViewController.setupBindings(for: mainViewModel.tableViewModel)
            let uploadViewController = CloudSongsUploadViewController.create()
            uploadViewController.setupBindings(for: mainViewModel.uploadViewModel)
            uploadViewController.delegate = tableViewController
            return .multiple(.show(mainViewController), .set([tableViewController, uploadViewController]))
        case .logout:
            return .close()
        case .personal:
            let viewController = PersonalViewController.create()
            let viewModel = PersonalViewModel(appServices: appServices, router: unownedRouter)
            viewController.setupBindings(for: viewModel)
            viewController.preferredContentSize = .init(width: 700, height: 250)
            return .presentOnRoot(viewController, mode: .asSheet)
        case .dismiss:
            return .dismiss()
        }
    }

    override func completeTransition(for route: MainRoute) {
        delegate?.mainCoordinator(self, didCompleteTransition: route)
        if route == .logout {
            removeFromParent()
        }
    }
}
