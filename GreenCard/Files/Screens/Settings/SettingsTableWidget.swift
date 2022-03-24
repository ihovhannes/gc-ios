//
// Created by Hovhannes Sukiasian on 13/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit

class SettingsTableWidget: UIView {


    let push = SettingsTableCheckerItem.init()
    let email = SettingsTableCheckerItem()
    let sms = SettingsTableCheckerItem()

    let checkersStackView = UIStackView()

    let passwordWidget = SettingsTableChangePasswordWidget.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(checkersStackView)
        addSubview(passwordWidget)

        let height: Double = Consts.getTableHeaderHeight()
        let offset: Double = Consts.getTableHeaderOffset(withFilters: false)

        checkersStackView.snp.makeConstraints { checkersStackView in
            checkersStackView.top.equalToSuperview().offset(height - offset - 20)
            checkersStackView.leading.equalToSuperview().offset(28)
            checkersStackView.trailing.equalToSuperview().offset(-28)
        }

        checkersStackView.axis = .vertical
        checkersStackView.spacing = 30

        push.legend.text = "Уведомления"
        checkersStackView.addArrangedSubview(push)

        email.legend.text = "Рассылка"
        checkersStackView.addArrangedSubview(email)

        sms.legend.text = "SMS"
        checkersStackView.addArrangedSubview(sms)

        passwordWidget.snp.makeConstraints { passwordWidget in
            passwordWidget.top.equalTo(checkersStackView.snp.bottom).offset(30)
            passwordWidget.leading.trailing.bottom.equalToSuperview()
        }

        look.apply(Style.settingsTableWidget)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension Style {

    static var settingsTableWidget: Change<SettingsTableWidget> {
        return { (view: SettingsTableWidget ) in

        }
    }

    static var settingsTableCheckerItem: Change<SettingsTableCheckerItem> {
        return { (view: SettingsTableCheckerItem) in
            view.legend.textColor = Palette.SettingsView.legendLabel.color
            view.legend.font = UIFont(name: "ProximaNova-Semibold", size: 14)
        }
    }

    static var settingsTableChangePasswordWidget: Change<SettingsTableChangePasswordWidget> {
        return { (view: SettingsTableChangePasswordWidget) in
            view.container.backgroundColor = Palette.SettingsView.passwordWidgetBackground.color
            view.container.layer.cornerRadius = 5

            view.title.text = "Смена пароля"
            view.title.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.title.textColor = Palette.SettingsView.passwordWidgetTitle.color

            view.icon.image = UIImage(named: "change_pwd_icon")
            view.icon.contentMode = .scaleAspectFit

            view.newPassword.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.newPassword.textColor = Palette.SettingsView.passwordWidgetTextField.color
            view.newPassword.isSecureTextEntry = true
            view.newPassword.keyboardType = .alphabet
            view.newPassword.returnKeyType = .next
            view.newPassword.clearsOnBeginEditing = false

            view.newPasswordPlaceholder.text = "Введите новый пароль"
            view.newPasswordPlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color

            view.newPasswordWarn.text = "Это поле не должно быть пустым"
            view.newPasswordWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.newPasswordWarn.textColor = Palette.SettingsView.passwordWidgetLabelWarn.color

            view.newPasswordRepeat.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.newPasswordRepeat.textColor = Palette.SettingsView.passwordWidgetTextField.color
            view.newPasswordRepeat.isSecureTextEntry = true
            view.newPasswordRepeat.keyboardType = .alphabet
            view.newPasswordRepeat.returnKeyType = .send
            view.newPasswordRepeat.clearsOnBeginEditing = false

            view.newPasswordRepeatPlaceholder.text = "Подтвердите новый пароль"
            view.newPasswordRepeatPlaceholder.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color

            view.newPasswordRepeatWarn.text = "Пароли не совпадают"
            view.newPasswordRepeatWarn.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.newPasswordRepeatWarn.textColor = Palette.SettingsView.passwordWidgetLabelWarn.color

            view.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color
            view.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

            view.saveButton.text = "СОХРАНИТЬ"
            view.saveButton.font = UIFont(name: "ProximaNova-Bold", size: 9)
            view.saveButton.textColor = Palette.SettingsView.passwordWidgetSaveButton.color

            view.cancelButton.text = "ОТМЕНИТЬ"
            view.cancelButton.font = UIFont(name: "ProximaNova-Bold", size: 9)
            view.cancelButton.textColor = Palette.SettingsView.passwordWidgetCancelButton.color
        }
    }

}

// -- Checkers

class SettingsTableCheckerItem: UIView {

