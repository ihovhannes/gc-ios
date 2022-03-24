//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import RxGesture
import IQKeyboardManagerSwift
import InputMask

class RegistrationDetailsView: UIView {

    let LOGIN_HEIGHT = 45
    let LOGIN_BOTTOM_PAD = 24
    let TAP_PAD = 20

    lazy var logo = UIImageView()
    lazy var title = UILabel()

    lazy var tapBackground = UIView()

    lazy var footerContainer = UIView()
    lazy var actionButton = UIButton(type: .custom)
    lazy var backButton = UIButton(type: .custom)
    lazy var backButtonUnderline = UIView()

    lazy var contentStack = UIStackView()

    lazy var cardNumberPlaceholder = UILabel()
    lazy var cardNumberValue = UITextField()

    lazy var cardCodePlaceholder = UILabel()
    lazy var cardCodeValue = UILabel()

    lazy var userNameWrapper = TextWrapper()
    lazy var userNamePlaceholder = UILabel()
    lazy var userNameField = UITextField()
    lazy var userNameWarn = UILabel()

    lazy var birthdayWrapper = TextWrapper()
    lazy var birthdayPlaceholder = UILabel()
    lazy var birthdayFormatPlaceholder = UILabel()
    lazy var birthdayField = UITextField()
    lazy var birthdayWarn = UILabel()

    lazy var genderRow = GenderRow()

    lazy var phoneNumberWrapper = TextWrapper()
    lazy var phoneNumberPlaceholder = UILabel()
    lazy var phoneNumberField = UITextField()
    lazy var phoneNumberWarn = UILabel()

    lazy var emailWrapper = TextWrapper()
    lazy var emailPlaceholder = UILabel()
    lazy var emailField = UITextField()
    lazy var emailWarn = UILabel()

    lazy var ofertaRow = OfertaRow()
    lazy var ofertaWarn = UILabel()

    lazy var scrollView = UIScrollView()
    lazy var container = UIView()

    lazy var visibleComponent: UIView? = nil

    // -- Delegates

    lazy var maskedCardNumber = PolyMaskTextFieldDelegate()

    override init(frame: CGRect) {
        super.init(frame: frame)

        tapBackground.addSubview(logo)
        tapBackground.addSubview(title)
        addSubview(tapBackground)

        addSubview(scrollView)
        scrollView.addSubview(container)
        container.addSubview(contentStack)

        addSubview(footerContainer)
        footerContainer.addSubview(actionButton)
        footerContainer.addSubview(backButton)
        footerContainer.addSubview(backButtonUnderline)

        scrollView.snp.makeConstraints { scrollView in
            scrollView.top.equalTo(80)
            scrollView.leading.trailing.equalToSuperview()
            scrollView.bottom.equalTo(footerContainer.snp.top)
        }

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview()
            container.width.equalToSuperview()
        }

        logo.snp.makeConstraints { logo in
            logo.left.equalToSuperview().offset(20)
            logo.top.equalToSuperview().offset(16)
            logo.width.height.equalTo(37)
        }

        title.snp.makeConstraints { title in
            title.top.equalToSuperview().offset(16)
            title.right.equalToSuperview().offset(-18)
        }

        tapBackground.snp.makeConstraints { tapBackground in
            tapBackground.edges.equalToSuperview()
        }

        footerContainer.snp.makeConstraints { footerContainer in
            footerContainer.leading.trailing.bottom.equalToSuperview()
        }

        actionButton.snp.makeConstraints { actionButton in
            actionButton.top.equalTo(footerContainer.snp.top).offset(LOGIN_BOTTOM_PAD)
            actionButton.left.equalToSuperview().offset(20)
            actionButton.bottom.equalToSuperview().offset(-1 * LOGIN_BOTTOM_PAD)
            actionButton.width.equalTo(168)
            actionButton.height.equalTo(LOGIN_HEIGHT)
        }

        backButton.snp.makeConstraints { backButton in
            backButton.height.equalTo(LOGIN_HEIGHT)
            backButton.centerY.equalTo(actionButton.snp.centerY)
            backButton.right.equalToSuperview().offset(-22)
        }

        backButtonUnderline.snp.makeConstraints { backButtonUnderline in
            backButtonUnderline.right.equalToSuperview().offset(-22)
            backButtonUnderline.bottom.equalToSuperview().offset(-30)
            backButtonUnderline.width.equalTo(34)
            backButtonUnderline.height.equalTo(2)
        }

