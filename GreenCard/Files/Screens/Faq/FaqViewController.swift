//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift

class FaqViewController: UIViewController, DisposeBagProvider {

    fileprivate var faqView: FaqView {
        return view as? FaqView ?? FaqView()
    }

    lazy var tapObservable = PublishSubject<Int>()

    fileprivate var viewModel: FaqViewModel!
    fileprivate(set) var didScrollTable = PublishSubject<CGFloat>()

    init() {
        super.init(nibName: nil, bundle: nil)

        view = FaqView()
        type = .faq

        faqView.questionsTable.dataSource = self
        faqView.questionsTable.delegate = self

        viewModel = FaqViewModel(bindingsFactory: getBindingsFactory())

        // -- Навигация

        viewModel.menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel.tableRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Table data

        viewModel
                .updateTableObservable
                .bind(to: faqView.questionsTable.rx.observerUpdates)
                .disposed(by: disposeBag)

        viewModel
                .updateTableObservable
                .map({ _ in true })
                .bind(to: faqView.rx.didLoadOffersObserver)
                .disposed(by: disposeBag)

        // -- Error

        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)


        // -- Анимация по скроллу таблицы

        let didScrollTableObservable = didScrollTable
                .asObservable()
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)

        didScrollTableObservable
                .bind(to: faqView.rx.scrollObserver)
                .disposed(by: disposeBag)

        // --
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        faqView.updateHeaderViewFrame()
    }

}

extension FaqViewController: UITableViewDelegate, UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollTable.onNext(scrollView.contentOffset.y)
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return CGFloat(Consts.IPHONE_4_HALF_HEIGHT)
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: FaqTableViewCell = tableView.dequeueReusableCell(withIdentifier: FaqTableViewCell.identifier, for: indexPath)
        as? FaqTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(text: viewModel[indexPath])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapObservable.onNext(indexPath.row)
    }

}

fileprivate extension FaqViewController {

    func getBindingsFactory() -> FaqViewControllerBindingsFactory {
        return { [unowned self] () -> FaqViewControllerBindings in
            return FaqViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    tapItem: self.tapObservable.asObservable()
            )
        }
    }

}
