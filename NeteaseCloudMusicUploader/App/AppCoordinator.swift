//
//  Navigator.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import Combine
import UIFoundation
import NeteaseCloudMusicService
import CocoaCoordinator

enum AppRoute: Routable {
    case login
    case main
    case settings
}

@MainActor
class AppCoordinator: Coordinator<AppRoute, AppTransition> {
    let appServices: AppServices

    private var isStarted: Bool = false
    
    init(appServices: AppServices) {
        self.appServices = appServices
        super.init(initialRoute: nil)
    }

    override func prepareTransition(for route: AppRoute) -> AppTransition {
        switch route {
        case .login:
            let loginCoordinator = LoginCoordinator(appServices: appServices)
            loginCoordinator.delegate = self
            addChild(loginCoordinator)
            return .none()
        case .main:
            let mainCoordinator = MainCoordinator(appServices: appServices)
            mainCoordinator.delegate = self
            addChild(mainCoordinator)
            return .none()
        case .settings:
            let settingsCoordinator = SettingsCoordinator(appServices: appServices)
            addChild(settingsCoordinator)
            return .none()
        }
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true
        trigger(appServices.neteaseService.isLogined ? .main : .login)
    }
}

extension AppCoordinator: MainCoordinator.Delegate {
    func mainCoordinator(_ coordinator: MainCoordinator, didCompleteTransition route: MainRoute) {
        switch route {
        case .logout:
            trigger(.login)
        default:
            break
        }
    }
}

extension AppCoordinator: LoginCoordinator.Delegate {
    func loginCoordinator(_ loginCoordinator: LoginCoordinator, didCompleteTransition route: LoginRoute) {
        switch route {
        case .login:
            trigger(.main)
        default:
            break
        }
    }
}
