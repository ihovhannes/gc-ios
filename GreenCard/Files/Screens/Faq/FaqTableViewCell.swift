//
// Created by Hovhannes Sukiasian on 14/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SnapKit
import Look

class FaqTableViewCell: UITableViewCell {

    static let identifier = "FaqTableViewCell"

    let container = UIView()

    let question = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        container.addSubview(question)

        contentView.addSubview(container)

        layout()
        selectionStyle = .none

        look.apply(Style.faqTableViewCell)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
//        question.text = nil
//        question.sizeToFit()
//    }

    private func layout() {
        container.snp.makeConstraints { container in
            container.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14))
        }

        question.snp.makeConstraints{ question in
            question.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }
    }

    func configure(text: String ) {
        question.text = text;
    }

}

fileprivate extension Style {

    static var faqTableViewCell: Change<FaqTableViewCell> {
        return { (view: FaqTableViewCell) -> Void in
            view.backgroundColor = Palette.FaqView.cellBackground.color
            view.contentView.backgroundColor = Palette.FaqView.cellBackground.color

            view.container.layer.cornerRadius = 5
            view.container.layer.masksToBounds = true
            view.container.backgroundColor = Palette.FaqView.containerBackground.color

            view.question.textColor = Palette.FaqView.questionText.color
            view.question.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.question.numberOfLines = 0
            view.question.lineBreakMode = .byWordWrapping
        }
    }

}
