//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class RegistrationView: UIView {

    let LOGIN_HEIGHT = 45
    let LOGIN_BOTTOM_PAD = 24
    let TAP_PAD = 20

    lazy var logo = UIImageView()
    lazy var title = UILabel()

    lazy var tapBackground = UIView()

    lazy var backButton = UIButton(type: .custom)
    lazy var backButtonUnderline = UIView()
    lazy var actionButton = UIButton(type: .custom)

    lazy var numberCodeHolder = UIView()

    lazy var numberWrapper = TextWrapper()
    lazy var numberPlaceholder = UILabel()
    lazy var numberField = UITextField()
    lazy var numberWarn = UILabel()

    lazy var codeWrapper = TextWrapper()
    lazy var codePlaceholder = UILabel()
    lazy var codeField = UITextField.init()
    lazy var codeWarn = UILabel()

    fileprivate var isKeyboardMode: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        tapBackground.addSubview(logo)
        tapBackground.addSubview(title)

        addSubview(tapBackground)

        addSubview(backButtonUnderline)
        addSubview(backButton)
        addSubview(actionButton)

        numberWrapper = TextWrapper()
                .add(text: numberField, topPad: 10)
                .add(placeholder: numberPlaceholder)

        numberCodeHolder.addSubview(numberWrapper)
        numberCodeHolder.addSubview(numberWarn)

        codeWrapper = TextWrapper()
                .add(text: codeField, topPad: 10, bottomPad: 7)
                .add(placeholder: codePlaceholder)

        numberCodeHolder.addSubview(codeWrapper)
        numberCodeHolder.addSubview(codeWarn)

        addSubview(numberCodeHolder)

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

        actionButton.snp.makeConstraints { actionButton in
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

        numberCodeHolder.snp.makeConstraints { numberCodeHolder in
            numberCodeHolder.center.equalToSuperview()
            numberCodeHolder.width.equalTo(self).offset(-40)
        }

        numberWrapper.snp.makeConstraints { numberWrapper in
            numberWrapper.top.equalToSuperview().offset(TAP_PAD)
            numberWrapper.leading.trailing.equalToSuperview()
        }

        numberWarn.snp.makeConstraints { numberWarn in
            numberWarn.top.equalTo(numberWrapper.snp.bottom)
            numberWarn.leading.equalToSuperview()
        }

        codeWrapper.snp.makeConstraints { codeWrapper in
            codeWrapper.top.equalTo(numberWarn.snp.bottom).offset(15)
            codeWrapper.leading.trailing.equalToSuperview()
            codeWrapper.bottom.equalToSuperview()
        }

        codeWarn.snp.makeConstraints { codeWarn in
            codeWarn.top.equalTo(codeWrapper.snp.bottom).offset(5)
            codeWarn.left.equalToSuperview()
        }

        numberWarn.alpha = 0
        codeWarn.alpha = 0

        look.apply(Style.registrationView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension RegistrationView {

    func moveUpComponentsByKeyboard(keyboardHeight: CGFloat, keyboardAnimDuration: TimeInterval) {
        if isKeyboardMode {
            return
        }
        defer {
            isKeyboardMode = true
        }

        let numberCodeHolderTop = numberCodeHolder.convert(CGPoint(x: 0, y: 0), to: self).y
        let desiredNumberCodeHolderTop = self.bounds.height - (numberCodeHolder.bounds.height + keyboardHeight + CGFloat(LOGIN_HEIGHT + LOGIN_BOTTOM_PAD) + 50)

        var holderTransform = numberCodeHolderTop - desiredNumberCodeHolderTop
        holderTransform = holderTransform > 0 ? holderTransform : 50

        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self, holderTransform] () in
            let keyboardTransform = CGAffineTransform(translationX: 0, y: -1 * keyboardHeight)
            self.actionButton.transform = keyboardTransform
            self.backButton.transform = keyboardTransform
            self.backButtonUnderline.transform = keyboardTransform

            let numberCodeTransform = CGAffineTransform(translationX: 0, y: -1 * holderTransform)
            self.numberCodeHolder.transform = numberCodeTransform
        })
    }

    func moveDownComponentsByKeyboard(duration: TimeInterval) {
        if !isKeyboardMode {
            return
        }
        defer {
            isKeyboardMode = false
        }

        UIView.animate(withDuration: duration, animations: { [unowned self] () in
            self.numberCodeHolder.transform = CGAffineTransform.identity
            self.actionButton.transform = CGAffineTransform.identity
            self.backButton.transform = CGAffineTransform.identity
            self.backButtonUnderline.transform = CGAffineTransform.identity
        })
    }

}

extension RegistrationView {

