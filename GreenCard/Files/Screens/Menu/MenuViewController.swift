//
//  MenuViewController.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 03.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Look

class MenuViewController: UIViewController, DisposeBagProvider {

    fileprivate var menuView: MenuView {
        return view as? MenuView ?? MenuView()
    }

    lazy var tapObservable = PublishSubject<Int>()

    fileprivate var viewModel: MenuViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = MenuView()
        type = .menu

        menuView.menu.delegate = self
        menuView.menu.dataSource = self

        viewModel = MenuViewModel(bindingsFactory: getBindingsFactory())

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension MenuViewController {
    func getBindingsFactory() -> MenuViewControllerBindingsFactory {
        return { [unowned self] () -> MenuViewControllerBindings in
            return self.tapObservable.asObservable()
        }
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier,
                for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        cell.name.text = viewModel[indexPath]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapObservable.onNext(indexPath.row)
    }
}
