//
// Created by Hovhannes Sukiasian on 10/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import Lottie

class SharesView: UIView {

    fileprivate let percent = LOTAnimationView(name: "percent")
    fileprivate let percentHolder = UIView()

    let tableHeader = SharesOfferHeaderView.init()
    lazy var offersTable = getTableView()

    lazy var title = UILabel()
    lazy var archiveShares = UILabel()
    lazy var archiveSharesUnderline = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        percentHolder.addSubview(percent)
        addSubview(percentHolder)

        addSubview(offersTable)

        addSubview(title)
        addSubview(archiveShares)
        addSubview(archiveSharesUnderline)


        title.text = "АКЦИИ"
        archiveShares.text = "АРХИВ АКЦИЙ"

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(18)
            maker.right.equalToSuperview().offset(-18)
        }

        archiveShares.snp.makeConstraints { archiveShares in
            archiveShares.top.equalToSuperview().offset(20)
            archiveShares.centerX.equalToSuperview()
        }

        archiveSharesUnderline.snp.makeConstraints { archiveSharesUnderline in
            archiveSharesUnderline.top.equalToSuperview().offset(41)
            archiveSharesUnderline.left.equalTo(archiveShares.snp.left)
            archiveSharesUnderline.height.equalTo(1)
            archiveSharesUnderline.width.equalTo(20)
        }

        percent.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percent.contentMode = .scaleAspectFill
        percent.clipsToBounds = false

        let height: Double = Consts.getTableHeaderHeight() / 2
        percentHolder.snp.makeConstraints { percentHolder in
            percentHolder.width.equalTo(100)
            percentHolder.height.equalTo(100)
            percentHolder.centerX.equalToSuperview()
            percentHolder.centerY.equalTo(self.snp.top).offset(height * 0.88)
        }

        offersTable.snp.makeConstraints { offersTable in
            offersTable.edges.equalToSuperview()
        }

        percentHolder.isShown = false
        offersTable.isShown = false
        tableHeader.subscribeOnTap(tapCallback: tapOnShowFilterHeader)

//        percent.play();
        look.apply(Style.sharesView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeaderViewFrame() {
        let height: Double = Consts.getTableHeaderHeight()
        let offset: Double = Consts.getTableHeaderOffset(withFilters: tableHeader.isFilterShown)
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(height - offset))
        tableHeader.frame = newFrame
        offersTable.tableHeaderView = tableHeader
    }

    deinit {
        log("deinit")
    }

}

extension SharesView {

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
            for visibleCell in self.offersTable.visibleCells {
                visibleCell.transform = CGAffineTransform(translationX: 0, y: CGFloat(offset))
            }
        }, completion: { [weak self] isComplete in
            if let visibleCells = self?.offersTable.visibleCells {
                for visibleCell in visibleCells {
                    visibleCell.transform = CGAffineTransform.identity
                }
            }
            self?.updateHeaderViewFrame()
        })
    }

    fileprivate func animateCellsUp() {
        let offset: Double = Consts.FILTER_TABLE_HEADER_ANIMATION_OFFSET

        self.updateHeaderViewFrame()
        for visibleCell in offersTable.visibleCells {
            visibleCell.transform = CGAffineTransform(translationX: 0, y: CGFloat(offset))
        }

        UIView.animate(withDuration: Consts.FILTER_TABLE_HEADER_ANIMATION_DURATION, animations: { [unowned self] () in
            for visibleCell in self.offersTable.visibleCells {
                visibleCell.transform = CGAffineTransform.identity
            }
        })
    }

    // --

    fileprivate func showPercentAndTable(isShown: Bool) {
        if self.percentHolder.isShown != isShown {
            self.percentHolder.isShown = isShown
            if isShown {
                self.percent.play(completion: { [weak self] finished in
                    if finished {
                        self?.showOffersTable(isShown: isShown)
                    }
                })
            }
        }

    }

    fileprivate func showOffersTable(isShown: Bool) {
        if self.offersTable.isShown != isShown {
            self.offersTable.isShown = isShown
            if isShown {
                self.offersTable.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned self] () in
                    self.offersTable.transform = CGAffineTransform.identity
                })
            }
        }
    }

}

fileprivate extension SharesView {

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

    static var sharesView: Change<SharesView> {
        return { (view: SharesView) -> Void in
            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)

            view.archiveShares.textColor = Palette.Common.whiteText.color
            view.archiveShares.font = UIFont(name: "ProximaNova-Bold", size: 10)

            view.archiveSharesUnderline.backgroundColor = Palette.Common.whiteText.color

            view.backgroundColor = Palette.SharesView.background.color
            view.offersTable.backgroundColor = Palette.SharesView.collectionBackground.color
        }
    }

}

extension Reactive where Base == SharesView {

    var scrollObserver: AnyObserver<CGFloat> {
        return Binder(base, binding: { (view: SharesView, offset: CGFloat) in
            view.percentHolder.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY, y: 0)
            view.title.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
            view.archiveShares.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
            view.archiveSharesUnderline.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
        }).asObserver()
    }

    var didLoadOffersObserver: AnyObserver<Bool> {
        return Binder(base, binding: { (view: SharesView, isShown: Bool) in
            view.showPercentAndTable(isShown: isShown)
        }).asObserver()
    }

    var offersCount: AnyObserver<Int64> {
        return Binder(base, binding: { (view: SharesView, value: Int64) in
            view.tableHeader.setOffersCount(newValue: value)
        }).asObserver()
    }

}
