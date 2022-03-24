//
// Created by Hovhannes Sukiasian on 12/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit

class OperationDetailTableWidget: UIView {

    let title = UILabel()

    let firstPart = UIView()
    let minHeightView = UIView()
    let stackView = UIStackView()
    fileprivate let header = OperationDetailTableHeader()
    let headerLine = UIView()

    fileprivate let footer = OperationDetailTableFooter()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(title)
        addSubview(firstPart)

//        firstPart.addSubview(header)
        addSubview(minHeightView)
        firstPart.addSubview(stackView)
        firstPart.addSubview(stackView)

        let height: Double = Consts.getTableHeaderHeight()
        let offset: Double = Consts.getTableHeaderOffset(withFilters: false)

        title.snp.makeConstraints { title in
            title.top.equalToSuperview().offset(height - offset - 20 - 53)
            title.leading.equalToSuperview().offset(14)
        }

        firstPart.snp.makeConstraints { firstPart in
            firstPart.top.equalTo(title.snp.bottom).offset(14)
            firstPart.leading.equalToSuperview().offset(14)
            firstPart.trailing.equalToSuperview().offset(-14)
//            firstPart.bottom.equalToSuperview()
        }

        let minHeight = Consts.getScreenHeight()
        stackView.axis = .vertical
        stackView.snp.makeConstraints { stackView in
            stackView.edges.equalToSuperview()
        }
        
        minHeightView.snp.makeConstraints { minHeightView in
            minHeightView.leading.equalTo(firstPart.snp.leading)
            minHeightView.trailing.equalTo(firstPart.snp.trailing)
            minHeightView.top.equalTo(firstPart.snp.top)
            minHeightView.bottom.equalToSuperview()
            minHeightView.height.greaterThanOrEqualTo(firstPart.snp.height).offset(14)
            minHeightView.height.greaterThanOrEqualTo(minHeight - 44)
        }

        header.snp.makeConstraints { header in
//            header.top.leading.trailing.equalToSuperview()
            header.height.equalTo(70)
//            header.width.equalToSuperview()
        }

        headerLine.snp.makeConstraints { headerLine in
            headerLine.height.equalTo(1)
        }

        footer.snp.makeConstraints { footer in
            footer.height.equalTo(70)
        }

