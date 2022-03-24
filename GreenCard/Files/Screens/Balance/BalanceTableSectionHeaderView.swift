//
// Created by Hovhannes Sukiasian on 08/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look

class BalanceTableSectionHeaderView : UITableViewHeaderFooterView {

    static let identifier = "BalanceTableSectionHeaderView"
    static let HEIGHT = 55

    let container = UIView()
    let dayLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(container)

        container.addSubview(dayLabel)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14))
        }

        dayLabel.snp.makeConstraints { dayLabel in
            dayLabel.leading.bottom.equalToSuperview()
        }

        look.apply(Style.balanceTableSectionHeaderView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: String) {
        dayLabel.text = day
    }

}

fileprivate extension Style {

    static var balanceTableSectionHeaderView: Change<BalanceTableSectionHeaderView> {
        return { (view: BalanceTableSectionHeaderView) -> Void in
            view.dayLabel.text = "12 / 11 / 17"
            view.dayLabel.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.dayLabel.textColor = Palette.BalanceView.time.color
        }
    }

}
