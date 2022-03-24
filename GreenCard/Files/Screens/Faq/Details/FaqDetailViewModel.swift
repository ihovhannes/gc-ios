//
// Created by Hovhannes Sukiasian on 16/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias FaqDetailViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias FaqDetailViewControllerBindingsFactory = () -> FaqDetailViewControllerBindings

class FaqDetailViewModel: ReactiveCompatible, DisposeBagProvider {

    lazy var questionAnswer: Variable<(question: String, answer: String)> = Variable(("", ""))

    fileprivate let bindingsFactory: FaqDetailViewControllerBindingsFactory

    fileprivate(set) var menuRoutingObservable = Observable<Routing>.never()

    fileprivate(set) var updateQuestionAnswerObservable = Observable<(question: String, answer: String)>.never()

    required init(bindingsFactory: @escaping FaqDetailViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        // -- Навигация
        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu, drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        // -- Data
        updateQuestionAnswerObservable = questionAnswer.asObservable()
    }

}

extension FaqDetailViewModel: RxViewModelNavigation {}
