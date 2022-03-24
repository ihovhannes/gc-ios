//
// Created by Hovhannes Sukiasian on 08/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift


class OperationDetailViewController: UIViewController, DisposeBagProvider {

    fileprivate var operationDetailView: OperationDetailView {
        return view as? OperationDetailView ?? OperationDetailView()
    }

    fileprivate var viewModel: OperationDetailViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = OperationDetailView()
        type = .operationDetails

        viewModel = OperationDetailViewModel(bindingsFactory: getBindingsFactory())

        // -- Start animation

        // -- Navigation

        viewModel
                .menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel
                .updateOperationObservable
                .bind(to: operationDetailView.rx.operationObserver)
                .disposed(by: disposeBag)

        // -- Error

        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(operationId: String?) -> OperationDetailViewController {
        viewModel.operationId.value = operationId
        return self
    }

}

fileprivate extension OperationDetailViewController {

    func getBindingsFactory() -> OperationDetailViewControllerBindingsFactory {
        return { [unowned self] () -> OperationDetailViewControllerBindings in
            return OperationDetailViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
