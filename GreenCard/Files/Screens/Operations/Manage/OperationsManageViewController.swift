//
// Created by Hovhannes Sukiasian on 08/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import RxGesture
import InputMask

class OperationsManageViewController: UIViewController, DisposeBagProvider {

    fileprivate var operationsManageView: OperationsManageView {
        return view as? OperationsManageView ?? OperationsManageView()
    }

    fileprivate weak var viewModel: OperationsManageViewModel!
    fileprivate weak var activeField: UITextField? = nil

    var lastKeyboardHeight: CGFloat = 0

    // -- Delegates

    lazy var maskedCardNumber = PolyMaskTextFieldDelegate()
    lazy var maskedCardCode = PolyMaskTextFieldDelegate()
    let phoneMasked = PolyMaskTextFieldDelegate()

    // -- Card's data
    lazy var cardNumberValue: String = ""
    lazy var cardCodeValue: String = ""

    init() {
        super.init(nibName: nil, bundle: nil)

        view = OperationsManageView()
        type = .operationsManage

        viewModel = OperationsManageViewModel(bindingsFactory: getBindingsFactory())

        // -- Delegates

        operationsManageView.scrollView.delegate = self

        maskedCardNumber.affineFormats = ["[0000] [0000] [0000] [0000]"]
        maskedCardCode.affineFormats = ["[0000]"]
        phoneMasked.affineFormats = ["+{7} [000] [000] [00] [00]"]

        maskedCardNumber.listener = self
        maskedCardCode.listener = self

        operationsManageView.cardNumberField.delegate = maskedCardNumber
        operationsManageView.cardCodeField.delegate = maskedCardCode
        operationsManageView.codeInputField.delegate = self

        // -- Data source

        viewModel.cardsList.asObservable()
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (list: [CardsListItem]?) in
                    self?.operationsManageView.addCards(cardList: list)
                })
                .disposed(by: disposeBag)

        // --  -- User info

        viewModel.cardInfoObservable
                .map({ event in event.error })
                .filter({ $0 != nil })
                .map({ $0! })
                .map({ [unowned self] error in self.errorToRouting(error: error) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.cardInfoObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .filter({ (response: (userName: String?, userPhone: String?, errors: [String?]?)? ) in
                    response?.errors != nil || response?.userName == nil || response?.userPhone == nil
                })
                .map({ (response: (userName: String?, userPhone: String?, errors: [String?]?)?) -> Routing in
                    Routing.alertView(title: "Ошибка.", body: (response?.errors?.first ?? "Неизвестная ошибка"), repeatCallback: nil)
                })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.cardInfoObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .filter({ $0?.userName != nil && $0?.userPhone != nil })
                .subscribe(onNext: { [weak self] response in
                    if let selfIt = self {
                        selfIt.operationsManageView.cardUserName.text = response?.userName ?? ""
                        selfIt.phoneMasked.put(text: response?.userPhone ?? "", into: selfIt.operationsManageView.cardUserPhone)
                        selfIt.operationsManageView.relaxAnimMode()
                    }
                })
                .disposed(by: disposeBag)

        // -- -- Sms code

        viewModel.smsResponseObservable
                .map({ event in event.error })
                .filter({ $0 != nil })
                .map({ $0! })
                .map({ [unowned self] error in self.errorToRouting(error: error) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.smsResponseObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .filter({ (response: AttachedCardResponse?) in response?.errors != nil || response?.smsSentTo == nil })
                .map({ (response: AttachedCardResponse?) in
                    Routing.alertView(title: "Ошибка.", body: (response?.errors?.first ?? "Неизвестная ошибка"), repeatCallback: nil)
                })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.smsResponseObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .filter({ $0?.smsSentTo != nil })
                .map({ response in Routing.toastView(msg: "Код отправлен на номер\n+\(response?.smsSentTo ?? "")") })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- -- Append card

        viewModel.addCardResponseObservable
                .map({ event in event.error })
                .filter({ $0 != nil })
                .map({ $0! })
                .map({ [unowned self] error in self.errorToRouting(error: error) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.addCardResponseObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .filter({ (response: AttachedCardResponse?) in response?.errors != nil || (response?.isAttached == nil || response?.isAttached == false) })
                .map({ (response: AttachedCardResponse?) in
                    Routing.alertView(title: "Ошибка.", body: (response?.errors?.first ?? "Неизвестная ошибка"), repeatCallback: nil)
                })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.addCardResponseObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .filter({ (response: AttachedCardResponse?) in (response?.isAttached != nil && response?.isAttached == true) })
                .do(onNext: { [weak self] _ in
                    self?.operationsManageView.animCancelCard()
                    self?.viewModel.refreshCards.onNext(())
                })
                .map({ _ in
                    return Routing.toastView(msg: "Карта добавлена")
                })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Navigation

        viewModel
                .menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel
                .menuRoutingObservable
                .bind(to: rx_observerRouting)
                .disposed(by: disposeBag)

        // -- Network

        viewModel.updateCardsListObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .map({ $0! })
                .bind(to: rx_observerResponse)
                .disposed(by: disposeBag)

        viewModel.updateCardsListObservable
                .map({ event in event.error })
                .filter({ $0 != nil })
                .map({ $0! })
                .map({ [unowned self] error in self.errorToRouting(error: error) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Buttons

        operationsManageView.tableWidget
                .addCardRow
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onAddCardTap() })
                .disposed(by: disposeBag)

        operationsManageView.tableWidget.cardDetailsRow
                .sendCodeContainer
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onSendCodeTap() })
                .disposed(by: disposeBag)

        operationsManageView.tableWidget.cardDetailsRow
                .addButton
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onAddCardButtonTap() })
                .disposed(by: disposeBag)

        operationsManageView.tableWidget.cardDetailsRow
                .cancelButton
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onCancelButtonTap() })
                .disposed(by: disposeBag)

        // -- Text Fields

        operationsManageView
                .cardNumberWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onCardNumberFieldTap() })
                .disposed(by: disposeBag)

        operationsManageView
                .cardCodeWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onCardCodeFieldTap() })
                .disposed(by: disposeBag)

        operationsManageView
                .codeInputWrapper
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onSmsCodeFieldTap() })
                .disposed(by: disposeBag)

        // -- Hide keyboard

        operationsManageView.rx
                .anyGesture(.swipe([.up, .down]))
                .when(.recognized)
                .filter({ [unowned self] _ in self.operationsManageView.isSwipeEnabled() })
                .subscribe(onNext: { [unowned self] _ in self.endEditing() })
                .disposed(by: disposeBag)

        operationsManageView.tableWidget.hideKeyboardBackground
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.endEditing() })
                .disposed(by: disposeBag)

        // --

        RxKeyboard.keyboardHeight()
                .subscribe(onNext: { [weak self] input in self?.onKeyboard(input: input) })
                .disposed(by: disposeBag)

        // -- Swipe

        operationsManageView.tableWidget.cardsHolder
                .rx
                .anyGesture(.swipe([.left]))
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in self?.operationsManageView.swipeCardsLeft() })
                .disposed(by: disposeBag)

        operationsManageView.tableWidget.cardsHolder
                .rx
                .anyGesture(.swipe([.right]))
                .when(.recognized)
                .subscribe(onNext: { [weak self] _ in self?.operationsManageView.swipeCardsRight() })
                .disposed(by: disposeBag)

        // --

        operationsManageView.rulesLabel
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .map({ _ in Routing.toastView(msg: "В разработке") })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension OperationsManageViewController: RoutingError {
}

