//
// Created by Hovhannes Sukiasian on 21/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import UIKit
import SnapKit
import Look
import RxGesture

class SharesOfferHeaderView: UIView, DisposeBagProvider {

    var isFilterShown: Bool {
        return filterWidget.isShown
    }

    fileprivate let amountTitle = UILabel()
    fileprivate let amountText = UILabel()

    fileprivate let filterLabel = UILabel()
    fileprivate let filterUnderline = UIView()

    fileprivate let stackView = UIStackView()
    fileprivate let topView = UIView()
    fileprivate let filterWidget = FilterWidget()

    fileprivate var tapCallback: ((Bool) -> ())? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(stackView)

        topView.addSubview(amountTitle)
        topView.addSubview(amountText)
        topView.addSubview(filterLabel)
        topView.addSubview(filterUnderline)

        amountTitle.snp.makeConstraints { amountTitle in
            amountTitle.top.equalToSuperview()
            amountTitle.leading.equalToSuperview().offset(14)
        }

        amountText.snp.makeConstraints { amountText in
            amountText.top.equalTo(amountTitle.snp.bottom).offset(14)
            amountText.leading.equalToSuperview().offset(14)
            amountText.bottom.equalToSuperview()
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

    public func setOffersCount(newValue: Int64) {
        amountText.text = String(newValue)
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

    static var sharesOfferHeaderView: Change<SharesOfferHeaderView> {
        return { (view: SharesOfferHeaderView) -> Void in
            view.amountTitle.text = "Свежих\nакций"
            view.amountTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.amountTitle.textColor = Palette.SharesTableHeaderView.title.color
            view.amountTitle.numberOfLines = 2

            view.amountText.text = "0"
            view.amountText.font = UIFont(name: "DINPro-Bold", size: 36)
            view.amountText.textColor = Palette.SharesTableHeaderView.text.color

            view.filterLabel.text = "ОТКРЫТЬ\nФИЛЬТР"
            view.filterLabel.font = UIFont(name: "ProximaNova-Regular", size: 12)
            view.filterLabel.textColor = Palette.SharesTableHeaderView.filter.color
            view.filterLabel.textAlignment = .right
            view.filterLabel.numberOfLines = 2

            view.filterUnderline.backgroundColor = Palette.Common.whiteText.color
        }
    }

}
