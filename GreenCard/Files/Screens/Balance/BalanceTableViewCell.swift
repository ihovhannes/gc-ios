//
// Created by Hovhannes Sukiasian on 07/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look


class BalanceTableViewCell: UITableViewCell, DisposeBagProvider {

    static let identifier = "BalanceTableViewCell"

    let TIME_BLOCK_WIDTH = 20
    let CELL_HEIGHT = 80

    let container = UIView()

    let stackViewBg = UIView()
    let stackView = UIStackView()

    let firstColumn = UIView()
    let placeOfBuyingTitle = UILabel()
    let placeOfBuyingText = UILabel()

    let firstLine = UIView()

    let secondColumn = UIView()
    let bonusesTitle = UILabel()
    let bonusesText = UILabel()

    let secondLine = UIView()

    let thirdColumn = UIView()
    let sumTitle = UILabel()
    let sumText = UILabel()
    let rouble = UILabel()

    let rotationContainer = UIView()
    let timeStack = UIStackView()
    let timeImage = UIImageView.init(image: UIImage(named: "time-90"))
    let timeLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(container)

        container.addSubview(stackViewBg)
        container.addSubview(stackView)
        stackView.addArrangedSubview(firstColumn)
        stackView.addArrangedSubview(secondColumn)
        stackView.addArrangedSubview(thirdColumn)

        container.addSubview(rotationContainer)
        rotationContainer.addSubview(timeStack)
        timeStack.addArrangedSubview(timeImage)
        timeStack.addArrangedSubview(timeLabel)

        firstColumn.addSubview(placeOfBuyingTitle)
        firstColumn.addSubview(placeOfBuyingText)

        secondColumn.addSubview(firstLine)

        secondColumn.addSubview(bonusesTitle)
        secondColumn.addSubview(bonusesText)

        secondColumn.addSubview(secondLine)

        thirdColumn.addSubview(sumTitle)
        thirdColumn.addSubview(sumText)
        thirdColumn.addSubview(rouble)

        container.addSubview(placeOfBuyingTitle)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14))
        }

        stackViewBg.snp.makeConstraints { stackViewBg in
            stackViewBg.edges.equalTo(stackView.snp.edges)
        }

        stackView.snp.makeConstraints { stackView in
            stackView.leading.top.bottom.equalToSuperview()
            stackView.trailing.equalToSuperview().offset(-1 * TIME_BLOCK_WIDTH)
            stackView.height.equalTo(CELL_HEIGHT)
        }

        placeOfBuyingTitle.snp.makeConstraints { placeOfBuyingTitle in
            placeOfBuyingTitle.leading.equalToSuperview().offset(9)
            placeOfBuyingTitle.top.equalToSuperview().offset(10)
        }

        placeOfBuyingText.snp.makeConstraints { placeOfBuyingText in
            placeOfBuyingText.leading.equalToSuperview().offset(18)
            placeOfBuyingText.trailing.equalToSuperview().offset(-9)
            placeOfBuyingText.bottom.equalToSuperview().offset(-10)
        }

        firstLine.snp.makeConstraints { firstLine in
            firstLine.leading.equalToSuperview().offset(-1)
            firstLine.width.equalTo(1)
            firstLine.top.bottom.equalToSuperview()
        }

        bonusesTitle.snp.makeConstraints { bonusesTitle in
            bonusesTitle.leading.equalToSuperview().offset(9)
            bonusesTitle.top.equalToSuperview().offset(10)
        }

        bonusesText.snp.makeConstraints { bonusesText in
            bonusesText.leading.equalToSuperview()
            bonusesText.trailing.equalToSuperview().offset(-9)
            bonusesText.bottom.equalToSuperview().offset(-10)
        }

        secondLine.snp.makeConstraints { secondLine in
            secondLine.trailing.equalToSuperview().offset(1)
            secondLine.width.equalTo(1)
            secondLine.top.bottom.equalToSuperview()
        }

        sumTitle.snp.makeConstraints { sumTitle in
            sumTitle.leading.equalToSuperview().offset(9)
            sumTitle.top.equalToSuperview().offset(10)
        }

        sumText.snp.makeConstraints { sumText in
            sumText.leading.equalToSuperview()
            sumText.bottom.equalToSuperview().offset(-10)
        }

        rouble.snp.makeConstraints { rouble in
            rouble.leading.equalTo(sumText.snp.trailing).offset(2)
            rouble.trailing.equalToSuperview().offset(-9)
            rouble.lastBaseline.equalTo(sumText.snp.lastBaseline)
        }

