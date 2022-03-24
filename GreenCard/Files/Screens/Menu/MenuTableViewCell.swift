//
//  MenuTableViewCell.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 06.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import SnapKit
import Look

class MenuTableViewCell: UITableViewCell {

    static let identifier = "MenuTableViewCell"
    
    let name = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(name)
        name.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.centerY.equalToSuperview()
        }
        
        look.apply(Style.menuCell)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension Style {
    static var menuCell: Change<MenuTableViewCell> {
        return { (view: MenuTableViewCell) -> Void in
            view.name.font = UIFont(name: "ProximaNova-Semibold", size: 19)
            view.name.textColor = Palette.Common.whiteText.color
            view.name.numberOfLines = 1
            view.backgroundColor = Palette.Common.transparentBackground.color
            view.contentView.backgroundColor = Palette.Common.transparentBackground.color
            view.selectionStyle = .none
        }
    }
}
