//
// Created by Hovhannes Sukiasian on 22/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import DTCoreText
import SnapKit
import Look

class BenefitsTabView : UIView {

    static let TAB_NAME = "Выгоды"

    lazy var textView = DTAttributedTextContentView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(textView)

        textView.snp.makeConstraints { textView in
            textView.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 14, bottom: 14, right: 14))
        }

        look.apply(Style.benefitsTabView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String) -> BenefitsTabView {
        DispatchQueue.global(qos: .userInteractive).async {
            let htmlBuilder = DTHTMLAttributedStringBuilder(html: text.utfData,
                    options: [
                        DTDefaultFontName: "ProximaNova-Regular",
                        DTDefaultFontSize: 14,
                        DTDefaultTextColor: Palette.PartnerDetailTabView.text.color,
                        DTDefaultLinkColor: Palette.PartnerDetailTabView.link.color
                    ],
                    documentAttributes: nil)
            let htmlText = htmlBuilder?.generatedAttributedString()
            DispatchQueue.main.async { [weak self] () in
                self?.textView.attributedString = htmlText
            }
        }
        return self
    }

}


fileprivate extension Style {

    static var benefitsTabView: Change<BenefitsTabView> {
        return { (view: BenefitsTabView) in
            view.textView.backgroundColor = Palette.PartnerDetailTabView.textBackground.color
        }
    }

}
