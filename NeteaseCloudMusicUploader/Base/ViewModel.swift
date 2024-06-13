//
//  Controller.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/27.
//

import AppKit
import RxSwift
import RxCocoa
import CocoaCoordinator

@MainActor
class ViewModel<Route: Routable>: NSObject {
    var appServices: AppServices

    let router: UnownedRouter<Route>

    let serviceError: PublishRelay<Error> = .init()

    init(appServices: AppServices, router: UnownedRouter<Route>) {
        self.appServices = appServices
        self.router = router
    }
}