        look.apply(Style.operationDetailTableWidget)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(response: OperationDetailsResponse) {
        let arrangedSubviews = stackView.arrangedSubviews
        arrangedSubviews.forEach { subview in
            stackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        stackView.addArrangedSubview(header)
        stackView.addArrangedSubview(headerLine)

        if let products = response.products {
            let itemCount = products.count

            for i in 0..<itemCount {
                let product: OperationDetailsResponseItem = products[i]
                let item = OperationDetailTableItem()
                item.snp.makeConstraints { item in
                    item.height.equalTo(70)
                }

                item.column1.text = product.name

                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.decimalSeparator = "."
                formatter.groupingSeparator = " "
                item.column2.text = formatter.string(from: NSNumber(value: product.count ?? 0))

                let (_, price) = ApiValuesFormatter.formatPrice(apiValue: product.price)
                item.column3top.text = price

                let (_, totalPrice) = ApiValuesFormatter.formatPrice(apiValue: product.totalPrice)
                item.column4top.text = totalPrice

                let (_, accruedBonuses) = ApiValuesFormatter.formatPrice(apiValue: product.accruedBonuses)
                item.column3bottom.text = accruedBonuses + " б."

                let (_, debitedBonuses) = ApiValuesFormatter.formatPrice(apiValue: product.debitedBonuses)
                item.column4bottom.text = debitedBonuses + " б."

                stackView.addArrangedSubview(item)
                if i < itemCount - 1 {
                    stackView.addArrangedSubview(TableLine())
                }
            }
        }

        let (_, totalPrice) = ApiValuesFormatter.formatPrice(apiValue: response.totalPrice)
        footer.column4top.text = totalPrice

        let (_, accruedBonuses) = ApiValuesFormatter.formatPrice(apiValue: response.accruedBonuses)
        footer.column3bottom.text = accruedBonuses + " б."

        let (_, debitedBonuses) = ApiValuesFormatter.formatPrice(apiValue: response.debitedBonuses)
        footer.column4bottom.text = debitedBonuses + " б."

        stackView.addArrangedSubview(footer)

    }

}

fileprivate extension Style {

    static var operationDetailTableWidget: Change<OperationDetailTableWidget> {
        return { (view: OperationDetailTableWidget) in
            view.title.text = "Состав чека"
            view.title.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.title.textColor = Palette.OperationDetailTableWidget.title.color

            view.firstPart.backgroundColor = Palette.OperationDetailTableWidget.background.color
            view.firstPart.layer.cornerRadius = 5
            view.firstPart.layer.masksToBounds = true

            view.headerLine.backgroundColor = Palette.OperationDetailTableWidget.line.color
        }
    }

    static var operationDetailTableHeader: Change<OperationDetailTableHeader> {
        return { (view: OperationDetailTableHeader) in
            view.column1.text = "товар\nили услуга"
            view.column1.numberOfLines = 0
            view.column1.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.column1.textColor = Palette.OperationDetailTableWidget.headerLabel.color

            view.column2.text = "кол-во"
            view.column2.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.column2.textAlignment = .center
            view.column2.textColor = Palette.OperationDetailTableWidget.headerLabel.color

            view.column3top.text = "цена"
            view.column3top.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.column3top.textColor = Palette.OperationDetailTableWidget.headerLabel.color

            view.column3bottom.text = "начислено"
            view.column3bottom.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.column3bottom.textColor = Palette.OperationDetailTableWidget.headerLabel.color

            view.column4top.text = "сумма"
            view.column4top.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.column4top.textColor = Palette.OperationDetailTableWidget.headerLabel.color

            view.column4bottom.text = "списано"
            view.column4bottom.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.column4bottom.textColor = Palette.OperationDetailTableWidget.headerLabel.color

            view.horizontalLine.backgroundColor = Palette.OperationDetailTableWidget.line.color
        }
    }

    static var operationDetailTableItem: Change<OperationDetailTableItem> {
        return { (view: OperationDetailTableItem) in
            view.column1.text = "ХЛЕБ МРАМОРНЫЙ 340гр."
            view.column1.numberOfLines = 0
            view.column1.lineBreakMode = .byWordWrapping
            view.column1.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column1.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column2.text = "1"
            view.column2.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column2.textAlignment = .center
            view.column2.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column3top.text = "47.20Р"
            view.column3top.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column3top.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column3topRouble.text = "₽"
            view.column3topRouble.font = UIFont(name: "IstokWeb-Regular", size: 10)
            view.column3topRouble.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column3bottom.text = "2.30б."
            view.column3bottom.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column3bottom.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column4top.text = "109.50б."
            view.column4top.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column4top.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column4topRouble.text = "₽"
            view.column4topRouble.font = UIFont(name: "IstokWeb-Regular", size: 10)
            view.column4topRouble.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.column4bottom.text = "0.14б."
            view.column4bottom.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column4bottom.textColor = Palette.OperationDetailTableWidget.itemLabel.color

            view.horizontalLine.backgroundColor = Palette.OperationDetailTableWidget.line.color
        }
    }

    static var operationDetailTableFooter: Change<OperationDetailTableFooter> {
        return { (view: OperationDetailTableFooter) in
            view.container.backgroundColor = Palette.OperationDetailTableWidget.footerBackground.color

            view.column3top.text = "ВСЕГО:"
            view.column3top.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column3top.textColor = Palette.OperationDetailTableWidget.footerLabel.color

            view.column3bottom.text = "42.333 б."
            view.column3bottom.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column3bottom.textColor = Palette.OperationDetailTableWidget.footerLabel.color

            view.column4top.text = "999 000 Р"
            view.column4top.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column4top.textColor = Palette.OperationDetailTableWidget.footerLabel.color

            view.column4topRouble.text = "₽"
            view.column4topRouble.font = UIFont(name: "IstokWeb-Regular", size: 10)
            view.column4topRouble.textColor = Palette.OperationDetailTableWidget.footerLabel.color

            view.column4bottom.text = "0.92 б."
            view.column4bottom.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.column4bottom.textColor = Palette.OperationDetailTableWidget.footerLabel.color

            view.horizontalLine.backgroundColor = Palette.OperationDetailTableWidget.footerLine.color
        }
    }

}

fileprivate class OperationDetailTableHeader: UIView {

    let container = UIView()

    let column1 = UILabel()
    let column2 = UILabel()

    let stackViewTop = UIStackView()
    let column3top = UILabel()
    let column4top = UILabel()

    let horizontalLine = UIView()

    let stackViewBottom = UIStackView()
    let column3bottom = UILabel()
    let column4bottom = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(column1)
        container.addSubview(column2)

        container.addSubview(stackViewTop)
        container.addSubview(horizontalLine)
        container.addSubview(stackViewBottom)

        stackViewTop.addArrangedSubview(column3top)
        stackViewTop.addArrangedSubview(column4top)

        stackViewBottom.addArrangedSubview(column3bottom)
        stackViewBottom.addArrangedSubview(column4bottom)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview()
        }

