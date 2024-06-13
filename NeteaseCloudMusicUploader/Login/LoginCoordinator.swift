//
//  LoginCoordinator.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/30.
//

import AppKit
import RxSwift
import RxCocoa
import RxSwiftPlus
import UIFoundation
import CocoaCoordinator

enum LoginRoute: Routable {
    case root
    case login
}

extension LoginCoordinator {
    protocol Delegate: AnyObject {
        func loginCoordinator(_ loginCoordinator: LoginCoordinator, didCompleteTransition route: LoginRoute)
    }
}

@MainActor
class LoginCoordinator: SceneCoordinator<LoginRoute, SceneTransition<LoginWindowController, LoginViewController>> {
    let appServices: AppServices

    weak var delegate: Delegate?

    init(appServices: AppServices) {
        self.appServices = appServices
        super.init(windowController: .create(), initialRoute: .root)
        observeLoginOperating()
    }

    func observeLoginOperating() {
        appServices.neteaseService.$isLoginOperating.asDriver()
            .driveOnNext { [weak self] isLoginOperating in
                guard let self else { return }
                guard let window = windowController.window else { return }
                if isLoginOperating {
                    LoadingIndicator.shared.show(in: window)
                } else {
                    LoadingIndicator.shared.hide(in: window)
                }
            }
            .disposed(by: rx.disposeBag)
    }

    override func prepareTransition(for route: LoginRoute) -> SceneTransition<LoginWindowController, LoginViewController> {
        switch route {
        case .root:
            let loginViewController = LoginViewController.create()
            let loginViewModel = LoginViewModel(appServices: appServices, router: unownedRouter)
            loginViewController.setupBindings(for: loginViewModel)
            return .show(loginViewController)
        case .login:
            return .close()
        }
    }

    override func completeTransition(for route: LoginRoute) {
        delegate?.loginCoordinator(self, didCompleteTransition: route)
        if route == .login {
            removeFromParent()
        }
    }
}