extension OperationsManageViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y * 2.5 / Consts.TITLE_ANIMATION_VELOCITY)
        operationsManageView.titleLabel.transform = transform
        operationsManageView.rulesLabel.transform = transform
        operationsManageView.rulesUnderline.transform = transform
    }

}

fileprivate extension OperationsManageViewController {

    func onAddCardTap() {
        cardNumberValue = ""
        cardCodeValue = ""
        operationsManageView.cardNumberField.text = ""
        operationsManageView.cardCodeField.text = ""
        operationsManageView.cardUserName.text = ""
        operationsManageView.cardUserPhone.text = ""
        operationsManageView.codeInputField.text = ""
        operationsManageView.relaxMode()
        operationsManageView.relaxAnimMode()
        operationsManageView.animAddCard()
    }

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
            operationsManageView.moveUpComponentsByKeyboard(keyboardHeight: input.height, keyboardAnimDuration: input.animDuration)
        } else {
            operationsManageView.moveDownComponentsByKeyboard(duration: input.animDuration)
        }
    }

    func onCardNumberFieldTap() {
        activateField(textField: operationsManageView.cardNumberField)
        operationsManageView.cardNumberInputMode()
    }

    func onCardCodeFieldTap() {
        activateField(textField: operationsManageView.cardCodeField)
        operationsManageView.cardCodeInputMode()
    }

    func onSmsCodeFieldTap() {
        activateField(textField: operationsManageView.codeInputField)
        operationsManageView.smsCodeInputMode()
    }

    func validateCardInputs() -> Bool {
        guard cardNumberValue.isEmpty == false else {
            activateField(textField: operationsManageView.cardNumberField)
            operationsManageView.cardNumberWarnMode(text: "Это поле не должно быть пустым")
            return false
        }

        guard cardNumberValue.count == 16 else {
            activateField(textField: operationsManageView.cardNumberField)
            operationsManageView.cardNumberWarnMode(text: "Неправильный номер")
            return false
        }

        guard cardCodeValue.isEmpty == false else {
            activateField(textField: operationsManageView.cardCodeField)
            operationsManageView.cardCodeWarnMode(text: "Это поле не должно быть пустым")
            return false
        }

        guard cardCodeValue.count == 4 else {
            activateField(textField: operationsManageView.cardCodeField)
            operationsManageView.cardCodeWarnMode(text: "Неправильный номер")
            return false
        }

        return true
    }

    func onSendCodeTap() {
        guard validateCardInputs() else {
            return
        }

        endEditing()
        viewModel.sendSmsCode.onNext(())
    }

    func onAddCardButtonTap() {
        guard validateCardInputs() else {
            return
        }

        guard let smsCode = operationsManageView.codeInputField.text, smsCode.isEmpty == false else {
            activateField(textField: operationsManageView.codeInputField)
            operationsManageView.smsCodeWarnMode(text: "Это поле не должно быть пустым")
            return
        }

        endEditing()
        viewModel.addCard.onNext(smsCode)
    }

    func onCancelButtonTap() {
        endEditing()
        operationsManageView.animCancelCard()
    }

    func endEditing() {
        activeField?.resignFirstResponder()
        operationsManageView.relaxMode()
        operationsManageView.relaxAnimMode()
    }

}

