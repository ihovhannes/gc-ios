//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift
import RxGesture

class NotificationsViewController: UIViewController, DisposeBagProvider {

    fileprivate  var notificationsView: NotificationsView {
        return view as? NotificationsView ?? NotificationsView()
    }

    fileprivate var viewModel: NotificationsViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = NotificationsView()
        type = .notifications

        viewModel = NotificationsViewModel(bindingsFactory: getBindingsFactory())

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Buttons

        notificationsView.buttonContainer
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.toastView(msg: "В разработке")})
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // --


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

    override func viewDidAppear(_ animated: Bool) {
        notificationsView.appearanceAnim()
    }
}

fileprivate extension NotificationsViewController {

    func getBindingsFactory() -> NotificationsViewControllerBindingsFactory {
        return { [unowned self] () -> NotificationsViewControllerBindings in
            return NotificationsViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
