//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias BalanceViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        tapItem: Observable<(Int, Int)>,
        doesNeedMoreData: Observable<Void>
)

typealias BalanceViewControllerBindingsFactory = () -> BalanceViewControllerBindings

fileprivate class SectionItem {

    var data: String = ""
    var operations: [OperationItem] = []

    var isEmpty: Bool {
        return data == "" && operations.count == 0
    }

    init() {
    }
}

class BalanceViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: BalanceViewControllerBindingsFactory

    fileprivate var page: Int = 1
    fileprivate var operations: Variable<[SectionItem]> = Variable([])
    
    fileprivate var currentOperationCount: Variable<Int> = Variable(0)
    fileprivate var totalOperationCount: Variable<Int> = Variable(0)

    fileprivate(set) lazy var accountObservable = Observable<Event<Account>>.never()
    fileprivate(set) lazy var updateOperationsObservable = Observable<UpdateableObject>.never()
    fileprivate(set) lazy var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var tableRoutingObservable = Observable<Routing>.never()
    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    required init(bindingsFactory: @escaping BalanceViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Network Account
        let loadAccount = loadAccountObservable(willAppearObservable: willAppearObservable)
        let saveAccount = saveAccountObservable(loadAccountObservable: loadAccount)
        saveAccount
                .subscribe { _ in
                    log("Saved user")
                }
                .disposed(by: disposeBag)

        accountObservable = transformAccountObservable(loadAccountObservable: loadAccount)

        // -- Network operations
        let didLoadAllData = didLoadAllDataObservable(didUpdateTotalCount: totalOperationCount.asObservable(),
                                                      didUpdateCurrentCount: currentOperationCount.asObservable())
        let shouldLoad = shouldLoadOperationsObservable(willAppearObservable: willAppearObservable,
                                                        doesNeedMoreDataObservable: bindingsFactory().doesNeedMoreData,
                                                        didLoadAllData: didLoadAllData)
        let loadOperations = loadOperationsObservable(shouldLoadObservable: shouldLoad)
        let transformOperations = transformOperationsObservable(loadOperationsObservable: loadOperations)
        let saveOperations = saveOffersObservable(loadOffersObservable: loadOperations)
        saveOperations
                .subscribe { _ in
                    log("Saved operations")

                }
                .disposed(by: disposeBag)
        updateOperationsObservable = rx_safeUpdateableObservable(observable: transformOperations)


        // -- Navigation

        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu,
                                               drawerButtonObservable: bindingsFactory().drawerButton,
                                               appearanceStateObservable: bindingsFactory().appearanceState)

        tableRoutingObservable = tableRowRouting(tapObservable: bindingsFactory().tapItem)

        // -- Error

        errorObservable = errorObservable(accountErrorObservable(accountObservable: accountObservable),
                rx_errorObservable(observable: transformOperations))

    }

}

extension BalanceViewModel {

    subscript(indexPath: IndexPath) -> OperationItem {
        return operations.value[indexPath.section].operations[indexPath.row]
    }

    func headerTitle(for section: Int) -> String {
        return operations.value[section].data
    }

    func itemsInSection(section: Int) -> Int {
        return operations.value[section].operations.count
    }

    var sections: Int {
        return operations.value.count
    }

}

extension BalanceViewModel: RxViewModelNavigation, RxViewModelAppearance, RxViewModelUpdateable {
}

