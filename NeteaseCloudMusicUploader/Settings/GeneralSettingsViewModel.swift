//
//  GeneralSettingsViewModel.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/6/1.
//

import AppKit
import RxSwift
import RxCocoa
import RxAppKit
import RxSwiftPlus

class GeneralSettingsViewModel: ViewModel<SettingsRoute> {
    struct Input {
        let baseURLChanged: Observable<String>
    }

    struct Output {
        let baseURL: Driver<String>
    }

    func transform(_ input: Input) -> Output {
        
        input.baseURLChanged.bind(on: appServices.settingsService, to: \.baseURL).disposed(by: rx.disposeBag)
        return .init(baseURL: appServices.settingsService.$baseURL.asDriverOnErrorJustComplete())
    }
}
