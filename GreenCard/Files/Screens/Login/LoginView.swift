//
//  LoginView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Look
import RxSwift
import InputMask

class LoginView: UIView, LoginAnimatedView {

    let LOGIN_HEIGHT = 45
    let LOGIN_BOTTOM_PAD = 24
    let TAP_PAD = 20

    lazy var logoAndTitleHolder = UIView()
    lazy var logo = UIImageView()
    lazy var title = UILabel()

    lazy var tapBackground = UIView()

    lazy var phonePasswordHolder = UIView()

    lazy var phone1Wrapper = TextWrapper()
    lazy var phone1Placeholder = UILabel()
    lazy var phone1Field = UITextField()
    lazy var phone1Warn = UILabel()

    lazy var password1Wrapper = TextWrapper()
    lazy var password1Placeholder = UILabel()
    lazy var password1Field = UITextField()
    lazy var password1Warn = UILabel()

    lazy var forgotPassword = UIButton(type: .custom)
    lazy var registration = UIButton(type: .custom)
    lazy var registrationUnderline = UIView()
    lazy var login = UIButton(type: .custom)

    lazy var phoneText = Variable<String?>(nil)

    fileprivate var isKeyboardMode: Bool = false

    var background: UIView {
        return self
    }

    init() {
        super.init(frame: .zero)

        logoAndTitleHolder.addSubview(logo)
        logoAndTitleHolder.addSubview(title)

        addSubview(logoAndTitleHolder)

        addSubview(tapBackground)

        phone1Wrapper = TextWrapper()
                .add(text: phone1Field, topPad: 10)
                .add(placeholder: phone1Placeholder)

        phonePasswordHolder.addSubview(phone1Wrapper)
        phonePasswordHolder.addSubview(phone1Warn)

        password1Wrapper = TextWrapper()
                .add(text: password1Field, topPad: 10, bottomPad: 7)
                .add(placeholder: password1Placeholder)

        phonePasswordHolder.addSubview(password1Wrapper)
        phonePasswordHolder.addSubview(password1Warn)

        addSubview(phonePasswordHolder)

        addSubview(forgotPassword)
        addSubview(registrationUnderline)
        addSubview(registration)
        addSubview(login)

        phone1Warn.alpha = 0
        password1Warn.alpha = 0

        phonePasswordHolder.alpha = 0

        layout()

        look.apply(Style.loginStyle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func layout() {
        logoAndTitleHolder.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }

        logo.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
            maker.width.height.equalTo(37)
        }

        title.snp.makeConstraints { maker in
            maker.top.right.bottom.equalToSuperview()
            maker.left.equalTo(logo.snp.right).offset(8)
        }

//        logo.snp.makeConstraints { logo in
//            logo.left.equalToSuperview().offset(17)
//            logo.top.equalToSuperview().offset(6)
//        }
//
//        title.snp.makeConstraints { title in
//            title.top.equalToSuperview().offset(16)
//            title.right.equalToSuperview().offset(-18)
//        }

        tapBackground.snp.makeConstraints { tapBackground in
            tapBackground.edges.equalToSuperview()
        }

        phonePasswordHolder.snp.makeConstraints { phonePasswordHolder in
            phonePasswordHolder.center.equalToSuperview()
            phonePasswordHolder.width.equalTo(self).offset(-40)
        }

        phone1Wrapper.snp.makeConstraints { phone1Wrapper in
            phone1Wrapper.top.equalToSuperview().offset(TAP_PAD)
            phone1Wrapper.left.right.equalToSuperview()
        }

        phone1Warn.snp.makeConstraints { phone1Warn in
            phone1Warn.top.equalTo(phone1Wrapper.snp.bottom)
            phone1Warn.left.equalToSuperview()
        }

        password1Wrapper.snp.makeConstraints { password1Wrapper in
            password1Wrapper.top.equalTo(phone1Warn.snp.bottom).offset(15)
            password1Wrapper.left.right.equalToSuperview()
            password1Wrapper.bottom.equalToSuperview()
        }

        password1Warn.snp.makeConstraints { password1Warn in
            password1Warn.top.equalTo(password1Wrapper.snp.bottom).offset(5)
            password1Warn.left.equalToSuperview()
        }

        login.snp.makeConstraints { login in
            login.left.equalToSuperview().offset(20)
            login.bottom.equalToSuperview().offset(-1 * LOGIN_BOTTOM_PAD)
            login.width.equalTo(168)
            login.height.equalTo(LOGIN_HEIGHT)
        }

        registration.snp.makeConstraints { registration in
            registration.height.equalTo(LOGIN_HEIGHT)
            registration.centerY.equalTo(login.snp.centerY)
            registration.right.equalToSuperview().offset(-22)
        }

        registrationUnderline.snp.makeConstraints { registrationUnderline in
            registrationUnderline.right.equalToSuperview().offset(-22)
            registrationUnderline.bottom.equalToSuperview().offset(-30)
            registrationUnderline.width.equalTo(34)
            registrationUnderline.height.equalTo(2)
        }

        forgotPassword.snp.makeConstraints { forgotPassword in
            forgotPassword.top.equalTo(phonePasswordHolder.snp.bottom).offset(-1)
            forgotPassword.right.equalToSuperview().offset(-20)
        }

    }

