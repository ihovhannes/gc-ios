//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture

class RestorePasswordSmsViewController: UIViewController, DisposeBagProvider {

    fileprivate var restorePasswordSmsView: RestorePasswordSmsView {
        return view as? RestorePasswordSmsView ?? RestorePasswordSmsView()
    }

    fileprivate var viewModel: RestorePasswordSmsViewModel!

    fileprivate weak var activeField: UITextField? = nil
    var lastKeyboardHeight: CGFloat = 0

    var phoneNumber: String = ""

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RestorePasswordSmsView()
        viewModel = RestorePasswordSmsViewModel()
        type = .restorePasswordSms

        // -- Navigation

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Buttons

        restorePasswordSmsView
                .actionButton
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onActionButtonTap() })
                .disposed(by: disposeBag)

        restorePasswordSmsView
                .backButton
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.dismiss(animated: true) })
                .do(onNext: { [unowned self] _ in self.endEditing() })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        restorePasswordSmsView
                .tapBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.endEditing() })
                .disposed(by: disposeBag)

        // -- Fields

        restorePasswordSmsView.smsWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onSmsTap() })
                .disposed(by: disposeBag)

        // -- Keyboard

        RxKeyboard.keyboardHeight()
                .subscribe(onNext: { [weak self] input in self?.onKeyboard(input: input) })
                .disposed(by: disposeBag)

        // -- Delegates

        restorePasswordSmsView.smsField.delegate = self

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

    func configure(phone: String) -> Self {
        self.phoneNumber = phone
        return self
    }

}

extension RestorePasswordSmsViewController {

    func onKeyboard(input: (height: CGFloat, animDuration: TimeInterval)) {
        defer {
            lastKeyboardHeight = input.height
        }
        guard lastKeyboardHeight != input.height else {
            return
        }
        if input.height > 0 {
            restorePasswordSmsView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            restorePasswordSmsView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func activateField(textField: UITextField) {
        self.activeField = textField
        activeField?.becomeFirstResponder()
    }

    func onSmsTap() {
        activateField(textField: restorePasswordSmsView.smsField)
        restorePasswordSmsView.switchToSmsInput()
    }

    func onActionButtonTap() {
        guard let smsCode = restorePasswordSmsView.smsField.text, smsCode.isEmpty == false else {
            activateField(textField: restorePasswordSmsView.smsField)
            restorePasswordSmsView.switchToSmsWarn(text: "Это поле не должно быть пустым")
            return
        }

        guard smsCode.count >= 4 else {
            activateField(textField: restorePasswordSmsView.smsField)
            restorePasswordSmsView.switchToSmsWarn(text: "Минимум 4 символа")
            return
        }

        endEditing()
        viewModel.sendTrigger.onNext((phoneNumber: phoneNumber, smsCode: smsCode))
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        restorePasswordSmsView.switchToRelax()
    }

}

extension RestorePasswordSmsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onActionButtonTap()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji {
            return false
        }
        return true
    }

}
