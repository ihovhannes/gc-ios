//
// Created by Hovhannes Sukiasian on 21/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look

class FilterWidget: UIView {

    let container = UIView()

    let titleSortBy = UILabel()
    let valueSortBy = UILabel()

    let titlePeriodCalendar = UILabel()
    let valuePeriodCalendar = UILabel()

    let titleStoresPoints = UILabel()
    let valueStoresPoints = UILabel()

    let firstLine = UIView()
    let secondLine = UIView()
    let thirdLine = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(titleSortBy)
        container.addSubview(valueSortBy)
        container.addSubview(firstLine)

        container.addSubview(titlePeriodCalendar)
        container.addSubview(valuePeriodCalendar)
        container.addSubview(secondLine)

        container.addSubview(titleStoresPoints)
        container.addSubview(valueStoresPoints)
        container.addSubview(thirdLine)

        titleSortBy.text = "Сортировать по:"
        valueSortBy.text = "дате возрастания"

        titlePeriodCalendar.text = "Период отбора"
        valuePeriodCalendar.text = "16 Ноября 2016 - 16 Ноября 2017"

        titleStoresPoints.text = "Точки продаж"
        valueStoresPoints.text = "Все"

        // --

        container.snp.makeConstraints{ container in
            container.top.leading.top.right.bottom.equalToSuperview().priority(999)
        }

        // --

        titleSortBy.snp.makeConstraints { titleSortBy in
            titleSortBy.top.equalTo(self.snp.top).offset(20)
            titleSortBy.leading.equalTo(self.snp.leading).offset(20)
        }

        valueSortBy.snp.makeConstraints { valueSortBy in
            valueSortBy.centerY.equalTo(titleSortBy.snp.centerY)
            valueSortBy.trailing.equalTo(self.snp.trailing).offset(-20)
        }

        // --

        firstLine.snp.makeConstraints { firstLine in
            firstLine.top.equalTo(titleSortBy.snp.bottom).offset(20)
            firstLine.leading.trailing.equalToSuperview()
            firstLine.height.equalTo(1)
        }

        // --

        titlePeriodCalendar.snp.makeConstraints { titlePeriodCalendar in
            titlePeriodCalendar.top.equalTo(firstLine.snp.bottom).offset(20)
            titlePeriodCalendar.leading.equalToSuperview().offset(20)
        }

        valuePeriodCalendar.snp.makeConstraints { valuePeriodCalendar in
            valuePeriodCalendar.centerY.equalTo(titlePeriodCalendar.snp.centerY)
            valuePeriodCalendar.trailing.equalToSuperview().offset(-20)
        }

        // --

        secondLine.snp.makeConstraints { secondLine in
            secondLine.top.equalTo(titlePeriodCalendar.snp.bottom).offset(20)
            secondLine.leading.trailing.equalToSuperview()
            secondLine.height.equalTo(1)
        }

        // --

        titleStoresPoints.snp.makeConstraints { titleStoresPoints in
            titleStoresPoints.top.equalTo(secondLine.snp.bottom).offset(20)
            titleStoresPoints.leading.equalToSuperview().offset(20)
        }

        valueStoresPoints.snp.makeConstraints { valueStoresPoints in
            valueStoresPoints.centerY.equalTo(titleStoresPoints.snp.centerY)
            valueStoresPoints.trailing.equalToSuperview().offset(-20)
        }

        // --

        thirdLine.snp.makeConstraints { thirdLine in
            thirdLine.top.equalTo(titleStoresPoints.snp.bottom).offset(20)
            thirdLine.leading.trailing.equalToSuperview()
            thirdLine.height.equalTo(1)
            thirdLine.bottom.equalToSuperview()
        }

        look.apply(Style.filterWidget)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension Style {

    static var filterWidget: Change<FilterWidget> {
        return { (view: FilterWidget) -> Void in
            view.backgroundColor = Palette.FilterWidget.background.color

            view.titleSortBy.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.titleSortBy.textColor = Palette.FilterWidget.leftLabel.color

            view.valueSortBy.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.valueSortBy.textColor = Palette.FilterWidget.rightLabel.color

            view.titlePeriodCalendar.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.titlePeriodCalendar.textColor = Palette.FilterWidget.leftLabel.color

            view.valuePeriodCalendar.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.valuePeriodCalendar.textColor = Palette.FilterWidget.rightLabel.color

            view.titleStoresPoints.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.titleStoresPoints.textColor = Palette.FilterWidget.leftLabel.color

            view.valueStoresPoints.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.valueStoresPoints.textColor = Palette.FilterWidget.rightLabel.color

            view.firstLine.backgroundColor = Palette.FilterWidget.line.color
            view.secondLine.backgroundColor = Palette.FilterWidget.line.color
            view.thirdLine.backgroundColor = Palette.Common.transparentBackground.color
        }
    }

}
