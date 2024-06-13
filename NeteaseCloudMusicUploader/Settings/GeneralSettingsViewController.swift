#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import Settings
import SFSymbol
import UIFoundation
import RxSwift
import RxCocoa
import RxAppKit
import RxSwiftPlus

class GeneralSettingsViewController: XibViewController, SettingsPane {
    var paneIdentifier: Settings.PaneIdentifier = .general

    var paneTitle: String = "General"

    var toolbarItemIcon: NSImage = SFSymbol(systemName: .gearshape).nsImage

    var viewModel: GeneralSettingsViewModel?
    
    @IBOutlet var baseURLTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupBindings(for viewModel: GeneralSettingsViewModel) {
        self.viewModel = viewModel

        let input = GeneralSettingsViewModel.Input(baseURLChanged: baseURLTextField.rx.text.compactMap { $0 }.skip(1))

        let output = viewModel.transform(input)

        output.baseURL.drive(baseURLTextField.rx.stringValue).disposed(by: rx.disposeBag)
    }
}





#endif
