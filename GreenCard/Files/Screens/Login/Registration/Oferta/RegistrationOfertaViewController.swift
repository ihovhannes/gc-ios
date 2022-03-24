//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxGesture

class RegistrationOfertaViewController: UIViewController, DisposeBagProvider {

    fileprivate var registrationOfertaView: RegistrationOfertaView {
        return view as? RegistrationOfertaView ?? RegistrationOfertaView()
    }

    fileprivate var viewModel: RegistrationOfertaViewModel!

    var acceptCallback: (() -> ())? = nil

    init() {
        super.init(nibName: nil, bundle: nil)

        view = RegistrationOfertaView()

        viewModel = RegistrationOfertaViewModel(bindingsFactory: getBindingsFactory())
        type = .registrationOfertaAccept

        // -- Data source

        viewModel.ofertaObservable
                .bind(to: rx_ofertaObserver)
                .disposed(by: disposeBag)

        // -- Button

        registrationOfertaView.acceptButton
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.registrationChangePassword })
                .do(onNext: { [unowned self] _ in self.acceptCallback?() })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)


        // -- Errors
        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("Error: \(error)")
                })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(type: ViewType, header: String, acceptCallback: (() -> ())?) -> RegistrationOfertaViewController {
        self.type = type
        registrationOfertaView.header.text = header
        self.acceptCallback = acceptCallback
        return self
    }

}

extension RegistrationOfertaViewController {

}

fileprivate extension RegistrationOfertaViewController {

    func getBindingsFactory() -> RegistrationOfertaViewControllerBindingsFactory {
        return { [unowned self] () -> RegistrationOfertaViewControllerBindings in
            return self.rx.observableAppearanceState()
        }
    }

}

fileprivate extension RegistrationOfertaViewController {

    var rx_ofertaObserver: AnyObserver<(title: String, subTitle: String, content: String)> {
        return Binder(self, binding: { (controller: RegistrationOfertaViewController, input: (title: String, subTitle: String, content: String)) in
            controller.registrationOfertaView.configure(title: input.title, subTitle: input.subTitle, ofertaText: input.content)
        }).asObserver()
    }

}
