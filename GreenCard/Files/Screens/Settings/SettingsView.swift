//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import Lottie

class SettingsView: UIView, DisposeBagProvider {

    fileprivate let settingsAnim = LOTAnimationView(name: "settings")
    fileprivate let settingsAnimHolder = UIView()

    lazy var title = UILabel()
    lazy var tableWidget = SettingsTableWidget.init()

    lazy var scrollView = UIScrollView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(settingsAnimHolder)
        settingsAnimHolder.addSubview(settingsAnim)
        addSubview(title)

        addSubview(scrollView)
        scrollView.addSubview(tableWidget)

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-18)
        }

//        settingsAnimHolder.backgroundColor = .black
        settingsAnim.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        settingsAnim.contentMode = .scaleAspectFill
        settingsAnim.clipsToBounds = false

        let height: Double = Consts.getTableHeaderHeight() / 2
        settingsAnimHolder.snp.makeConstraints { percentHolder in
            percentHolder.width.equalTo(100)
            percentHolder.height.equalTo(100)
            percentHolder.centerX.equalToSuperview()
            percentHolder.centerY.equalTo(self.snp.top).offset(height * 0.88)
        }

        scrollView.snp.makeConstraints { scrollView in
            scrollView.top.left.equalToSuperview()
            scrollView.width.equalToSuperview()
            scrollView.height.equalToSuperview()
        }

        tableWidget.snp.makeConstraints { tableWidget in
            tableWidget.edges.equalToSuperview()
            tableWidget.width.equalToSuperview()
        }

        scrollView.delegate = self
        scrollView.keyboardDismissMode = .onDrag

        settingsAnimHolder.isShown = false
        scrollView.isShown = false

        look.apply(Style.settingsView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SettingsView {

    var newPassword: UITextField {
        return tableWidget.passwordWidget.newPassword
    }

    var newPasswordRepeat: UITextField {
        return tableWidget.passwordWidget.newPasswordRepeat
    }

    var saveButton: UILabel {
        return tableWidget.passwordWidget.saveButton
    }

    var cancelButton: UILabel {
        return tableWidget.passwordWidget.cancelButton
    }

    func switchToNewPasswordInput() {
        tableWidget.passwordWidget.switchToNewPasswordInput()
    }

    func switchToNewPasswordRepeatInput() {
        tableWidget.passwordWidget.switchToNewPasswordRepeatInput()
    }

    func switchToNewPasswordWarn(text: String) {
        tableWidget.passwordWidget.switchToNewPasswordWarn(text: text)
    }

    func switchToNewPasswordRepeatWarn(){
        tableWidget.passwordWidget.switchToNewPasswordRepeatWarn()
    }

    func switchToWaitingMode() {
        tableWidget.passwordWidget.switchToWaitingMode()
    }

    func resetState() {
        tableWidget.passwordWidget.resetState()
    }

}

extension SettingsView {

    var pushChecker: SettingsCheckerWidget {
        return tableWidget.push.checker
    }

    var emailChecker: SettingsCheckerWidget {
        return tableWidget.email.checker
    }

    var smsChecker: SettingsCheckerWidget {
        return tableWidget.sms.checker
    }

}

extension SettingsView {

    func getKeyboardOffset(field: UITextField) -> CGFloat {
        let inWidgetPosition = field.convert(CGPoint(x: 0, y: 0), to: tableWidget).y
        let offset = tableWidget.frame.size.height - inWidgetPosition
        return offset
    }

}

extension SettingsView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        settingsAnimHolder.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY, y: 0)
        title.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
    }

}

extension SettingsView {

    func initCheckers(push: Bool, sms: Bool, email: Bool) {
        pushChecker.turnIt(isOn: push)
        smsChecker.turnIt(isOn: sms)
        emailChecker.turnIt(isOn: email)
    }

    func animateOnInit() {
        settingsAnimHolder.isShown = true
        settingsAnim.play(completion: { [weak self] finished in
            if finished {
                self?.animateTable()
            }
        })
    }

    func animateTable() {
        self.scrollView.isShown = true
        self.scrollView.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned self] () in
            self.scrollView.transform = CGAffineTransform.identity
        })
    }

}

fileprivate extension Style {

    static var settingsView: Change<SettingsView> {
        return { (view: SettingsView) -> Void in
            view.backgroundColor = Palette.NotificationsView.background.color

            view.title.text = "НАСТРОЙКИ"
            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)

            view.scrollView.showsScrollIndicator = false
        }
    }

}