    deinit {
        debugPrint("deinit \(#file)+\(#line)")
    }
}

extension LoginView {

    func setLogoAndTitle(_ withAnim: Bool) {
        logoAndTitleHolder.snp.remakeConstraints { maker in
            maker.top.left.right.equalToSuperview()
        }

        logo.snp.remakeConstraints { logo in
            logo.left.equalToSuperview().offset(20)
            logo.top.equalToSuperview().offset(16)
            logo.width.height.equalTo(37)
        }

        title.snp.remakeConstraints { title in
            title.top.equalToSuperview().offset(16)
            title.right.equalToSuperview().offset(-18)
        }

        self.look.apply(Style.loginAnimatedStyle)

        if withAnim {
            UIView.animate(withDuration: 0.2, animations: setLogoAndTitleCompletion)
        } else {
            setLogoAndTitleCompletion()
        }
    }

    func setLogoAndTitleCompletion() {
        self.phonePasswordHolder.alpha = 1
        self.layoutIfNeeded()
    }

}

extension LoginView {

    func moveUpComponentsByKeyboard(keyboardHeight: CGFloat, keyboardAnimDuration: TimeInterval) {
        if isKeyboardMode {
            return
        }
        defer {
            isKeyboardMode = true
        }

        let phonePasswordHolderTop = phonePasswordHolder.convert(CGPoint(x: 0, y: 0), to: self).y
        let desiredPhonePasswordHolderTop = self.bounds.height - (phonePasswordHolder.bounds.height + keyboardHeight + CGFloat(LOGIN_HEIGHT + LOGIN_BOTTOM_PAD) + 50)

        var holderTransform = phonePasswordHolderTop - desiredPhonePasswordHolderTop
        holderTransform = holderTransform > 0 ? holderTransform : 50

        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self, holderTransform] () in
            let keyboardTransform = CGAffineTransform(translationX: 0, y: -1 * keyboardHeight)
            self.login.transform = keyboardTransform
            self.registration.transform = keyboardTransform
            self.registrationUnderline.transform = keyboardTransform

            let phonePasswordTransform = CGAffineTransform(translationX: 0, y: -1 * holderTransform)
            self.phonePasswordHolder.transform = phonePasswordTransform
            self.forgotPassword.transform = phonePasswordTransform
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
            self.phonePasswordHolder.transform = CGAffineTransform.identity
            self.forgotPassword.transform = CGAffineTransform.identity
            self.login.transform = CGAffineTransform.identity
            self.registration.transform = CGAffineTransform.identity
            self.registrationUnderline.transform = CGAffineTransform.identity
        })
    }

}

extension LoginView {

