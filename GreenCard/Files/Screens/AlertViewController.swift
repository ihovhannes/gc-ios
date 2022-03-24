//
//  AlertViewController.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 27.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import RxGesture
import RxCocoa
import RxSwift

class AlertViewController: UIViewController, DisposeBagProvider {

    fileprivate var alertView: AlertView {
        return view as? AlertView ?? AlertView()
    }

    var repeatCallback: (() -> ())? = nil

    var dismissSubject = PublishSubject<()>()

    init() {
        super.init(nibName: nil, bundle: nil)

        view = AlertView()
        type = .alertView

        alertView.repeatBtn
                .gestureArea(leftOffset: 10, topOffset: 20, rightOffset: 20, bottomOffset: 20)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onRepeatBtnTap() })
                .disposed(by: disposeBag)

        alertView.closeBtn
                .gestureArea(leftOffset: 20, topOffset: 20, rightOffset: 10, bottomOffset: 20)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onCloseBtnTap() })
                .disposed(by: disposeBag)

        dismissSubject.asObservable()
                .map({ _ in Routing.dismiss(animated: true) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onRepeatBtnTap() {
        repeatCallback?()
        dismissSubject.on(.next(()))
    }

    func onCloseBtnTap() {
        dismissSubject.on(.next(()))
    }

    func configure(title: String?, body: String?, repeatCallback: (() -> ())?) -> AlertViewController {
        alertView.title.isShown = title != nil
        alertView.title.text = title

        alertView.bodyContainer.isShown = body != nil
        alertView.body.text = body

        alertView.repeatBtn.isShown = repeatCallback != nil
        self.repeatCallback = repeatCallback
        return self
    }

    deinit {
        log("deinit")
    }

}


