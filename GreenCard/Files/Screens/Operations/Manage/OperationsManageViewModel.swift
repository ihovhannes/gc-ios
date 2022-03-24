//
// Created by Hovhannes Sukiasian on 08/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

typealias OperationsManageViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias OperationsManageViewControllerBindingsFactory = () -> OperationsManageViewControllerBindings

class OperationsManageViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: OperationsManageViewControllerBindingsFactory

    lazy var refreshCards = PublishSubject<()>()

    fileprivate(set) var menuRoutingObservable = Observable<Routing>.never()

    fileprivate(set) var updateCardsListObservable = Observable<Event<CardsListResponse>>.never()

    fileprivate(set) lazy var cardsList: Variable<[CardsListItem]?> = Variable(nil)

    lazy var sendCardInfo = PublishSubject<(cardNumber: String, cardCode: String)>()
    var cardInfoObservable = Observable<Event<(userName: String?, userPhone: String?, errors: [String?]?)>>.never()

    var userId: String? = nil
    lazy var sendSmsCode = PublishSubject<()>()
    lazy var smsResponseObservable = Observable<Event<AttachedCardResponse>>.never()

    lazy var addCard = PublishSubject<String>()
    lazy var addCardResponseObservable = Observable<Event<AttachedCardResponse>>.never()

    required init(bindingsFactory: @escaping OperationsManageViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        willAppearObservable
                .subscribe(onNext: { [weak self] () in
                    self?.refreshCards.onNext(())
                })
                .disposed(by: disposeBag)

        // -- Навигация
        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu, drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        // -- Network

        let loadCardsList = rx_loadCardsListObservable(willAppearObservable: refreshCards.asObservable())
        let saveCardsList = rx_saveCardsListObservable(loadCardsListObservable: loadCardsList)

        saveCardsList
                .subscribe { input in
                    log("Saved cards list \(input)")
                }
                .disposed(by: disposeBag)

        updateCardsListObservable = rx_transformCardsListObservable(loadCardsListObservable: loadCardsList)

        // -- User info

        cardInfoObservable = rx_cardGetUserInfo(cardInfoObservable: sendCardInfo.asObservable())

        // -- Send Sms
        smsResponseObservable = rx_sendSmsCode(sendSmsCodeObservable: sendSmsCode.asObservable().map({ [weak self] _ in
            self?.userId
        }))

        // -- Append card
        addCardResponseObservable = rx_cardAppendNew(smsCodeObservable: addCard.asObservable()
                .map({ [weak self] smsCode in
                    (userId: self?.userId, smsCode: smsCode)
                })
        )

    }

    deinit {
        log("deinit")
    }

}

extension OperationsManageViewModel: RxViewModelNavigation, RxViewModelAppearance {
}

extension OperationsManageViewModel {

    // -- Get cards

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
                .share()
    }

    func rx_transformCardsListObservable(loadCardsListObservable: Observable<Event<CardsListResponse>>) -> Observable<Event<CardsListResponse>> {
        return loadCardsListObservable
                .do(onNext: { [weak self] event in
                    switch event {
                    case .next(let response):
                        self?.cardsList.value = response.list

                    case _:
                        log("\(event)")
                    }
                })
                .share()
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
    }

    // -- Save

    func rx_saveCardsListObservable(loadCardsListObservable: Observable<Event<CardsListResponse>>) -> Observable<Void> {
        return Observable.just(())
    }

    // -- Get user info

    func rx_cardGetUserInfo(cardInfoObservable: Observable<(cardNumber: String, cardCode: String)>) -> Observable<Event<(userName: String?, userPhone: String?, errors: [String?]?)>> {
        return cardInfoObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest({ (input: (cardNumber: String, cardCode: String)) -> Observable<(token: String, cardNumber: String, cardCode: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map { token in
                                return (token: token, cardNumber: input.cardNumber, cardCode: input.cardCode)
                            }
                })
                .flatMapLatest { (input: (token: String, cardNumber: String, cardCode: String)) -> Observable<Event<UserResponse>> in
                    return Observable.using({ NetworkService(token: input.token) }, observableFactory: { (service: NetworkService) -> Observable<Event<UserResponse>> in
                        let request: Request<CardGetUserInfoStrategy> = service.request()
                        return request.observe((cardNumber: input.cardNumber, cardCode: input.cardCode)).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .map { (event: Event<UserResponse>) -> Event<(userName: String?, userPhone: String?, errors: [String?]?)> in
                    return event.map { [weak self] response in
                        self?.userId = response.idString
                        return (userName: response.fullName, userPhone: response.phone, errors: response.errors)
                    }
                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
    }

    // -- Send sms code

    func rx_sendSmsCode(sendSmsCodeObservable: Observable<String?>) -> Observable<Event<AttachedCardResponse>> {
        return sendSmsCodeObservable
                .filter({ $0 != nil })
                .map({ $0! })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest({ (input: String) -> Observable<(token: String, userId: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map { token in
                                return (token: token, userId: input)
                            }
                })
                .flatMapLatest { (input: (token: String, userId: String)) -> Observable<Event<AttachedCardResponse>> in
                    return Observable.using({ NetworkService(token: input.token) }, observableFactory: { (service: NetworkService) -> Observable<Event<AttachedCardResponse>> in
                        let request: Request<CardSmsForAppendStrategy> = service.request()
                        return request.observe(input.userId).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
    }

    // -- Add new card

    func rx_cardAppendNew(smsCodeObservable: Observable<(userId: String?, smsCode: String)>) -> Observable<Event<AttachedCardResponse>> {
        return smsCodeObservable
                .filter({ $0.userId != nil })
                .map({ (userId: $0.userId!, smsCode: $0.smsCode) })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest({ (input: (userId: String, smsCode: String)) -> Observable<(token: String, userId: String, smsCode: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map { token in
                                return (token: token, userId: input.userId, smsCode: input.smsCode)
                            }
                })
                .flatMapLatest { (input: (token: String, userId: String, smsCode: String)) -> Observable<Event<AttachedCardResponse>> in
                    return Observable.using({ NetworkService(token: input.token) }, observableFactory: { (service: NetworkService) -> Observable<Event<AttachedCardResponse>> in
                        let request: Request<CardAppendNewStrategy> = service.request()
                        return request.observe((userId: input.userId, smsCode: input.smsCode)).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
    }

}
