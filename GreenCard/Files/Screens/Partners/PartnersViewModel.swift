//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias PartnersViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        tapItem: Observable<Int>
)

typealias PartnersViewControllerBindingsFactory = () -> PartnersViewControllerBindings

class PartnersViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate lazy var partnersList: Variable<[PartnerInfo]> = Variable([])

    fileprivate let bindingsFactory: PartnersViewControllerBindingsFactory

    fileprivate(set) lazy var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var tableRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var updateTableObservable = Observable<UpdateableObject>.never()
    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    required init(bindingsFactory: @escaping PartnersViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory;

        let willAppearsObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Navigation

        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu, drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        tableRoutingObservable = rx_tableRowRouting(tapObservable: bindingsFactory().tapItem)


        // -- Network
        let loadListPartnersObservable = rx_loadListPartnersObservable(willAppearObservable: willAppearsObservable)
        let transformListPartnersObservable = rx_transformListPartnersObservable(loadListPartnersObservable: loadListPartnersObservable)
        updateTableObservable = rx_safeUpdateableObservable(observable: transformListPartnersObservable)
        errorObservable = rx_errorObservable(observable: transformListPartnersObservable)

        transformListPartnersObservable
                .subscribe { _ in
                    log("transform")
                }
                .disposed(by: disposeBag)

        let saveListPartnersObservable = rx_saveListPartnersObservable(observable: loadListPartnersObservable)
        saveListPartnersObservable
                .subscribe { _ in
                    log("Save partners list")
                }
                .disposed(by: disposeBag)


    }

}

extension PartnersViewModel {

    subscript(indexPath: IndexPath) -> PartnerInfo {
        return partnersList.value[indexPath.row]
    }

    var itemsInSection: Int {
        return partnersList.value.count
    }

    var sections: Int {
        return partnersList.value.count == 0 ? 0 : 1
    }

}

extension PartnersViewModel: RxViewModelNavigation,
        RxViewModelAppearance,
        RxViewModelUpdateable {
}

extension PartnersViewModel {

    // -- Network

    func rx_loadListPartnersObservable(willAppearObservable: Observable<Void>) -> Observable<ListPartnersResponse> {
        return willAppearObservable
                .flatMapLatest { _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                }
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { token -> Observable<ListPartnersResponse> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { (service: NetworkService) -> Observable<ListPartnersResponse> in
                        let request: Request<ListPartnersStrategy> = service.request()
                        return request.observe(nil)

                    })

                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_tableRowRouting(tapObservable: Observable<Int>) -> Observable<Routing> {
        return tapObservable.map({ [unowned self] index in
            let detail: PartnerInfo = self.partnersList.value[index]
            return Routing.partnerDetail(id: detail.id, logoSrc: detail.logoDetailSrc, pageColor: detail.detailColor)
        })
    }

    // -- Transform

    func rx_transformListPartnersObservable(loadListPartnersObservable: Observable<ListPartnersResponse>) -> Observable<UpdateableObject> {
        return loadListPartnersObservable
                .map({ response in response.results })
                .errorOnNil(GreencardError.unknown)
                .flatMapLatest({ list in Observable.from(list) })
                .errorOnNil(GreencardError.unknown)
                .toArray()
                .do(onNext: { [unowned self] list in
                    self.partnersList.value = list
                })
                .map { list -> UpdateableObject in
                    let changes = (0..<list.count).map({ IndexPath(row: $0, section: 0) })
                    let rowUpdates = RowUpdates(delete: [], insert: changes, reload: [])
                    let sectionUpdates = SectionUpdates(delete: IndexSet(), insert: IndexSet(integer: 0))
                    let updates = Updates(row: rowUpdates, section: sectionUpdates)
                    return UpdateableObject(updates: updates, animated: false)
                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })

    }

    // -- Save

    func rx_saveListPartnersObservable(observable: Observable<ListPartnersResponse>) -> Observable<Void> {
        return Observable.just(())
    }

}