fileprivate extension BalanceViewModel {

    // -- Navigation

    func tableRowRouting(tapObservable: Observable<(Int, Int)>) -> Observable<Routing> {
        return tapObservable.map { [unowned self] index in
            let operationItem = self.operations.value[index.0].operations[index.1]
            return Routing.operationDetails(operationId: operationItem.uniqueId)
        }
    }

    // -- Network Account
    
    func didLoadAllDataObservable(didUpdateTotalCount: Observable<Int>, didUpdateCurrentCount: Observable<Int>) -> Observable<Void> {
        return Observable
            .combineLatest(didUpdateTotalCount, didUpdateCurrentCount, resultSelector: { (total, current) -> Bool in
                return current != 0 && total == current
            })
            .filter({ $0 })
            .map({ _ in () })
    }
    
    func shouldLoadOperationsObservable(willAppearObservable: Observable<Void>,
                                        doesNeedMoreDataObservable: Observable<Void>,
                                        didLoadAllData: Observable<Void>) -> Observable<Int> {
        return Observable.merge(willAppearObservable, doesNeedMoreDataObservable)
            .takeUntil(didLoadAllData)
            .map({ [unowned self] _ in self.page })
    }

    func loadAccountObservable(willAppearObservable: Observable<Void>) -> Observable<Event<UserResponse>> {
        return willAppearObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                }
                .flatMapLatest { token -> Observable<Event<UserResponse>> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<Event<UserResponse>> in
                        let request: Request<UserStrategy> = service.request()
                        return request.observe(()).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func transformAccountObservable(loadAccountObservable: Observable<Event<UserResponse>>) -> Observable<Event<Account>> {
        return loadAccountObservable
                .map({ event in  event.map(Account.init(apiObject: )) })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func saveAccountObservable(loadAccountObservable: Observable<Event<UserResponse>>) -> Observable<Void> {
        return Observable.just(()) //TODO: rewrite for saving
    }

    // --

    func loadOperationsObservable(shouldLoadObservable: Observable<Int>) -> Observable<OperationsListResponse> {
        return shouldLoadObservable
                .flatMapLatest { _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                }
                .flatMapLatest { (token: String) -> Observable<OperationsListResponse> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<OperationsListResponse> in
                        let request: Request<OperationsListStrategy> = service.request()
                        return request.observe(self.page)
                    })
                }
                .do(onNext: nil, onError: { (error) in
                    log("Error:\n\(error)")
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func transformOperationsObservable(loadOperationsObservable: Observable<OperationsListResponse>) -> Observable<UpdateableObject> {
        return loadOperationsObservable
                .do(onNext: { [unowned self] response in
                    self.totalOperationCount.value = response.count ?? 0
                })
                .map({ response in return response.results })
                .errorOnNil(GreencardError.unknown)
                .map({ items -> [OperationItem] in //TODO: check and fix
                    return items
                        .filter({ (item) -> Bool in
                            return item != nil
                        })
                        .map({ (item) -> OperationItem in
                            return item!
                        })
                })
                /*.flatMapLatest({ list in Observable.from(list) })
                .errorOnNil(GreencardError.unknown)
                .toArray()*/
                .do(onNext: { [unowned self] items in
                    self.currentOperationCount.value += items.count
                })
                .map { [unowned self] (newList: [OperationItem]) -> UpdateableObject in
                    guard newList.count > 0 else {
                        return UpdateableObject(updates: .empty, animated: false)
                    }

                    var indexNewSections: IndexSet = IndexSet.init()

                    var sectionsArray = self.operations.value
                    var currentSection: SectionItem = SectionItem()

                    if sectionsArray.count == 0 {
                        indexNewSections.insert(0)
                        sectionsArray.append(currentSection)
                    } else {
                        currentSection = sectionsArray[sectionsArray.count - 1]
                    }

                    var changes: [IndexPath] = []

                    for operation in newList {
                        if currentSection.isEmpty {
                            currentSection.data = operation.day
                        } else if currentSection.data != operation.day {
                            currentSection = SectionItem()
                            currentSection.data = operation.day
                            sectionsArray.append(currentSection)
                            indexNewSections.insert(sectionsArray.count - 1)
                        }

                        currentSection.operations.append(operation)
                        changes.append(IndexPath(row: currentSection.operations.count - 1, section: sectionsArray.count - 1))
                    }


                    self.operations.value = sectionsArray

                    let rowUpdates = RowUpdates(delete: [], insert: changes, reload: [])
                    let sectionUpdates: SectionUpdates = SectionUpdates(delete: IndexSet(), insert: indexNewSections)
                    let updates = Updates(row: rowUpdates, section: sectionUpdates)
                    return UpdateableObject(updates: updates, animated: false)
                }
                .do(onNext: { [unowned self] _ in
                    self.page += 1
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
    }

    func saveOffersObservable(loadOffersObservable: Observable<OperationsListResponse>) -> Observable<Void> {
        return Observable.just(()) //TODO: rewrite for saving
    }

// -- Errors

    func errorObservable(_ observables: Observable<Void>...) -> Observable<Void> {
        return Observable.merge(observables)
    }

    func accountErrorObservable(accountObservable: Observable<Event<Account>>) -> Observable<Void> {
        return accountObservable.map({ _ in () })
    }

}
