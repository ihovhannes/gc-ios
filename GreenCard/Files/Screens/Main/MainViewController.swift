//
//  MainViewController.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 28.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import PINRemoteImage
import RxSwift

class MainViewController: UIViewController, DisposeBagProvider {

    fileprivate var mainView: MainView {
        return view as? MainView ?? MainView()
    }

    lazy var tapShareObservable = PublishSubject<(shareId: Int64?, title: String?, endDate: String?)>()

    fileprivate var viewModel: MainViewModel!

    fileprivate(set) var didScrollOffers = PublishSubject<CGFloat>()
    fileprivate(set) var doesNeedMoreData = PublishSubject<Void>()

    init() {
        super.init(nibName: nil, bundle: nil)

        view = MainView()
        type = .main

        mainView.offersTable.dataSource = self
        mainView.offersTable.delegate = self

        viewModel = MainViewModel(bindingsFactory: getbindingsFactory())

        // -- Data bindings

        viewModel
                .accountObservable
                .bind(to: mainView.account)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .bind(to: mainView.offersTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        viewModel
                .updateOffersObservable
                .bind { [unowned self] _ in
                    self.mainView.tableRefreshControl.endRefreshing()
                }
                .disposed(by: disposeBag)

        viewModel
                .playAnimationObservable
                .map({ _ in true })
                .bind(to: mainView.rx.didLoadOffersObserver)
                .disposed(by: disposeBag)

        viewModel
                .showLoadingFooter
                .bind(to: mainView.pageLoadingObserver)
                .disposed(by: disposeBag)

        viewModel
                .offersCount
                .asObservable()
                .bind(to: mainView.rx.offersCount)
                .disposed(by: disposeBag)

        // -- Навигация

        viewModel
                .routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel
                .accountObservable
                .filter({ acc in
                    if let isActive = acc.isActive {
                        return !isActive
                    }
                    return false
                })
                .map({ _ in Routing.oferta(type: .activationOfertaAccept, header: "Активация\nучетной записи", acceptCallback: nil) })
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Анимация по скроллу таблицы

        let didScrollOffersObservable = didScrollOffers
                .asObservable()
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

        didScrollOffersObservable
                .bind(to: mainView.rx.scrollObserver)
                .disposed(by: disposeBag)

//        // Taps
//
//        mainView.virtualCardHolder.gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
//                .rx.tapGesture()
//                .when(.recognized)
//                .map({ _ in Routing.toastView(msg: "В разработке") })
//                .bind(to: rx.observerRouting)
//                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.updateHeaderViewFrame()
    }

    func configure(needRefresh: Bool) -> Self {
        self.mainView.refreshSubject.onNext(())
        return self
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollOffers.onNext(scrollView.contentOffset.y)
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: MainOfferHeaderView.identifier) as? MainOfferHeaderView
//        view?.amountText.text = String(viewModel.offersCount)
//        return view
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat(Consts.IPHONE_4_HEIGHT - 30)
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: OfferTableViewCell = tableView.dequeueReusableCell(withIdentifier: OfferTableViewCell.identifier,
                for: indexPath) as? OfferTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(offer: viewModel[indexPath])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer: Offer = viewModel[indexPath]
        tapShareObservable.onNext((shareId: offer.id, title: offer.title, endDate: offer.endDate))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.itemsInSection - 2) {
//            doesNeedMoreData.onNext(())
        }
    }
}

fileprivate extension MainViewController {
    func getbindingsFactory() -> MainViewControllerBindingsFactory {
        return { [unowned self] () -> MainViewControllerBindings in
            return MainViewControllerBindings(
                    tapShareObservable: self.tapShareObservable.asObservable(),
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    doesNeedMoreData: self.doesNeedMoreData.asObservable(),
                    reloadData: self.mainView.refreshSubject.asObservable()
            )
        }
    }
}