fileprivate extension OperationsManageViewController {

    func getBindingsFactory() -> OperationsManageViewControllerBindingsFactory {
        return { [unowned self] () -> OperationsManageViewControllerBindings in
            return OperationsManageViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}

fileprivate extension OperationsManageViewController {

    var rx_observerResponse: AnyObserver<CardsListResponse> {
        return Binder(self, binding: { (controller: OperationsManageViewController, input: CardsListResponse) in
            controller.operationsManageView.startupAnim()
        }).asObserver()
    }

    var rx_observerRouting: AnyObserver<Routing> {
        return Binder(self, binding: { (controller: OperationsManageViewController, routing: Routing) in
            controller.endEditing()
        }).asObserver()
    }

}

extension OperationsManageViewController: MaskedTextFieldDelegateListener {

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        switch textField {
        case operationsManageView.cardNumberField:
            cardNumberValue = value
        case operationsManageView.cardCodeField:
            cardCodeValue = value
        case _:
            break
        }

        if cardNumberValue.count == 16, cardCodeValue.count == 4 {
            viewModel.sendCardInfo.onNext((cardNumber: cardNumberValue, cardCode: cardCodeValue))
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case operationsManageView.cardNumberField:
            onCardCodeFieldTap()
        case operationsManageView.cardCodeField:
            onSmsCodeFieldTap()
        case operationsManageView.codeInputField:
            onAddCardButtonTap()
        case _:
            log("missing case")
        }
        return false
    }

}
