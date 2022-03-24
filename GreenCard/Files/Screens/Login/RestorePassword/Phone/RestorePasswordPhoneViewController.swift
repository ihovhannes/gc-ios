//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture
import InputMask

class RestorePasswordPhoneViewController: UIViewController, DisposeBagProvider {

    fileprivate var restorePasswordPhoneView: RestorePasswordPhoneView {
        return view as? RestorePasswordPhoneView ?? RestorePasswordPhoneView()
    }

    fileprivate var viewModel: RestorePasswordPhoneViewModel!

    fileprivate weak var activeField: UITextField? = nil
    var lastKeyboardHeight: CGFloat = 0

    lazy var maskedDelegate = PolyMaskTextFieldDelegate()
    var phoneNumber: String? = nil

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RestorePasswordPhoneView()
        viewModel = RestorePasswordPhoneViewModel()
        type = .restorePasswordPhone

        // -- Navigation

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Buttons

        restorePasswordPhoneView
                .actionButton
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[unowned self] _ in self.onActionButtonTap()})
                .disposed(by: disposeBag)

        restorePasswordPhoneView
                .backButton
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.dismiss(animated: true)})
                .do(onNext: {[unowned self] _ in self.endEditing()})
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        restorePasswordPhoneView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[unowned self] _ in self.endEditing()})
                .disposed(by: disposeBag )

        // -- Fields
        
        restorePasswordPhoneView.phoneWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: {[unowned self] _ in self.onPhoneTap()})
                .disposed(by: disposeBag)

        // -- Delegates

        restorePasswordPhoneView.phoneField.delegate = maskedDelegate
        maskedDelegate.listener = self

        maskedDelegate.affineFormats = ["+{7} ([000]) [000]-[00]-[00]"]

        // -- Keyboard

        RxKeyboard.keyboardHeight()
                .subscribe(onNext: {[weak self] input in self?.onKeyboard(input: input)})
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension RestorePasswordPhoneViewController {

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            restorePasswordPhoneView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            restorePasswordPhoneView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func activateField(textField: UITextField) {
        self.activeField = textField
        activeField?.becomeFirstResponder()
    }

    func onPhoneTap() {
        if activeField != restorePasswordPhoneView.phoneField, restorePasswordPhoneView.phoneField.text.isEmpty() {
            maskedDelegate.put(text: "+7 (", into: restorePasswordPhoneView.phoneField)
        }
        activateField(textField: restorePasswordPhoneView.phoneField)
        restorePasswordPhoneView.switchToPhoneInput()
    }

    func onActionButtonTap() {
        guard let phone = phoneNumber, phone.isEmpty == false else {
            activateField(textField: restorePasswordPhoneView.phoneField)
            maskedDelegate.put(text: "+7 (", into: restorePasswordPhoneView.phoneField)
            restorePasswordPhoneView.switchToPhoneWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard phone.count == 11 else {
            activateField(textField: restorePasswordPhoneView.phoneField)
            restorePasswordPhoneView.switchToPhoneWarn(text: "Неверный номер телефона")
            return
        }

        endEditing()
        viewModel.sendTrigger.onNext(phone)
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        restorePasswordPhoneView.switchToRelax()
    }

}

extension RestorePasswordPhoneViewController: MaskedTextFieldDelegateListener {

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        phoneNumber = value
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onActionButtonTap()
        return false
    }

}
