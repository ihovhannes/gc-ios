//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class BalanceView: UIView {

    lazy var title = UILabel()

    lazy var account = AccountView.init()
    lazy var operationsTable = getTableView()

    let tableHeader = BalanceTableHeaderView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(title)
        addSubview(account)
        addSubview(operationsTable)

        title.text = "БАЛАНС\nИ ОПЕРАЦИИ"

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-18)
        }

        let halfHeight: Double = Consts.getTableHeaderHeight() / 2
        account.snp.makeConstraints { account in
            account.centerY.equalTo(self.snp.top).offset(halfHeight - 20)
            account.leading.width.equalToSuperview()
        }

        operationsTable.snp.makeConstraints { operationsTable in
            operationsTable.edges.equalToSuperview()
        }

        account.isShown = false
        operationsTable.isShown = false
        tableHeader.subscribeOnTap(tapCallback: tapOnShowFilterHeader)

        look.apply(Style.balanceView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeaderViewFrame() {
        let height: Double = Consts.getTableHeaderHeight()
        let offset: Double = Consts.getTableHeaderOffset(withFilters: tableHeader.isFilterShown) + Double(BalanceTableSectionHeaderView.HEIGHT) * 0.8
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(height - offset))
        tableHeader.frame = newFrame
        operationsTable.tableHeaderView = tableHeader
    }

}

extension BalanceView {

    fileprivate func tapOnShowFilterHeader(willShow: Bool) {
        if willShow {
            animateCellsDown()
        } else {
            animateCellsUp()
        }
    }

    // -- Cells Animations

    fileprivate func animateCellsDown() {
        let offset: Double = Consts.FILTER_TABLE_HEADER_ANIMATION_OFFSET

        UIView.animate(withDuration: Consts.FILTER_TABLE_HEADER_ANIMATION_DURATION, animations: { [unowned self] () in
            for visibleCell in self.operationsTable.visibleCells {
                visibleCell.transform = CGAffineTransform(translationX: 0, y: CGFloat(offset))
            }
            for index in 0..<self.operationsTable.numberOfSections {
                if let section = self.operationsTable.headerView(forSection: index) {
                    section.transform = CGAffineTransform(translationX: 0, y: CGFloat(offset))
                }
            }
        }, completion: { [weak self] isComplete in
            if let visibleCells = self?.operationsTable.visibleCells {
                for visibleCell in visibleCells {
                    visibleCell.transform = CGAffineTransform.identity
                }
            }
            if let numberOfSection = self?.operationsTable.numberOfSections {
                for index in 0..<numberOfSection {
                    if let section = self?.operationsTable.headerView(forSection: index) {
                        section.transform = CGAffineTransform.identity
                    }
                }
            }
            self?.updateHeaderViewFrame()
        })
    }

    fileprivate func animateCellsUp() {
        let offset: Double = Consts.FILTER_TABLE_HEADER_ANIMATION_OFFSET

        self.updateHeaderViewFrame()
        for visibleCell in operationsTable.visibleCells {
            visibleCell.transform = CGAffineTransform(translationX: 0, y: CGFloat(offset))
        }

        for index in 0..<self.operationsTable.numberOfSections {
            if let section = self.operationsTable.headerView(forSection: index) {
                section.transform = CGAffineTransform(translationX: 0, y: CGFloat(offset))
            }
        }

        UIView.animate(withDuration: Consts.FILTER_TABLE_HEADER_ANIMATION_DURATION, animations: { [unowned self] () in
            for visibleCell in self.operationsTable.visibleCells {
                visibleCell.transform = CGAffineTransform.identity
            }
            for index in 0..<self.operationsTable.numberOfSections {
                if let section = self.operationsTable.headerView(forSection: index) {
                    section.transform = CGAffineTransform.identity
                }
            }
        })
    }

}

fileprivate extension BalanceView {

    func getTableView() -> UITableView {
        let tableView = UITableView(frame: frame, style: .grouped)
        tableView.separatorStyle = .none
        tableView.rowHeight = 80 + 7 * 2
        tableView.estimatedRowHeight = 80 + 7 * 2
        tableView.showsScrollIndicator = false

        tableView.estimatedSectionHeaderHeight = CGFloat(BalanceTableSectionHeaderView.HEIGHT)
        tableView.sectionHeaderHeight = CGFloat(BalanceTableSectionHeaderView.HEIGHT)

        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionFooterHeight = 0

        tableView.allowsSelection = true

        tableView.tableHeaderView = tableHeader
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 7))

        tableView.register(BalanceTableViewCell.self, forCellReuseIdentifier: BalanceTableViewCell.identifier)
        tableView.register(BalanceTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: BalanceTableSectionHeaderView.identifier)
        return tableView

    }

}

fileprivate extension Style {

    static var balanceView: Change<BalanceView> {
        return { (view: BalanceView) -> Void in
            view.backgroundColor = Palette.BalanceView.background.color
            view.operationsTable.backgroundColor = Palette.BalanceView.tableBackground.color

            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.textAlignment = .right
            view.title.numberOfLines = 2
        }
    }

}

extension Reactive where Base == BalanceView {

    var scrollObserver: AnyObserver<CGFloat> {
        return Binder(base, binding: { (view: BalanceView, offset: CGFloat) in
            view.account.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY, y: 0)
            view.title.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
        }).asObserver()
    }

    var didLoadOperationsObserver: AnyObserver<Bool> {
        return Binder(base, binding: { (view: BalanceView, isShown: Bool) in
            if view.account.isShown != isShown {
                view.account.isShown = isShown
                if isShown {
                    view.account.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                        view.account.transform = CGAffineTransform.identity
                    })
                }
            }
            if view.operationsTable.isShown != isShown {
                view.operationsTable.isShown = isShown
                if isShown {
                    view.operationsTable.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                        view.operationsTable.transform = CGAffineTransform.identity
                    })
                }
            }

        }).asObserver()
    }

}
