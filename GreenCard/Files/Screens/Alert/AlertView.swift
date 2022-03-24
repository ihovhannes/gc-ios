//
//  AlertView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 27.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Look
import SnapKit

class AlertView: UIView {

    let container = UIView()
    let stackView = UIStackView()

    let title = UILabel()
    let bodyContainer = UIView()
    let bodyScrollView = UIScrollView.init()
    let body = UILabel.init()
    let buttons = UIView()
    let repeatBtn = UILabel()
    let closeBtn = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(container)
        container.addSubview(stackView)

        container.snp.makeConstraints { container in
            container.width.equalToSuperview().offset(-28)
            container.center.equalToSuperview()
        }

        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.addArrangedSubview(title)

        stackView.snp.makeConstraints { stackView in
            stackView.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        }

        stackView.addArrangedSubview(bodyContainer)

        bodyContainer.snp.makeConstraints { bodyContainer in
            bodyContainer.height.equalTo(220)
        }

        bodyContainer.addSubview(bodyScrollView)

        bodyScrollView.snp.makeConstraints { bodyScrollView in
            bodyScrollView.left.bottom.equalToSuperview()
            bodyScrollView.top.equalToSuperview().offset(20)
            bodyScrollView.right.equalToSuperview().offset(10)
        }

        bodyScrollView.addSubview(body)
        body.snp.makeConstraints { body in
            body.left.top.bottom.equalToSuperview()
            body.right.equalToSuperview().offset(-10)
            body.width.equalToSuperview().offset(-10)
        }

        stackView.addArrangedSubview(buttons)
        buttons.addSubview(repeatBtn)
        buttons.addSubview(closeBtn)

        closeBtn.snp.makeConstraints { closeBtn in
            closeBtn.trailing.equalToSuperview()
            closeBtn.top.equalToSuperview().offset(20)
            closeBtn.bottom.equalToSuperview().offset(-20)
        }

        repeatBtn.snp.makeConstraints {repeatBtn in
            repeatBtn.leading.equalToSuperview()
            repeatBtn.firstBaseline.equalTo(closeBtn.snp.firstBaseline)
        }

        look.apply(Style.alertView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension Style {

    static var alertView: Change<AlertView> {
        return {(view: AlertView) -> Void in
            view.backgroundColor = Palette.AlertView.background.color

            view.container.backgroundColor = Palette.AlertView.container.color
            view.container.layer.cornerRadius = 5

            view.title.font = UIFont(name: "ProximaNova-Regular", size: 20)
            view.title.textColor = .black
            view.title.text = "Ошибка при получении данных"

            view.body.font = UIFont(name: "ProximaNova-Regular", size: 14)
            view.body.textColor = .black
            view.body.text = "Вы неверно"
            view.body.numberOfLines = 0
            view.body.lineBreakMode = .byWordWrapping

            view.repeatBtn.font = UIFont(name: "ProximaNova-Semibold", size: 12)
            view.repeatBtn.textColor = Palette.AlertView.button.color
            view.repeatBtn.text = "ПОВТОРИТЬ"

            view.closeBtn.font = UIFont(name: "ProximaNova-Semibold", size: 12)
            view.closeBtn.textColor = Palette.AlertView.button.color
            view.closeBtn.text = "ЗАКРЫТЬ"
        }
    }

}
