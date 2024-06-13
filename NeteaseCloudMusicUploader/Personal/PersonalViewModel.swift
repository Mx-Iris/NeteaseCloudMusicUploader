//
//  PersonalViewModel.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/6/1.
//

import AppKit
import NeteaseCloudMusicModel
import NeteaseCloudMusicService
import RxSwift
import RxCocoa
import RxSwiftPlus
import RxCocoaCoordinator
import RxConcurrency

@MainActor
class PersonalViewModel: ViewModel<MainRoute> {
    struct Input {
        let clickDismiss: Observable<Void>
        let clickLogout: Observable<Void>
    }

    struct Output {
        let avatarURL: Driver<URL?>
        let nickname: Driver<String?>
    }

    func transform(_ input: Input) -> Output {
        input.clickDismiss.bind(to: router.rx.trigger(.dismiss)).disposed(by: rx.disposeBag)
        let logoutRequest = input.clickLogout.flatMapLatest { [unowned self] in try await appServices.neteaseService.logout() }.share().materialize()
        logoutRequest.elements().bind(to: router.rx.trigger(.logout)).disposed(by: rx.disposeBag)
        return Output(avatarURL: .just(appServices.neteaseService.personalInfo?.avatarURL), nickname: .just(appServices.neteaseService.personalInfo?.nickname))
    }
}