    let legend = UILabel()
    let checker = SettingsCheckerWidget.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(legend)
        addSubview(checker)

        legend.snp.makeConstraints { legend in
            legend.leading.equalToSuperview()
            legend.centerY.equalToSuperview()
        }

        checker.snp.makeConstraints { checker in
            checker.trailing.equalToSuperview()
            checker.top.bottom.equalToSuperview()
        }

        look.apply(Style.settingsTableCheckerItem)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// -- Password

class SettingsTableChangePasswordWidget: UIView {

    let container = UIView()

    let title = UILabel()
    let icon = UIImageView()

    let newPassword = UITextField()
    let newPasswordPlaceholder = UILabel()
    let newPasswordStack = UIStackView()
    let newPasswordUnderline = UIView()
    let newPasswordWarn = UILabel()

    let newPasswordRepeat = UITextField.init()
    let newPasswordRepeatPlaceholder = UILabel()
    let newPasswordRepeatStack = UIStackView()
    let newPasswordRepeatUnderline = UIView()
    let newPasswordRepeatWarn = UILabel()

    let saveButton = UILabel()
    let cancelButton = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        newPasswordStack.axis = .vertical
        newPasswordStack.spacing = 8
        newPasswordRepeatStack.axis = .vertical
        newPasswordRepeatStack.spacing = 8

        newPasswordWarn.isShown = false
        newPasswordRepeatWarn.isShown = false

        addSubview(container)

        container.addSubview(title)
        container.addSubview(icon)

        container.addSubview(newPasswordPlaceholder)
        container.addSubview(newPassword)
        container.addSubview(newPasswordStack)
        newPasswordStack.addArrangedSubview(newPasswordUnderline)
        newPasswordStack.addArrangedSubview(newPasswordWarn)

        container.addSubview(newPasswordRepeatPlaceholder)
        container.addSubview(newPasswordRepeat)
        container.addSubview(newPasswordRepeatStack)
        newPasswordRepeatStack.addArrangedSubview(newPasswordRepeatUnderline)
        newPasswordRepeatStack.addArrangedSubview(newPasswordRepeatWarn)

        container.addSubview(saveButton)
        container.addSubview(cancelButton)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        }

        title.snp.makeConstraints { title in
            title.leading.equalToSuperview().offset(42)
            title.top.equalToSuperview().offset(28)
        }

        icon.snp.makeConstraints { icon in
            icon.height.equalTo(2.5)
            icon.width.equalTo(15)
            icon.trailing.equalToSuperview().offset(-28)
            icon.centerY.equalTo(title.snp.centerY)
        }

        newPassword.snp.makeConstraints { newPassword in
            newPassword.top.equalTo(title.snp.bottom).offset(50)
            newPassword.leading.equalToSuperview().offset(42)
            newPassword.trailing.equalToSuperview().offset(-42)
        }

        newPasswordPlaceholder.snp.makeConstraints { newPasswordPlaceholder in
            newPasswordPlaceholder.edges.equalTo(newPassword.snp.edges)
        }

        newPasswordUnderline.snp.makeConstraints { newPasswordUnderline in
            newPasswordUnderline.height.equalTo(1)
        }

        newPasswordStack.snp.makeConstraints { newPasswordStack in
            newPasswordStack.leading.equalTo(newPassword.snp.leading)
            newPasswordStack.top.equalTo(newPassword.snp.bottom).offset(8)
            newPasswordStack.trailing.equalTo(newPassword.snp.trailing)
        }

        newPasswordRepeat.snp.makeConstraints { newPasswordRepeat in
            newPasswordRepeat.top.equalTo(newPasswordUnderline.snp.bottom).offset(50)
            newPasswordRepeat.leading.equalTo(newPassword.snp.leading)
            newPasswordRepeat.trailing.equalTo(newPassword.snp.trailing)
        }

        newPasswordRepeatPlaceholder.snp.makeConstraints { newPasswordRepeatPlaceholder in
            newPasswordRepeatPlaceholder.edges.equalTo(newPasswordRepeat.snp.edges)
        }

