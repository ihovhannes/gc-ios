//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxGesture
import InputMask

class RegistrationDetailsViewController: UIViewController, DisposeBagProvider {

    fileprivate var registrationDetailsView: RegistrationDetailsView {
        return view as? RegistrationDetailsView ?? RegistrationDetailsView()
    }

    fileprivate var viewModel: RegistrationDetailsViewModel!

    fileprivate var activeField: UITextField?

    lazy var maskedDelegate = PolyMaskTextFieldDelegate()
    lazy var birthdayDelegate = PolyMaskTextFieldDelegate()

    var phone: String = ""

    var lastKeyboardHeight: CGFloat = 0

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RegistrationDetailsView()

        viewModel = RegistrationDetailsViewModel()
        type = .registrationDetails

        // -- Navigation

        viewModel
                .routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Text Fields

        registrationDetailsView.userNameWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in
                    return !(self.registrationDetailsView.scrollView.isDecelerating ||
                            self.registrationDetailsView.scrollView.isDragging)
                })
                .subscribe(onNext: onUserNameFieldTap)
                .disposed(by: disposeBag)

        registrationDetailsView.birthdayWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in
                    return !(self.registrationDetailsView.scrollView.isDecelerating ||
                            self.registrationDetailsView.scrollView.isDragging)
                })
                .subscribe(onNext: onBirthdayFieldTap)
                .disposed(by: disposeBag)

        registrationDetailsView.phoneNumberWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in
                    return !(self.registrationDetailsView.scrollView.isDecelerating ||
                            self.registrationDetailsView.scrollView.isDragging)
                })
                .subscribe(onNext: onPhoneNumberFieldTap)
                .disposed(by: disposeBag)

        registrationDetailsView.emailWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in
                    return !(self.registrationDetailsView.scrollView.isDecelerating ||
                            self.registrationDetailsView.scrollView.isDragging)
                })
                .subscribe(onNext: onEmailFieldTap)
                .disposed(by: disposeBag)

        registrationDetailsView.ofertaRow.checkButton
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onOfertaCheckTap)
                .disposed(by: disposeBag)

        registrationDetailsView.userNameField.delegate = self

        birthdayDelegate.listener = self
        birthdayDelegate.affineFormats = ["[09].[09].[0000]"]
        registrationDetailsView.birthdayField.delegate = birthdayDelegate

        maskedDelegate.listener = self
        maskedDelegate.affineFormats = ["+{7} ([000]) [000]-[00]-[00]"]
        registrationDetailsView.phoneNumberField.delegate = maskedDelegate

        registrationDetailsView.emailField.delegate = self

        // -- Buttons

        registrationDetailsView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onTapBackground)
                .disposed(by: disposeBag)

        registrationDetailsView.actionButton
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onContinueTap)
                .disposed(by: disposeBag)

        registrationDetailsView
                .backButton
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.dismiss(animated: true) })
                .do(onNext: { [unowned self] _ in self.endEditing() })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        registrationDetailsView.ofertaRow
                .question
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ [unowned self] _ in Routing.oferta(type: .registrationOfertaAccept, header: "Регистрация\nучетной записи", acceptCallback: self.onOfertaAccept) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // --

        registrationDetailsView.rx
                .anyGesture(.swipe([.up, .down]))
                .when(.recognized)
                .filter({ [unowned self] _ in self.registrationDetailsView.isSwipeEnabled() })
                .subscribe(onNext: onSwipe)
                .disposed(by: disposeBag)

        // --

        RxKeyboard.keyboardHeight()
                .subscribe(onNext: onKeyboard)
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(cardNumber: String, cardCode: String) -> RegistrationDetailsViewController {
        registrationDetailsView.configure(cardNumber: cardNumber, cardCode: cardCode)
        return self
    }

}

