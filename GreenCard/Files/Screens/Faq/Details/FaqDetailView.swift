//
// Created by Hovhannes Sukiasian on 16/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import DTCoreText

class FaqDetailView: UIView {

    lazy var titleLabel = UILabel()
    lazy var questionContainer = UIView()
    lazy var questionLabel = UILabel()
    lazy var answerContainer = UIView()
    lazy var answerText = DTAttributedTextView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)

        addSubview(questionContainer)
        questionContainer.addSubview(questionLabel)

        addSubview(answerContainer)
        answerContainer.addSubview(answerText)

        answerText.textDelegate = self

        layout()
        look.apply(Style.faqDetailView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        titleLabel.snp.makeConstraints { title in
            title.top.equalToSuperview().offset(16)
            title.trailing.equalToSuperview().offset(-18)
        }

        questionContainer.snp.makeConstraints { questionContainer in
            questionContainer.top.equalToSuperview().offset(120)
            questionContainer.leading.equalToSuperview().offset(14)
            questionContainer.trailing.equalToSuperview().offset(-14)
        }

        questionLabel.snp.makeConstraints { questionLabel in
            questionLabel.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        }

        answerContainer.snp.makeConstraints { answerContainer in
            answerContainer.top.equalTo(questionContainer.snp.bottom).offset(28)
            answerContainer.leading.equalToSuperview().offset(14)
            answerContainer.trailing.equalToSuperview().offset(-14)
            answerContainer.bottom.equalToSuperview().offset(-14)
        }

        answerText.snp.makeConstraints { answerLabel in
            answerLabel.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 0))
        }
    }

    func configure(question: String, answer: String) {
        questionLabel.text = question
        // Парсинг html тяжелая операция

        DispatchQueue.global(qos: .userInteractive).async {
            let htmlBuilder = DTHTMLAttributedStringBuilder(html: answer.utfData,
                    options: [
                        DTDefaultFontName: "ProximaNova-Regular",
                        DTDefaultFontSize: 14,
                        DTDefaultTextColor: Palette.FaqDetailView.answerText.color,
                        DTDefaultLinkColor: Palette.FaqDetailView.link.color
                    ],
                    documentAttributes: nil)
            let htmlText = htmlBuilder?.generatedAttributedString()
            DispatchQueue.main.async { [weak self] () in
                self?.answerText.attributedString = htmlText
            }
        }

    }

}

extension FaqDetailView: DTAttributedTextContentViewDelegate {

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

    static var faqDetailView: Change<FaqDetailView> {
        return { (view: FaqDetailView) in
            view.backgroundColor = Palette.FaqDetailView.background.color

            view.titleLabel.text = "ОТВЕТ"
            view.titleLabel.textColor = Palette.Common.whiteText.color
            view.titleLabel.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.titleLabel.textAlignment = .right
            view.titleLabel.numberOfLines = 1

            view.questionContainer.layer.cornerRadius = 5
            view.questionContainer.layer.masksToBounds = true
            view.questionContainer.backgroundColor = Palette.FaqDetailView.containerBackground.color

            view.questionLabel.textColor = Palette.FaqDetailView.questionText.color
            view.questionLabel.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.questionLabel.numberOfLines = 0
            view.questionLabel.lineBreakMode = .byWordWrapping

            view.answerText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)

            view.answerContainer.layer.cornerRadius = 5
            view.answerContainer.layer.masksToBounds = true
            view.answerContainer.backgroundColor = Palette.FaqDetailView.containerBackground.color

//            view.answerLabel.textColor = Palette.FaqDetailView.answerText.color
//            view.answerLabel.font = UIFont(name: "ProximaNova-Bold", size: 14) // TODO: set it
//            view.answerLabel.numberOfLines = 0
//            view.answerLabel.lineBreakMode = .byWordWrapping
        }
    }

}

extension Reactive where Base == FaqDetailView {

    var questionAnswerObserver: AnyObserver<(question: String, answer: String)> {
        return Binder(base, binding: { (view: FaqDetailView, input: (question: String, answer: String) ) in
            view.configure(question: input.question, answer: input.answer)
        }).asObserver()
    }

}

