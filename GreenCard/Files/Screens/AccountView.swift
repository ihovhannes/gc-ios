//
//  AccountView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 27.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import SnapKit
import Look
import RxSwift

class AccountView: UIView {

    lazy var bonusesTitle = UILabel()
    lazy var bonusesText = UILabel()
    lazy var holder = UIView()
    lazy var statusTitle = UILabel()
    lazy var statusText = UILabel()
    lazy var nextStatusTitle = UILabel()
    lazy var nextStatusText = UILabel()
    lazy var nextStatusRouble = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bonusesTitle)
        addSubview(bonusesText)
        addSubview(holder)
        
        holder.addSubview(statusTitle)
        holder.addSubview(statusText)
        holder.addSubview(nextStatusTitle)
        holder.addSubview(nextStatusText)
        holder.addSubview(nextStatusRouble)
        
        bonusesTitle.text = "Доступно\nбонусов"
        statusTitle.text = "Текущий статус:"
        nextStatusTitle.text = "До следующего статуса:"
        nextStatusRouble.text = "₽"

        look.apply(Style.accountView) // порядок важен!
        layout()                      //
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        bonusesTitle.snp.makeConstraints { bonusesTitle in
            bonusesTitle.left.equalToSuperview().offset(20)
            bonusesTitle.top.equalToSuperview().offset(30)
        }
        
        bonusesText.snp.makeConstraints { bonusesText in
            bonusesText.left.equalToSuperview().offset(20)
            bonusesText.top.equalTo(bonusesTitle.snp.bottom)
        }
        
        holder.snp.makeConstraints { holder in
            holder.top.equalTo(bonusesText.snp.bottom)
            holder.right.bottom.equalToSuperview()
            holder.width.equalToSuperview().dividedBy(2)
        }
        
        statusTitle.snp.makeConstraints { statusTitle in
            statusTitle.left.equalToSuperview()
            statusTitle.right.equalToSuperview()
            statusTitle.top.equalToSuperview().offset(24)
        }

        // Так как текст lowercased, то нужно подкорректировать расстояние
        let offset = statusText.font.capHeight - statusText.font.xHeight
        statusText.snp.makeConstraints { statusText in
            statusText.left.equalToSuperview()
            statusText.top.equalTo(statusTitle.snp.bottom).offset(5 - offset)
        }
        
        nextStatusTitle.snp.makeConstraints { nextStatusTitle in
            nextStatusTitle.left.equalToSuperview()
            nextStatusTitle.top.equalTo(statusText.snp.bottom).offset(24)
        }
        
        nextStatusText.snp.makeConstraints { nextStatusText in
            nextStatusText.left.equalToSuperview()
            nextStatusText.bottom.equalToSuperview()
            nextStatusText.top.equalTo(nextStatusTitle.snp.bottom).offset(5)
        }

        nextStatusRouble.snp.makeConstraints{ nextStatusRuble in
            nextStatusRuble.leading.equalTo(nextStatusText.snp.trailing).offset(5)
            nextStatusRuble.firstBaseline.equalTo(nextStatusText.snp.firstBaseline)
        }
    }
}

extension AccountView: ObserverType {
    
    func on(_ event: Event<Account>) {
        guard let account = event.element else { return }

//        0.99/-0.99 шрифт 180
//        999.99/-999.99 шрифт 160
//        остальные 140

        let apiValue = account.bonuses
        let (bonusesFloatValue, bonusesTextValue) = ApiValuesFormatter.formatBonuses(apiValue: apiValue)

        var bonusesFontSize = 140.0;
        if let bonusesFloat = bonusesFloatValue {
            if abs(bonusesFloat) <= 0.99 {
                bonusesFontSize = 180.0
            } else if abs(bonusesFloat) <= 999.99 {
                bonusesFontSize = 160.0
            } else if abs(bonusesFloat) >= 10_000 && abs(bonusesFloat) < 1_000_000 {
                bonusesFontSize = 130.0
            }
        }
        bonusesText.font = bonusesText.font.withSize(CGFloat(bonusesFontSize * 0.5))
        bonusesText.text = bonusesTextValue
        statusText.text =  account.status.lowercased()

        let bonusesToNextStatus = ApiValuesFormatter.formatBonuses(apiValue: account.bonusesToNextStatus)
        nextStatusText.text = bonusesToNextStatus.formatted
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    typealias E = Account
}

fileprivate extension Style {
    static var accountView: Change<AccountView> {
        return { (view: AccountView) -> Void in
            view.bonusesText.look.apply(Style.bonuses)
            view.statusText.look.apply(Style.text)
            view.nextStatusText.look.apply(Style.text)
            view.bonusesTitle.look.apply(Style.title)
            view.nextStatusRouble.look.apply(Style.rouble)
            view.bonusesTitle.numberOfLines = 2
            view.bonusesTitle.lineBreakMode = .byWordWrapping
            view.statusTitle.look.apply(Style.title)
            view.nextStatusTitle.look.apply(Style.title)
            
            view.backgroundColor = Palette.AccountView.background.color
        }
    }
    
    static var title: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.backgroundColor = Palette.AccountView.textBackground.color
            view.textColor = Palette.AccountView.title.color
        }
    }
    
    static var bonuses: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-SemiBold", size: 90)
            view.textAlignment = .left
            view.backgroundColor = Palette.AccountView.textBackground.color
            view.textColor = Palette.AccountView.text.color
        }
    }
    
    static var text: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-SemiBold", size: 21)
            view.backgroundColor = Palette.AccountView.textBackground.color
            view.textColor = Palette.AccountView.text.color
        }
    }

    static var rouble: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "IstokWeb-Regular", size: 21)
            view.backgroundColor = Palette.AccountView.textBackground.color
            view.textColor = Palette.AccountView.text.color
        }
    }
}
