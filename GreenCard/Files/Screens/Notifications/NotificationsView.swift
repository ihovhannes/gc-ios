//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift

class NotificationsView: UIView {

    let BUTTON_WIDTH = 180.0
    let BUTTON_HEIGHT = 45.0

    lazy var title = UILabel()
    lazy var newLabel = UILabel()

    lazy var buttonContainer = UIView()
    lazy var buttonLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(title)
        addSubview(newLabel)
        addSubview(buttonContainer)

        buttonContainer.addSubview(buttonLabel)

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-18)
        }

        newLabel.snp.makeConstraints { newLabel in
            newLabel.leading.equalToSuperview().offset(14)
            newLabel.top.equalToSuperview().offset(140)
        }

        buttonContainer.snp.makeConstraints { buttonContainer in
            buttonContainer.width.equalTo(BUTTON_WIDTH)
            buttonContainer.height.equalTo(BUTTON_HEIGHT)
            buttonContainer.top.equalTo(newLabel.snp.bottom).offset(30)
            buttonContainer.centerX.equalToSuperview()
        }

        buttonLabel.snp.makeConstraints { buttonLabel in
            buttonLabel.center.equalToSuperview()
        }

        // --

        newLabel.isShown = false
        buttonContainer.isShown = false

        // --

        look.apply(Style.notificationsView);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension NotificationsView {

    func appearanceAnim() {
        newLabel.isShown = true
        buttonContainer.isShown = true

        newLabel.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        buttonContainer.transform = CGAffineTransform(translationX: 0, y: self.frame.height)

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.newLabel.transform = CGAffineTransform.identity
            self.buttonContainer.transform = CGAffineTransform.identity
        })
    }

}

fileprivate extension Style {

    static var notificationsView: Change<NotificationsView> {
        return { (view: NotificationsView) -> Void in
            view.backgroundColor = Palette.NotificationsView.background.color

            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.text = "УВЕДОМЛЕНИЯ"

            view.newLabel.font = UIFont(name: "ProximaNova-SemiBold", size: 14)
            view.newLabel.textColor = Palette.NotificationsView.text.color
            view.newLabel.text = "Новые"

            view.buttonContainer.layer.borderWidth = 1
            view.buttonContainer.layer.borderColor = Palette.NotificationsView.buttonBorder.color.cgColor
            view.buttonContainer.layer.allowsEdgeAntialiasing = true
            view.buttonContainer.layer.cornerRadius = CGFloat(view.BUTTON_HEIGHT / 2.0)

            view.buttonLabel.font = UIFont(name: "ProximaNova-Bold", size: 8)
            view.buttonLabel.textColor = Palette.NotificationsView.buttonText.color
            view.buttonLabel.text = "ВСЕ УВЕДОМЛЕНИЯ"
        }
    }

}
