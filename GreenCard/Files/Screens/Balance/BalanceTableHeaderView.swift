//
// Created by Hovhannes Sukiasian on 06/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look
import RxGesture

class BalanceTableHeaderView: UIView, DisposeBagProvider {

    var isFilterShown: Bool {
        return filterWidget.isShown
    }

    fileprivate let lastOperations = UILabel()

    fileprivate let filterLabel = UILabel()
    fileprivate let filterUnderline = UIView()

    fileprivate let stackView = UIStackView.init()
    fileprivate let topView = UIView()
    fileprivate let filterWidget = FilterWidget.init()

    fileprivate var tapCallback: ((Bool) -> ())? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(stackView)

        topView.addSubview(lastOperations)
        topView.addSubview(filterLabel)
        topView.addSubview(filterUnderline)

        lastOperations.snp.makeConstraints { lastOperations in
            lastOperations.top.bottom.equalToSuperview()
            lastOperations.leading.equalToSuperview().offset(14)
        }

        filterLabel.snp.makeConstraints { filterLabel in
            filterLabel.trailing.equalToSuperview().offset(-14)
            filterLabel.bottom.equalTo(filterUnderline.snp.top).offset(-10)
        }

        filterUnderline.snp.makeConstraints { filterUnderline in
            filterUnderline.width.equalTo(30)
            filterUnderline.height.equalTo(1)
            filterUnderline.bottom.equalToSuperview()
            filterUnderline.trailing.equalToSuperview().offset(-14)
        }

        let offset: Double = Consts.getTableHeaderOffset(withFilters: false)
        let height: Double = Consts.getTableHeaderHeight()
        stackView.snp.makeConstraints { stackView in
            stackView.top.equalToSuperview().offset(height - offset - 82)
            stackView.leading.trailing.equalToSuperview()
        }

        stackView.axis = .vertical
        stackView.spacing = 30

        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(filterWidget)

        filterWidget.isShown = false

        filterLabel
                .gestureArea(leftOffset: 5, topOffset: 5, rightOffset: 5, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: filterLabelTapHandler)
                .disposed(by: disposeBag)

        filterLabel.isShown = false
        filterUnderline.isShown = false

        look.apply(Style.sharesOfferHeaderView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func subscribeOnTap(tapCallback: ((Bool) -> ())? = nil) {
        self.tapCallback = tapCallback
    }

    fileprivate func filterLabelTapHandler(arg: Any) {
        let willShow = !self.filterWidget.isShown
        filterLabel.text = willShow ? "СКРЫТЬ\nФИЛЬТР" : "ОТКРЫТЬ\nФИЛЬТР"
        self.filterWidget.container.isShown = false

        UIView.animate(withDuration: Consts.FILTER_TABLE_HEADER_ANIMATION_DURATION, animations: { [unowned self] () in
            self.filterWidget.isShown = willShow
            self.layoutIfNeeded()
        }, completion: { [unowned self] _ in
            self.filterWidget.container.isShown = true
        })

        tapCallback?(willShow)
    }

}


fileprivate extension Style {

    static var sharesOfferHeaderView: Change<BalanceTableHeaderView> {
        return { (view: BalanceTableHeaderView) -> Void in
            view.lastOperations.text = "Последние\nоперации"
            view.lastOperations.font = UIFont(name: "ProximaNova-Regular", size: 16)
            view.lastOperations.textColor = Palette.Common.whiteText.color
            view.lastOperations.textAlignment = .left
            view.lastOperations.numberOfLines = 2

            view.filterLabel.text = "ОТКРЫТЬ\nФИЛЬТР"
            view.filterLabel.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.filterLabel.textColor = Palette.Common.whiteText.color
            view.filterLabel.textAlignment = .right
            view.filterLabel.numberOfLines = 2

            view.filterUnderline.backgroundColor = Palette.Common.whiteText.color
        }
    }

}
