//
// Created by Hovhannes Sukiasian on 30/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias ShareDetailViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        backSwipe: Observable<Void>
)

typealias ShareDetailViewControllerBindingsFactory = () -> ShareDetailViewControllerBindings


class ShareDetailViewModel: ReactiveCompatible, DisposeBagProvider {

    var isArchive: Bool = false

    lazy var shareId: Variable<Int64?> = Variable(nil)
    lazy var partnerColor: Variable<UIColor?> = Variable(nil)
    lazy var retry: PublishSubject<Void> = PublishSubject<Void>()
    lazy var error: PublishSubject<Error> = PublishSubject<Error>()

    fileprivate let bindingsFactory: ShareDetailViewControllerBindingsFactory
    fileprivate let shareRepository: ShareRepository

    fileprivate(set) var routingObservable = Observable<Routing>.never()

    fileprivate(set) lazy var updateShareObservable = Observable<(imgSrc: String?, description: String?)>.never()

    required init(bindingsFactory: @escaping ShareDetailViewControllerBindingsFactory,
                  shareRepository: @escaping () -> ShareRepository) {
        self.bindingsFactory = bindingsFactory
        self.shareRepository = shareRepository()

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Network
        let shouldLoadObservable = rx_shouldLoadObservable(observables: willAppearObservable, retry.asObservable())
        let loadShare = rx_loadShareObservable(shouldLoadObservable: shouldLoadObservable, shareIdObservable: shareId.asObservable())

        updateShareObservable = rx_transform(loadShareObservable: loadShare)

        // -- Navigation

        let menuRoutingObservable = rx_menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)
        let backSwipeRoutingObservable = rx_backRouting(backSwipeObservable: bindingsFactory().backSwipe)
        let errorRoutingObservable = rx_errorRouting(errorObservable: error.asObservable())

        routingObservable = rx_routing(observables: menuRoutingObservable, backSwipeRoutingObservable, errorRoutingObservable)
    }

    convenience init(bindingsFactory: @escaping ShareDetailViewControllerBindingsFactory) {
        self.init(
                bindingsFactory: bindingsFactory,
                shareRepository: { ShareRepository() }
        )
    }
}

extension ShareDetailViewModel: RxViewModelAppearance, RxViewModelError {
}

fileprivate extension ShareDetailViewModel {

    // -- Navigation

    func rx_routing(observables: Observable<Routing>...) -> Observable<Routing> {
        return Observable.merge(observables)
    }

    func rx_menuRouting(drawerButtonObservable: Observable<Void>,
                        appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ _ in Routing.backWithMenuColor(color: self.partnerColor.value) })
    }

    func rx_backRouting(backSwipeObservable: Observable<Void>) -> Observable<Routing> {
        return backSwipeObservable
                .map({ _ in Routing.backWithMenuColor(color: self.partnerColor.value) })
    }

    func rx_errorRouting(errorObservable: Observable<Error>) -> Observable<Routing> {
        return errorObservable
                .observeOn(MainScheduler.instance)
                .flatMapLatest({ error -> Observable<Routing> in
                    return Observable.just(ErrorHander.errorToRouting1(error: error, repeatCallback: { [unowned self] () in self.retry.onNext(()) }))
                })
    }

    // -- Network

    func rx_shouldLoadObservable(observables: Observable<Void>...) -> Observable<Void> {
        return Observable.merge(observables)
    }

    func rx_loadShareObservable(shouldLoadObservable: Observable<Void>, shareIdObservable: Observable<Int64?>) -> Observable<ShareEntity?> {
        return shouldLoadObservable
                .flatMapLatest({ _ in shareIdObservable })
                .errorOnNil(GreencardError.unknown)
                .flatMapLatest({ [unowned self] shareId -> Observable<ShareEntity?> in
                    return self
                            .shareRepository
//                            .getShare(id: shareId, isArchive: self.isArchive ?? false)
                            .getShareFromApi(id: shareId, isArchive: self.isArchive ?? false)
                            .catchError({ [unowned self] error -> Observable<ShareEntity?> in
                                self.error.onNext(error)
                                return self.shareRepository.getShareFromDb(id: shareId)
                            })
                })
    }

    func rx_transform(loadShareObservable: Observable<ShareEntity?>) -> Observable<(imgSrc: String?, description: String?)> {
        return loadShareObservable
                .map { shareEntity in
                    guard let shareEntity = shareEntity else {
                        return (nil, nil)
                    }
                    return (shareEntity.verticalImage, shareEntity.content)
                }
                .observeOn(MainScheduler.instance)
    }
}
