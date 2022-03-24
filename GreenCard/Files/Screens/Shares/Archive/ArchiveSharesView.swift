//
// Created by Hovhannes Sukiasian on 29/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class ArchiveSharesView: UIView {

    let tableHeader = MainTableHeaderView.init()
    lazy var offersTable = getTableView()

    lazy var title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(offersTable)

        addSubview(title)

        title.text = "АРХИВ\nАКЦИЙ"
        tableHeader.setTitle(text: "Истекшие\nакции")

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-18)
        }

        offersTable.snp.makeConstraints { offersTable in
            offersTable.edges.equalToSuperview()
        }

        offersTable.isShown = false

        look.apply(Style.archiveSharesView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

    func updateHeaderViewFrame() {
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: 260)
        tableHeader.frame = newFrame
        offersTable.tableHeaderView = tableHeader
    }

}

fileprivate extension ArchiveSharesView {

    func showTable() {
        offersTable.isShown = true
        offersTable.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned self] () in
            self.offersTable.transform = CGAffineTransform.identity
        })
    }

}

fileprivate extension ArchiveSharesView {

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
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 7))

        tableView.register(OfferTableViewCell.self, forCellReuseIdentifier: OfferTableViewCell.identifier)
        return tableView
    }

}


fileprivate extension Style {

    static var archiveSharesView: Change<ArchiveSharesView> {
        return { (view: ArchiveSharesView) -> Void in
            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.numberOfLines = 2
            view.title.textAlignment = .right

            view.backgroundColor = Palette.SharesView.background.color
            view.offersTable.backgroundColor = Palette.SharesView.collectionBackground.color
        }
    }

}

extension Reactive where Base == ArchiveSharesView {

    var scrollObserver: AnyObserver<CGFloat> {
        return Binder(base, binding: { (view: ArchiveSharesView, offset: CGFloat) in
            view.title.transform = CGAffineTransform(translationX: 0, y: -1 * offset/* / Consts.TITLE_ANIMATION_VELOCITY*/)
        }).asObserver()
    }

    var didLoadOffersObserver: AnyObserver<()> {
        return Binder(base, binding: { (view: ArchiveSharesView, input: ()) in
            view.showTable()
        }).asObserver()
    }

    var offersCount: AnyObserver<Int64> {
        return Binder(base, binding: { (view: ArchiveSharesView, value: Int64) in
            view.tableHeader.setOffersCount(newValue: "\(value)")
        }).asObserver()
    }

}
