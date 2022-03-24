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
import Lottie

class AboutView: UIView {

    let container = UIView()

    let logoContainer = UIView()
    let logo = UIImageView()
    let logoText = UILabel()
    let firstLine = UIView()

    let appDescription = UILabel()
    let ratingContainer = UIView()
    let secondLine = UIView()

    let versionLabel = UILabel()

    let starsAnim = LOTAnimationView(name: "five_stars")

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(logoContainer)

        logoContainer.addSubview(logo)
        logoContainer.addSubview(logoText)

        container.addSubview(firstLine)
        container.addSubview(appDescription)
        container.addSubview(ratingContainer)
        container.addSubview(secondLine)
        container.addSubview(versionLabel)

        ratingContainer.addSubview(starsAnim)
//        starsAnim.frame = CGRect(x: 0, y: 0, width: 240, height: 40)
        starsAnim.snp.makeConstraints { starsAnim in
            starsAnim.edges.equalToSuperview()
        }
        starsAnim.contentMode = .scaleAspectFill
        starsAnim.clipsToBounds = false

        container.snp.makeConstraints { container in
            container.center.equalToSuperview()
            container.width.equalToSuperview().offset(-28)
        }

        logoContainer.snp.makeConstraints { logoContainer in
            logoContainer.centerX.equalToSuperview()
            logoContainer.top.equalToSuperview().offset(10)
        }

        logo.snp.makeConstraints { logo in
            logo.leading.top.bottom.equalToSuperview()
            logo.width.height.equalTo(37)
        }

        logoText.snp.makeConstraints { logoText in
            logoText.leading.equalTo(logo.snp.trailing).offset(10)
            logoText.centerY.trailing.equalToSuperview()
        }

        firstLine.snp.makeConstraints { logoLine in
            logoLine.height.equalTo(1)
            logoLine.leading.trailing.equalToSuperview()
            logoLine.top.equalTo(logoContainer.snp.bottom).offset(10)
        }

        appDescription.snp.makeConstraints { appDescription in
            appDescription.top.equalTo(firstLine.snp.bottom).offset(40)
            appDescription.leading.equalToSuperview().offset(10)
            appDescription.trailing.equalToSuperview().offset(-10)
        }

        ratingContainer.snp.makeConstraints { ratingContainer in
            ratingContainer.width.equalTo(240)
            ratingContainer.height.equalTo(40)
            ratingContainer.centerX.equalToSuperview()
            ratingContainer.top.equalTo(appDescription.snp.bottom).offset(30)
        }

        secondLine.snp.makeConstraints { secondLine in
            secondLine.height.equalTo(1)
            secondLine.leading.trailing.equalToSuperview()
            secondLine.top.equalTo(ratingContainer.snp.bottom).offset(30)
        }

        versionLabel.snp.makeConstraints { versionLabel in
            versionLabel.centerX.equalToSuperview()
            versionLabel.top.equalTo(secondLine.snp.bottom).offset(10)
            versionLabel.bottom.equalToSuperview().offset(-10)
        }

        look.apply(Style.aboutView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension Style {

    static var aboutView: Change<AboutView> {
        return { (view: AboutView) -> Void in
            view.backgroundColor = Palette.AboutView.background.color

            view.container.backgroundColor = Palette.AboutView.container.color
            view.container.layer.cornerRadius = 5

            view.logo.look.apply(Style.logo)
            view.logoText.look.apply(Style.logoText)

            view.firstLine.backgroundColor = Palette.AboutView.line.color

            view.appDescription.text = "Мобильное приложение «Гринкарта» –  это дополнительный инструмент с уникальными возможностями управления ежедневными покупками."
            view.appDescription.font = UIFont(name: "ProximaNova-Regular", size: 14)
            view.appDescription.textColor = Palette.AboutView.description.color
            view.appDescription.numberOfLines = 0
            view.appDescription.lineBreakMode = .byWordWrapping
            view.appDescription.textAlignment = .center

            view.secondLine.backgroundColor = Palette.AboutView.line.color

            view.versionLabel.text = "0.1"
            view.versionLabel.font = UIFont(name: "ProximaNova-Regular", size: 14)
            view.versionLabel.textColor = Palette.AboutView.version.color
        }
    }

    static var logo: Change<UIImageView> {
        return { (imageView: UIImageView) -> Void in
            imageView.image = UIImage(named: "logo_37_green")
        }
    }

    static var logoText: Change<UILabel> {
        return { (label: UILabel) -> Void in
            label.text = "ГРИН\nКАРТА"
            label.font = UIFont(name: "ProximaNova-Extrabld", size: 14)
            label.textAlignment = .left
            label.numberOfLines = 2
            label.textColor = Palette.AboutView.logo.color
        }
    }

}