        newPasswordRepeatUnderline.snp.makeConstraints { newPasswordRepeatUnderline in
            newPasswordRepeatUnderline.height.equalTo(1)
        }

        newPasswordRepeatStack.snp.makeConstraints { newPasswordRepeatStack in
            newPasswordRepeatStack.top.equalTo(newPasswordRepeat.snp.bottom).offset(8)
            newPasswordRepeatStack.leading.equalTo(newPassword.snp.leading)
            newPasswordRepeatStack.trailing.equalTo(newPassword.snp.trailing)
        }

        saveButton.snp.makeConstraints { saveButton in
            saveButton.top.equalTo(newPasswordRepeatUnderline.snp.bottom).offset(50)
            saveButton.leading.equalToSuperview().offset(28)
            saveButton.bottom.equalToSuperview().offset(-28)
        }

        cancelButton.snp.makeConstraints { cancelButton in
            cancelButton.trailing.equalToSuperview().offset(-28)
            cancelButton.firstBaseline.equalTo(saveButton.snp.firstBaseline)
        }

        look.apply(Style.settingsTableChangePasswordWidget)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

 // -- Widget states

extension SettingsTableChangePasswordWidget {

    func switchToNewPasswordInput() {
        self.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextFieldInput.color
        self.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderlineInput.color

        self.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordWarn.isShown = false
        self.newPasswordRepeatWarn.isShown = false

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.newPasswordPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            if self.newPasswordRepeat.text.isEmpty() {
                self.newPasswordRepeatPlaceholder.transform = CGAffineTransform.identity
            }
            self.layoutIfNeeded()
        })
    }

    func switchToNewPasswordRepeatInput() {
        self.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextFieldInput.color
        self.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderlineInput.color

        self.newPasswordWarn.isShown = false
        self.newPasswordRepeatWarn.isShown = false

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.newPasswordRepeatPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            if self.newPassword.text.isEmpty() {
                self.newPasswordPlaceholder.transform = CGAffineTransform.identity
            }
            self.layoutIfNeeded()
        })
    }

    func resetState() {
        self.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordWarn.isShown = false
        self.newPasswordRepeatWarn.isShown = false

        self.newPassword.text = ""
        self.newPasswordRepeat.text = ""

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.newPasswordRepeatPlaceholder.transform = CGAffineTransform.identity
            self.newPasswordPlaceholder.transform = CGAffineTransform.identity
            self.layoutIfNeeded()
        })
    }

    func switchToNewPasswordWarn(text: String) {
        self.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextFieldInput.color
        self.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderlineWarn.color

        self.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordWarn.text = text
        self.newPasswordWarn.isShown = true
        self.newPasswordRepeatWarn.isShown = false

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.newPasswordPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            if self.newPasswordRepeat.text.isEmpty() {
                self.newPasswordRepeatPlaceholder.transform = CGAffineTransform.identity
            } else {
                self.newPasswordRepeatPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            }
            self.layoutIfNeeded()
        })
    }

    func switchToNewPasswordRepeatWarn() {
        self.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextFieldInput.color
        self.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderlineWarn.color

        self.newPasswordWarn.isShown = false
        self.newPasswordRepeatWarn.isShown = true

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            if self.newPassword.text.isEmpty() {
                self.newPasswordPlaceholder.transform = CGAffineTransform.identity
            } else {
                self.newPasswordPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            }

            self.newPasswordRepeatPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            self.layoutIfNeeded()
        })
    }

    func switchToWaitingMode() {
        self.newPasswordPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordRepeatPlaceholder.textColor = Palette.SettingsView.passwordWidgetTextField.color
        self.newPasswordRepeatUnderline.backgroundColor = Palette.SettingsView.passwordWidgetUnderline.color

        self.newPasswordWarn.isShown = false
        self.newPasswordRepeatWarn.isShown = false

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            if self.newPassword.text.isEmpty() {
                self.newPasswordPlaceholder.transform = CGAffineTransform.identity
            } else {
                self.newPasswordPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            }
            if self.newPasswordRepeat.text.isEmpty() {
                self.newPasswordRepeatPlaceholder.transform = CGAffineTransform.identity
            } else {
                self.newPasswordRepeatPlaceholder.transform = CGAffineTransform(translationX: 0, y: -20)
            }
            self.layoutIfNeeded()
        })
    }

}
