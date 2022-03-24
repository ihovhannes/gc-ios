//
// Created by Hovhannes Sukiasian on 11/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit

class OperationDetailHeaderWidget: UIView {

    let logo = UIImageView()

    let addressTitle = UILabel()
    let addressValue = UILabel()

    let timeOfTitle = UILabel()
    let timeOfValue = UILabel()

    let typeOfTitle = UILabel()
    let typeOfValue = UILabel()

    let uniqueIdTitle = UILabel()
    let uniqueIdValue = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(logo)
        addSubview(addressTitle)
        addSubview(addressValue)

        addSubview(timeOfTitle)
        addSubview(timeOfValue)

        addSubview(typeOfTitle)
        addSubview(typeOfValue)

        addSubview(uniqueIdTitle)
        addSubview(uniqueIdValue)

        logo.snp.makeConstraints { logo in
            logo.width.equalTo(110)
            logo.height.equalTo(60)
            logo.top.equalToSuperview()
            logo.centerX.equalTo(self.snp.centerX).dividedBy(2).offset(-5)
        }

        addressTitle.snp.makeConstraints { addressTitle in
            addressTitle.top.equalToSuperview()
            addressTitle.leading.equalTo(self.snp.centerX)
        }

        addressValue.snp.makeConstraints { addressValue in
            addressValue.leading.equalTo(self.snp.centerX)
            addressValue.top.equalTo(addressTitle.snp.bottom).offset(6)
        }

        timeOfTitle.snp.makeConstraints { timeOfTitle in
            timeOfTitle.leading.equalTo(self.snp.centerX)
            timeOfTitle.top.equalTo(addressValue.snp.bottom).offset(26)
        }

        timeOfValue.snp.makeConstraints { timeOfValue in
            timeOfValue.leading.equalTo(self.snp.centerX)
            timeOfValue.top.equalTo(timeOfTitle.snp.bottom).offset(6)
        }

        typeOfTitle.snp.makeConstraints { typeOfTitle in
            typeOfTitle.leading.equalTo(self.snp.centerX)
            typeOfTitle.top.equalTo(timeOfValue.snp.bottom).offset(26)
        }

        typeOfValue.snp.makeConstraints { typeOfValue in
            typeOfValue.leading.equalTo(self.snp.centerX)
            typeOfValue.top.equalTo(typeOfTitle.snp.bottom).offset(6)
        }

        uniqueIdTitle.snp.makeConstraints { uniqueIdTitle in
            uniqueIdTitle.leading.equalTo(self.snp.centerX)
            uniqueIdTitle.top.equalTo(typeOfValue.snp.bottom).offset(26)
        }

        uniqueIdValue.snp.makeConstraints { uniqueIdValue in
            uniqueIdValue.leading.equalTo(self.snp.centerX)
            uniqueIdValue.trailing.equalToSuperview().offset(-40)
            uniqueIdValue.top.equalTo(uniqueIdTitle.snp.bottom).offset(6)
            uniqueIdValue.bottom.equalToSuperview()
        }

        look.apply(Style.operationDetailHeaderWidget)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(address: String?, dateOf: String?, typeOf: String?, uniqueId: String?,
                   partnerLogoSrc: String?) {
        logo.pin_clearImages()
        logo.pin_cancelImageDownload()
        if let partnerLogo = partnerLogoSrc {
            logo.pin_setImage(from: URL(string: partnerLogo))
        } else {
            logo.image = UIImage(named: "default_logo_2")
        }


        addressValue.text = address
        typeOfValue.text = typeOf?.firstLetterUppercase()
        uniqueIdValue.text = uniqueId

        if let dateString = dateOf, let dateNumber = Double(dateString) {
            let date = Date(timeIntervalSince1970: dateNumber)
            let formatter = DateFormatter.init()
            formatter.dateFormat = "HH:mm  dd / MM / yy"

            timeOfValue.text = formatter.string(from: date)
        } else {
            timeOfValue.text = dateOf
        }
    }

}

fileprivate extension Style {

    static var operationDetailHeaderWidget: Change<OperationDetailHeaderWidget> {
        return { (view: OperationDetailHeaderWidget) in
            view.logo.pin_updateWithProgress = true
            view.logo.contentMode = .scaleAspectFit
            view.logo.clipsToBounds = true

            view.addressTitle.text = "Адрес"
            view.addressTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.addressTitle.textColor = Palette.OperationDetailHeaderWidget.title.color

            view.addressValue.text = " "
            view.addressValue.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.addressValue.textColor = Palette.OperationDetailHeaderWidget.text.color

            view.timeOfTitle.text = "Время и дата"
            view.timeOfTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.timeOfTitle.textColor = Palette.OperationDetailHeaderWidget.title.color

            view.timeOfValue.text = " "
            view.timeOfValue.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.timeOfValue.textColor = Palette.OperationDetailHeaderWidget.text.color

            view.typeOfTitle.text = "Вид операции"
            view.typeOfTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.typeOfTitle.textColor = Palette.OperationDetailHeaderWidget.title.color

            view.typeOfValue.text = " "
            view.typeOfValue.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.typeOfValue.textColor = Palette.OperationDetailHeaderWidget.text.color

            view.uniqueIdTitle.text = "Номер операции"
            view.uniqueIdTitle.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.uniqueIdTitle.textColor = Palette.OperationDetailHeaderWidget.title.color

            view.uniqueIdValue.text = " "
            view.uniqueIdValue.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.uniqueIdValue.textColor = Palette.OperationDetailHeaderWidget.text.color
            view.uniqueIdValue.numberOfLines = 0
            view.uniqueIdValue.lineBreakMode = .byCharWrapping
        }
    }

}
