//
// Created by Hovhannes Sukiasian on 10/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift
import RxGesture

class SharesViewController: UIViewController, DisposeBagProvider {

    fileprivate var sharesView: SharesView {
        return view as? SharesView ?? SharesView()
    }

    lazy var tapShareObservable = PublishSubject<(shareId: Int64?, title: String?, endDate: String?)>()

    fileprivate var viewModel: SharesViewModel!
    fileprivate(set) var didScrollOffers = PublishSubject<CGFloat>()

    var offset = 30

    init() {
        super.init(nibName: nil, bundle: nil)

        view = SharesView()
        type = .shares

        sharesView.offersTable.dataSource = self
        sharesView.offersTable.delegate = self

        // set data sources

        viewModel = SharesViewModel(bindingsFactory: getBindingsFactory())

        // -- Data bindings

        viewModel
                .offersCount
                .asObservable()
                .bind(to: sharesView.rx.offersCount)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .bind(to: sharesView.offersTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .map({ _ in true })
                .bind(to: sharesView.rx.didLoadOffersObserver)
                .disposed(by: disposeBag)

        // -- Navigation

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.detailRoutingObservable
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
                .bind(to: sharesView.rx.scrollObserver)
                .disposed(by: disposeBag)

        // -- Taps

        sharesView.archiveShares.gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 30)
                .rx
                .tapGesture()
                .when(.recognized)
                .map({ _ in Routing.archiveShares})
                .bind(to: rx.observerRouting)
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
        sharesView.updateHeaderViewFrame()
    }

}

extension SharesViewController: UITableViewDelegate, UITableViewDataSource {

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
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer:Offer = viewModel[indexPath]
        tapShareObservable.onNext((shareId: offer.id, title: offer.title, endDate: offer.endDate))
    }

}


fileprivate extension SharesViewController {

    func getBindingsFactory() -> SharesViewControllerBindingsFactory {
        return { [unowned self] () -> SharesViewControllerBindings in
            return SharesViewControllerBindings(
                    tapShareObservable: self.tapShareObservable.asObservable(),
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
