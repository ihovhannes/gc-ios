//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import DTCoreText

class RegistrationOfertaView :UIView {

    lazy var background = UIView()

    lazy var header = UILabel()
    lazy var title = UILabel()
    lazy var subTitle = UILabel()

    lazy var ofertaText = DTAttributedTextView()

    lazy var acceptButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(background)

        background.snp.makeConstraints { background in
            background.edges.equalToSuperview()
        }

        addSubview(header)
        addSubview(title)
        addSubview(subTitle)

        addSubview(ofertaText)

        addSubview(acceptButton)

        header.snp.makeConstraints { header in
            header.top.equalToSuperview().offset(14)
            header.right.equalToSuperview().offset(-14)
        }

        title.snp.makeConstraints { title in
            title.centerX.equalToSuperview()
            title.top.equalTo(header.snp.bottom).offset(30)
        }

        subTitle.snp.makeConstraints { subTitle in
            subTitle.centerX.equalToSuperview()
            subTitle.top.equalTo(title.snp.bottom).offset(20)
        }

        ofertaText.snp.makeConstraints { ofertaText in
            ofertaText.left.equalToSuperview().offset(14)
            ofertaText.top.equalTo(subTitle.snp.bottom).offset(14)
            ofertaText.right.equalToSuperview().offset(-14)
            ofertaText.bottom.equalTo(acceptButton.snp.top).offset(-14)
        }

        acceptButton.snp.makeConstraints { acceptButton in
            acceptButton.width.equalTo(180)
            acceptButton.height.equalTo(50)
            acceptButton.bottom.equalToSuperview().offset(-14)
            acceptButton.centerX.equalToSuperview()
        }

        ofertaText.textDelegate = self

        look.apply(Style.registrationOfertaView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subTitle: String, ofertaText: String) {
        self.title.text = title
        self.subTitle.text = subTitle

        DispatchQueue.global(qos: .userInteractive).async {
            let htmlBuilder = DTHTMLAttributedStringBuilder(html: ofertaText.utfData,
                    options: [
                        DTDefaultFontName: "ProximaNova-Regular",
                        DTDefaultFontSize: 14,
                        DTDefaultTextColor: Palette.LoginView.text.color,
                        DTDefaultLinkColor: Palette.LoginView.highlight.color
                    ],
                    documentAttributes: nil)
            let htmlText = htmlBuilder?.generatedAttributedString()
            DispatchQueue.main.async { [weak self] () in
                self?.ofertaText.attributedString = htmlText
            }
        }
    }

}

extension RegistrationOfertaView : DTAttributedTextContentViewDelegate {

    func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
        let linkButton = DTLinkButton(frame: frame)
        if let url = url {
            linkButton.url = url
            linkButton.addTarget(self, action: #selector(linkButtonClicked(sender:)), for: .touchUpInside)
        }
        return linkButton
    }

    @objc func linkButtonClicked(sender: DTLinkButton) {
        UIApplication.shared.openURL(sender.url)
    }

}

fileprivate extension Style {

    static var registrationOfertaView: Change<RegistrationOfertaView> {
        return { (view: RegistrationOfertaView) in
            view.background.backgroundColor = Palette.LoginView.background.color

            view.acceptButton.setTitle("ПРИНИМАЮ", for: .normal)
            view.acceptButton.backgroundColor = Palette.LoginView.highlight.color
            view.acceptButton.setTitleColor(Palette.LoginView.text.color, for: .normal)
            view.acceptButton.layer.cornerRadius = 25
            view.acceptButton.layer.masksToBounds = true
            view.acceptButton.titleLabel?.font = UIFont(name: "ProximaNova-Bold", size: 10)

            view.header.font = UIFont(name: "ProximaNova-Semibold", size: 12)
            view.header.text = "Активация\nучетной записи"
            view.header.numberOfLines = 2
            view.header.textAlignment = .right
            view.header.textColor = Palette.LoginView.text.color

            view.title.font = UIFont(name: "ProximaNova-Semibold", size: 20)
            view.title.textColor = Palette.LoginView.text.color
            view.title.text = "Оферта"

            view.subTitle.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.subTitle.textColor = Palette.LoginView.text.color
            view.subTitle.text = "Договор участия в программе лояльности"

            view.ofertaText.showsScrollIndicator = false
            view.ofertaText.backgroundColor = Palette.LoginView.background.color
        }
    }

}
