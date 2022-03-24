//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift

class BalanceViewController: UIViewController, DisposeBagProvider {

    fileprivate var balanceView: BalanceView {
        return view as? BalanceView ?? BalanceView()
    }

    var tapObservable = PublishSubject<(Int, Int)>()
    fileprivate var viewModel: BalanceViewModel!

    fileprivate(set) var didScrollOperations = PublishSubject<CGFloat>()
    fileprivate(set) var doesNeedMoreData = PublishSubject<Void>()

    init() {
        super.init(nibName: nil, bundle: nil)

        view = BalanceView()
        type = .balance

        balanceView.operationsTable.delegate = self
        balanceView.operationsTable.dataSource = self

        viewModel = BalanceViewModel(bindingsFactory: getBindingsFactory())

        // -- Data bindings

        viewModel
                .accountObservable
                .map({ event in event.element })
                .filter({ $0 != nil })
                .map({ $0! })
                .bind(to: balanceView.account)
                .disposed(by: disposeBag)

        viewModel.accountObservable
                .map({ event in event.error })
                .filter({ $0 != nil })
                .map({ $0! })
                .map(errorToRouting(error: ))
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.accountObservable
                .map({ _ in true })
                .bind(to: balanceView.rx.didLoadOperationsObserver)
                .disposed(by: disposeBag)

        viewModel
                .updateOperationsObservable
                .bind(to: balanceView.operationsTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        // -- Error
        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("Error: \(error)")
                })
                .disposed(by: disposeBag)

        // Navigation

        viewModel.menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.tableRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Animation by scroll table

        let didScrollOperationsObservable = didScrollOperations
                .asObservable()
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

        didScrollOperationsObservable
                .bind(to: balanceView.rx.scrollObserver)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        balanceView.updateHeaderViewFrame()
    }

}

extension BalanceViewController: RoutingError {

}

extension BalanceViewController: UITableViewDelegate, UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollOperations.onNext(scrollView.contentOffset.y)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsInSection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: BalanceTableViewCell = tableView.dequeueReusableCell(withIdentifier: BalanceTableViewCell.identifier, for: indexPath) as? BalanceTableViewCell else {
            return UITableViewCell()
        }
        let data: OperationItem = viewModel[indexPath]
        cell.configure(apiVendorName: data.vendorName, apiBonuses: data.bonuses, apiTotalPrice: data.totalPrice, apiDate: data.dateOf)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header: BalanceTableSectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: BalanceTableSectionHeaderView.identifier) as? BalanceTableSectionHeaderView else {
            return UITableViewHeaderFooterView()
        }
        header.configure(day: viewModel.headerTitle(for: section))
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapObservable.onNext((indexPath.section, indexPath.row))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == viewModel.sections - 2) {
//            doesNeedMoreData.onNext(())
        }
    }

}

fileprivate extension BalanceViewController {

    func getBindingsFactory() -> BalanceViewControllerBindingsFactory {
        return { [unowned self] () -> BalanceViewControllerBindings in
            return BalanceViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    tapItem: self.tapObservable.asObservable(),
                    doesNeedMoreData: self.doesNeedMoreData.asObservable()
            )

        }
    }

}
