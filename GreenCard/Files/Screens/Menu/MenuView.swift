//
//  MenuView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 06.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import SnapKit
import Look

class MenuView: UIView {

    lazy var menu = UITableView(frame: .zero, style: .plain)
    lazy var title = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(menu)
        addSubview(title)
        menu.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)

        layout()

        look.apply(Style.menu)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-18)
        }

        menu.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().offset(32)
            maker.bottom.equalToSuperview().offset(-30)
            maker.width.equalTo(Consts.IPHONE_4_WIDTH - 32)
            maker.height.equalTo(8 * 44)
        }
    }
}

fileprivate extension Style {
    static var menu: Change<MenuView> {
        return { (view: MenuView) -> Void in
            view.backgroundColor = Palette.Common.greenText.color
            view.menu.rowHeight = 44
            view.menu.separatorStyle = .none
            view.menu.backgroundColor = Palette.Common.transparentBackground.color
            view.menu.bounces = false

            view.title.look.apply(Style.title)
        }
    }

    static var title: Change<UILabel> {
        return { (label: UILabel) -> Void in
            label.text = "ГРИН\nКАРТА"
            label.textColor = Palette.Common.whiteText.color
            label.font = UIFont(name: "ProximaNova-Extrabld", size: 14)
            label.textAlignment = .right
            label.numberOfLines = 2
        }
    }
}