fileprivate extension RegistrationDetailsViewController {

    fileprivate func activateField(field: UITextField) {
        activeField = field
        field.becomeFirstResponder()
    }

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            registrationDetailsView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            registrationDetailsView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func onUserNameFieldTap(any: Any) {
        registrationDetailsView.userNameInputMode()
        activateField(field: registrationDetailsView.userNameField)
    }

    func onBirthdayFieldTap(any: Any) {
        registrationDetailsView.birthdayInputMode()
        activateField(field: registrationDetailsView.birthdayField)
    }

    func onPhoneNumberFieldTap(any: Any) {
        if activeField != registrationDetailsView.phoneNumberField, registrationDetailsView.phoneNumberField.text.isEmpty() {
            maskedDelegate.put(text: "+7 (", into: registrationDetailsView.phoneNumberField)
        }
        registrationDetailsView.phoneNumberInputMode()
        activateField(field: registrationDetailsView.phoneNumberField)
    }

    func onEmailFieldTap(any: Any) {
        registrationDetailsView.emailInputMode()
        activateField(field: registrationDetailsView.emailField)
    }

    func onOfertaCheckTap(any: Any) {
        registrationDetailsView.resetMode()
        registrationDetailsView.ofertaRow.setChecked(checked: !registrationDetailsView.ofertaRow.isChecked)
    }

    func onContinueTap(any: Any) {
        guard let userName = registrationDetailsView.userNameField.text, userName.isEmpty == false else {
            registrationDetailsView.userNameWarnMode(text: "Это поле не должно быть пустым")
            activateField(field: registrationDetailsView.userNameField)
            return
        }

        guard let birthday = registrationDetailsView.birthdayField.text, birthday.isEmpty == false else {
            registrationDetailsView.birthdayWarnMode(text: "Это поле не должно быть пустым")
            activateField(field: registrationDetailsView.birthdayField)
            return
        }

        let birthdayValue = birthday.components(separatedBy: ".")
        guard birthdayValue.count == 3,
              let day = Int(birthdayValue[0]), day >= 1, day <= 31,
              let month = Int(birthdayValue[1]), month >= 1, month <= 12,
              let year = Int(birthdayValue[2]), year >= 1900
                else {
            registrationDetailsView.birthdayWarnMode(text: "Неверная дата")
            activateField(field: registrationDetailsView.birthdayField)
            return
        }

        let dateComponent = DateComponents(calendar: .current, year: year, month: month, day: day)
        guard dateComponent.isValidDate, let date = dateComponent.date, date < Date() else {
            registrationDetailsView.birthdayWarnMode(text: "Неверная дата")
            activateField(field: registrationDetailsView.birthdayField)
            return
        }

        guard let phoneNumber = registrationDetailsView.phoneNumberField.text, phoneNumber.isEmpty == false else {
            registrationDetailsView.phoneNumberWarnMode(text: "Это поле не должно быть пустым")
            activateField(field: registrationDetailsView.phoneNumberField)
            maskedDelegate.put(text: "+7 (", into: registrationDetailsView.phoneNumberField)
            return
        }

        guard phone.count == 11 else {
            registrationDetailsView.phoneNumberWarnMode(text: "Неверный номер телефона")
            activateField(field: registrationDetailsView.phoneNumberField)
            return
        }

        if let email = registrationDetailsView.emailField.text, email.isEmpty == false {
            let pat = ".+@.+\\.+.+"
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: email, options: [], range: NSRange(location: 0, length: email.count))

            if matches.count == 0 {
                activateField(field: registrationDetailsView.emailField)
                registrationDetailsView.emailWarnMode(text: "Неверный формат электронной почты")
                return
            }
        }

        guard registrationDetailsView.ofertaRow.isChecked else {
            registrationDetailsView.ofertaWarnMode(text: "Необходимо дать согласие на обработку персональных данных")
            activeField?.resignFirstResponder()
            return
        }

        viewModel.userRegistration.onNext((
                cardNumber: registrationDetailsView.cardNumberValue.text ?? "",
                cardCode: registrationDetailsView.cardCodeValue.text ?? "",
                firstName: registrationDetailsView.userNameField.text ?? "",
                gender: registrationDetailsView.genderRow.isMale ? "M" : "F",
                birthDate: "\(year)-\(month)-\(day)",
                phone: phone,
                email: registrationDetailsView.emailField.text ?? "",
                agreement: true
        ))

    }

    func onTapBackground(any: Any) {
        endEditing()
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        registrationDetailsView.resetMode()
    }

    func onSwipe(any: Any) {
        endEditing()
    }

    func onOfertaAccept() {
        registrationDetailsView.resetMode()
        registrationDetailsView.ofertaRow.setChecked(checked: true)
    }

}

extension RegistrationDetailsViewController: MaskedTextFieldDelegateListener {

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        switch textField {
        case registrationDetailsView.phoneNumberField:
            phone = value
        case registrationDetailsView.birthdayField:
            registrationDetailsView.birthdayFormatPlaceholder.isShown = value.count == 0
        case _:
            log("missing case")
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case registrationDetailsView.userNameField:
            onBirthdayFieldTap(any: ())
        case registrationDetailsView.birthdayField:
            onPhoneNumberFieldTap(any: ())
        case registrationDetailsView.phoneNumberField:
            onEmailFieldTap(any: ())
        case registrationDetailsView.emailField:
            onContinueTap(any: ())
        case _:
            log("missing case")
        }
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }

        var maxLength = 320
        switch textField {
        case registrationDetailsView.userNameField:
            maxLength = 50
        case _:
            break
        }
        let str = (textField.text ?? "") + string
        if str.count <= maxLength {
            return true
        }
        textField.text = str.substring(to: str.index(str.startIndex, offsetBy: maxLength))
        return false
    }

}
