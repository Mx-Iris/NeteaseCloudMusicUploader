//
//  LoginController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import RxSwiftPlus
import CocoaCoordinator
import NeteaseCloudMusicService

@MainActor
class LoginViewModel: ViewModel<LoginRoute> {
    enum LoginMode: Int, CaseIterable {
        case mobile
        case mail
        case qrcode
    }

    enum AuthMode: Int, CaseIterable {
        case password
        case captcha
    }

    @Observed
    var loginMode: LoginMode = .mobile

    lazy var mobileModeController = MobileModeViewModel(appServices: appServices, router: router)

    lazy var mailModeController = MailModeViewModel(appServices: appServices, router: router)

    lazy var qrcodeModeController = QRCodeModeViewModel(appServices: appServices, router: router)

    override init(appServices: AppServices, router: UnownedRouter<LoginRoute>) {
        super.init(appServices: appServices, router: router)
        $loginMode.subscribe(with: self, onNext: {
            if $1 == .qrcode {
                $0.qrcodeModeController.initValidation()
            }
        })
        .disposed(by: rx.disposeBag)
    }
    
    @MainActor
    class MobileModeViewModel: ViewModel<LoginRoute> {
        @Observed
        var authMode: AuthMode = .password

        @Observed
        var mobile: String = ""

        @Observed
        var password: String = ""

        @Observed
        var captcha: String = ""

        @Observed
        var sentCaptchaTips: String?

        @Observed
        var loginMessage: String?

        func sentCaptcha() {
            guard authMode == .captcha else {
                sentCaptchaTips = "未知错误"
                return
            }

            guard !mobile.isEmpty else {
                sentCaptchaTips = "手机号不能为空"
                return
            }

            Task {
                do {
                    try await appServices.neteaseService.sentCaptcha(mobile)
                    sentCaptchaTips = "发送成功"

                } catch {
                    sentCaptchaTips = error.localizedDescription
                }
            }
        }

        func login() {
            Task {
                do {
                    switch authMode {
                    case .password:
                        try await appServices.neteaseService.mobileLogin(mobile, password: password)
                    case .captcha:
                        try await appServices.neteaseService.mobileLogin(mobile, captcha: captcha)
                    }
                    router.trigger(.login)
                } catch {
                    loginMessage = error.localizedDescription
                }
            }
        }
    }

    @MainActor
    class MailModeViewModel: ViewModel<LoginRoute> {
        @Observed
        var mail: String = ""
        
        @Observed
        var password: String = ""
        
        @Observed
        var loginMessage: String?
        
        func login() {
            Task {
                do {
                    try await appServices.neteaseService.mailLogin(mail, password: password)
                    router.trigger(.login)
                } catch {
                    print(error)
                    loginMessage = error.localizedDescription
                }
            }
        }
    }

    @MainActor
    class QRCodeModeViewModel: ViewModel<LoginRoute> {
        @Observed
        var qrcodeImage: NSImage?
        
        private var currentLevel: Int = 0
        
        private var finalLevel: Int = 200
        
        private var timer: Timer?
        
        func initValidation() {
            timer?.invalidate()

            Task {
                do {
                    qrcodeImage = try await appServices.neteaseService.qrcodeLoginImage(for: .init(width: 800, height: 800))
                    startValidation()
                } catch {
                    print(error)
                }
            }
        }
        
        func startValidation() {
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await MainActor.run {
                        self.currentLevel += 1
                        if self.currentLevel > self.finalLevel {
                            self.stopValidation()
                        }
                        self.loopValidation()
                    }
                }
            }
        }

        func stopValidation() {
            timer?.invalidate()
            timer = nil
        }

        func loopValidation() {
            Task {
                do {
                    let state = try await appServices.neteaseService.qrcodeLoginCheck()
                    switch state {
                    case .success:
                        finishValidation()
                        break
                    case .fail:
                        break
                    case .expire:
                        initValidation()
                    case .waiting:
                        break
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        func finishValidation() {
            stopValidation()
            router.trigger(.login)
        }
    }
}
