//
//  SettingsCoordinator.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/6/1.
//

import AppKit
import Settings
import CocoaCoordinator

enum SettingsRoute: Routable {
    case root
}

typealias SettingsTransition = SceneTransition<SettingsWindowController, NSViewController>

class SettingsCoordinator: SceneCoordinator<SettingsRoute, SettingsTransition> {
    let appServices: AppServices

    init(appServices: AppServices) {
        self.appServices = appServices
        let generalSettingsViewController = GeneralSettingsViewController()
        let windowController = SettingsWindowController(panes: [generalSettingsViewController], style: .toolbarItems, animated: true, hidesToolbarForSingleItem: true)
        super.init(windowController: windowController, initialRoute: .root)
        let generalSettingsViewModel = GeneralSettingsViewModel(appServices: appServices, router: unownedRouter)
        generalSettingsViewController.setupBindings(for: generalSettingsViewModel)
    }

    override func prepareTransition(for route: SettingsRoute) -> SettingsTransition {
        switch route {
        case .root:
            return .show(pane: .general)
        }
    }
}

extension SettingsTransition {
    static func show(pane: Settings.PaneIdentifier? = nil) -> Self {
        Self(presentables: []) { windowController, viewController, options, completion in
            windowController?.show(pane: pane)
            completion?()
        }
    }
}

extension Settings.PaneIdentifier {
    static let general = Self("general")
}
