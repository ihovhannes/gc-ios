//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class RestorePasswordConfirmView : UIView {

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

    lazy var fieldsHolder = UIView()

    lazy var passwordWrapper = TextWrapper()
    lazy var passwordPlaceholder = UILabel()
    lazy var passwordField = UITextField()
    lazy var passwordWarn = UILabel()

    lazy var confirmWrapper = TextWrapper()
    lazy var confirmPlaceholder = UILabel()
    lazy var confirmField = UITextField()
    lazy var confirmWarn = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tapBackground)

        tapBackground.addSubview(logo)
        tapBackground.addSubview(title)

        addSubview(footerContainer)

        footerContainer.addSubview(actionButton)
        footerContainer.addSubview(backButton)
        footerContainer.addSubview(backButtonUnderline)

        passwordWrapper = TextWrapper()
                .add(text: passwordField, topPad: 10)
                .add(placeholder: passwordPlaceholder)

        fieldsHolder.addSubview(passwordWrapper)
        fieldsHolder.addSubview(passwordWarn)

        confirmWrapper = TextWrapper()
                .add(text: confirmField, topPad: 10, bottomPad: 7)
                .add(placeholder: confirmPlaceholder)

        fieldsHolder.addSubview(confirmWrapper)
        fieldsHolder.addSubview(confirmWarn)

        addSubview(fieldsHolder)

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

        fieldsHolder.snp.makeConstraints { phonePasswordHolder in
            phonePasswordHolder.center.equalToSuperview()
            phonePasswordHolder.width.equalTo(self).offset(-40)
        }

        passwordWrapper.snp.makeConstraints { passwordWrapper in
            passwordWrapper.top.equalToSuperview().offset(TAP_PAD)
            passwordWrapper.left.right.equalToSuperview()
        }

        passwordWarn.snp.makeConstraints { passwordWarn in
            passwordWarn.top.equalTo(passwordWrapper.snp.bottom)
            passwordWarn.left.equalToSuperview()
        }

        confirmWrapper.snp.makeConstraints { confirmWrapper in
            confirmWrapper.top.equalTo(passwordWarn.snp.bottom).offset(15)
            confirmWrapper.left.right.equalToSuperview()
            confirmWrapper.bottom.equalToSuperview()
        }

        confirmWarn.snp.makeConstraints { confirmWarn in
            confirmWarn.top.equalTo(confirmWrapper.snp.bottom).offset(5)
            confirmWarn.left.equalToSuperview()
        }

        passwordWarn.alpha = 0
        confirmWarn.alpha = 0

        look.apply(Style.restorePasswordConfirmView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension RestorePasswordConfirmView {


    func moveUpComponentsByKeyboard(keyboardHeight: CGFloat, keyboardAnimDuration: TimeInterval) {
        let fieldsHolderTop = fieldsHolder.convert(CGPoint(x: 0, y: 0), to: self).y
        let desiredFieldsHolderTop = self.bounds.height - (fieldsHolder.bounds.height + keyboardHeight + CGFloat(LOGIN_HEIGHT + LOGIN_BOTTOM_PAD) + 50)

        var holderTransform = fieldsHolderTop - desiredFieldsHolderTop
        holderTransform = holderTransform > 0 ? holderTransform : 50

        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self, holderTransform] () in
            let keyboardTransform = CGAffineTransform(translationX: 0, y: -1 * keyboardHeight)
            self.footerContainer.transform = keyboardTransform

            let phonePasswordTransform = CGAffineTransform(translationX: 0, y: -1 * holderTransform)
            self.fieldsHolder.transform = phonePasswordTransform
        })
    }

    func moveDownComponentsByKeyboard(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: { [unowned self] () in
            self.footerContainer.transform  = CGAffineTransform.identity
            self.fieldsHolder.transform = CGAffineTransform.identity
        })
    }

}

extension RestorePasswordConfirmView {

