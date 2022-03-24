//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

typealias OperationsViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        manageButton: Observable<Void>
)

typealias OperationsViewControllerBindingsFactory = () -> OperationsViewControllerBindings

class OperationsViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: OperationsViewControllerBindingsFactory

    fileprivate(set) lazy var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var manageRoutingObservable = Observable<Routing>.never()
    fileprivate(set) var errorObservable = Observable<Void>.never()

    fileprivate(set) var updateCardsListObservable = Observable<Event<CardsListResponse>>.never()
    fileprivate(set) var mainCardObservable = Observable<CardsListItem?>.never()

    fileprivate(set) lazy var blockCardWithPassword = PublishSubject<String>()
    fileprivate(set) lazy var blockCardMsg = PublishSubject<String>()
    fileprivate(set) lazy var errorMsg = PublishSubject<(String, String)>()

    fileprivate(set) lazy var cardsList: Variable<[CardsListItem]?> = Variable(nil)
    fileprivate(set) lazy var mainCard: Variable<CardsListItem?> = Variable(nil)

    required init(bindingsFactory: @escaping OperationsViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu, drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        manageRoutingObservable = rx_routingToManage(tapButtonObservable: bindingsFactory().manageButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        // -- Network

        let loadCardsList = rx_loadCardsListObservable(willAppearObservable: willAppearObservable)
        let saveCardsList = rx_saveCardsListObservable(loadCardsListObservable: loadCardsList)
        saveCardsList
                .subscribe { input in
                    log("Saved cards list \(input)")
                }
                .disposed(by: disposeBag)

        updateCardsListObservable = rx_transformCardsListObservable(loadCardsListObservable: loadCardsList)

        // -- Data source

        mainCardObservable = mainCard.asObservable()

        let changeCardState = rx_cardChangeState(
                passwordObservable: blockCardWithPassword.asObservable())

        changeCardState
                .bind(to: rx_cardChangeStateObserver)
                .disposed(by: disposeBag)

        // -- Error
        errorObservable = rx_errorMerge(rx_errorObservable(observable: updateCardsListObservable),
                rx_errorObservable(observable: changeCardState))
    }

    deinit {
        log("deinit")
    }

}

extension OperationsViewModel: RxViewModelNavigation, RxViewModelAppearance, RxViewModelError {

}

extension OperationsViewModel {

    // -- Navigation

    func rx_routingToManage(tapButtonObservable: Observable<Void>,
                            appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return tapButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ stat in Routing.operationsManage })
    }

    // -- Network load card

    func rx_loadCardsListObservable(willAppearObservable: Observable<Void>) -> Observable<Event<CardsListResponse>> {
        return willAppearObservable
                .flatMapLatest({ _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest({ token -> Observable<Event<CardsListResponse>> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { (service: NetworkService) -> Observable<Event<CardsListResponse>> in
                        let request: Request<CardsListStrategy> = service.request()
                        return request.observe(()).materialize()
                    })
                })
                .filter({ event in !event.isCompleted })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transformCardsListObservable(loadCardsListObservable: Observable<Event<CardsListResponse>>) -> Observable<Event<CardsListResponse>> {
        return loadCardsListObservable
                .do(onNext: { [weak self] event in
                    switch event {
                    case .next(let response):
                        self?.cardsList.value = response.list
                        self?.mainCard.value = response.list.flatMap { (list: [CardsListItem]) in
                            list.filter({ $0.isMain && $0.cardNum != nil && $0.id != nil }).first
                        }
                    case _:
                        log("\(event)")
                    }
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
    }

    // -- Network card change state

    func rx_cardChangeState(passwordObservable: Observable<String>) -> Observable<CardChangeStateResponse> {
        return passwordObservable
                .filter({ [weak self] _ in self?.mainCard.value?.id != nil })
                .map { [weak self] (password) -> (password: String, cardId: Int64) in
                    return (password: password, cardId: self?.mainCard.value?.id ?? 0)
                }
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { arg -> Observable<(password: String, cardId: Int64, token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (password: arg.password, cardId: arg.cardId, token: $0)
                            }
                }
                .flatMapLatest { arg -> Observable<CardChangeStateResponse> in
                    return Observable.using({ NetworkService(token: arg.token) }, observableFactory: { service -> Observable<CardChangeStateResponse> in
                        let request: Request<CardChangeStateStrategy> = service.request()
                        return request.observe((cardId: arg.cardId, password: arg.password))
                    })
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    // -- Save

    func rx_saveCardsListObservable(loadCardsListObservable: Observable<Event<CardsListResponse>>) -> Observable<Void> {
        return Observable.just(())
    }

    // -- Change state observer

    var rx_cardChangeStateObserver: AnyObserver<CardChangeStateResponse> {
        return Binder(self, binding: { (viewModel: OperationsViewModel, input: CardChangeStateResponse) in
            if let error = input.nonFieldError {
                viewModel.errorMsg.onNext(("Ошибка при получении данных", error.first ?? "Ошибка"))
            } else if input.isChanged, let mainCardValue = viewModel.mainCard.value {
                var mainCardMut = mainCardValue
                mainCardMut.isLocked = !mainCardMut.isLocked
                viewModel.mainCard.value = mainCardMut

                if let cards: [CardsListItem] = viewModel.cardsList.value {
                    var cardsMut = cards
                    for i in cardsMut.indices {
                        if cardsMut[i].id == mainCardMut.id {
                            cardsMut[i].isLocked = mainCardMut.isLocked
                            break
                        }
                    }
                    viewModel.cardsList.value = cardsMut
                }

                viewModel.blockCardMsg.onNext(mainCardMut.isLocked ? "Карта успешно заблокирована" : "Карта успешно разблокирована")
            }
        }).asObserver()
    }


    // -- Errors

    func rx_errorMerge(_ observables: Observable<Void>...) -> Observable<Void> {
        return Observable.merge(observables)
    }

}