    func switchToNumberInput() {
        self.numberWrapper.textFieldBlocker.isShown = false
        self.codeWrapper.textFieldBlocker.isShown = true

        self.numberPlaceholder.textColor = Palette.LoginView.text.color
        self.numberWrapper.underline.backgroundColor = Palette.LoginView.highlight.color
        self.codePlaceholder.textColor = Palette.LoginView.placeholder.color
        self.codeWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.numberWarn.alpha = 0
            self.codeWarn.alpha = 0
            self.numberPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.numberField.transform = CGAffineTransform.identity
            self.numberWrapper.transform = CGAffineTransform.identity
            self.codePlaceholder.transform = self.codeField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToCodeInput() {
        self.numberWrapper.textFieldBlocker.isShown = true
        self.codeWrapper.textFieldBlocker.isShown = false

        self.numberPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.numberWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.codePlaceholder.textColor = Palette.LoginView.text.color
        self.codeWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.numberWarn.alpha = 0
            self.codeWarn.alpha = 0
            self.numberPlaceholder.transform = self.numberField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.numberField.transform = CGAffineTransform.identity
            self.numberWrapper.transform = CGAffineTransform.identity
            self.codePlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToNumberWarn(text: String) {
        self.numberWrapper.textFieldBlocker.isShown = false
        self.codeWrapper.textFieldBlocker.isShown = true

        self.numberWarn.text = text
        self.numberPlaceholder.textColor = Palette.LoginView.text.color
        self.numberWrapper.underline.backgroundColor = Palette.LoginView.warn.color
        self.codePlaceholder.textColor = Palette.LoginView.placeholder.color
        self.codeWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.numberWarn.alpha = 1
            self.codeWarn.alpha = 0
            self.numberPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.numberWrapper.transform = CGAffineTransform(translationX: 0, y: -4)
            self.codePlaceholder.transform = self.codeField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToCodeWarn(text: String) {
        self.numberWrapper.textFieldBlocker.isShown = true
        self.codeWrapper.textFieldBlocker.isShown = false

        self.codeWarn.text = text
        self.numberPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.numberWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.codePlaceholder.textColor = Palette.LoginView.text.color
        self.codeWrapper.underline.backgroundColor = Palette.LoginView.warn.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.numberWarn.alpha = 0
            self.codeWarn.alpha = 1
            self.numberPlaceholder.transform = self.numberField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.numberField.transform = CGAffineTransform.identity
            self.numberWrapper.transform = CGAffineTransform.identity
            self.codePlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func resetNumberCodeState() {
        self.numberWrapper.textFieldBlocker.isShown = true
        self.codeWrapper.textFieldBlocker.isShown = true

        self.numberPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.numberWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.codePlaceholder.textColor = Palette.LoginView.placeholder.color
        self.codeWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.numberWarn.alpha = 0
            self.codeWarn.alpha = 0
            self.numberPlaceholder.transform = self.numberField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.numberField.transform = CGAffineTransform.identity
            self.numberWrapper.transform = CGAffineTransform.identity
            self.codePlaceholder.transform = self.codeField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

}


fileprivate extension Style {

    static var registrationView: Change<RegistrationView> {
        return { (view: RegistrationView) -> Void in
            view.tapBackground.backgroundColor = Palette.LoginView.background.color

            view.logo.look.apply(Style.logo)
            view.title.look.apply(Style.title)

            view.backButton.look.apply(Style.backButton)
            view.actionButton.look.apply(Style.actionButton)
            view.backButtonUnderline.backgroundColor = Palette.LoginView.text.color

            view.numberField.look.apply(Style.textField)
            view.numberField.keyboardType = .numberPad
            view.numberField.keyboardAppearance = .default
            view.numberField.returnKeyType = .next

            view.codeField.look.apply(Style.textField)
            view.codeField.keyboardType = .numberPad
            view.codeField.returnKeyType = .go

            view.numberPlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.numberPlaceholder.textColor = Palette.LoginView.placeholder.color
            view.numberPlaceholder.text = "Номер карты"

            view.numberWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.numberWarn.textColor = Palette.LoginView.warn.color
            view.numberWarn.text = "Это поле не должно быть пустым"

            view.numberWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

            view.codePlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.codePlaceholder.textColor = Palette.LoginView.placeholder.color
            view.codePlaceholder.text = "Код карты"

            view.codeWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.codeWarn.textColor = Palette.LoginView.warn.color
            view.codeWarn.text = "Это поле не должно быть пустым"

            view.codeWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
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
            button.setTitle("РЕГИСТРАЦИЯ", for: .normal)
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

    static var textField: Change<UITextField> {
        return { (field: UITextField) -> Void in
            field.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            field.textColor = Palette.LoginView.text.color
        }
    }

}