    func switchToPasswordInput() {
        self.passwordWrapper.textFieldBlocker.isHidden = true
        self.confirmWrapper.textFieldBlocker.isHidden = false

        self.passwordPlaceholder.textColor = Palette.LoginView.text.color
        self.passwordWrapper.underline.backgroundColor = Palette.LoginView.highlight.color
        self.confirmPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.confirmWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.passwordWarn.alpha = 0
            self.confirmWarn.alpha = 0
            self.passwordPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.passwordWrapper.underline.transform = CGAffineTransform.identity
            self.confirmPlaceholder.transform = self.confirmField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToConfirmInput() {
        self.passwordWrapper.textFieldBlocker.isHidden = false
        self.confirmWrapper.textFieldBlocker.isHidden = true

        self.passwordPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.passwordWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.confirmPlaceholder.textColor = Palette.LoginView.text.color
        self.confirmWrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.passwordWarn.alpha = 0
            self.confirmWarn.alpha = 0
            self.passwordPlaceholder.transform = self.passwordField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.passwordWrapper.transform = CGAffineTransform.identity
            self.confirmPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToPasswordWarn(text: String) {
        self.passwordWrapper.textFieldBlocker.isHidden = true
        self.confirmWrapper.textFieldBlocker.isHidden = false

        self.passwordWarn.text = text
        self.passwordPlaceholder.textColor = Palette.LoginView.text.color
        self.passwordWrapper.underline.backgroundColor = Palette.LoginView.warn.color
        self.confirmPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.confirmWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.passwordWarn.alpha = 1
            self.confirmWarn.alpha = 0
            self.passwordPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.passwordWrapper.transform = CGAffineTransform(translationX: 0, y: -4)
            self.confirmPlaceholder.transform = self.confirmField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToConfirmWarn(text: String) {
        self.passwordWrapper.textFieldBlocker.isHidden = false
        self.confirmWrapper.textFieldBlocker.isHidden = true

        self.confirmWarn.text = text
        self.passwordPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.passwordWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.confirmPlaceholder.textColor = Palette.LoginView.text.color
        self.confirmWrapper.underline.backgroundColor = Palette.LoginView.warn.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.passwordWarn.alpha = 0
            self.confirmWarn.alpha = 1
            self.passwordPlaceholder.transform = self.passwordField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.passwordWrapper.transform = CGAffineTransform.identity
            self.confirmPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func resetFieldsState() {
        self.passwordWrapper.textFieldBlocker.isHidden = false
        self.confirmWrapper.textFieldBlocker.isHidden = false

        self.passwordPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.passwordWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.confirmPlaceholder.textColor = Palette.LoginView.placeholder.color
        self.confirmWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.passwordWarn.alpha = 0
            self.confirmWarn.alpha = 0
            self.passwordPlaceholder.transform = self.passwordField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.passwordWrapper.transform = CGAffineTransform.identity
            self.confirmPlaceholder.transform = self.confirmField.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

}

fileprivate extension Style {

    static var restorePasswordConfirmView: Change<RestorePasswordConfirmView> {
        return { (view: RestorePasswordConfirmView) -> Void in
            view.backgroundColor = Palette.LoginView.background.color
            view.tapBackground.backgroundColor = Palette.LoginView.background.color

            view.logo.look.apply(Style.logo)
            view.title.look.apply(Style.title)

            view.backButton.look.apply(Style.backButton)
            view.actionButton.look.apply(Style.actionButton)
            view.backButtonUnderline.backgroundColor = Palette.LoginView.text.color
            view.footerContainer.backgroundColor = Palette.LoginView.background.color

            view.passwordField.look.apply(Style.textField)
            view.passwordField.isSecureTextEntry = true
            view.passwordField.keyboardType = .default
            view.passwordField.returnKeyType = .next

            view.confirmField.look.apply(Style.textField)
            view.confirmField.isSecureTextEntry = true
            view.confirmField.keyboardType = .default
            view.confirmField.returnKeyType = .go

            view.passwordPlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.passwordPlaceholder.textColor = Palette.LoginView.placeholder.color
            view.passwordPlaceholder.text = "Новый пароль"

            view.passwordWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.passwordWarn.textColor = Palette.LoginView.warn.color
            view.passwordWarn.text = "Это поле не должно быть пустым"

            view.passwordWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

            view.confirmPlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.confirmPlaceholder.textColor = Palette.LoginView.placeholder.color
            view.confirmPlaceholder.text = "Подтвердите пароль"

            view.confirmWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.confirmWarn.textColor = Palette.LoginView.warn.color
            view.confirmWarn.text = "Это поле не должно быть пустым"

            view.confirmWrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
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
            button.setTitle("СОХРАНИТЬ ПАРОЛЬ", for: .normal)
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
