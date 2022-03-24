//
// Created by Hovhannes Sukiasian on 26/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

typealias PartnerSharesViewControllerBindings = (
        tapShareObservable:  Observable<(shareId: Int64?, title: String?, endDate: String?)>,
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias PartnerSharesViewControllerBindingsFactory = () -> PartnerSharesViewControllerBindings

class PartnerSharesViewModel: ReactiveCompatible, DisposeBagProvider {

    lazy var partnerId: Variable<Int64?> = Variable(nil)
    lazy var partnerColor: Variable<UIColor?> = Variable(nil)
    lazy var partnerVendors: Variable<PartnerVendorsResponse?> = Variable(nil)
    lazy var partnerLogoMapSrc: Variable<String?> = Variable(nil)

    fileprivate lazy var offers: Variable<[Offer]> = Variable([])
    lazy var offersCount: Variable<Int64> = Variable(0)
    fileprivate var page: Int = 1

    fileprivate let bindingsFactory: PartnerSharesViewControllerBindingsFactory

    fileprivate(set) lazy var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var detailRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var locationsRoutingObservable = Observable<Routing>.never()

    fileprivate(set) lazy var updateOffersObservable = Observable<UpdateableObject>.never()
    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    required init(bindingsFactory: @escaping PartnerSharesViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory;

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Navigation

        menuRoutingObservable = rx_menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        detailRoutingObservable = rx_detailRouting(tapObservable: bindingsFactory().tapShareObservable)

        locationsRoutingObservable = rx_locationsRouting(partnerIdObservable: partnerId.asObservable())

        // -- Offers

        let loadOffersObservable = rx_loadSharesObservable(willAppearObservable, partnerIdObservable: partnerId.asObservable())
        let saveOffersObservable = rx_saveOffersObservable(loadOffersObservable: loadOffersObservable)
        saveOffersObservable
                .subscribe { arg in
                    log("Saved offers \(arg)")
                }
                .disposed(by: disposeBag)

        let transformOffersObservable = rx_transformOffersObservable(loadOffersObservable: loadOffersObservable)
        updateOffersObservable = rx_safeOffersObservable(offersObservable: transformOffersObservable)

        // -- Error

        errorObservable = rx_offersErrorObservable(offersObservable: transformOffersObservable)
    }

}

extension PartnerSharesViewModel: RxViewModelError, RxViewModelAppearance, RxViewModelUpdateable {
}

extension PartnerSharesViewModel {

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


fileprivate extension PartnerSharesViewModel {

    // -- Navigation

    func rx_detailRouting(tapObservable: Observable<(shareId: Int64?, title: String?, endDate: String?)>) -> Observable<Routing> {
        return tapObservable.map{ [weak self] args in
            return Routing.shareDetail(id: args.shareId, title: args.title, endDate: args.endDate, partnerColor: self?.partnerColor.value, isArchive: false)
        }
    }

    func rx_menuRouting(drawerButtonObservable: Observable<Void>,
                        appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ [weak self]   state in
                    Routing.backWithMenuColor(color: self?.partnerColor.value)
                })
    }

    func rx_locationsRouting(partnerIdObservable: Observable<Int64?>) -> Observable<Routing> {
        return Observable.just(())
                .flatMapLatest({ partnerIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .map { [unowned self] partnerId in
                    return Routing.partnerLocations(partnerId: partnerId,
                            color: self.partnerColor.value ?? .black,
                            vendors: self.partnerVendors.value,
                            mapLogoSrc: self.partnerLogoMapSrc.value)
                }
    }

    // -- Network

    func rx_loadSharesObservable(_ willAppearObservable: Observable<Void>, partnerIdObservable: Observable<Int64?>) -> Observable<OfferListResponse> {
        return willAppearObservable
                .flatMapLatest({ partnerIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { (partnerId: Int64) -> Observable<(partnerId: Int64, token: String)> in
                    log("\(partnerId)")
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (partnerId: partnerId, token: $0)
                            }
                }
                .flatMapLatest { [unowned self] (partnerId: Int64, token: String) -> Observable<OfferListResponse> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<OfferListResponse> in
                        let request: Request<PartnerSharesStrategy> = service.request()
                        return request.observe((partnerId, self.page))
                    })
                }
                .do(onNext: { result in
                    log("\(result)")
                }, onError: { (error) in
                    log("\(error)")
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transformOffersObservable(loadOffersObservable: Observable<OfferListResponse>) -> Observable<UpdateableObject> {
        return loadOffersObservable
                .do(onNext: { [unowned self] (response: OfferListResponse) -> Void in
                    self.offersCount.value = Int64(response.count ?? 0)
                })
                .map({ response in response.results })
                .errorOnNil(GreencardError.unknown)
                .map { (results: [ShareResponse?]) -> [Offer] in
                    return results.flatMap { itemOpt in
                        if let item = itemOpt {
                            return Offer(apiObject: item)
                        }
                        return nil
                    }
                }
                .map { [unowned self] list -> ([Offer], Int) in
                    return (list, self.offers.value.count)
                }
                .do(onNext: { [unowned self] list, _ in
                    var array = self.offers.value
                    array.append(contentsOf: list)
                    self.offers.value = array
                })
                .map { list, endIndex -> UpdateableObject in
                    if list.count == 0 {
                        return UpdateableObject(updates: .empty, animated: false)
                    }

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

    func rx_saveOffersObservable(loadOffersObservable: Observable<OfferListResponse>) -> Observable<Void> {
        return Observable.just(())
    }

    func rx_safeOffersObservable(offersObservable: Observable<UpdateableObject>) -> Observable<UpdateableObject> {
        return offersObservable
                .catchError { (error) -> Observable<UpdateableObject> in
            return Observable.just(UpdateableObject(updates: .empty, animated: false))
        }
    }

    func rx_offersErrorObservable(offersObservable: Observable<UpdateableObject>) -> Observable<Void> {
        return offersObservable.map({ _ in () })
    }

}