        column2.snp.makeConstraints { column2 in
            column2.width.equalTo(40)
            column2.trailing.equalTo(container.snp.centerX)
            column2.bottom.equalTo(stackViewBottom.snp.bottom)
        }

        column1.snp.makeConstraints { column1 in
            column1.leading.equalToSuperview().offset(8)
            column1.trailing.equalTo(column2.snp.leading)
//            column1.width.equalToSuperview().dividedBy(2).offset(-40 - 8)
            column1.bottom.equalTo(stackViewBottom.snp.bottom)
        }

        horizontalLine.backgroundColor = .black
        horizontalLine.snp.makeConstraints { horizontalLine in
            horizontalLine.height.equalTo(1)
            horizontalLine.trailing.equalToSuperview().offset(-8)
            horizontalLine.width.equalToSuperview().dividedBy(2).offset(-8 - 8)
            horizontalLine.centerY.equalToSuperview()
        }

        stackViewTop.distribution = .fillEqually
        stackViewBottom.distribution = .fillEqually

        stackViewTop.snp.makeConstraints { stackViewTop in
            stackViewTop.width.equalTo(horizontalLine.snp.width)
            stackViewTop.leading.equalTo(horizontalLine.snp.leading)
            stackViewTop.bottom.equalTo(horizontalLine.snp.top).offset(-2)
        }

        stackViewBottom.snp.makeConstraints { stackViewBottom in
            stackViewBottom.width.equalTo(horizontalLine.snp.width)
            stackViewBottom.leading.equalTo(horizontalLine.snp.leading)
            stackViewBottom.top.equalTo(horizontalLine.snp.bottom).offset(5)
        }

        look.apply(Style.operationDetailTableHeader)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class OperationDetailTableItem: UIView {

    let container = UIView()

    let column1 = UILabel()
    let column2 = UILabel()

    let stackViewTop = UIStackView()
    let column3TopStack = UIView()
    let column3top = UILabel()
    let column3topRouble = UILabel()
    let column4TopStack = UIView()
    let column4top = UILabel()
    let column4topRouble = UILabel()

    let horizontalLine = UIView()

    let stackViewBottom = UIStackView()
    let column3bottom = UILabel()
    let column4bottom = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(column1)
        container.addSubview(column2)

        container.addSubview(stackViewTop)
        container.addSubview(horizontalLine)
        container.addSubview(stackViewBottom)

        column3TopStack.addSubview(column3top)
        column3TopStack.addSubview(column3topRouble)

        column4TopStack.addSubview(column4top)
        column4TopStack.addSubview(column4topRouble)

        stackViewTop.addArrangedSubview(column3TopStack)
        stackViewTop.addArrangedSubview(column4TopStack)

        stackViewBottom.addArrangedSubview(column3bottom)
        stackViewBottom.addArrangedSubview(column4bottom)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview()
        }

        column2.snp.makeConstraints { column2 in
            column2.width.equalTo(40)
            column2.trailing.equalTo(container.snp.centerX)
            column2.centerY.equalToSuperview()
        }

        column1.snp.makeConstraints { column1 in
            column1.leading.equalToSuperview().offset(8)
            column1.trailing.equalTo(column2.snp.leading)
//            column1.width.equalToSuperview().dividedBy(2).offset(-40 - 8)
            column1.centerY.equalToSuperview()
        }

        horizontalLine.backgroundColor = .black
        horizontalLine.snp.makeConstraints { horizontalLine in
            horizontalLine.height.equalTo(1)
            horizontalLine.trailing.equalToSuperview().offset(-8)
            horizontalLine.width.equalToSuperview().dividedBy(2).offset(-8 - 8)
            horizontalLine.centerY.equalToSuperview()
        }