    func switchToPhoneInput() {
        self.phone1Wrapper.textFieldBlocker.isHidden = true
        self.password1Wrapper.textFieldBlocker.isHidden = false

        self.phone1Placeholder.textColor = Palette.LoginView.text.color
        self.phone1Wrapper.underline.backgroundColor = Palette.LoginView.highlight.color
        self.password1Placeholder.textColor = Palette.LoginView.placeholder.color
        self.password1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phone1Warn.alpha = 0
            self.password1Warn.alpha = 0
            self.phone1Placeholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.phone1Wrapper.underline.transform = CGAffineTransform.identity
            self.password1Placeholder.transform = self.password1Field.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToPasswordInput() {
        self.phone1Wrapper.textFieldBlocker.isHidden = false
        self.password1Wrapper.textFieldBlocker.isHidden = true

        self.phone1Placeholder.textColor = Palette.LoginView.placeholder.color
        self.phone1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.password1Placeholder.textColor = Palette.LoginView.text.color
        self.password1Wrapper.underline.backgroundColor = Palette.LoginView.highlight.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phone1Warn.alpha = 0
            self.password1Warn.alpha = 0
            self.phone1Placeholder.transform = self.phone1Field.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.phone1Wrapper.transform = CGAffineTransform.identity
            self.password1Placeholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToPhoneWarn(text: String) {
        self.phone1Wrapper.textFieldBlocker.isHidden = true
        self.password1Wrapper.textFieldBlocker.isHidden = false

        self.phone1Warn.text = text
        self.phone1Placeholder.textColor = Palette.LoginView.text.color
        self.phone1Wrapper.underline.backgroundColor = Palette.LoginView.warn.color
        self.password1Placeholder.textColor = Palette.LoginView.placeholder.color
        self.password1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phone1Warn.alpha = 1
            self.password1Warn.alpha = 0
            self.phone1Placeholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.phone1Wrapper.transform = CGAffineTransform(translationX: 0, y: -4)
            self.password1Placeholder.transform = self.password1Field.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func switchToPasswordWarn() {
        self.phone1Wrapper.textFieldBlocker.isHidden = false
        self.password1Wrapper.textFieldBlocker.isHidden = true

        self.phone1Placeholder.textColor = Palette.LoginView.placeholder.color
        self.phone1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.password1Placeholder.textColor = Palette.LoginView.text.color
        self.password1Wrapper.underline.backgroundColor = Palette.LoginView.warn.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phone1Warn.alpha = 0
            self.password1Warn.alpha = 1
            self.phone1Placeholder.transform = self.phone1Field.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.phone1Wrapper.transform = CGAffineTransform.identity
            self.password1Placeholder.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func resetPhonePasswordState() {
        self.phone1Wrapper.textFieldBlocker.isHidden = false
        self.password1Wrapper.textFieldBlocker.isHidden = false

        self.phone1Placeholder.textColor = Palette.LoginView.placeholder.color
        self.phone1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color
        self.password1Placeholder.textColor = Palette.LoginView.placeholder.color
        self.password1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.phone1Warn.alpha = 0
            self.password1Warn.alpha = 0
            self.phone1Placeholder.transform = self.phone1Field.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
            self.phone1Wrapper.transform = CGAffineTransform.identity
            self.password1Placeholder.transform = self.password1Field.text.isEmpty() ?
                    CGAffineTransform.identity :
                    CGAffineTransform(translationX: 0, y: -20)
        })
    }

}

fileprivate extension Style {
    static var loginStyle: Change<LoginView> {
        return { (view: LoginView) -> Void in
            view.backgroundColor = Palette.LoginView.background.color

            view.logo.look.apply(Style.logo)
            view.title.look.apply(Style.title)

            view.phone1Field.look.apply(Style.textField)
            view.phone1Field.keyboardType = .phonePad
            view.phone1Field.keyboardAppearance = .default
            view.phone1Field.returnKeyType = .next

            view.password1Field.look.apply(Style.textField)
            view.password1Field.isSecureTextEntry = true
            view.password1Field.keyboardType = .default
            view.password1Field.returnKeyType = .go

            view.phone1Placeholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.phone1Placeholder.textColor = Palette.LoginView.placeholder.color
            view.phone1Placeholder.text = "Номер телефона"

            view.phone1Warn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.phone1Warn.textColor = Palette.LoginView.warn.color
            view.phone1Warn.text = "Это поле не должно быть пустым"

            view.phone1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

            view.password1Placeholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.password1Placeholder.textColor = Palette.LoginView.placeholder.color
            view.password1Placeholder.text = "Пароль"

            view.password1Warn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.password1Warn.textColor = Palette.LoginView.warn.color
            view.password1Warn.text = "Это поле не должно быть пустым"

            view.password1Wrapper.underline.backgroundColor = Palette.LoginView.placeholder.color

            view.forgotPassword.look.apply(Style.forgotPassword)

            view.registration.look.apply(Style.registration)
            view.login.look.apply(Style.login)
            view.registrationUnderline.backgroundColor = Palette.LoginView.text.color
        }
    }

    static var login: Change<UIButton> {
        return { (button: UIButton) -> Void in
            button.setTitle("ВОЙТИ", for: .normal)
            button.backgroundColor = Palette.LoginView.highlight.color
            button.setTitleColor(Palette.LoginView.text.color, for: .normal)
            button.layer.cornerRadius = 22.5
            button.layer.masksToBounds = true
            button.titleLabel?.font = UIFont(name: "ProximaNova-Bold", size: 9)
        }
    }

    static var registration: Change<UIButton> {
        return { (button: UIButton) -> Void in
            button.backgroundColor = Palette.Common.transparentBackground.color
            button.contentHorizontalAlignment = .right
            button.contentVerticalAlignment = .top
            button.setTitleColor(Palette.LoginView.text.color, for: .normal)
            button.setTitle("ОН-ЛАЙН\nРЕГИСТРАЦИЯ", for: .normal)
            button.titleLabel?.font = UIFont(name: "ProximaNova-Bold", size: 9)
            button.titleLabel?.textAlignment = .right
            button.titleLabel?.numberOfLines = 2
        }
    }

    static var forgotPassword: Change<UIButton> {
        return { (button: UIButton) -> Void in
            button.contentHorizontalAlignment = .right
            button.setTitleColor(Palette.LoginView.text.color, for: .normal)
            button.setTitle("Забыли пароль?", for: .normal)
            button.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 10)
            button.titleLabel?.textAlignment = .right
            button.titleLabel?.numberOfLines = 1
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
            label.textAlignment = .left
            label.numberOfLines = 2
            label.textColor = Palette.LoginView.text.color
        }
    }

    static var activeSeparator: Change<UIView> {
        return { (view: UIView) -> Void in
            view.backgroundColor = Palette.LoginView.highlight.color
        }
    }

    static var inactiveSeparator: Change<UIView> {
        return { (view: UIView) -> Void in
            view.backgroundColor = Palette.LoginView.placeholder.color
        }
    }
}

//extension Reactive where Base == LoginView {
//    internal var didTapLoginButton: Observable<(String?, String?)> {
//        get {
//            let phone = base.phoneText.asObservable()
//            let password = base.password.rx.text.asObservable()
//            return base.login.rx.tap.asObservable()
//                    .flatMapLatest({ (_) -> Observable<(String?, String?)> in
//                        return Observable.combineLatest(phone, password, resultSelector: { ($0, $1) })
//                                .take(1)
//                    })
//        }
//    }
//}