        contentStack.snp.makeConstraints { contentStack in
            contentStack.top.equalToSuperview()
            contentStack.leading.equalToSuperview().offset(20)
            contentStack.trailing.equalToSuperview().offset(-20)
            contentStack.bottom.equalToSuperview()
        }

        contentStack.addArrangedSubview(cardNumberPlaceholder)
        contentStack.addArrangedSubview(TextWrapper().add(text: cardNumberValue, topPad: 1, bottomPad: 9))

        contentStack.addArrangedSubview(cardCodePlaceholder)
        contentStack.addArrangedSubview(TextWrapper().add(text: cardCodeValue, topPad: 1, bottomPad: 9))

        userNameWrapper = TextWrapper()
                .add(text: userNameField, topPad: 30)
                .add(placeholder: userNamePlaceholder)

        contentStack.addArrangedSubview(userNameWrapper)
        contentStack.addArrangedSubview(userNameWarn)

        birthdayWrapper = TextWrapper()
                .add(text: birthdayField)
                .add(placeholder: birthdayPlaceholder)
                .add(placeholder: birthdayFormatPlaceholder)

        contentStack.addArrangedSubview(birthdayWrapper)
        contentStack.addArrangedSubview(birthdayWarn)

        contentStack.addArrangedSubview(genderRow)

        phoneNumberWrapper = TextWrapper()
                .add(text: phoneNumberField)
                .add(placeholder: phoneNumberPlaceholder)

        contentStack.addArrangedSubview(phoneNumberWrapper)
        contentStack.addArrangedSubview(phoneNumberWarn)

        emailWrapper = TextWrapper()
                .add(text: emailField)
                .add(placeholder: emailPlaceholder)

        contentStack.addArrangedSubview(emailWrapper)
        contentStack.addArrangedSubview(emailWarn)

        contentStack.addArrangedSubview(ofertaRow)
        contentStack.addArrangedSubview(ofertaWarn)

        contentStack.axis = .vertical
        contentStack.spacing = 1

        userNameWarn.isShown = false
        birthdayWarn.isShown = false
        phoneNumberWarn.isShown = false
        emailWarn.isShown = false
        ofertaWarn.isShown = false

        relaxMode()
        relaxAnimMode()

        scrollView.bounces = false
        scrollView.showsScrollIndicator = false

        look.apply(Style.registrationDetailsView)

        // -- Delegates

        maskedCardNumber.affineFormats = ["[0000] [0000] [0000] [0000]"]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(cardNumber: String, cardCode: String) {
        maskedCardNumber.put(text: cardNumber, into: cardNumberValue)
        cardCodeValue.text = cardCode
    }

}

extension RegistrationDetailsView {

    func relaxMode() {
        userNamePlaceholder.textColor = Palette.LoginView.placeholder.color
        birthdayPlaceholder.textColor = Palette.LoginView.placeholder.color
        birthdayFormatPlaceholder.isShown = false
        phoneNumberPlaceholder.textColor = Palette.LoginView.placeholder.color
        emailPlaceholder.textColor = Palette.LoginView.placeholder.color

        userNameWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        birthdayWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        phoneNumberWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        emailWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        userNameWrapper     .textFieldBlocker.isHidden = false
        birthdayWrapper     .textFieldBlocker.isHidden = false
        phoneNumberWrapper  .textFieldBlocker.isHidden = false
        emailWrapper        .textFieldBlocker.isHidden = false
    }

