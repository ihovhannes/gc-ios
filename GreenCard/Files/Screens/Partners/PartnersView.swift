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
import Lottie

class PartnersView: UIView {

    fileprivate let plusAnim = LOTAnimationView(name: "plus")
    fileprivate let plusAnimHolder = UIView()

    let tableHeader = UIView()
    lazy var partnersTable = getTableView()

    lazy var title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(plusAnimHolder)
        plusAnimHolder.addSubview(plusAnim)
        addSubview(partnersTable)
        addSubview(title)

        title.text = "ПАРТНЕРЫ\nПРОГРАММЫ"

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.trailing.equalToSuperview().offset(-18)
        }

        plusAnim.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        plusAnim.contentMode = .scaleAspectFill
        plusAnim.clipsToBounds = false

        let height: Double = Consts.getTableHeaderHeight() / 2
        plusAnimHolder.snp.makeConstraints { percentHolder in
            percentHolder.width.equalTo(100)
            percentHolder.height.equalTo(100)
            percentHolder.centerX.equalToSuperview()
            percentHolder.centerY.equalTo(self.snp.top).offset(height * 0.88)
        }

        partnersTable.snp.makeConstraints { partnersTable in
            partnersTable.edges.equalToSuperview()
        }

        plusAnimHolder.isShown = false
        partnersTable.isShown = false

//        plus.play()
        look.apply(Style.partnersView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeaderViewFrame() {
        let height: Double = Consts.getTableHeaderHeight()
        let offset: Double = Consts.getTableHeaderOffset(withFilters: false)
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(height - offset - 65))
        tableHeader.frame = newFrame
        partnersTable.tableHeaderView = tableHeader
    }

}

fileprivate extension PartnersView {

    func showPlusAndTable(isShown: Bool) {
        if self.plusAnimHolder.isShown != isShown {
            self.plusAnimHolder.isShown = isShown
            if isShown {
                self.plusAnim.play(completion: { [weak self] finished in
                    if finished {
                        self?.showTable(isShown: isShown)
                    }
                })
            }
        }

    }

    func showTable(isShown: Bool) {
        if self.partnersTable.isShown != isShown {
            self.partnersTable.isShown = isShown
            if isShown {
                self.partnersTable.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
                UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned self] () in
                    self.partnersTable.transform = CGAffineTransform.identity
                })
            }
        }
    }

}

fileprivate extension PartnersView {

    func getTableView() -> UITableView {
        let tableView = UITableView(frame: frame, style: .grouped)
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.showsScrollIndicator = false
//        tableView.separatorColor = Palette.PartnersView.tableSeparator.color

        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0

        tableView.tableHeaderView = tableHeader
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))

        tableView.register(PartnersTableViewCell.self, forCellReuseIdentifier: PartnersTableViewCell.identifier)
        return tableView

    }

}

fileprivate extension Style {

    static var partnersView: Change<PartnersView> {
        return { (view: PartnersView) -> Void in
            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.textAlignment = .right
            view.title.numberOfLines = 2

            view.backgroundColor = Palette.PartnersView.background.color
            view.partnersTable.backgroundColor = Palette.PartnersView.tableBackground.color
        }
    }

}

extension Reactive where Base == PartnersView {

    var scrollObserver: AnyObserver<CGFloat> {
        return Binder(base, binding: { (view: PartnersView, offset: CGFloat) in
            view.plusAnimHolder.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY, y: 0)
            view.title.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
        }).asObserver()
    }

    var didLoadPartnersObserver: AnyObserver<Bool> {
        return Binder(base, binding: { (view: PartnersView, isShown: Bool) in
            view.showPlusAndTable(isShown: isShown)
        }).asObserver()
    }

}
