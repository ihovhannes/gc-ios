//
//  MainViewModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias MainViewControllerBindings = (
        tapShareObservable: Observable<(shareId: Int64?, title: String?, endDate: String?)>,
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        doesNeedMoreData: Observable<Void>,
        reloadData: Observable<Void>
)

typealias MainViewControllerBindingsFactory = () -> MainViewControllerBindings

class MainViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate lazy var offers: Variable<[Offer]> = Variable([])
    lazy var offersCount: Variable<Int> = Variable(0)
    lazy var error = PublishSubject<Error>()
    lazy var retry = PublishSubject<Bool>()
    fileprivate var page: Int = 1

    fileprivate let bindingsFactory: MainViewControllerBindingsFactory
    fileprivate let userRepository: () -> UserRepository
    fileprivate let shareRepository: () -> ShareRepository

    fileprivate(set) lazy var accountObservable = Observable<Account>.never()
    fileprivate(set) lazy var updateOffersObservable = Observable<UpdateableObject>.never()
    fileprivate(set) lazy var playAnimationObservable = Observable<Bool>.never()
    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var showLoadingFooter = Observable<Bool>.never()

    required init(bindingsFactory: @escaping MainViewControllerBindingsFactory,
                  userRepositoryFactory: @escaping () -> UserRepository,
                  shareRepositoryFactory: @escaping () -> ShareRepository) {
        self.bindingsFactory = bindingsFactory
        self.userRepository = userRepositoryFactory
        self.shareRepository = shareRepositoryFactory

        let willAppearObservable = willAppearObservableOnce()

        let loadDataOnWillAppear = willAppearObservable.map { _ in
            false
        }
        let loadDataOnRefresh = bindingsFactory()
                .reloadData
                .map { _ in
                    true
                }
                .do(onNext: { [unowned self] _ in
                    self.page = 1
                })
                .share(replay: 1, scope: .whileConnected)
        let loadSharesOnScroll = bindingsFactory().doesNeedMoreData.map { _ in
            false
        }
        let loadDataOnRetry = retry.asObservable()

        let shouldLoadShares = shouldLoadSharesObservable(shouldLoadObservables: loadDataOnWillAppear, loadDataOnRefresh, loadSharesOnScroll, loadDataOnRetry)

        accountObservable = accountObservable(shouldLoadObservables: loadDataOnWillAppear, loadDataOnRetry, loadDataOnRefresh)
        updateOffersObservable = sharesObservable(shouldLoadObservable: shouldLoadShares)

        let didLoadInitialPage = didLoadInitialPageObservable(didLoadSharesObservable: updateOffersObservable)
        playAnimationObservable = playAnimationObservable(accountObservable: accountObservable,
                shareObservable: didLoadInitialPage)

        showLoadingFooter = showLoadingFooterObservable(shouldLoadSharesObservable: shouldLoadShares,
                didLoadSharesObservable: updateOffersObservable)

        // -- Error

        let errorObservable = errorRoutingObservable(errorObservable: error.asObservable())

        // -- Навигация

        let menuRoutingObservable = menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)
        routingObservable = routingObservable(menuRoutingObservable,
                errorObservable,
                detailRouting(tapObservable: bindingsFactory().tapShareObservable))
    }

    convenience init(bindingsFactory: @escaping MainViewControllerBindingsFactory) {
        self.init(bindingsFactory: bindingsFactory,
                userRepositoryFactory: { UserRepository() },
                shareRepositoryFactory: { ShareRepository() }
        )
    }
}

extension MainViewModel {

    subscript(indexPath: IndexPath) -> Offer {
        return offers.value[indexPath.row]
    }

    var itemsInSection: Int {
        return offers.value.count
    }

    var sections: Int {
        return offers.value.count == 0 ? 0 : 1
    }
}

