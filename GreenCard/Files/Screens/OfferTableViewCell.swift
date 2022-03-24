//
//  OfferCollectionViewCell.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import SnapKit
import Look
import RxGesture

class OfferTableViewCell: UITableViewCell, DisposeBagProvider {

    static let identifier = "OfferTableViewCell"

    let container = UIView()

    let partner = UIImageView.init()
    let timeLeftTitle = UILabel()
    let timeLeftText = UILabel()
    let specialText = UILabel()
    let specialIcon = UIImageView()
    let headerHolder = UIView()

    let offerImage = UIImageView()
    let gotoButton = UIImageView()

    let title = UILabel()
    let expiryDate = UILabel()
    let footerHolder = UIView()

    var offer: Offer? = nil

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        headerHolder.addSubview(partner)
        headerHolder.addSubview(timeLeftTitle)
        headerHolder.addSubview(timeLeftText)
        headerHolder.addSubview(specialText)
        headerHolder.addSubview(specialIcon)

        footerHolder.addSubview(title)
        footerHolder.addSubview(expiryDate)

        container.addSubview(headerHolder)
        container.addSubview(offerImage)
        container.addSubview(gotoButton)
        container.addSubview(footerHolder)

        contentView.addSubview(container)

        timeLeftTitle.text = "дней до\nокончания\nакции"
        specialText.text = "спецпредложение"

        layout()
        selectionStyle = .none

        look.apply(Style.offer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

//        title.text = nil
//        title.sizeToFit()

//        expiryDate.text = nil
//        expiryDate.sizeToFit()

//        tapCallback = nil
    }

    func configure(offer: Offer) {
        self.offer = offer

        offerImage.pin_clearImages()
        offerImage.pin_cancelImageDownload()
        offerImage.pin_setImage(from: offer.image, placeholderImage: UIImage(named: "placeholder"))

        partner.pin_clearImages()
        partner.pin_cancelImageDownload()
        if let partnerImage = offer.partnerImage {
            log("\(partnerImage)")
            partner.pin_setImage(from: partnerImage, placeholderImage: nil)
        } else {
            partner.image = UIImage(named: "default_logo_1")
        }


        title.text = offer.title
//        title.sizeToFit()
//        title.setNeedsLayout()

        expiryDate.text = offer.endDate
//        expiryDate.sizeToFit()
//        expiryDate.setNeedsLayout()

        specialIcon.isShown = offer.isSpecial
        specialText.isShown = offer.isSpecial
        timeLeftTitle.isShown = !offer.isSpecial
        timeLeftText.isShown = !offer.isSpecial
        if (!offer.isSpecial) {
            timeLeftText.text = offer.timeLeft
        }

        self.setNeedsLayout()
    }

    func showTimeLeft(isShown: Bool) {
        timeLeftTitle.isShown = isShown
        timeLeftText.isShown = isShown
    }

    private func layout() {
        container.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14))
        }

        headerHolder.snp.makeConstraints { maker in
            maker.leading.top.trailing.equalToSuperview()
            maker.height.equalTo(60)
        }

        specialIcon.snp.makeConstraints { maker in
            maker.trailing.equalToSuperview().offset(-28)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(19)
        }

        specialText.snp.makeConstraints { maker in
            maker.trailing.equalTo(specialIcon.snp.leading).offset(-8)
            maker.centerY.equalToSuperview()
        }

        timeLeftTitle.snp.makeConstraints { timeLeftTitle in
            timeLeftTitle.trailing.equalTo(timeLeftText.snp.leading).offset(-18)
            timeLeftTitle.centerY.equalToSuperview()
        }

        timeLeftText.snp.makeConstraints { timeLeftText in
            timeLeftText.trailing.equalToSuperview().offset(-28)
            timeLeftText.centerY.equalToSuperview()
        }

        partner.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().offset(28)
            maker.centerY.equalToSuperview()
            maker.width.equalTo(80)
            maker.height.equalTo(46)
        }

        offerImage.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(headerHolder.snp.bottom)
            maker.height.equalTo(150)
        }

        gotoButton.snp.makeConstraints { gotoButton in
            gotoButton.top.equalTo(offerImage.snp.bottom).offset(-25)
            gotoButton.trailing.equalToSuperview().offset(-28)
            gotoButton.size.equalTo(50)
        }

        footerHolder.snp.makeConstraints { footerHolder in
            footerHolder.top.equalTo(offerImage.snp.bottom).offset(30)
            footerHolder.leading.equalToSuperview().offset(28)
            footerHolder.trailing.equalToSuperview().offset(-28)
            footerHolder.bottom.equalToSuperview().offset(-30)
        }

        title.snp.makeConstraints { title in
            title.leading.top.bottom.equalToSuperview()
        }

        expiryDate.snp.makeConstraints { expiryDate in
            expiryDate.trailing.equalToSuperview()
            expiryDate.firstBaseline.equalTo(title.snp.lastBaseline)
            expiryDate.leading.equalTo(title.snp.trailing).offset(20)
        }
        expiryDate.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        expiryDate.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
    }

}

fileprivate extension Style {
    static var offer: Change<OfferTableViewCell> {
        return { (view: OfferTableViewCell) -> Void in
            view.backgroundColor = Palette.OfferCollectionViewCell.cellBackground.color
            view.contentView.backgroundColor = Palette.OfferCollectionViewCell.cellBackground.color

            view.container.layer.cornerRadius = 5
            view.container.layer.masksToBounds = true
            view.container.backgroundColor = Palette.OfferCollectionViewCell.containerBackground.color

            view.partner.pin_updateWithProgress = true
//            view.partner.alignment = .left
            view.partner.contentMode = UIViewContentMode.scaleAspectFit

            view.offerImage.pin_updateWithProgress = true
            view.offerImage.contentMode = UIViewContentMode.scaleAspectFill
            view.offerImage.clipsToBounds = true

            view.title.look.apply(Style.title)
            view.expiryDate.look.apply(Style.expiryDate)

            view.specialText.look.apply(Style.special)
            view.specialText.numberOfLines = 1

            view.specialIcon.image = UIImage(named: "alarm")

            view.timeLeftTitle.look.apply(Style.special)
            view.timeLeftTitle.numberOfLines = 3
            view.timeLeftTitle.textAlignment = .right

            view.timeLeftText.look.apply(Style.timeLeft)

            view.gotoButton.image = UIImage(named: "ic_mark")
            view.gotoButton.look.apply(Style.corners(rounded: true,
                    size: CGSize(width: 50, height: 50),
                    radius: 25))
            view.gotoButton.backgroundColor = Palette.OfferCollectionViewCell.markBackground.color
            view.gotoButton.contentMode = .center
        }
    }

    static var special: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.textColor = Palette.Common.blackText.color
        }
    }

    static var timeLeft: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-Bold", size: 39)
            view.textColor = Palette.OfferCollectionViewCell.timeLeftText.color
        }
    }

    static var title: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.numberOfLines = 0
            view.lineBreakMode = .byWordWrapping
        }
    }

    static var expiryDate: Change<UILabel> {
        return { (view: UILabel) -> Void in
            view.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.numberOfLines = 1
            view.textColor = Palette.OfferCollectionViewCell.expiryDateText.color
        }
    }
}
