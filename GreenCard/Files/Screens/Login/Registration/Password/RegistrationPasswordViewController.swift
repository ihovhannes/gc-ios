//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift

class RegistrationPasswordViewController: UIViewController, DisposeBagProvider {

    fileprivate var registrationPasswordView: RegistrationPasswordView {
        return view as? RegistrationPasswordView ?? RegistrationPasswordView()
    }

    fileprivate var viewModel: RegistrationPasswordViewModel!

    fileprivate weak var activeField: UITextField? = nil

    var lastKeyboardHeight: CGFloat = 0

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RegistrationPasswordView.init()

        viewModel = RegistrationPasswordViewModel()
        type = .registrationChangPassword

        // -- Navigation

        viewModel
                .routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Text Fields

        registrationPasswordView.passwordWrapper
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[weak self] _ in self?.onPasswordTap()} )
                .disposed(by: disposeBag)

        registrationPasswordView.confirmWrapper
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[weak self] _ in self?.onPasswordRepeatTap()} )
                .disposed(by: disposeBag)

        // -- Buttons

        registrationPasswordView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[weak self] _ in self?.onTapBackground()} )
                .disposed(by: disposeBag)

        registrationPasswordView
                .actionButton
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[weak self] _ in self?.onActionButtonTap()} )
                .disposed(by: disposeBag)

        registrationPasswordView
                .backButton
                .rx
                .tapGesture()
                .when(.recognized)
                .do(onNext: {[weak self] _ in self?.onBackButtonTap()} )
                .map({ _ in Routing.logout})
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Delegates

        registrationPasswordView.passwordField.delegate = self
        registrationPasswordView.confirmField.delegate = self

        // --
        RxKeyboard.keyboardHeight()
                .subscribe(onNext: {[weak self] arg in self?.onKeyboard(input: arg) } )
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension RegistrationPasswordViewController {

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            registrationPasswordView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            registrationPasswordView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func activateField(textField: UITextField) {
        self.activeField = textField
        activeField?.becomeFirstResponder()
    }

    func onPasswordTap() {
        activateField(textField: registrationPasswordView.passwordField)
        registrationPasswordView.switchToPasswordInput()
    }

    func onPasswordRepeatTap() {
        activateField(textField: registrationPasswordView.confirmField)
        registrationPasswordView.switchToConfirmInput()
    }

    func onActionButtonTap() {
        guard let password = registrationPasswordView.passwordField.text, password.isEmpty == false else {
            activateField(textField: registrationPasswordView.passwordField)
            registrationPasswordView.switchToPasswordWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard password.count >= 6 else {
            activateField(textField: registrationPasswordView.passwordField)
            registrationPasswordView.switchToPasswordWarn(text: "Минимум шесть символов")
            return
        }

        guard let passwordRepeat = registrationPasswordView.confirmField.text, passwordRepeat == password else {
            activateField(textField: registrationPasswordView.confirmField)
            registrationPasswordView.switchToConfirmWarn(text: "Пароли не совпадают")
            return
        }

        endEditing()
        viewModel.acceptTrigger.onNext(password)
    }

    func onBackButtonTap() {
        endEditing()
        dismiss(animated: true)
    }

    func onTapBackground() {
        endEditing()
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        registrationPasswordView.resetFieldsState()
    }

}

extension RegistrationPasswordViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        log("textFieldDidEndEditing")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case registrationPasswordView.passwordField:
            onPasswordRepeatTap()
        case registrationPasswordView.confirmField:
            onActionButtonTap()
        case _:
            log("missing case")
        }
        return false
    }

}
