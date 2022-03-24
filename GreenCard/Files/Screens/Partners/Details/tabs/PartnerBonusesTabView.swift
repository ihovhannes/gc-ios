//
// Created by Hovhannes Sukiasian on 22/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import DTCoreText
import SnapKit
import Look

class BonusesTabView: UIView {

    static let TAB_NAME = "Таблица бонусов"

    let statusTitle = UILabel()
    let percentsTitle = UILabel()

    let tableStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(statusTitle)
        addSubview(percentsTitle)

        addSubview(tableStack)

        statusTitle.snp.makeConstraints { statusTitle in
            statusTitle.leading.equalToSuperview().offset(14)
        }

        percentsTitle.snp.makeConstraints { percentsTitle in
            percentsTitle.top.equalToSuperview()
            percentsTitle.trailing.equalToSuperview().offset(-14)
            percentsTitle.lastBaseline.equalTo(statusTitle.snp.lastBaseline)
        }

        tableStack.snp.makeConstraints { tableStack in
            tableStack.top.equalTo(percentsTitle.snp.bottom).offset(10)
            tableStack.leading.equalToSuperview().offset(14)
            tableStack.bottom.equalToSuperview().offset(-14)
            tableStack.trailing.equalToSuperview().offset(-14)
        }

        tableStack.axis = .vertical
        tableStack.spacing = 15

        look.apply(Style.bonusesTabView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [PartnerDetailsBonus]) -> BonusesTabView {
        for item in items {
            let cell = PartnerBonusesTableCell()
            cell.configure(left: item.status, right: item.percents)
            tableStack.addArrangedSubview(cell)
        }
        return self
    }
}


fileprivate  extension  Style {

    static var bonusesTabView: Change<BonusesTabView> {
        return { (view: BonusesTabView) in
            view.statusTitle.text = "Cтатус"
            view.statusTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.statusTitle.textColor = Palette.PartnerDetailBonusesView.title.color

            view.percentsTitle.text = "Процент начисления\nбонусов"
            view.percentsTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.percentsTitle.textColor = Palette.PartnerDetailBonusesView.title.color
            view.percentsTitle.numberOfLines = 2
            view.percentsTitle.textAlignment = .right
        }
    }

    static var bonusesTableCell: Change<PartnerBonusesTableCell> {
        return { (view: PartnerBonusesTableCell) in
            view.leftLabel.textColor = Palette.PartnerDetailBonusesView.text.color
            view.leftLabel.font = UIFont(name: "ProximaNova-Bold", size: 37)

            view.rightLabel.textColor = Palette.PartnerDetailBonusesView.text.color
            view.rightLabel.font = UIFont(name: "ProximaNova-Regular", size: 21)

            view.line.backgroundColor = Palette.PartnerDetailBonusesView.line.color
        }
    }
}

fileprivate class PartnerBonusesTableCell : UIView {

    let leftLabel = UILabel()
    let rightLabel = UILabel()
    let line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(leftLabel)
        addSubview(rightLabel)
        addSubview(line)

        leftLabel.snp.makeConstraints { leftLabel in
            leftLabel.top.equalToSuperview()
            leftLabel.leading.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { rightLabel in
            rightLabel.trailing.equalToSuperview()
            rightLabel.lastBaseline.equalTo(leftLabel.snp.lastBaseline)
        }

        line.snp.makeConstraints { line in
            line.leading.trailing.bottom.equalToSuperview()
            line.top.equalTo(leftLabel.snp.bottom)
            line.height.equalTo(2)
        }

        look.apply(Style.bonusesTableCell)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(left: String?, right: Int?) {
        leftLabel.text = left
        rightLabel.text = "\(right ?? 0)" + "%"
    }

}
