//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class RestorePasswordPhoneView: UIView {

    let LOGIN_HEIGHT = 45
    let LOGIN_BOTTOM_PAD = 24
    let TAP_PAD = 20

    lazy var logo = UIImageView()
    lazy var title = UILabel()

    lazy var tapBackground = UIView()

    lazy var numberCodeHolder = UIView()

    lazy var phoneWrapper = TextWrapper()
    lazy var phoneField = UITextField()
    lazy var phonePlaceholder = UILabel()
    lazy var phoneWarn = UILabel()

    lazy var codeWrapper = TextWrapper()
    lazy var codeField = UITextField.init()

    lazy var footerContainer = UIView()
    lazy var actionButton = UIButton(type: .custom)
    lazy var backButton = UIButton(type: .custom)
    lazy var backButtonUnderline = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tapBackground)

        tapBackground.addSubview(logo)
        tapBackground.addSubview(title)

        addSubview(numberCodeHolder)
        addSubview(footerContainer)

        footerContainer.addSubview(actionButton)
        footerContainer.addSubview(backButton)
        footerContainer.addSubview(backButtonUnderline)

        phoneWrapper = TextWrapper()
                .add(text: phoneField, topPad: 10, bottomPad: 7)
                .add(placeholder: phonePlaceholder)

        numberCodeHolder.addSubview(phoneWrapper)
        numberCodeHolder.addSubview(phoneWarn)

        codeWrapper = TextWrapper()
                .add(text: codeField, topPad: 10, bottomPad: 7)

        numberCodeHolder.addSubview(codeWrapper)

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

        numberCodeHolder.snp.makeConstraints { numberCodeHolder in
            numberCodeHolder.center.equalToSuperview()
            numberCodeHolder.width.equalTo(self).offset(-40)
        }

        phoneWrapper.snp.makeConstraints { phoneWrapper in
            phoneWrapper.top.equalToSuperview().offset(TAP_PAD)
            phoneWrapper.leading.trailing.equalToSuperview()
        }

        phoneWarn.snp.makeConstraints { phoneWarn in
            phoneWarn.top.equalTo(phoneWrapper.snp.bottom).offset(3)
            phoneWarn.leading.equalToSuperview()
        }

        codeWrapper.snp.makeConstraints { codeWrapper in
            codeWrapper.top.equalTo(phoneWarn.snp.bottom).offset(12)
            codeWrapper.leading.trailing.equalToSuperview()
            codeWrapper.bottom.equalToSuperview()
        }

        self.phoneWarn.alpha = 0
        self.codeWrapper.alpha = 0

        look.apply(Style.restorePasswordPhoneView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension RestorePasswordPhoneView {

    func switchToPhoneInput() {
        self.phoneWrapper.textFieldBlocker.isShown = false
        self.phonePlaceholder.textColor = Palette.LoginView.text.color
        self.phoneWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phoneWarn.alpha = 0
            self.phonePlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToPhoneWarn(text: String) {
        self.phoneWarn.text = text

        self.phoneWrapper.textFieldBlocker.isShown = false
        self.phonePlaceholder.textColor = Palette.LoginView.text.color
        self.phoneWrapper.underline.backgroundColor = Palette.LoginView.warn.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phoneWarn.alpha = 1
            self.phonePlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToRelax() {
        self.phoneWrapper.textFieldBlocker.isShown = true
        self.phonePlaceholder.textColor = Palette.LoginView.placeholder.color
        self.phoneWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phoneWarn.alpha = 0
            self.phonePlaceholder.transform = self.phoneField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

}

extension RestorePasswordPhoneView {

    func moveUpComponentsByKeyboard(keyboardHeight: CGFloat, keyboardAnimDuration: TimeInterval) {
        let phoneTop = phoneWrapper.convert(CGPoint(x: 0, y: 0), to: self).y
        let desiredPhoneTop = self.bounds.height - (phoneWrapper.bounds.height + keyboardHeight + CGFloat(LOGIN_HEIGHT + LOGIN_BOTTOM_PAD) + 50)

        var holderTransform = phoneTop - desiredPhoneTop
        holderTransform = holderTransform > 0 ? holderTransform : 50

        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self, holderTransform, keyboardHeight] () in
            self.footerContainer.transform = CGAffineTransform(translationX: 0, y: -1 * keyboardHeight)

            let phoneTransform = CGAffineTransform(translationX: 0, y: -1 * holderTransform)
            self.phoneWrapper.transform = phoneTransform
            self.phoneWarn.transform = phoneTransform
        })
    }

    func moveDownComponentsByKeyboard(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { [unowned self] () in
            self.footerContainer.transform = CGAffineTransform.identity
            self.phoneWrapper.transform = CGAffineTransform.identity
            self.phoneWarn.transform = CGAffineTransform.identity
        })
    }

}

fileprivate extension Style {

    static var restorePasswordPhoneView: Change<RestorePasswordPhoneView> {
        return { (view: RestorePasswordPhoneView) -> Void in
            view.backgroundColor = Palette.LoginView.background.color
            view.tapBackground.backgroundColor = Palette.LoginView.background.color

            view.logo.look.apply(Style.logo)
            view.title.look.apply(Style.title)

            view.backButton.look.apply(Style.backButton)
            view.actionButton.look.apply(Style.actionButton)
            view.backButtonUnderline.backgroundColor = Palette.LoginView.text.color
            view.footerContainer.backgroundColor = Palette.LoginView.background.color

            view.phoneField.look.apply(Style.textField)
            view.phoneField.keyboardType = .numberPad
            view.phoneField.keyboardAppearance = .default
            view.phoneField.returnKeyType = .go

            view.phonePlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.phonePlaceholder.textColor = Palette.LoginView.placeholder.color
            view.phonePlaceholder.text = "Номер телефона"

            view.phoneWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.phoneWarn.textColor = Palette.LoginView.warn.color
            view.phoneWarn.text = "Это поле не должно быть пустым"

            view.phoneWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

            view.codeField.look.apply(Style.textField)
        }
    }

    static var textField: Change<UITextField> {
        return { (field: UITextField) -> Void in
            field.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            field.textColor = Palette.LoginView.text.color
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
            button.setTitle("ОТПРАВИТЬ КОД", for: .normal)
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

}
