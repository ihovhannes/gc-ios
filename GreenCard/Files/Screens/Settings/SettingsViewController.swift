//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

class SettingsViewController: UIViewController, DisposeBagProvider {

    fileprivate var settingsView: SettingsView {
        return view as? SettingsView ?? SettingsView()
    }

    fileprivate var viewModel: SettingsViewModel!

    fileprivate var activeField: UITextField?
    fileprivate var missEndEditing = false

    init() {
        super.init(nibName: nil, bundle: nil)

        view = SettingsView();
        type = .settings
        settingsView.newPassword.delegate = self
        settingsView.newPasswordRepeat.delegate = self

        viewModel = SettingsViewModel(bindingsFactory: getBindingsFactory())

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.routingObservable
                .bind(to: rx_observerRouting)
                .disposed(by: disposeBag)

        viewModel.accountObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .map({ $0! })
                .bind(to: rx_accountObserver)
                .disposed(by: disposeBag)

        viewModel.accountObservable
                .map({event in event.error})
                .filter({$0 != nil})
                .map({ $0!})
                .map(errorToRouting(error:))
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.accountObservable
                .map({_ in ()})
                .bind(to: rx_startAnimateObserver)
                .disposed(by: disposeBag)

        // -- Checkers

        settingsView.pushChecker
                .subscribeOnTap(callback: onCheckerTap)

        settingsView.emailChecker
                .subscribeOnTap(callback: onCheckerTap)

        settingsView.smsChecker
                .subscribeOnTap(callback: onCheckerTap)

        // -- Interactions TextFields

        settingsView.newPassword
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onNewPasswordTap)
                .disposed(by: disposeBag)

        settingsView.newPasswordRepeat
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onNewPasswordRepeatTap)
                .disposed(by: disposeBag)

        settingsView.newPassword
                .rx
                .controlEvent(.editingDidEndOnExit)
                .subscribe(onNext: onNewPasswordReturn)
                .disposed(by: disposeBag)

        settingsView.newPasswordRepeat
                .rx
                .controlEvent(.editingDidEndOnExit)
                .subscribe(onNext: onNewPasswordRepeatReturn)
                .disposed(by: disposeBag)

        settingsView.newPassword
                .rx
                .controlEvent(.editingDidEnd)
                .subscribe(onNext: endEditing)
                .disposed(by: disposeBag)

        settingsView.newPasswordRepeat
                .rx
                .controlEvent(.editingDidEnd)
                .subscribe(onNext: endEditing)
                .disposed(by: disposeBag)

        // -- Buttons

        settingsView.saveButton
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onSaveTap)
                .disposed(by: disposeBag)

        settingsView.cancelButton
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onCancelTap)
                .disposed(by: disposeBag)

        // -- Error
        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("Error: \(error)")
                })
                .disposed(by: disposeBag)

        // -- Network

        viewModel.changePasswordObservable
                .bind(to: rx_changePasswordObserver)
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SettingsViewController: RoutingError {

}

extension SettingsViewController {

    func onCheckerTap(isOn: Bool) -> Void {
        viewModel.toggleChecker.onNext((
                push: settingsView.pushChecker.isOn(),
                sms: settingsView.smsChecker.isOn(),
                email: settingsView.emailChecker.isOn()
        ))
    }
}

extension SettingsViewController {

    fileprivate func activateField(field: UITextField) {
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = settingsView.getKeyboardOffset(field: field)
        activeField = field
        field.becomeFirstResponder()
    }

    fileprivate func onNewPasswordTap(args: Any) {
        missEndEditing = false
        activateField(field: settingsView.newPassword)
        settingsView.switchToNewPasswordInput()
    }

    fileprivate func onNewPasswordRepeatTap(args: Any) {
        missEndEditing = false
        activateField(field: settingsView.newPasswordRepeat)
        settingsView.switchToNewPasswordRepeatInput()
    }

    fileprivate func onSaveTap(args: Any) {
        missEndEditing = false
        if settingsView.newPassword.text.isEmpty() {
            activateField(field: settingsView.newPassword)
            settingsView.switchToNewPasswordWarn(text: "Это поле не должно быть пустым")
        } else if settingsView.newPassword.text!.count < 6 {
            activateField(field: settingsView.newPassword)
            settingsView.switchToNewPasswordWarn(text: "Минимум шесть символов")
        } else if settingsView.newPassword.text != settingsView.newPasswordRepeat.text {
            missEndEditing = true
            activateField(field: self.settingsView.newPasswordRepeat)
            settingsView.switchToNewPasswordRepeatWarn()
        } else {
            activeField = nil
            settingsView.endEditing(true)
            viewModel.changePassword.onNext(settingsView.newPassword.text!)
        }
    }

    fileprivate func onCancelTap(args: Any) {
        activeField = nil
        missEndEditing = false
        settingsView.endEditing(true)
        settingsView.resetState()
    }

    fileprivate func onNewPasswordReturn(args: Any) {
        if settingsView.newPassword.text.isEmpty() {
            missEndEditing = true
            activateField(field: self.settingsView.newPassword)
            settingsView.switchToNewPasswordWarn(text: "Это поле не должно быть пустым")
        } else if settingsView.newPassword.text!.count < 6 {
            missEndEditing = true
            activateField(field: self.settingsView.newPassword)
            settingsView.switchToNewPasswordWarn(text: "Минимум шесть символов")
        } else {
            missEndEditing = false
            onNewPasswordRepeatTap(args: args)
        }
    }

    fileprivate func onNewPasswordRepeatReturn(args: Any) {
        missEndEditing = false
        onSaveTap(args: args)
    }

    fileprivate func endEditing(args: Any) {
        missEndEditing = false
        settingsView.switchToWaitingMode()
    }

}

extension SettingsViewController: UITextFieldDelegate {

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if missEndEditing {
            missEndEditing = false
            return false
        }
        return true
    }
}


fileprivate extension SettingsViewController {

    var rx_observerRouting: AnyObserver<Routing> {
        return Binder(self, binding: { (controller: SettingsViewController, routing: Routing) in
            controller.activeField?.resignFirstResponder()
            controller.endEditing(args: true)
        }).asObserver()
    }

    var rx_accountObserver: AnyObserver<Account> {
        return Binder(self, binding: { (controller: SettingsViewController, account: Account) in
            controller.settingsView.initCheckers(push: account.push, sms: account.sms, email: account.email)
        }).asObserver()
    }

    var rx_startAnimateObserver: AnyObserver<()> {
        return Binder(self, binding: { (controller: SettingsViewController, input: ()) in
            controller.settingsView.animateOnInit()
        }).asObserver()
    }

    var rx_changePasswordObserver: AnyObserver<ChangePasswordResponse> {
        return Binder(self, binding: { (controller: SettingsViewController, response: ChangePasswordResponse) in
            controller.onCancelTap(args: "")

            let alertView = UIAlertController(title: nil, message: "Пароль успешно изменен", preferredStyle: UIKit.UIAlertControllerStyle.alert);
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
            controller.present(alertView, animated: true, completion: nil);

        }).asObserver()
    }

    func getBindingsFactory() -> SettingsViewControllerBindingsFactory {
        return { [unowned self] () -> SettingsViewControllerBindings in
            return SettingsViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
