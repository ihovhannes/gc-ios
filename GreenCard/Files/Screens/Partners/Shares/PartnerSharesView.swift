//
// Created by Hovhannes Sukiasian on 26/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import RxGesture

class PartnerSharesView: UIView {

    let SHARES_BUTTON_HEIGHT = 45.0

    let logo = UIImageView()

    let locationButton = UIView()
    let locationLabel = UILabel()
    let locationIcon = UIImageView()

    lazy var offersTable = getTableView()
    lazy var tableHeader = PartnerSharesTableHeader()

    override init(frame: CGRect) {
        super.init(frame: frame)


        locationButton.addSubview(locationLabel)
        locationButton.addSubview(locationIcon)

        addSubview(offersTable)

        addSubview(logo)
        addSubview(locationButton)

        logo.snp.makeConstraints { logo in
            logo.width.equalTo(106)
            logo.height.equalTo(52)
            logo.trailing.equalToSuperview().offset(-14)
            logo.top.equalToSuperview().offset(14)
        }

        locationIcon.snp.makeConstraints { locationIcon in
            locationIcon.width.equalTo(19)
            locationIcon.height.equalTo(20)
            locationIcon.trailing.equalToSuperview()
            locationIcon.centerY.equalToSuperview()
        }

        locationLabel.snp.makeConstraints { locationLabel in
            locationLabel.leading.equalToSuperview()
            locationLabel.trailing.equalTo(locationIcon.snp.leading).offset(-14)
            locationLabel.centerY.equalToSuperview()
        }

        locationButton.snp.makeConstraints { locationButton in
            locationButton.top.equalToSuperview().offset(110)
            locationButton.trailing.equalToSuperview().offset(-14)
            locationButton.height.equalTo(SHARES_BUTTON_HEIGHT)
        }

        offersTable.snp.makeConstraints { offersTable in
            offersTable.edges.equalToSuperview()
        }

        offersTable.isShown = false
        locationButton.isShown = false

        look.apply(Style.partnerSharesView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeaderViewFrame() {
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(110 + SHARES_BUTTON_HEIGHT + 15))
        tableHeader.frame = newFrame
        offersTable.tableHeaderView = tableHeader
    }

    func configure(pageColor: UIColor, logoSrc: String?) {
        self.backgroundColor = pageColor

        logo.pin_clearImages()
        logo.pin_cancelImageDownload()
        logo.pin_setImage(from: URL(string: logoSrc ?? ""))
    }

}

extension PartnerSharesView {

    func scrollTable(offset: CGFloat) {
        locationButton.transform = CGAffineTransform(translationX: 0, y: offset * -1)
    }

}

fileprivate extension PartnerSharesView {

    func getTableView() -> UITableView {
        let tableView = UITableView(frame: frame, style: .grouped)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.allowsSelection = true

        tableView.tableHeaderView = tableHeader
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 7))

        tableView.showsVerticalScrollIndicator =  false
        tableView.showsHorizontalScrollIndicator = false

        tableView.register(OfferTableViewCell.self, forCellReuseIdentifier: OfferTableViewCell.identifier)
        return tableView
    }

}

fileprivate extension Style {

    static var partnerSharesView: Change<PartnerSharesView> {
        return { (view: PartnerSharesView) -> Void in
            view.backgroundColor = .red

            view.locationLabel.text = "Магазины\nна карте"
            view.locationLabel.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.locationLabel.textColor = Palette.PartnerDetailView.location.color
            view.locationLabel.numberOfLines = 2
            view.locationLabel.textAlignment = .right

            view.locationIcon.image = UIImage(named: "ic_location")
            view.locationIcon.contentMode = .scaleAspectFill

            view.logo.contentMode = .scaleAspectFit

            view.offersTable.backgroundColor = Palette.PartnerSharesView.tableBackground.color
        }
    }

    static var partnerSharesTableHeader: Change<PartnerSharesTableHeader> {
        return { (view: PartnerSharesTableHeader) -> Void in
            view.countValue.text = "4"
            view.countValue.font = UIFont(name: "DINPro-Bold", size: 36)
            view.countValue.textColor = Palette.PartnerSharesView.countValue.color

            view.sharesText.text = "акций\nот партнера"
            view.sharesText.font = UIFont(name: "DINPro-Medium", size: 12)
            view.sharesText.textColor = Palette.PartnerSharesView.sharesText.color
            view.sharesText.numberOfLines = 2
        }
    }

}

extension Reactive where Base == PartnerSharesView {

    var offersCountObserver: AnyObserver<Int64> {
        return Binder(base, binding: { (view: PartnerSharesView, value: Int64) in
            view.tableHeader.countValue.text = "\(value)"
        }).asObserver()
    }

    var didLoadOffersObserver: AnyObserver<Bool> {
        return Binder(base, binding: { (view: PartnerSharesView, isShown: Bool) in
            if view.offersTable.isShown != isShown {
                view.offersTable.isShown = isShown
                view.offersTable.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                    view.offersTable.transform = CGAffineTransform.identity
                })
            }
        }).asObserver()
    }

    var vendorsObserver: AnyObserver<PartnerVendorsResponse?> {
        return Binder(base, binding: { (view: PartnerSharesView, input: PartnerVendorsResponse?) in
            if let input = input, let vendors = input.list, vendors.isEmpty == false {
                view.locationButton.isShown = true
            }
        }).asObserver()
    }

}

class PartnerSharesTableHeader: UIView {

    let container = UIView()

    let countValue = UILabel()
    let sharesText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(countValue)
        container.addSubview(sharesText)

        container.snp.makeConstraints { container in
            container.height.equalTo(45)
            container.leading.equalToSuperview().offset(14)
            container.top.equalToSuperview().offset(110 + 2)
        }

        countValue.snp.makeConstraints { countValue in
            countValue.centerY.equalToSuperview().offset(3)
            countValue.leading.equalToSuperview()
        }

        sharesText.snp.makeConstraints { sharesText in
            sharesText.centerY.equalToSuperview()
            sharesText.leading.equalTo(countValue.snp.trailing).offset(10)
            sharesText.trailing.equalToSuperview()
        }

        look.apply(Style.partnerSharesTableHeader)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
