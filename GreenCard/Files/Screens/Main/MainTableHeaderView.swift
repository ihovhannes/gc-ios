//
// Created by Hovhannes Sukiasian on 06/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look

class MainTableHeaderView: UIView, DisposeBagProvider {

    fileprivate let amountTitle = UILabel()
    fileprivate let amountText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(amountTitle)
        self.addSubview(amountText)

        amountTitle.snp.makeConstraints { amountTitle in
            amountTitle.leading.equalToSuperview().offset(14)
        }

        amountText.snp.makeConstraints { amountText in
            amountText.top.equalTo(amountTitle.snp.bottom).offset(14)
            amountText.leading.equalToSuperview().offset(14)
            amountText.bottom.equalToSuperview().offset(-8)
        }

        look.apply(Style.mainTableHeaderView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setTitle(text: String) {
        amountTitle.text = text
    }

    public func setOffersCount(newValue: String) {
        amountText.text = newValue
    }
}

fileprivate extension Style {

    static var mainTableHeaderView: Change<MainTableHeaderView> {
        return { (view: MainTableHeaderView) -> Void in
            view.amountTitle.text = "Свежих\nакций"
            view.amountTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.amountTitle.textColor = Palette.MainTableHeaderView.title.color
            view.amountTitle.numberOfLines = 2

            view.amountText.text = "0"
            view.amountText.font = UIFont(name: "DINPro-Bold", size: 36)
            view.amountText.textColor = Palette.MainTableHeaderView.text.color
        }
    }

}
