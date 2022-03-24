//
// Created by Hovhannes Sukiasian on 10/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias SharesViewControllerBindings = (
        tapShareObservable:  Observable<(shareId: Int64?, title: String?, endDate: String?)>,
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias SharesViewControllerBindingsFactory = () -> SharesViewControllerBindings

class SharesViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate lazy var offers: Variable<[Offer]> = Variable([])
    lazy var offersCount: Variable<Int64> = Variable(0)
    fileprivate var page: Int = 1

    fileprivate let bindingsFactory: SharesViewControllerBindingsFactory

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var detailRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var updateOffersObservable = Observable<UpdateableObject>.never()
    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    required init(bindingsFactory: @escaping SharesViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx.willAppearObservableOnce()

        // -- Offers

        let loadOffersObservable = rx.loadOffersObservable(willAppearObservable: willAppearObservable)
        let saveOffersObservable = rx.saveOffersObservable(loadOffersObservable: loadOffersObservable)
        saveOffersObservable
                .subscribe { _ in
                    log("Saved offers")
                }
                .disposed(by: disposeBag)

        let transformOffersObservable = rx.transformOffersObservable(loadOffersObservable: loadOffersObservable)
        updateOffersObservable = rx.safeOffersObservable(offersObservable: transformOffersObservable)

        // -- Error

        errorObservable = rx.errorObservable(rx.offersErrorObservable(offersObservable: transformOffersObservable))

        // -- Navigation

        let menuRoutingObservable = rx.menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        routingObservable = rx.routingObservable(menuRoutingObservable)

        detailRoutingObservable = rx.detailRouting(tapObservable: bindingsFactory().tapShareObservable)

    }

    deinit {
        log("deinit")
    }

}

extension SharesViewModel {

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

fileprivate extension Reactive where Base == SharesViewModel {

    // -- Navigation

    func menuRouting(drawerButtonObservable: Observable<Void>,
                     appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter { state in
                    state == .didAppear
                }
                .map { state in
                    Routing.switchMenu
                }
    }

    func routingObservable(_ observables: Observable<Routing>) -> Observable<Routing> {
        return Observable.merge(observables)
    }

    func detailRouting(tapObservable: Observable<(shareId: Int64?, title: String?, endDate: String?)>) -> Observable<Routing> {
        return tapObservable.map{ args in
            return Routing.shareDetail(id: args.shareId, title: args.title, endDate: args.endDate, partnerColor: nil, isArchive: false)
        }
    }

    // -- Network offers

    func loadOffersObservable(willAppearObservable: Observable<Void>) -> Observable<OfferListResponse> {
        return willAppearObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                }
                .flatMapLatest { [unowned base] token -> Observable<OfferListResponse> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<OfferListResponse> in
                        let request: Request<OfferListStrategy> = service.request()
                        return request.observe(base.page)
                    })
                }
                .do(onNext: nil, onError: { (error) in
                    debugPrint(error)
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func transformOffersObservable(loadOffersObservable: Observable<OfferListResponse>) -> Observable<UpdateableObject> {
        return loadOffersObservable
                .do(onNext: { [unowned base] (response: OfferListResponse) -> Void in
                    base.offersCount.value = Int64(response.count ?? 0)
                })
                .map({ response in response.results })
                .errorOnNil(GreencardError.unknown)
                .flatMapLatest({ list in Observable.from(list) })
                .errorOnNil(GreencardError.unknown)
                .map({ item in Offer(apiObject: item) })
                .toArray()
                .map { [unowned base] list -> ([Offer], Int) in
                    return (list, base.offers.value.count)
                }
                .do(onNext: { [unowned base] list, _ in
                    var array = base.offers.value
                    array.append(contentsOf: list)
                    base.offers.value = array
                })
                .map { list, endIndex -> UpdateableObject in
                    let changes = Array(endIndex...list.count + endIndex - 1)
                            .map { id -> IndexPath in
                                return IndexPath(row: id, section: 0)
                            }
                    let rowUpdates = RowUpdates(delete: [], insert: changes, reload: [])
                    let sectionUpdates = endIndex == 0 ? SectionUpdates(delete: IndexSet(), insert: IndexSet.init(integer: 0)) : .empty
                    let updates = Updates(row: rowUpdates, section: sectionUpdates)
                    return UpdateableObject(updates: updates, animated: false)
                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
    }

    func saveOffersObservable(loadOffersObservable: Observable<OfferListResponse>) -> Observable<Void> {
        return Observable.just(())
    }

    func safeOffersObservable(offersObservable: Observable<UpdateableObject>) -> Observable<UpdateableObject> {
        return offersObservable
                .catchError { (error) -> Observable<UpdateableObject> in
            return Observable.just(UpdateableObject(updates: .empty, animated: false))
        }
    }

    func errorObservable(_ observables: Observable<Void>...) -> Observable<Void> {
        return Observable.merge(observables)
    }

    func offersErrorObservable(offersObservable: Observable<UpdateableObject>) -> Observable<Void> {
        return offersObservable.map({ _ in () })
    }

    // -- Appearence states

    func willAppearObservableOnce() -> Observable<Void> {
        return base.bindingsFactory()
                .appearanceState
                .filter({ $0 == .willAppear })
                .map({ _ in () })
                .take(1)
                .share(replay: 1, scope: SubjectLifetimeScope.forever)
    }

    func didAppearObservable() -> Observable<Void> {
        return base.bindingsFactory()
                .appearanceState
                .filter({ $0 == .didAppear })
                .map({ _ in () })
    }

}
