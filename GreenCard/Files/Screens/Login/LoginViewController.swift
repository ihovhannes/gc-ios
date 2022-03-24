//
//  LoginViewController.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 28.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import InputMask

class LoginViewController: UIViewController, DisposeBagProvider {

    fileprivate var loginView: LoginView {
        return view as? LoginView ?? LoginView()
    }

    fileprivate var viewModel: LoginViewModel!
    fileprivate weak var activeField: UITextField? = nil

    lazy var maskedDelegate = PolyMaskTextFieldDelegate()
    var withAnimLogoAndTitle = true

    var lastKeyboardHeight: CGFloat = 0

    init() {
        super.init(nibName: nil, bundle: nil)

        view = LoginView()
        type = .login

        // -
        viewModel = LoginViewModel(bindingsFactory: getbindingsFactory())

        // -- Navigation
        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)


        // -- Text Fields

        loginView.phone1Wrapper
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onPhoneTap)
                .disposed(by: disposeBag)

        loginView.password1Wrapper
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onPasswordTap)
                .disposed(by: disposeBag)

        // -- Buttons

        loginView
                .login
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onLoginButtonTap)
                .disposed(by: disposeBag)

        loginView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onTapBackground)
                .disposed(by: disposeBag)

        loginView
                .forgotPassword
                .rx
                .tapGesture()
                .when(.recognized)
//                .map({ _ in Routing.toastView(msg: "В разработке") })
                .map({ _ in Routing.restorePasswordPhone})
                .do(onNext: { [unowned self] _ in self.endEditing() })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        loginView
                .registration
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.registration })
                .do(onNext: { [unowned self] _ in self.endEditing() })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)


        // -- Delegates

        loginView.password1Field.delegate = self
        maskedDelegate.listener = self
        loginView.phone1Field.delegate = maskedDelegate

        maskedDelegate.affineFormats = ["+{7} ([000]) [000]-[00]-[00]"]

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginView.setLogoAndTitle(withAnimLogoAndTitle)
    }

    func configure(animateLogoAndTitle: Bool) -> LoginViewController {
        self.withAnimLogoAndTitle = animateLogoAndTitle
        return self
    }
}

extension LoginViewController {

    func activateField(textField: UITextField) {
        self.activeField = textField
        activeField?.becomeFirstResponder()
    }

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            loginView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            loginView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func onPhoneTap(any: Any) {
        if activeField != loginView.phone1Field, loginView.phone1Field.text.isEmpty() {
            maskedDelegate.put(text: "+7 (", into: loginView.phone1Field)
        }
        activateField(textField: loginView.phone1Field)
        loginView.switchToPhoneInput()
    }

    func onPasswordTap(any: Any) {
        activateField(textField: loginView.password1Field)
        loginView.switchToPasswordInput()
    }

    func onLoginButtonTap(any: Any) {
        guard let phone = loginView.phoneText.value, phone.isEmpty == false else {
            activateField(textField: loginView.phone1Field)
            maskedDelegate.put(text: "+7 (", into: loginView.phone1Field)
            loginView.switchToPhoneWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard phone.count == 11 else {
            activateField(textField: loginView.phone1Field)
            loginView.switchToPhoneWarn(text: "Неверный номер телефона")
            return
        }

        guard let password = loginView.password1Field.text, password.isEmpty == false else {
            activateField(textField: loginView.password1Field)
            loginView.switchToPasswordWarn()
            return
        }

        endEditing()
        viewModel.doLogin.onNext((phone, password))
    }

    func onTapBackground(any: Any) {
        endEditing()
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        loginView.resetPhonePasswordState()
    }

}

extension LoginViewController: MaskedTextFieldDelegateListener {

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        loginView.phoneText.value = value
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        log("textFieldDidEndEditing")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case loginView.phone1Field:
            onPasswordTap(any: ())
        case loginView.password1Field:
            onLoginButtonTap(any: ())
        case _:
            log("missing case")
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == loginView.password1Field else {
            return true
        }

        let nsString: NSString? = textField.text as NSString?
        let updatedString = nsString?.replacingCharacters(in: range, with: string);

        textField.text = updatedString;

        //Setting the cursor at the right place
        let selectedRange = NSMakeRange(range.location + string.count, 0)
        if let from = textField.position(from: textField.beginningOfDocument, offset: selectedRange.location),
           let to = textField.position(from: from, offset: selectedRange.length) {
            textField.selectedTextRange = textField.textRange(from: from, to: to)
            //Sending an action
            textField.sendActions(for: UIControlEvents.editingChanged)
        }

        return false;
    }

}

fileprivate extension LoginViewController {
    func getbindingsFactory() -> () -> LoginViewControllerBindings {

        return { [unowned self] () -> LoginViewControllerBindings in
            return LoginViewControllerBindings(
                    stub: (),
                    appearenceState: nil
            )
        }
    }
}
