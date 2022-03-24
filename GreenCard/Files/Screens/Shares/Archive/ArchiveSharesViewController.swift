//
// Created by Hovhannes Sukiasian on 29/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift
import RxGesture

class ArchiveSharesViewController: UIViewController, DisposeBagProvider {

    fileprivate var archiveSharesView: ArchiveSharesView {
        return view as? ArchiveSharesView ?? ArchiveSharesView()
    }

    lazy var tapShareObservable = PublishSubject<(shareId: Int64?, title: String?, endDate: String?)>()

    fileprivate var viewModel: ArchiveSharesViewModel!
    fileprivate(set) var didScrollOffers = PublishSubject<CGFloat>()

    init() {
        super.init(nibName: nil, bundle: nil)

        view = ArchiveSharesView()
        type = .archiveShares

        // -- Table delegates

        archiveSharesView.offersTable.dataSource = self
        archiveSharesView.offersTable.delegate = self

        viewModel = ArchiveSharesViewModel(bindingsFactory: getBindingsFactory())

        // -- Data bindings

        viewModel
                .offersCount
                .asObservable()
                .bind(to: archiveSharesView.rx.offersCount)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .bind(to: archiveSharesView.offersTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .map({ _ in ()})
                .bind(to: archiveSharesView.rx.didLoadOffersObserver)
                .disposed(by: disposeBag)

        // -- Error

        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)

        // -- Navigation

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.detailRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Scroll animation

        didScrollOffers
                .asObservable()
                .bind(to: archiveSharesView.rx.scrollObserver)
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        archiveSharesView.updateHeaderViewFrame()
    }

}

extension ArchiveSharesViewController : UITableViewDelegate, UITableViewDataSource {

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
        guard let cell: OfferTableViewCell = tableView.dequeueReusableCell(withIdentifier: OfferTableViewCell.identifier, for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(offer: viewModel[indexPath])
        cell.showTimeLeft(isShown: false)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer:Offer = viewModel[indexPath]
        tapShareObservable.onNext((shareId: offer.id, title: offer.title, endDate: offer.endDate))
    }

}

fileprivate extension ArchiveSharesViewController {

    func getBindingsFactory() -> ArchiveSharesViewControllerBindingsFactory {
        return { [unowned self] () -> ArchiveSharesViewControllerBindings in
            return ArchiveSharesViewControllerBindings(
                    tapShareObservable: self.tapShareObservable.asObservable(),
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
