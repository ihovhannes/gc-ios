//
//  MainView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 27.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class MainView: UIView {

    lazy var account = AccountView.init()
    lazy var offersTable = getTableView()
    lazy var virtualCardHolder = UIView()
    lazy var barcode = UIImageView()
    lazy var virtualCard = UILabel()

    let tableHeader = MainTableHeaderView.init()
    let tableFooter = LoadingTableFooter.init()
    let tableRefreshControl = UIRefreshControl()
    
    let refreshSubject = PublishSubject<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(account)
        addSubview(offersTable)
        addSubview(virtualCardHolder)
        virtualCardHolder.addSubview(barcode)
        virtualCardHolder.addSubview(virtualCard)

        let halfHeight: Double = Consts.getTableHeaderHeight() / 2
        account.snp.makeConstraints { account in
            account.centerY.equalTo(self.snp.top).offset(halfHeight - 20)
            account.leading.width.equalToSuperview()
        }
        offersTable.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        virtualCardHolder.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(19)
            maker.trailing.equalToSuperview().offset(-14)
        }
        barcode.snp.makeConstraints { maker in
            maker.top.trailing.bottom.equalToSuperview()
        }
        virtualCard.snp.makeConstraints { maker in
            maker.top.leading.bottom.equalToSuperview()
            maker.trailing.equalTo(barcode.snp.leading).offset(-16)
        }

        account.isShown = false
        offersTable.isShown = false
        virtualCardHolder.isShown = false

        look.apply(Style.mainView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeaderViewFrame() {
        let height: Double = Consts.getTableHeaderHeight()
        let offset: Double = Consts.getTableHeaderOffset(withFilters: false)
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(height - offset))
        tableHeader.frame = newFrame
        offersTable.tableHeaderView = tableHeader
    }

    func showTableFooter() {
        log("show footer")
        self.tableFooter.spinner.play()

        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: 120)
        tableFooter.frame = newFrame
        offersTable.tableFooterView = tableFooter
    }

    func hideTableFooter() {
        log("hide footer")
        self.tableFooter.spinner.pause()
        self.offersTable.tableFooterView = nil
    }

    var pageLoadingObserver: AnyObserver<Bool> {
        return Binder(self, binding: { (view: MainView, isLoading: Bool) in
            if isLoading {
                view.showTableFooter()
            } else {
                view.hideTableFooter()
            }
        }).asObserver()
    }
}

fileprivate extension MainView {
    func getTableView() -> UITableView {
        let tableView = UITableView(frame: frame, style: .grouped)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = true
        tableView.showsScrollIndicator = false

        tableView.tableHeaderView = tableHeader
        //tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 7))
        
//        if #available(iOS 10.0, *) {
//            tableView.refreshControl = tableRefreshControl
//        } else {
//            tableView.addSubview(tableRefreshControl)
//        }
//        tableRefreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)

        tableView.register(OfferTableViewCell.self, forCellReuseIdentifier: OfferTableViewCell.identifier)
        return tableView
    }
    
    @objc func reload() {
        refreshSubject.onNext(())
    }
}

fileprivate extension Style {
    static var mainView: Change<MainView> {
        return { (view: MainView) -> Void in
            view.backgroundColor = Palette.MainView.background.color
            view.offersTable.backgroundColor = Palette.MainView.collectionBackground.color

            view.barcode.image = UIImage(named: "ic_barcode")
            view.barcode.contentMode = .scaleAspectFit
            view.virtualCard.textColor = Palette.Common.whiteText.color
            view.virtualCard.text = "ВИРТУАЛЬНАЯ\nКАРТА"
            view.virtualCard.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.virtualCard.textAlignment = .right
            view.virtualCard.numberOfLines = 2
            view.tableRefreshControl.tintColor = Palette.Common.greenText.color
        }
    }
}

extension Reactive where Base == MainView {

    var scrollObserver: AnyObserver<CGFloat> {
        return Binder(base, binding: { (view: MainView, offset: CGFloat) in
            view.account.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY, y: 0)
            view.virtualCardHolder.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
        }).asObserver()
    }

    var didLoadOffersObserver: AnyObserver<Bool> {
        return Binder(base, binding: { (view: MainView, isShown: Bool) in
            if view.account.isShown != isShown {
                view.account.isShown = isShown
                if isShown {
                    view.account.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                        view.account.transform = CGAffineTransform.identity
                    })
                }
            }
            if view.offersTable.isShown != isShown {
                view.offersTable.isShown = isShown
                if isShown {
                    view.offersTable.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                        view.offersTable.transform = CGAffineTransform.identity
                    })
                }
            }
        }).asObserver()
    }

    var offersCount: AnyObserver<Int> {
        return Binder(base, binding: { (view: MainView, value: Int) in
            view.tableHeader.setOffersCount(newValue: "\(value)")
        }).asObserver()
    }

}