    func relaxAnimMode() {
        userNamePlaceholder.transform = userNameField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)
        birthdayPlaceholder.transform = birthdayField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)
        phoneNumberPlaceholder.transform = phoneNumberField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)
        emailPlaceholder.transform = emailField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)
    }

    func relaxWarnMode() {
        self.userNameWarn.isShown = false
        self.birthdayWarn.isShown = false
        self.phoneNumberWarn.isShown = false
        self.emailWarn.isShown = false
        self.ofertaWarn.isShown = false
    }

    func userNameInputMode() {
        relaxMode()
        visibleComponent = userNameWrapper
        userNameWrapper.textFieldBlocker.isHidden = true
        userNamePlaceholder.textColor = Palette.LoginView.text.color
        userNameWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        relaxWarnMode()
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.userNamePlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func userNameWarnMode(text: String) {
        relaxMode()
        visibleComponent = userNameWarn
        userNameWrapper.textFieldBlocker.isHidden = true
        userNamePlaceholder.textColor = Palette.LoginView.text.color
        userNameWrapper.underline.backgroundColor = Palette.LoginView.warn.color
        userNameWarn.text = text

        relaxWarnMode()
        self.userNameWarn.isShown = true
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.userNamePlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }


    func birthdayInputMode() {
        relaxMode()
        visibleComponent = birthdayWrapper
        birthdayWrapper.textFieldBlocker.isHidden = true
        birthdayFormatPlaceholder.isShown = birthdayField.text.isEmpty()
        birthdayPlaceholder.textColor = Palette.LoginView.text.color
        birthdayWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        relaxWarnMode()
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.birthdayPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func birthdayWarnMode(text: String) {
        relaxMode()
        visibleComponent = birthdayWarn
        birthdayWrapper.textFieldBlocker.isHidden = true
        birthdayPlaceholder.textColor = Palette.LoginView.text.color
        birthdayWrapper.underline.backgroundColor = Palette.LoginView.warn.color
        birthdayWarn.text = text

        relaxWarnMode()
        self.birthdayWarn.isShown = true
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.birthdayPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }


    func phoneNumberInputMode() {
        relaxMode()
        visibleComponent = phoneNumberWrapper
        phoneNumberWrapper.textFieldBlocker.isHidden = true
        phoneNumberPlaceholder.textColor = Palette.LoginView.text.color
        phoneNumberWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        relaxWarnMode()
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.phoneNumberPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func phoneNumberWarnMode(text: String) {
        relaxMode()
        visibleComponent = phoneNumberWarn
        phoneNumberWrapper.textFieldBlocker.isHidden = true
        phoneNumberPlaceholder.textColor = Palette.LoginView.text.color
        phoneNumberWrapper.underline.backgroundColor = Palette.LoginView.warn.color
        phoneNumberWarn.text = text

        relaxWarnMode()
        self.phoneNumberWarn.isShown = true
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.phoneNumberPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func emailInputMode() {
        relaxMode()
        visibleComponent = emailWrapper
        emailWrapper.textFieldBlocker.isHidden = true
        emailPlaceholder.textColor = Palette.LoginView.text.color
        emailWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        relaxWarnMode()
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.emailPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func emailWarnMode(text: String) {
        relaxMode()
        visibleComponent = emailWarn
        emailWrapper.textFieldBlocker.isHidden = true
        emailPlaceholder.textColor = Palette.LoginView.text.color
        emailWrapper.underline.backgroundColor = Palette.LoginView.warn.color
        emailWarn.text = text

        relaxWarnMode()
        self.emailWarn.isShown = true
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.emailPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func ofertaWarnMode(text: String) {
        visibleComponent = ofertaWarn
        relaxMode()
        ofertaWarn.text = text

        relaxWarnMode()
        self.ofertaWarn.isShown = true
        self.layoutIfNeeded()

        showVisibleComponent()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
        })
    }

    func resetMode() {
        relaxMode()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
        })
    }

}

extension RegistrationDetailsView {

    func moveUpComponentsByKeyboard(keyboardHeight: CGFloat, keyboardAnimDuration: TimeInterval) {
//        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self] () in
//            self.footerContainer.transform = CGAffineTransform(translationX: 0, y: -1 * keyboardHeight)
//        })

        footerContainer.snp.remakeConstraints { footerContainer in
            footerContainer.leading.trailing.equalToSuperview()
            footerContainer.bottom.equalToSuperview().offset(-1 * keyboardHeight)
        }

        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self] () in
            self.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if finished {
                self?.showVisibleComponent()
            }
        })
    }

    func moveDownComponentsByKeyboard(duration: TimeInterval) {
//        UIView.animate(withDuration: duration, animations: { [unowned self] () in
//            self.footerContainer.transform = CGAffineTransform.identity
//        })

        footerContainer.snp.remakeConstraints { footerContainer in
            footerContainer.leading.trailing.bottom.equalToSuperview()
        }
        UIView.animate(withDuration: duration, animations: { [unowned self] () in
            self.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if finished {
                self?.showVisibleComponent()
            }
        })
    }

    func showVisibleComponent() {
        if let visibleComponent = visibleComponent {
            let visibleRect = visibleComponent.convert(visibleComponent.bounds, to: container)
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }

}

