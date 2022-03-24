//
//  SplashView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Look
import SnapKit
import RxSwift
import RxCocoa

class SplashView: UIView, DisposeBagProvider, LoginAnimatedView {

    lazy var logo = UILabel()
    lazy var title = UILabel()
    lazy var logoAndTitleHolder = UIView()

    lazy var bonus = UILabel()
    lazy var tagline = UILabel()
    lazy var siteLink = UILabel()
    lazy var bottomTimeline = UIView()

    lazy var logoAndTitleImage = UIImageView()
    lazy var footerImage = UIImageView()

    var background: UIView {
        return self
    }

    init(styleObservable: Observable<Void>) {
        super.init(frame: .zero)

        logoAndTitleHolder.addSubview(logo)
        logoAndTitleHolder.addSubview(title)
        addSubview(logoAndTitleHolder)
        addSubview(bonus)
        addSubview(tagline)
        addSubview(siteLink)
        addSubview(bottomTimeline)

        addSubview(logoAndTitleImage)
        addSubview(footerImage)

        layout()

        logo.text = "G"
        title.text = "ГРИН\nКАРТА"
        bonus.text = "бонусная\nпрограмма"
        tagline.text = "Гринкарта —\nДля тех, кто хочет\nбооооольше!"
        siteLink.text = "www.green-bonus.ru"

        logoAndTitleHolder.isShown = false
        bonus.isShown = false
        tagline.isShown = false
        siteLink.isShown = false

        look.apply(Style.splashStyle)
        styleObservable
                .subscribe({ [weak self] _ -> Void in
                    guard let unwrapSelf = self else {
                        return
                    }
                })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        logoAndTitleHolder.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }

        logo.snp.makeConstraints { maker in
            maker.left.top.bottom.equalToSuperview()
        }

        title.snp.makeConstraints { maker in
            maker.top.right.bottom.equalToSuperview()
            maker.left.equalTo(logo.snp.right).offset(8)
        }

        bottomTimeline.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview()
            maker.top.equalTo(siteLink.snp.bottom).offset(18)
            maker.height.equalTo(5)
            maker.width.equalToSuperview()
        }

        bonus.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(26)
        }

        tagline.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(26)
            maker.top.equalTo(bonus.snp.bottom).offset(20)
        }

        siteLink.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(26)
            maker.top.equalTo(tagline.snp.bottom).offset(40)
        }

        logoAndTitleImage.snp.makeConstraints { logoAndTitleImage in
            logoAndTitleImage.center.equalToSuperview()
            logoAndTitleImage.width.equalTo(99)
            logoAndTitleImage.height.equalTo(42)
        }

        footerImage.snp.makeConstraints { footerImage in
            footerImage.left.bottom.equalToSuperview()
            footerImage.width.equalTo(201)
            footerImage.height.equalTo(191)
        }
    }

    deinit {
        debugPrint("deinit \(#file)+\(#line)")
    }
}

fileprivate extension Style {
    static var splashStyle: Change<SplashView> {
        return { (view: SplashView) -> Void in
            view.backgroundColor = Palette.SplashView.background.color

            view.logo.textColor = Palette.SplashView.text.color
            view.logo.font = UIFont(name: "ProximaNova-Bold", size: 60)

            view.title.textColor = Palette.SplashView.text.color
            view.title.font = UIFont(name: "ProximaNova-Extrabld", size: 14)
            view.title.textAlignment = .left
            view.title.numberOfLines = 2

            view.bonus.textColor = Palette.SplashView.semiTransparent.color
            view.bonus.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.bonus.textAlignment = .left
            view.bonus.numberOfLines = 2

            view.tagline.textColor = Palette.SplashView.text.color
            view.tagline.font = UIFont(name: "ProximaNova-Bold", size: 21)
            view.tagline.textAlignment = .left
            view.tagline.numberOfLines = 3
            view.tagline.look.apply(Style.taglineStyle)

            view.siteLink.textColor = Palette.SplashView.text.color
            view.siteLink.font = UIFont(name: "ProximaNova-Regular", size: 10)

            view.bottomTimeline.backgroundColor = Palette.SplashView.highlight.color

            view.logoAndTitleImage.image = UIImage(named: "launch_logo_and_title")
            view.footerImage.image = UIImage(named: "launch_footer_2")
        }
    }

    static var taglineStyle: Change<UILabel> {
        return { (label: UILabel) -> Void in
            guard let text = label.text else {
                return
            }
            let nsText = text as NSString
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes([NSAttributedStringKey.foregroundColor: Palette.SplashView.semiTransparent.color],
                    range: nsText.range(of: "Гринкарта —"))
            attributedText.addAttributes([NSAttributedStringKey.foregroundColor: Palette.SplashView.highlight.color],
                    range: nsText.range(of: "ооооо"))
            label.attributedText = attributedText
        }
    }
}
