//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias FaqViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        tapItem: Observable<Int>
)

typealias FaqViewControllerBindingsFactory = () -> FaqViewControllerBindings

class FaqViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate lazy var questions: Variable<[FaqListItem]> = Variable([])

    fileprivate let bindingsFactory: FaqViewControllerBindingsFactory

    fileprivate(set) lazy var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var tableRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var updateTableObservable = Observable<UpdateableObject>.never()
    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    required init(bindingsFactory: @escaping FaqViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearsObservable = rx.willAppearObservableOnce()

        // -- Навигация
        menuRoutingObservable = rx.menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        tableRoutingObservable = rx.tableRowRouting(tapObservable: bindingsFactory().tapItem)

        // -- Network

        let loadFaqListObservable = rx.loadFaqListObservable(willAppearObservable: willAppearsObservable)
        let transformFaqListObservable = rx.transformFaqListObservable(loadFaqListObservable: loadFaqListObservable)
        updateTableObservable = rx.safeFaqListObservable(transformFaqListObservable: transformFaqListObservable)

        let saveFaqListObservable = rx.saveFaqListObservable(loadFaqListObservable: loadFaqListObservable)
        saveFaqListObservable
                .subscribe { _ in
                    log("Save faq list")

                }
                .disposed(by: disposeBag)

        // -- Error

        errorObservable = rx.faqListErrorObservable(faqListObservable: transformFaqListObservable)
    }
}

extension FaqViewModel {

    subscript(indexPath: IndexPath) -> String {
        return questions.value[indexPath.row].question ?? ""
    }

    var itemsInSection: Int {
        return questions.value.count
    }

    var sections: Int {
        return questions.value.count == 0 ? 0 : 1
    }

}

fileprivate extension Reactive where Base == FaqViewModel {

    // -- Navigation

    func menuRouting(drawerButtonObservable: Observable<Void>,
                     appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ state in Routing.switchMenu })
    }

    func tableRowRouting(tapObservable: Observable<Int>) -> Observable<Routing> {
        return tapObservable.map({ [unowned base] index in
            let faqItem = base.questions.value[index]
            return Routing.faqDetail(faqItem: faqItem)
        })
    }

    func routingObservable(_ observables: Observable<Routing>) -> Observable<Routing> {
        return Observable.merge(observables)
    }

    // -- Network

    func loadFaqListObservable(willAppearObservable: Observable<Void>) -> Observable<FaqListResponse> {
        return willAppearObservable
                .flatMapLatest({ _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest({ token -> Observable<FaqListResponse> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { (service: NetworkService) -> Observable<FaqListResponse> in
                        let request: Request<FaqListStrategy> = service.request()
                        return request.observe(())
                    })
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    // -- Transform

    func transformFaqListObservable(loadFaqListObservable: Observable<FaqListResponse>) -> Observable<UpdateableObject> {
        return loadFaqListObservable
                .map({ response in response.results })
                .errorOnNil(GreencardError.unknown)
                .flatMapLatest({ list in Observable.from(list) })
                .errorOnNil(GreencardError.unknown)
                .toArray()
                .do(onNext: { [unowned base] list in
                    base.questions.value = list
                })
                .map { list -> UpdateableObject in
                    let changes = (0..<list.count)
                            .map({ IndexPath(row: $0, section: 0) })
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

    // -- Appearance states

    func willAppearObservableOnce() -> Observable<Void> {
        return base.bindingsFactory()
                .appearanceState
                .filter({ $0 == .willAppear })
                .map({ _ in () })
                .take(1)
                .share(replay: 1, scope: SubjectLifetimeScope.forever)
    }

    // -- To view

    func safeFaqListObservable(transformFaqListObservable: Observable<UpdateableObject>) -> Observable<UpdateableObject> {
        return transformFaqListObservable
                .catchError { (error) -> Observable<UpdateableObject> in
            Observable.just(UpdateableObject(updates: .empty, animated: false))
        }
    }

    // -- Errors

    func faqListErrorObservable(faqListObservable: Observable<UpdateableObject>) -> Observable<Void> {
        return faqListObservable.map({ _ in () })
    }

    // -- Save

    func saveFaqListObservable(loadFaqListObservable: Observable<FaqListResponse>) -> Observable<Void> {
        return Observable.just(())
    }

}
