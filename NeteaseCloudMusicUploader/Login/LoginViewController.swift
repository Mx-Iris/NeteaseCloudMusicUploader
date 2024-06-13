//
//  LoginViewController.swift
//  NeteaseCloudMusicUploader
//
//  Created by JH on 2024/5/25.
//

import AppKit
import UIFoundation
import RxSwift
import RxCocoa
import RxAppKit
import RxSwiftPlus
import RxSwiftExt

class LoginViewController: ViewController<LoginViewModel> {
    @MagicViewLoading
    @IBOutlet var segmentControl: NSSegmentedControl

    @MagicViewLoading
    @IBOutlet var tabView: NSTabView

    @MagicViewLoading
    @IBOutlet var mobileTabViewItem: LoginMobileTabViewItem

    @MagicViewLoading
    @IBOutlet var mailTabViewItem: LoginMailTabViewItem

    @MagicViewLoading
    @IBOutlet var qrcodeTabViewItem: LoginQRCodeTabViewItem

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupBindings(for viewModel: LoginViewModel) {
        super.setupBindings(for: viewModel)

        segmentControl.rx.selectedSegment.asControlEvent().compactMap { .init(rawValue: $0) }.bind(to: viewModel.$loginMode).disposed(by: rx.disposeBag)
        mobileTabViewItem.mobileView.mobileTextField.rx.text.compactMap { $0 }.bind(to: viewModel.mobileModeController.$mobile).disposed(by: rx.disposeBag)
        mobileTabViewItem.mobileView.authModeSwitch.rx.state.map { $0 == .on ? .captcha : .password }.bind(to: viewModel.mobileModeController.$authMode).disposed(by: rx.disposeBag)
        mobileTabViewItem.mobileView.fetchCaptchaButton.rx.click.subscribe(with: self, onNext: { $0.viewModel?.mobileModeController.sentCaptcha() }).disposed(by: rx.disposeBag)
        mobileTabViewItem.mobileView.passwordTextField.rx.text.compactMap { $0 }.bind(to: viewModel.mobileModeController.$password).disposed(by: rx.disposeBag)
        mobileTabViewItem.mobileView.captchaTextField.rx.text.compactMap { $0 }.bind(to: viewModel.mobileModeController.$captcha).disposed(by: rx.disposeBag)
        mobileTabViewItem.mobileView.loginButton.rx.click.subscribe(with: self, onNext: { $0.viewModel?.mobileModeController.login() }).disposed(by: rx.disposeBag)
        mailTabViewItem.mailView.mailTextField.rx.text.compactMap { $0 }.bind(to: viewModel.mailModeController.$mail).disposed(by: rx.disposeBag)
        mailTabViewItem.mailView.passwordTextField.rx.text.compactMap { $0 }.bind(to: viewModel.mailModeController.$password).disposed(by: rx.disposeBag)
        mailTabViewItem.mailView.loginButton.rx.click.subscribe(with: self, onNext: { $0.viewModel?.mailModeController.login() }).disposed(by: rx.disposeBag)
        viewModel.$loginMode.map(\.rawValue).bind(to: tabView.rx.selectedTabViewItemIndex).disposed(by: rx.disposeBag)
        viewModel.mobileModeController.$mobile.bind(to: mobileTabViewItem.mobileView.mobileTextField.rx.stringValue).disposed(by: rx.disposeBag)
        viewModel.mobileModeController.$authMode.map(\.rawValue).bind(to: mobileTabViewItem.mobileView.authTabView.rx.selectedTabViewItemIndex).disposed(by: rx.disposeBag)
        viewModel.qrcodeModeController.$qrcodeImage.asDriver().drive(qrcodeTabViewItem.qrcodeView.qrcodeImageView.rx.image).disposed(by: rx.disposeBag)
        Observable.of(viewModel.mobileModeController.$loginMessage, viewModel.mobileModeController.$sentCaptchaTips, viewModel.mailModeController.$loginMessage).merge().compactMap { $0 }.subscribeOnNext { message in
            NSAlert().do {
                $0.messageText = "提示"
                $0.informativeText = message
                $0.runModal()
            }
            
        }.disposed(by: rx.disposeBag)
    }
}

class LoginMobileTabViewItem: NSTabViewItem {
    @IBOutlet var mobileView: LoginMobileView!
}

class LoginMobileView: NSView {
    @IBOutlet var mobileTextField: NSTextField!
    @IBOutlet var passwordTextField: NSSecureTextField!
    @IBOutlet var loginButton: NSButton!
    @IBOutlet var authTabView: NSTabView!
    @IBOutlet var authModeSwitch: NSSwitch!
    @IBOutlet var captchaTextField: NSTextField!
    @IBOutlet var fetchCaptchaButton: NSButton!
}

class LoginMailTabViewItem: NSTabViewItem {
    @IBOutlet var mailView: LoginMailView!
}

class LoginMailView: NSView {
    @IBOutlet var mailTextField: NSTextField!
    @IBOutlet var passwordTextField: NSSecureTextField!
    @IBOutlet var loginButton: NSButton!
}

class LoginQRCodeTabViewItem: NSTabViewItem {
    @IBOutlet var qrcodeView: LoginQRCodeView!
}

class LoginQRCodeView: NSView {
    @IBOutlet var qrcodeImageView: NSImageView!
}

class PhoneNumberFormatter: NumberFormatter {}