fileprivate extension MainViewModel {

    // -- Навигация

    func menuRouting(drawerButtonObservable: Observable<Void>,
                     appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ state in Routing.switchMenu })
    }

    func routingObservable(_ observables: Observable<Routing>...) -> Observable<Routing> {
        return Observable.merge(observables)
    }

    func detailRouting(tapObservable: Observable<(shareId: Int64?, title: String?, endDate: String?)>) -> Observable<Routing> {
        return tapObservable.map { args in
            return Routing.shareDetail(id: args.shareId, title: args.title, endDate: args.endDate, partnerColor: nil, isArchive: false)
        }
    }

    // -- Network Account

    func accountObservable(shouldLoadObservables: Observable<Bool>...) -> Observable<Account> {
        return Observable
                .merge(shouldLoadObservables)
                .flatMapLatest({ [unowned self] refresh -> Observable<UserEntity?> in
                    return self.userRepository()
//                            .getUser(refresh: refresh)
                            .getUserFromApi()
                            .catchError({ [unowned self] error -> Observable<UserEntity?> in
                                self.error.onNext(error)
                                return Observable.just(UserEntity()) // self.userRepository().getUserFromDb()
                            })
                })
                .filterNil()
                .map({ userEntity -> Account in
                    return Account(userEntity: userEntity)
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
    }

    func shouldLoadSharesObservable(shouldLoadObservables: Observable<Bool>...) -> Observable<(Int, Bool)> {
        return Observable
                .merge(shouldLoadObservables)
                .filter({ [unowned self] refresh -> Bool in
                    return refresh || self.offers.value.count != self.offersCount.value || self.offers.value.count == 0
                })
                .map({ [unowned self] refresh in (self.page, refresh) })
                .share(replay: 1, scope: .whileConnected)
    }

    func sharesObservable(shouldLoadObservable: Observable<(Int, Bool)>) -> Observable<UpdateableObject> {
        return shouldLoadObservable
                .flatMapLatest({ [unowned self] (page, refresh) -> Observable<([ShareEntity], Int, Bool)> in
                    return self
                            .shareRepository()
                            //                    .getShares(page: page, refresh: refresh)
                            .getSharesFromApi(page: page)
                            .catchError({ [unowned self] error -> Observable<([ShareEntity], Int)> in
                                self.error.onNext(error)
//                                return self.shareRepository()
//                                        .getSharesFromDb(page: page)
                                return Observable.just(([], 0))
                            })
                            .map({ (shares, count) -> ([ShareEntity], Int, Bool) in
                                return (shares, count, refresh)
                            })
                })
                .do(onNext: { [unowned self] (shareEntities, count, refresh) in
                    self.offersCount.value = count
                })
                .map({ (shareEntities, count, refresh) -> ([Offer], Int, Bool) in
                    return (shareEntities.map({ shareEntity -> Offer in
                        return Offer(shareEntity: shareEntity)
                    }), count, refresh)
                })
                .do(onNext: { [unowned self] list, _, refresh in
                    var array = self.offers.value
                    if (refresh) {
                        array.removeAll()
                    }
                    array.append(contentsOf: list)
                    self.offers.value = array
                })
                .map({ _, _, _ -> UpdateableObject in
                    let upd = Updates(row: .empty, section: .empty)
                    return UpdateableObject(updates: upd, animated: false)
                })
                .do(onNext: { [unowned self] _ in
                    self.page += 1
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
    }

    func didLoadInitialPageObservable(didLoadSharesObservable: Observable<UpdateableObject>) -> Observable<Void> {
        return didLoadSharesObservable
                .take(1)
                .do(onNext: { _ in
                    print("Did Load initial page")
                })
                .map({ _ in () })
    }

    func playAnimationObservable(accountObservable: Observable<Account>, shareObservable: Observable<Void>) -> Observable<Bool> {
        return Observable
                .zip(accountObservable, shareObservable, resultSelector: { (_, _) in true })
                .do(onNext: { _ in LoadingIndicator.hide() }, onError: { _ in LoadingIndicator.hide() })
                .take(1)
    }

    func updateUserObservable(shouldLoadUser: Observable<Bool>...) -> Observable<Account> {
        return Observable
                .merge(shouldLoadUser)
                .flatMapLatest({ [unowned self] refresh -> Observable<UserEntity?> in
                    return self.userRepository().getUser(refresh: refresh)
                })
                .filterNil()
                .map({ userEntity -> Account in
                    return Account(userEntity: userEntity)
                })
    }

    func showLoadingFooterObservable(shouldLoadSharesObservable: Observable<(Int, Bool)>,
                                     didLoadSharesObservable: Observable<UpdateableObject>) -> Observable<Bool> {
        let start = shouldLoadSharesObservable
                .filter({ (page, _) -> Bool in
                    page != 1
                })
                .map({ _ in true })

        let stop = didLoadSharesObservable
                .map({ _ in false })

        return Observable.merge(start, stop)
    }

    // -- Errors

    func errorRoutingObservable(errorObservable: Observable<Error>) -> Observable<Routing> {
        return errorObservable
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ error -> Observable<Routing> in
                    if let greenError = error as? GreencardError {
                        switch greenError {
                        case .network:
                            return Observable.just(Routing.alertView(title: "Ошибка интернет-соединения.",
                                    body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.",
                                    repeatCallback: { [unowned self] () in self.retry.onNext(false) }
                            )
                            )
                        default:
                            return Observable.just(Routing.alertView(title: "Неизвестная ошибка.", body: nil, repeatCallback: { [unowned self] () in self.retry.onNext(false) }
                            )
                            )
                        }
                    }
                    return Observable.just(Routing.alertView(title: "Неизвестная ошибка.", body: nil, repeatCallback: { [unowned self] () in self.retry.onNext(false) }
                    )
                    )
                })
    }

    func accountErrorObservable(accountObservable: Observable<Account>) -> Observable<Void> {
        return accountObservable.map({ _ in () })
    }

    func offersErrorObservable(offersObservable: Observable<UpdateableObject>) -> Observable<Void> {
        return offersObservable.map({ _ in () })
    }

    func safeOffersObservable(offersObservable: Observable<UpdateableObject>) -> Observable<UpdateableObject> {
        return offersObservable
                .catchError { (error) -> Observable<UpdateableObject> in
            return Observable.just(UpdateableObject(updates: .empty, animated: false))
        }
    }

    // -- Appearance states

    func willAppearObservableOnce() -> Observable<Void> {
        return bindingsFactory()
                .appearanceState
                .filter({ $0 == .willAppear })
                .map({ _ in () })
                .take(1)
                .do(onNext: { _ in LoadingIndicator.show() })
                .share(replay: 1, scope: SubjectLifetimeScope.forever)
    }
}