//        rotationContainer.backgroundColor = .black
        rotationContainer.snp.makeConstraints { rotationContainer in
            rotationContainer.width.equalTo(CELL_HEIGHT)
            rotationContainer.height.equalTo(TIME_BLOCK_WIDTH)
            rotationContainer.centerX.equalTo(container.snp.trailing).offset(TIME_BLOCK_WIDTH / -2)
            rotationContainer.centerY.equalTo(container.snp.centerY)
        }

        rotationContainer.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))

        timeStack.snp.makeConstraints { timeStack in
            timeStack.centerX.equalToSuperview()
            timeStack.top.equalToSuperview()
        }

        timeImage.snp.makeConstraints { timeImage in
            timeImage.width.height.equalTo(10)
        }


        selectionStyle = .none

        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.spacing = 1

        timeStack.axis = .horizontal
        timeStack.alignment = .center
        timeStack.spacing = 7

        look.apply(Style.balanceTableViewCell)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(apiVendorName: String?, apiBonuses: String?, apiTotalPrice: String?, apiDate: String?) {
        if let vendor = apiVendorName {
            placeOfBuyingText.text = vendor.components(separatedBy: ",")[0]
        } else {
            placeOfBuyingText.text = ""
        }
        if let bonuses = apiBonuses {
            if bonuses.hasPrefix("-") {
                var bonusesValue = bonuses
                bonusesValue.remove(at: bonusesValue.startIndex)
                bonusesText.text = "- " + bonusesValue
                bonusesText.textColor = Palette.BalanceView.bonusesMinus.color
            } else {
                bonusesText.text = "+ " + bonuses
                bonusesText.textColor = Palette.BalanceView.bonusesPlus.color
            }
        } else {
            bonusesText.text = ""
        }

        let (_, totalPrice) = ApiValuesFormatter.formatPrice(apiValue: apiTotalPrice)
        sumText.text = totalPrice

        if let dateString = apiDate, let dateNumber = Double(dateString ) {
            let date = Date(timeIntervalSince1970: dateNumber)
            let formatter = DateFormatter.init()
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: date)
        } else {
            timeLabel.text = ""
        }
    }

}

fileprivate extension Style {

    static var balanceTableViewCell: Change<BalanceTableViewCell> {
        return { (view: BalanceTableViewCell) -> Void in
            view.backgroundColor = Palette.BalanceView.cellBackground.color
            view.contentView.backgroundColor = Palette.BalanceView.cellBackground.color

            view.stackViewBg.layer.cornerRadius = 5
            view.stackViewBg.layer.masksToBounds = true
            view.stackViewBg.backgroundColor = Palette.BalanceView.columnsBackground.color

            view.container.layer.masksToBounds = true
            view.container.backgroundColor = Palette.BalanceView.containerBackground.color

            view.placeOfBuyingTitle.text = "Место покупки"
            view.placeOfBuyingTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.placeOfBuyingTitle.textColor = Palette.BalanceView.topTitle.color

            view.placeOfBuyingText.text = "" // TODO: remove
            view.placeOfBuyingText.font = UIFont(name: "ProximaNova-Bold", size: 12)
            view.placeOfBuyingText.textColor = Palette.BalanceView.bottomText.color
            view.placeOfBuyingText.textAlignment = .right
            view.placeOfBuyingText.numberOfLines = 0
            view.placeOfBuyingText.lineBreakMode = .byWordWrapping

            view.bonusesTitle.text = "Бонусы"
            view.bonusesTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.bonusesTitle.textColor = Palette.BalanceView.topTitle.color

            view.bonusesText.text = ""
            view.bonusesText.font = UIFont(name: "ProximaNova-Bold", size: 12)
            view.bonusesText.textColor = Palette.BalanceView.bottomText.color
            view.bonusesText.textAlignment = .right

            view.sumTitle.text = "Сумма чека"
            view.sumTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.sumTitle.textColor = Palette.BalanceView.topTitle.color

            view.sumText.text = ""
            view.sumText.font = UIFont(name: "ProximaNova-Bold", size: 12)
            view.sumText.textColor = Palette.BalanceView.bottomText.color
            view.sumText.textAlignment = .right

            view.rouble.text = "₽"
            view.rouble.font = UIFont(name: "IstokWeb-Regular", size: 12)
            view.rouble.textColor = Palette.BalanceView.bottomText.color

            view.firstLine.backgroundColor = Palette.BalanceView.line.color
            view.secondLine.backgroundColor = Palette.BalanceView.line.color

            view.timeLabel.text = ""
            view.timeLabel.font = UIFont(name: "ProximaNova-Semibold", size: 9)
            view.timeLabel.textColor = Palette.BalanceView.time.color
        }
    }

}
