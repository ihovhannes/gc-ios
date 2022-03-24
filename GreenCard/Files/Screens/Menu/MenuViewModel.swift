//
//  MenuViewModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 06.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias MenuViewControllerBindings = (
        Observable<Int>
)

typealias MenuViewControllerBindingsFactory = () -> MenuViewControllerBindings

class MenuViewModel: ReactiveCompatible, DisposeBagProvider {

    typealias MenuItem = (title: String, route: Routing)

    let menuItems: [MenuItem] = [
        ("Главная", Routing.main),
        ("Акции", Routing.shares),
        ("Партнёры", Routing.partners),
        ("Баланс и операции", Routing.balance),
//        ("Уведомления", Routing.notifications),
        ("Настройки", Routing.settings),
        ("Вопросы и ответы", Routing.faq),
        ("Операции с картой", Routing.operations),
//        ("О приложении", Routing.about),
        ("Выйти", Routing.logout)
    ]

    fileprivate let bindingsFactory: MenuViewControllerBindingsFactory
    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    required init(bindingsFactory: @escaping MenuViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        routingObservable = rx.routing(didTapObservable: bindingsFactory())
    }
}

extension MenuViewModel {

    subscript(indexPath: IndexPath) -> String {
        return menuItems[indexPath.row].title
    }

    var itemsInSection: Int {
        return menuItems.count
    }

    var sections: Int {
        return 1
    }
}

fileprivate extension Reactive where Base == MenuViewModel {

    func routing(didTapObservable: Observable<Int>) -> Observable<Routing> {
        return didTapObservable.map({ [unowned base] item in base.menuItems[item].route })
    }
}
