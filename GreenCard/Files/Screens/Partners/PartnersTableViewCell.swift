//
// Created by Hovhannes Sukiasian on 29/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look

class PartnersTableViewCell: UITableViewCell, DisposeBagProvider {

    static let identifier = "PartnersTableViewCell"

    let container = UIView()

    let topLine = UIView()
    let partnerLogo = UIImageView()
    let partnerName = UILabel()
    let gotoButton = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        container.addSubview(topLine)
        container.addSubview(partnerLogo)
        container.addSubview(partnerName)
        container.addSubview(gotoButton)

        contentView.addSubview(container)

        container.snp.makeConstraints { container in
            container.edges.equalToSuperview()
        }

        topLine.snp.makeConstraints { topLine in
            topLine.height.equalTo(1)
            topLine.top.leading.trailing.equalToSuperview()
        }

        partnerLogo.snp.makeConstraints { partnerLogo in
            partnerLogo.width.equalTo(90)
            partnerLogo.height.equalTo(53)
            partnerLogo.top.equalToSuperview().offset(13)
            partnerLogo.bottom.equalToSuperview().offset(-13)
            partnerLogo.leading.equalToSuperview().offset(35)
        }

        partnerName.snp.makeConstraints { partnerName in
            partnerName.leading.equalTo(partnerLogo.snp.trailing)
            partnerName.centerY.equalToSuperview()
        }

        gotoButton.snp.makeConstraints { gotoButton in
            gotoButton.leading.equalTo(partnerName.snp.trailing).offset(8)
            gotoButton.trailing.equalToSuperview().offset(-8)
            gotoButton.height.equalTo(15)
            gotoButton.width.equalTo(9)
            gotoButton.centerY.equalToSuperview()
        }

        selectionStyle = .none
        look.apply(Style.partnersCell)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(partnerInfo: PartnerInfo ) {
        partnerName.text = partnerInfo.partnerName ?? ""
        partnerLogo.pin_clearImages()
        partnerLogo.pin_cancelImageDownload()
        partnerLogo.pin_setImage(from: URL(string: partnerInfo.logoSrc ?? ""), placeholderImage: nil)
    }
}

fileprivate extension Style {

    static var partnersCell: Change<PartnersTableViewCell> {
        return { (view: PartnersTableViewCell) in
            view.backgroundColor = Palette.PartnersTableViewCell.cellBackground.color
            view.contentView.backgroundColor = Palette.PartnersTableViewCell.cellBackground.color

//            view.container.layer.cornerRadius = 5
            view.container.layer.masksToBounds = true
            view.container.backgroundColor = Palette.PartnersTableViewCell.containerBackground.color

            view.topLine.backgroundColor = Palette.PartnersView.tableSeparator.color

            view.partnerLogo.pin_updateWithProgress = true
            view.partnerLogo.contentMode = .scaleAspectFit

            view.partnerName.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.partnerName.textColor = Palette.PartnersTableViewCell.partnerName.color
            view.partnerName.numberOfLines = 0
            view.partnerName.textAlignment = .center
            view.partnerName.lineBreakMode = .byWordWrapping

            view.gotoButton.image = UIImage(named: "ic_go")
            view.gotoButton.contentMode = .scaleAspectFit
        }
    }

}
