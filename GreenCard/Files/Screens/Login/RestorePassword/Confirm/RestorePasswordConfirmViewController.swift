//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture

class RestorePasswordConfirmViewController: UIViewController, DisposeBagProvider {

    fileprivate var restorePasswordConfirmView: RestorePasswordConfirmView {
        return view as? RestorePasswordConfirmView ?? RestorePasswordConfirmView()
    }

    fileprivate var viewModel: RestorePasswordConfirmViewModel!

    fileprivate weak var activeField: UITextField? = nil
    var lastKeyboardHeight: CGFloat = 0

    var phoneNumber: String = ""
    var smsCode: String = ""

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RestorePasswordConfirmView()
        viewModel = RestorePasswordConfirmViewModel()
        type = .restorePasswordConfirm

        // -- Navigation

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Buttons

        restorePasswordConfirmView
                .actionButton
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onActionButtonTap() })
                .disposed(by: disposeBag)

        restorePasswordConfirmView
                .backButton
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.dismiss(animated: true) })
                .do(onNext: { [unowned self] _ in self.endEditing() })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        restorePasswordConfirmView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.endEditing() })
                .disposed(by: disposeBag)

        // -- Fields

        restorePasswordConfirmView.passwordWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onPasswordTap() })
                .disposed(by: disposeBag)

        restorePasswordConfirmView.confirmWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onConfirmTap() })
                .disposed(by: disposeBag)

        // -- Keyboard

        RxKeyboard.keyboardHeight()
                .subscribe(onNext: { [weak self] input in self?.onKeyboard(input: input) })
                .disposed(by: disposeBag)

        // -- Delegates

        restorePasswordConfirmView.passwordField.delegate = self
        restorePasswordConfirmView.confirmField.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

    func configure(phone: String, sms: String) -> Self {
        self.phoneNumber = phone
        self.smsCode = sms
        return self
    }

}

extension RestorePasswordConfirmViewController {

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            restorePasswordConfirmView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            restorePasswordConfirmView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func activateField(textField: UITextField) {
        self.activeField = textField
        activeField?.becomeFirstResponder()
    }

    func onPasswordTap() {
        activateField(textField: restorePasswordConfirmView.passwordField)
        restorePasswordConfirmView.switchToPasswordInput()
    }

    func onConfirmTap() {
        activateField(textField: restorePasswordConfirmView.confirmField)
        restorePasswordConfirmView.switchToConfirmInput()
    }

    func onActionButtonTap() {
        guard let password = restorePasswordConfirmView.passwordField.text, password.isEmpty == false else {
            activateField(textField: restorePasswordConfirmView.passwordField)
            restorePasswordConfirmView.switchToPasswordWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard password.count >= 6 else {
            activateField(textField: restorePasswordConfirmView.passwordField)
            restorePasswordConfirmView.switchToPasswordWarn(text: "Минимум шесть символов")
            return
        }

        guard let passwordRepeat = restorePasswordConfirmView.confirmField.text, passwordRepeat == password else {
            activateField(textField: restorePasswordConfirmView.confirmField)
            restorePasswordConfirmView.switchToConfirmWarn(text: "Пароли не совпадают")
            return
        }

        endEditing()
        viewModel.sendTrigger.onNext((phoneNumber: phoneNumber, smsCode: smsCode, password: password))
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        restorePasswordConfirmView.resetFieldsState()
    }

}

extension RestorePasswordConfirmViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case restorePasswordConfirmView.passwordField:
            onConfirmTap()
        case restorePasswordConfirmView.confirmField:
            onActionButtonTap()
        case _:
            log("missing case")
        }
        return false
    }

}
