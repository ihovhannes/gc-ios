//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

class OperationsViewController: UIViewController, DisposeBagProvider {

    fileprivate var operationsView: OperationsView {
        return view as? OperationsView ?? OperationsView()
    }

    fileprivate var viewModel: OperationsViewModel!

    fileprivate var activeField: UITextField?

    init() {
        super.init(nibName: nil, bundle: nil)

        view = OperationsView()
        type = .operations

        viewModel = OperationsViewModel(bindingsFactory: getBindingsFactory())

        operationsView.typePasswordField.delegate = self

        // -- Error

        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)

        // -- Navigation

        viewModel.menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.manageRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.menuRoutingObservable
                .bind(to: rx_hideKeyboardObserver)
                .disposed(by: disposeBag)

        viewModel.manageRoutingObservable
                .bind(to: rx_hideKeyboardObserver)
                .disposed(by: disposeBag)


        // -- Network

        viewModel.updateCardsListObservable
                .map({ event in event.element})
                .filter({ $0 != nil})
                .map({ $0!})
                .bind(to: rx_observerResponse)
                .disposed(by: disposeBag)

        viewModel.updateCardsListObservable
                .map({ event in event.error})
                .filter({ $0 != nil})
                .map({ $0!})
                .map(errorToRouting)
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Start animation

        viewModel.updateCardsListObservable
                .map({ _ in () })
                .bind(to: operationsView.rx.startAnimObserver)
                .disposed(by: disposeBag)

        // -- Data source

        viewModel.mainCardObservable
                .bind(to: operationsView.rx.mainCardObserver)
                .disposed(by: disposeBag)

        viewModel.errorMsg
                .asObservable()
                .map( { (arg:(String, String))  in Routing.alertView(title: arg.0, body: arg.1, repeatCallback: nil) } )
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.blockCardMsg
                .asObservable()
                .bind(to: rx_blockCardMsgObserver)
                .disposed(by: disposeBag)

        // -- Interactions TextFields

        operationsView
                .typePasswordField
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in
                    self.viewModel.mainCard.value != nil
                })
                .subscribe(onNext: onTypePasswordFieldTap)
                .disposed(by: disposeBag)

        operationsView
                .typePasswordField
                .rx
                .controlEvent(.editingDidEndOnExit)
                .subscribe(onNext: onTypePasswordFieldReturn)
                .disposed(by: disposeBag)

        operationsView
                .typePasswordField
                .rx
                .controlEvent(.editingDidEnd)
                .subscribe(onNext: endEditing)
                .disposed(by: disposeBag)

        // -- Buttons

        operationsView.blockButton
                .gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in
                    self.viewModel.mainCard.value != nil
                })
                .subscribe(onNext: onBlockButtonTap)
                .disposed(by: disposeBag)

        operationsView.blockHelpButton
                .gestureArea(leftOffset: 20, topOffset: 20, rightOffset: 20, bottomOffset: 20)
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ state in Routing.alertView(title: "Помощь", body: "Информация", repeatCallback: nil) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        operationsView.blockHelpButton.isShown = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension OperationsViewController : RoutingError {

}

fileprivate extension OperationsViewController {

    func getBindingsFactory() -> OperationsViewControllerBindingsFactory {
        return { [unowned self] () -> OperationsViewControllerBindings in
            return OperationsViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    manageButton: self.operationsView.manageRow
                            .rx
                            .tapGesture()
                            .when(.recognized)
                            .map({ _ in () })
            )
        }
    }

}

extension OperationsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onTypePasswordFieldReturn(args: ())
        return false
    }

}

fileprivate extension OperationsViewController {

    func activeField(field: UITextField) {
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = operationsView.getKeyboardOffset(field: field)
        activeField = field
        field.becomeFirstResponder()
    }

    func onTypePasswordFieldTap(args: Any) {
        activeField(field: operationsView.typePasswordField)
        operationsView.switchToPasswordTyping()
    }

    func onTypePasswordFieldReturn(args: Any) {
        if operationsView.typePasswordField.text.isEmpty() {
            operationsView.switchToPasswordWarn(text: "Это поле не должно быть пустым")
        } else if operationsView.typePasswordField.text!.count < 6 {
            operationsView.switchToPasswordWarn(text: "Минимум шесть символов")
        } else {
            operationsView.typePasswordField.resignFirstResponder()
            operationsView.resetPasswordState()
            viewModel.blockCardWithPassword.onNext(operationsView.typePasswordField.text!)
        }
    }

    func endEditing(args: Any) {
        operationsView.resetPasswordState()
    }

    func onBlockButtonTap(args: Any) {
        onTypePasswordFieldReturn(args: args)
    }

    func onManageRowTap(args: Any) {
        log("Go to manage")
    }

}


fileprivate extension OperationsViewController {

    var rx_hideKeyboardObserver: AnyObserver<Routing> {
        return Binder(self, binding: { (controller: OperationsViewController, routing: Routing) in
            controller.activeField?.resignFirstResponder()
            controller.endEditing(args: true)
        }).asObserver()
    }

    var rx_observerResponse: AnyObserver<CardsListResponse> {
        return Binder(self, binding: { (controller: OperationsViewController, input: CardsListResponse) in
            log("\(input)")
        }).asObserver()
    }

    var rx_blockCardMsgObserver: AnyObserver<String> {
        return Binder(self, binding: { (controller: OperationsViewController, input: String) in
            let alertView = UIAlertController(title: nil, message: input, preferredStyle: UIKit.UIAlertControllerStyle.alert);
            alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
            controller.present(alertView, animated: true, completion: nil);
        }).asObserver()
    }

}