extension RegistrationDetailsView {

    func isSwipeEnabled() -> Bool {
        return scrollView.contentOffset.y <= 0 || scrollView.contentOffset.y + scrollView.bounds.height >= container.bounds.height
    }

}

fileprivate extension Style {

    static var registrationDetailsView: Change<RegistrationDetailsView> {
        return { (view: RegistrationDetailsView) in
            view.tapBackground.backgroundColor = Palette.LoginView.background.color

            view.logo.look.apply(Style.logo)
            view.title.look.apply(Style.title)

            view.backButton.look.apply(Style.backButton)
            view.actionButton.look.apply(Style.actionButton)
            view.backButtonUnderline.backgroundColor = Palette.LoginView.text.color
            view.footerContainer.backgroundColor = Palette.LoginView.background.color

            view.cardNumberPlaceholder.look.apply(Style.placeholder2)
            view.cardNumberPlaceholder.text = "Номер карты"

            view.cardNumberValue.look.apply(Style.textField)
            view.cardNumberValue.text = "5544555"

            view.cardCodePlaceholder.look.apply(Style.placeholder2)
            view.cardCodePlaceholder.text = "Код карты"

            view.cardCodeValue.look.apply(Style.textValue)
            view.cardCodeValue.text = "5554"

            view.userNamePlaceholder.look.apply(Style.placeholder2)
            view.userNamePlaceholder.text = "Ваше имя*"

            view.userNameField.look.apply(Style.textField)
            view.userNameField.keyboardType = .namePhonePad
            view.userNameField.autocorrectionType = .no
            view.userNameField.returnKeyType = .next

            view.userNameWarn.look.apply(Style.warn)
            view.userNameWarn.text = "Это поле не должно быть пустым"

            view.birthdayPlaceholder.look.apply(Style.placeholder2)
            view.birthdayPlaceholder.text = "Дата рождения*"

            view.birthdayFormatPlaceholder.look.apply(Style.placeholder2)
            view.birthdayFormatPlaceholder.text = "дд.мм.гггг"

            view.birthdayField.look.apply(Style.textField)
            view.birthdayField.keyboardType = .numbersAndPunctuation
            view.birthdayField.autocorrectionType = .no
            view.birthdayField.returnKeyType = .next

            view.birthdayWarn.look.apply(Style.warn)
            view.birthdayWarn.text = "Это поле не должно быть пустым"

            view.phoneNumberPlaceholder.look.apply(Style.placeholder2)
            view.phoneNumberPlaceholder.text = "Номер телефона*"

            view.phoneNumberField.look.apply(Style.textField)
            view.phoneNumberField.keyboardType = .phonePad
            view.phoneNumberField.returnKeyType = .next

            view.phoneNumberWarn.look.apply(Style.warn)
            view.phoneNumberWarn.text = "Это поле не должно быть пустым"

            view.emailPlaceholder.look.apply(Style.placeholder2)
            view.emailPlaceholder.text = "E-mail"

            view.emailField.look.apply(Style.textField)
            view.emailField.keyboardType = .emailAddress
            view.emailField.autocorrectionType = .no
            view.emailField.returnKeyType = .go

            view.emailWarn.look.apply(Style.warn)
            view.emailWarn.text = "Это поле не должно быть пустым"

            view.ofertaWarn.look.apply(Style.warn)
            view.ofertaWarn.text = "Необходимо дать согласие на обработку персональных данных"
            view.ofertaWarn.numberOfLines = 0
            view.ofertaWarn.lineBreakMode = .byWordWrapping
        }
    }

    static var logo: Change<UIImageView> {
        return { (imageView: UIImageView) -> Void in
            imageView.image = UIImage(named: "logo_37_green")
        }
    }

    static var title: Change<UILabel> {
        return { (label: UILabel) -> Void in
            label.text = "ГРИН\nКАРТА"
            label.font = UIFont(name: "ProximaNova-Extrabld", size: 14)
            label.textAlignment = .right
            label.numberOfLines = 2
            label.textColor = Palette.LoginView.text.color
            guard let text = label.text else {
                return
            }
            let nsText = text as NSString
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSAttributedStringKey.foregroundColor: Palette.LoginView.highlight.color],
                    range: nsText.range(of: "ГРИН"))
            label.attributedText = attributedText
        }
    }

    static var actionButton: Change<UIButton> {
        return { (button: UIButton) -> Void in
            button.setTitle("ПРОДОЛЖИТЬ РЕГИСТРАЦИЮ", for: .normal)
            button.backgroundColor = Palette.LoginView.highlight.color
            button.setTitleColor(Palette.LoginView.text.color, for: .normal)
            button.layer.cornerRadius = 22.5
            button.layer.masksToBounds = true
            button.titleLabel?.font = UIFont(name: "ProximaNova-Bold", size: 9)
        }
    }

    static var backButton: Change<UIButton> {
        return { (button: UIButton) -> Void in
            button.backgroundColor = Palette.Common.transparentBackground.color
            button.contentHorizontalAlignment = .right
            button.setTitleColor(Palette.LoginView.text.color, for: .normal)
            button.setTitle("АВТОРИЗАЦИЯ", for: .normal)
            button.titleLabel?.font = UIFont(name: "ProximaNova-Bold", size: 9)
            button.titleLabel?.textAlignment = .right
            button.titleLabel?.numberOfLines = 2
        }
    }

    static var placeholder1: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            label.textColor = Palette.LoginView.text.color
        }
    }

    static var placeholder2: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            label.textColor = Palette.LoginView.placeholder.color
        }
    }

    static var textValue: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            label.textColor = Palette.LoginView.text.color
        }
    }

    static var textField: Change<UITextField> {
        return { (field: UITextField) -> Void in
            field.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            field.textColor = Palette.LoginView.text.color
        }
    }

    static var warn: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            label.textColor = Palette.LoginView.warn.color
        }
    }

}

