//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift

class PartnersViewController: UIViewController, DisposeBagProvider  {

    fileprivate var partnersView: PartnersView {
        return view as? PartnersView ?? PartnersView()
    }

    lazy var tapObservable = PublishSubject<Int>()

    fileprivate var viewModel: PartnersViewModel!
    fileprivate(set) var didScrollOffers = PublishSubject<CGFloat>()

    init() {
        super.init(nibName: nil, bundle: nil)

        view = PartnersView()
        type = .partners

        viewModel = PartnersViewModel(bindingsFactory: getBindingsFactory())

        partnersView.partnersTable.dataSource = self
        partnersView.partnersTable.delegate = self


        // -- Data bindings

        viewModel
                .updateTableObservable
                .bind(to: partnersView.partnersTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        viewModel
                .updateTableObservable
                .map({ _ in true })
                .bind(to: partnersView.rx.didLoadPartnersObserver)
                .disposed(by: disposeBag)

        // -- Navigation

        viewModel.menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.tableRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Error

        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)

        // -- Анимация по скроллу таблицы

        let didScrollOffersObservable = didScrollOffers
                .asObservable()
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

        didScrollOffersObservable
                .bind(to: partnersView.rx.scrollObserver)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        partnersView.updateHeaderViewFrame()
    }

}

extension PartnersViewController: UITableViewDelegate, UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollOffers.onNext(scrollView.contentOffset.y)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PartnersTableViewCell = tableView.dequeueReusableCell(withIdentifier: PartnersTableViewCell.identifier, for: indexPath) as? PartnersTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(partnerInfo: viewModel[indexPath])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapObservable.onNext(indexPath.row)
    }

}

fileprivate extension PartnersViewController {

    func getBindingsFactory() -> PartnersViewControllerBindingsFactory {
        return { [unowned self] () -> PartnersViewControllerBindings in
            return PartnersViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    tapItem: self.tapObservable.asObservable()
            )
        }
    }

}

