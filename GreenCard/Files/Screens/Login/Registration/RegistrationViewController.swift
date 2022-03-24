//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture
import InputMask

class RegistrationViewController: UIViewController, DisposeBagProvider {

    fileprivate var registrationView: RegistrationView {
        return view as? RegistrationView ?? RegistrationView()
    }

    fileprivate var viewModel: RegistrationViewModel!

    fileprivate weak var activeField: UITextField? = nil

    var lastKeyboardHeight: CGFloat = 0

    // -- Delegates

    lazy var maskedCardNumber = PolyMaskTextFieldDelegate()
    lazy var maskedCardCode = PolyMaskTextFieldDelegate()

    // -- Card's data

    lazy var cardNumberValue: String = ""
    lazy var cardCodeValue: String = ""

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RegistrationView()

        viewModel = RegistrationViewModel()
        type = .registration

        // -- Text Fields

        registrationView.numberWrapper
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onNumberTap)
                .disposed(by: disposeBag)

        registrationView.codeWrapper
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onCodeTap)
                .disposed(by: disposeBag)

        // -- Buttons

        registrationView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onTapBackground)
                .disposed(by: disposeBag)

        registrationView
                .actionButton
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onActionButtonTap)
                .disposed(by: disposeBag)

        registrationView
                .backButton
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.dismiss(animated: true)})
                .do(onNext: {[unowned self] _ in self.endEditing()})
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Delegates

        maskedCardNumber.affineFormats = ["[0000] [0000] [0000] [0000]"]
        maskedCardCode.affineFormats = ["[0000]"]

        maskedCardNumber.listener = self
        maskedCardCode.listener = self

        registrationView.numberField.delegate = maskedCardNumber
        registrationView.codeField.delegate = maskedCardCode

        // -- Routings

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // --
        RxKeyboard.keyboardHeight()
                .subscribe(onNext: onKeyboard)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension RegistrationViewController {

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            registrationView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            registrationView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func activateField(textField: UITextField) {
        self.activeField = textField
        activeField?.becomeFirstResponder()
    }

    func onNumberTap(any: Any) {
        activateField(textField: registrationView.numberField)
        registrationView.switchToNumberInput()
    }

    func onCodeTap(any: Any) {
        activateField(textField: registrationView.codeField)
        registrationView.switchToCodeInput()
    }

    func onActionButtonTap(any: Any) {
        guard cardNumberValue.isEmpty == false else {
            activateField(textField: registrationView.numberField)
            registrationView.switchToNumberWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard cardNumberValue.count >= 16 else {
            activateField(textField: registrationView.numberField)
            registrationView.switchToNumberWarn(text: "Минимум 16 символов")
            return
        }

        guard cardCodeValue.isEmpty == false else {
            activateField(textField: registrationView.codeField)
            registrationView.switchToCodeWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard cardCodeValue.count >= 4 else {
            activateField(textField: registrationView.codeField)
            registrationView.switchToCodeWarn(text: "Минимум 4 символа")
            return
        }

        endEditing()
        viewModel.checkCard.onNext((number: cardNumberValue, code: cardCodeValue))
    }

    func onTapBackground(any: Any) {
        endEditing()
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        registrationView.resetNumberCodeState()
    }

}

extension RegistrationViewController: MaskedTextFieldDelegateListener {

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        switch textField {
        case registrationView.numberField:
            cardNumberValue = value
        case registrationView.codeField:
            cardCodeValue = value
        case _:
            break
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        log("textFieldDidEndEditing")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case registrationView.numberField:
            onCodeTap(any: ())
        case registrationView.codeField:
            onActionButtonTap(any: ())
        case _:
            log("missing case")
        }
        return false
    }

}