class TextWrapper: UIView {

    let underline = UIView()
    var text: UIView?
    let textFieldBlocker = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(text: UIView, topPad: Int = 20, bottomPad: Int = 7) -> TextWrapper {
        self.text = text

        let scrollView = UIScrollView()
        addSubview(scrollView)

        scrollView.addSubview(text)
        addSubview(underline)

        scrollView.snp.makeConstraints { scrollView in
            scrollView.leading.equalToSuperview()
            scrollView.trailing.equalToSuperview()
            scrollView.top.equalToSuperview().offset(topPad)
            scrollView.bottom.equalToSuperview().offset(-1 * bottomPad)
        }

        underline.snp.makeConstraints { underline in
            underline.leading.trailing.equalToSuperview()
            underline.top.equalTo(text.snp.bottom).offset(4)
            underline.height.equalTo(1)
        }

        text.snp.makeConstraints { text in
            text.edges.equalToSuperview()
            text.width.height.equalToSuperview()
        }

        addSubview(textFieldBlocker)
        textFieldBlocker.snp.makeConstraints { textFieldBlocker in
            textFieldBlocker.edges.equalToSuperview()
        }
        textFieldBlocker.backgroundColor = .clear

        underline.backgroundColor = Palette.LoginView.placeholder.color

//        backgroundColor = .blue

        return self
    }

    func add(placeholder: UILabel) -> TextWrapper {
        guard let text = self.text else {
            return self
        }
        insertSubview(placeholder, at: 0)

        placeholder.snp.makeConstraints { placeholder in
            placeholder.leading.equalToSuperview()
            placeholder.centerY.equalTo(text.snp.centerY)
        }

        return self
    }

}

class GenderRow: UIView, DisposeBagProvider {

    let genderLabel = UILabel()

    let maleRadio = RadioButton()
    let maleLabel = UILabel()

    let femaleRadio = RadioButton()
    let femaleLabel = UILabel()

    var isMale = true

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(genderLabel)

        addSubview(maleRadio)
        addSubview(maleLabel)

        addSubview(femaleRadio)
        addSubview(femaleLabel)

        self.snp.makeConstraints { selfSize in
            selfSize.height.equalTo(85)
//            selfSize.height.equalTo(30)
        }

        genderLabel.snp.makeConstraints { genderLabel in
            genderLabel.leading.equalToSuperview()
            genderLabel.centerY.equalToSuperview()
        }

