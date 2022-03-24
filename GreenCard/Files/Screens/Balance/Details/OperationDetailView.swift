//
// Created by Hovhannes Sukiasian on 08/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import Lottie

class OperationDetailView: UIView {

    let title = UILabel()
    let headerWidget = OperationDetailHeaderWidget()
    let tableWidget = OperationDetailTableWidget.init()

    let scrollView = UIScrollView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(title)
        addSubview(headerWidget)

        addSubview(scrollView)
        scrollView.addSubview(tableWidget)

        title.snp.makeConstraints { title in
            title.top.equalToSuperview().offset(16)
            title.trailing.equalToSuperview().offset(-18)
        }

        let height: Double = Consts.getTableHeaderHeight()
        let halfHeight: Double = height / 2
        headerWidget.snp.makeConstraints { headerWidget in
            headerWidget.leading.trailing.equalToSuperview()
            headerWidget.centerY.equalTo(self.snp.top).offset(halfHeight - 20)
        }

        scrollView.snp.makeConstraints { scrollView in
            scrollView.top.left.equalToSuperview()
            scrollView.width.equalToSuperview()
            scrollView.height.equalToSuperview()
        }

        tableWidget.snp.makeConstraints { tableWidget in
            tableWidget.edges.equalToSuperview()
            tableWidget.width.equalToSuperview()
        }

        scrollView.delegate = self

        headerWidget.isShown = false
        tableWidget.isShown = false

        look.apply(Style.operationDetailView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension Style {

    static var operationDetailView: Change<OperationDetailView> {
        return { (view: OperationDetailView) -> Void in
            view.backgroundColor = Palette.OperationDetailView.background.color

            view.title.text = "ИНФОРМАЦИЯ\nПО ОПЕРАЦИИ"
            view.title.textColor = Palette.OperationDetailView.title.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.textAlignment = .right
            view.title.numberOfLines = 2

            view.scrollView.showsScrollIndicator = false
        }
    }

}

extension OperationDetailView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        headerWidget.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY, y: 0)
        title.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
    }

}

extension Reactive where Base == OperationDetailView {

    var operationObserver: AnyObserver<OperationDetailsResponse> {
        return Binder(base, binding: { (view: OperationDetailView, input: OperationDetailsResponse) in
            view.headerWidget.configure(address: input.address, dateOf: input.dateOf,
                    typeOf: input.typeOf, uniqueId: input.uniqueId,
                    partnerLogoSrc: input.partnerLogoSrc)
            view.tableWidget.configure(response: input)

            view.headerWidget.isShown = true
            view.headerWidget.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
            UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                view.headerWidget.transform = CGAffineTransform.identity
            })

            view.tableWidget.isShown = true
            view.tableWidget.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
            UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                view.tableWidget.transform = CGAffineTransform.identity
            })
        }).asObserver()
    }

}