        stackViewTop.distribution = .fillEqually
        stackViewBottom.distribution = .fillEqually

        stackViewTop.alignment = .firstBaseline

        stackViewTop.snp.makeConstraints { stackViewTop in
            stackViewTop.width.equalTo(horizontalLine.snp.width)
            stackViewTop.leading.equalTo(horizontalLine.snp.leading)
            stackViewTop.bottom.equalTo(horizontalLine.snp.top).offset(-3)
        }

        stackViewBottom.snp.makeConstraints { stackViewBottom in
            stackViewBottom.width.equalTo(horizontalLine.snp.width)
            stackViewBottom.leading.equalTo(horizontalLine.snp.leading)
            stackViewBottom.top.equalTo(horizontalLine.snp.bottom).offset(5)
        }

        column3top.snp.makeConstraints { column3top in
            column3top.leading.top.bottom.equalToSuperview()
        }

        column3topRouble.snp.makeConstraints { column3topRouble in
            column3topRouble.leading.equalTo(column3top.snp.trailing).offset(2)
            column3topRouble.firstBaseline.equalTo(column3top.snp.firstBaseline)
        }

        column4top.snp.makeConstraints { column4top in
            column4top.leading.top.bottom.equalToSuperview()
        }

        column4topRouble.snp.makeConstraints { column4topRouble in
            column4topRouble.leading.equalTo(column4top.snp.trailing).offset(2)
            column4topRouble.firstBaseline.equalTo(column4top.snp.firstBaseline)
        }

        look.apply(Style.operationDetailTableItem)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class OperationDetailTableFooter: UIView {

    let container = UIView()

    let stackViewTop = UIStackView()
    let column3top = UILabel()
    let column4TopStack = UIView()
    let column4top = UILabel()
    let column4topRouble = UILabel()

    let horizontalLine = UIView()

    let stackViewBottom = UIStackView()
    let column3bottom = UILabel()
    let column4bottom = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(stackViewTop)
        container.addSubview(horizontalLine)
        container.addSubview(stackViewBottom)

        column4TopStack.addSubview(column4top)
        column4TopStack.addSubview(column4topRouble)

        stackViewTop.addArrangedSubview(column3top)
        stackViewTop.addArrangedSubview(column4TopStack)

        stackViewBottom.addArrangedSubview(column3bottom)
        stackViewBottom.addArrangedSubview(column4bottom)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview()
        }

        horizontalLine.backgroundColor = .black
        horizontalLine.snp.makeConstraints { horizontalLine in
            horizontalLine.height.equalTo(1)
            horizontalLine.trailing.equalToSuperview().offset(-8)
            horizontalLine.width.equalToSuperview().dividedBy(2).offset(-8 - 8)
            horizontalLine.centerY.equalToSuperview()
        }

        stackViewTop.distribution = .fillEqually
        stackViewBottom.distribution = .fillEqually

        stackViewTop.snp.makeConstraints { stackViewTop in
            stackViewTop.width.equalTo(horizontalLine.snp.width)
            stackViewTop.leading.equalTo(horizontalLine.snp.leading)
            stackViewTop.bottom.equalTo(horizontalLine.snp.top).offset(-3)
        }

        stackViewBottom.snp.makeConstraints { stackViewBottom in
            stackViewBottom.width.equalTo(horizontalLine.snp.width)
            stackViewBottom.leading.equalTo(horizontalLine.snp.leading)
            stackViewBottom.top.equalTo(horizontalLine.snp.bottom).offset(5)
        }


        column4top.snp.makeConstraints { column4top in
            column4top.leading.top.bottom.equalToSuperview()
        }

        column4topRouble.snp.makeConstraints { column4topRouble in
            column4topRouble.leading.equalTo(column4top.snp.trailing).offset(2)
            column4topRouble.firstBaseline.equalTo(column4top.snp.firstBaseline)
        }

        look.apply(Style.operationDetailTableFooter)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class TableLine: UIView {

    let line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(line)

        line.snp.makeConstraints { line in
            line.height.equalTo(1)
            line.top.bottom.equalToSuperview()
            line.leading.equalToSuperview().offset(8)
            line.trailing.equalToSuperview().offset(-8)
        }

        line.backgroundColor = Palette.OperationDetailTableWidget.line.color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