        maleRadio.snp.makeConstraints { maleRadio in
            maleRadio.leading.equalTo(genderLabel.snp.trailing).offset(10)
            maleRadio.centerY.equalToSuperview()
        }

        maleLabel.snp.makeConstraints { maleLabel in
            maleLabel.leading.equalTo(maleRadio.snp.trailing).offset(10)
            maleLabel.centerY.equalToSuperview()
        }

        femaleRadio.snp.makeConstraints { femaleRadio in
            femaleRadio.leading.equalTo(maleLabel.snp.trailing).offset(30)
            femaleRadio.centerY.equalToSuperview()
        }

        femaleLabel.snp.makeConstraints { femaleLabel in
            femaleLabel.leading.equalTo(femaleRadio.snp.trailing).offset(10)
            femaleLabel.centerY.equalToSuperview()
        }

        genderLabel.text = "Пол*:"
        genderLabel.look.apply(Style.placeholder1)

        maleLabel.text = "Мужской"
        maleLabel.look.apply(Style.placeholder1)

        femaleLabel.text = "Женский"
        femaleLabel.look.apply(Style.placeholder1)

        maleRadio.setChecked(checked: true)
        femaleRadio.setChecked(checked: false)

        maleRadio
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onMaleTap)
                .disposed(by: disposeBag)

        maleLabel
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onMaleTap)
                .disposed(by: disposeBag)

        femaleRadio
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onFemaleTap)
                .disposed(by: disposeBag)

        femaleLabel
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: onFemaleTap)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onMaleTap(any: Any) {
        isMale = true

        maleRadio.setChecked(checked: true)
        femaleRadio.setChecked(checked: false)
    }

    func onFemaleTap(any: Any) {
        isMale = false

        maleRadio.setChecked(checked: false)
        femaleRadio.setChecked(checked: true)
    }

}

class RadioButton: UIView {

    let bigCircle = UIView()
    let smallCircle = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bigCircle)
        addSubview(smallCircle)

        bigCircle.snp.makeConstraints { bigCircle in
            bigCircle.edges.equalToSuperview()
            bigCircle.width.equalTo(15)
            bigCircle.height.equalTo(15)
        }

        smallCircle.snp.makeConstraints { smallCircle in
            smallCircle.center.equalToSuperview()
            smallCircle.width.equalTo(4)
            smallCircle.height.equalTo(4)
        }

        bigCircle.backgroundColor = Palette.LoginView.highlight.color
        bigCircle.layer.cornerRadius = 7.5

        smallCircle.backgroundColor = Palette.LoginView.text.color
        smallCircle.layer.cornerRadius = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(checked: Bool) {
        bigCircle.backgroundColor = checked ? Palette.LoginView.highlight.color : Palette.LoginView.text.color
        smallCircle.isShown = checked
    }

}

class OfertaRow: UIView {

    let checkButton = CheckButton()
    let agreeLabel = UILabel()
    let question = UIImageView()

    var isChecked = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(checkButton)
        addSubview(agreeLabel)
        addSubview(question)

        self.snp.makeConstraints { selfSize in
            selfSize.height.equalTo(30)
        }

        checkButton.snp.makeConstraints { checkButton in
            checkButton.leading.equalToSuperview()
            checkButton.centerY.equalToSuperview()
        }

        agreeLabel.snp.makeConstraints { agreeLabel in
            agreeLabel.leading.equalTo(checkButton.snp.trailing).offset(10)
            agreeLabel.centerY.equalToSuperview()
        }

        question.snp.makeConstraints { question in
            question.width.height.equalTo(12)
            question.leading.equalTo(agreeLabel.snp.trailing).offset(10)
            question.centerY.equalToSuperview()
        }

        agreeLabel.text = "С условиями оферты ознакомлен*"
        agreeLabel.look.apply(Style.placeholder1)

        question.image = UIImage(named: "ic_question")

        checkButton.setChecked(checked: false)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(checked: Bool) {
        isChecked = checked
        checkButton.setChecked(checked: checked)
    }

}

class CheckButton: UIView {

    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)

        imageView.snp.makeConstraints { imageView in
            imageView.edges.equalToSuperview()
            imageView.width.height.equalTo(15)
        }

        imageView.image = UIImage(named: "check_box_setted")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChecked(checked: Bool) {
        imageView.image = UIImage(named: checked ? "check_box_setted" : "check_box_unsetted")
    }

}
