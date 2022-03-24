//
// Created by Hovhannes Sukiasian on 26/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class PartnerSharesViewController: UIViewController, DisposeBagProvider {

    fileprivate var partnerShares: PartnerSharesView {
        return view as? PartnerSharesView ?? PartnerSharesView()
    }

    lazy var tapShareObservable = PublishSubject<(shareId: Int64?, title: String?, endDate: String?)>()

    fileprivate var viewModel: PartnerSharesViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = PartnerSharesView()
        type = .partnerShares

        partnerShares.offersTable.dataSource = self
        partnerShares.offersTable.delegate = self

        viewModel = PartnerSharesViewModel(bindingsFactory: getBindingsFactory())

        // -- Navigation

        viewModel.menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.detailRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        partnerShares
                .locationButton
                .rx
                .tapGesture()
                .when(.recognized)
                .flatMapLatest({ [unowned self] _ in self.viewModel.locationsRoutingObservable })
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Data bindings

        viewModel
                .offersCount
                .asObservable()
                .bind(to: partnerShares.rx.offersCountObserver)
                .disposed(by: disposeBag)

        viewModel
                .partnerVendors
                .asObservable()
                .bind(to: partnerShares.rx.vendorsObserver)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .bind(to: partnerShares.offersTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .map({_ in true})
                .bind(to: partnerShares.rx.didLoadOffersObserver)
                .disposed(by: disposeBag)

        // -- Error

        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        partnerShares.updateHeaderViewFrame()
    }

    func configure(partnerId: Int64, pageColor: UIColor, logoSrc: String?, vendors: PartnerVendorsResponse?, mapLogo: String?) -> PartnerSharesViewController {
        viewModel.partnerId.value = partnerId
        viewModel.partnerColor.value = pageColor
        viewModel.partnerVendors.value = vendors
        viewModel.partnerLogoMapSrc.value = mapLogo
        partnerShares.configure(pageColor: pageColor, logoSrc: logoSrc)
        return self
    }

}

extension PartnerSharesViewController: UITableViewDelegate, UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        partnerShares.scrollTable(offset: scrollView.contentOffset.y)
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

fileprivate extension PartnerSharesViewController {

    func getBindingsFactory() -> PartnerSharesViewControllerBindingsFactory {
        return { [unowned self] () -> PartnerSharesViewControllerBindings in
            return PartnerSharesViewControllerBindings(
                    tapShareObservable: self.tapShareObservable.asObservable(),
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
