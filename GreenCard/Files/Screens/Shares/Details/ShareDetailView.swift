//
// Created by Hovhannes Sukiasian on 30/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import RxGesture
import DTCoreText

class ShareDetailView: UIView, DisposeBagProvider {

    lazy var placeHolder = UIImageView()
    lazy var shareImage = UIImageView()
    lazy var underShareBlack = UIView()
    lazy var dateExpireLabel = UILabel()
    lazy var shareName = UILabel()

    lazy var swipeUpForDescriptionArea = UIView()
    lazy var descriptionText = DTAttributedTextView()

    lazy var moreStack = UIStackView()
    lazy var moreLabel = UILabel()
    lazy var moreImg = UIImageView()

    lazy var backSwipe = PublishSubject<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(placeHolder)
        addSubview(shareImage)
        addSubview(underShareBlack)
        addSubview(dateExpireLabel)
        addSubview(shareName)
        addSubview(swipeUpForDescriptionArea)
        addSubview(moreStack)

        moreStack.addArrangedSubview(moreLabel)
        moreStack.addArrangedSubview(moreImg)

        addSubview(descriptionText)

        placeHolder.snp.makeConstraints { placeHolder in
            placeHolder.edges.equalToSuperview()
        }

        shareImage.snp.makeConstraints { shareImage in
            shareImage.edges.equalToSuperview()
        }

        underShareBlack.snp.makeConstraints { underShareBlack in
            underShareBlack.edges.equalToSuperview()
        }

        dateExpireLabel.snp.makeConstraints { dateExpireLabel in
            dateExpireLabel.top.equalToSuperview().offset(33)
            dateExpireLabel.trailing.equalToSuperview().offset(-18)
        }

        shareName.snp.makeConstraints { shareName in
            shareName.bottom.equalToSuperview().offset(-100)
            shareName.leading.equalToSuperview().offset(30)
            shareName.width.equalToSuperview().multipliedBy(0.8)
        }

        moreStack.axis = .horizontal
        moreStack.alignment = .center
        moreStack.spacing = 14

        moreImg.snp.makeConstraints { moreImg in
            moreImg.width.equalTo(28)
            moreImg.height.equalTo(7)
        }

        moreStack.snp.makeConstraints { moreStack in
            moreStack.bottom.equalToSuperview().offset(-28)
            moreStack.right.equalToSuperview().offset(-30)
        }

        swipeUpForDescriptionArea.snp.makeConstraints { swipeUpForDescriptionArea in
            swipeUpForDescriptionArea.left.bottom.right.equalToSuperview()
            swipeUpForDescriptionArea.height.equalToSuperview().multipliedBy(0.3)
        }

        showDescriptionText(isShow: false, animate: false)

        descriptionText.textDelegate = self

        moreStack
                .gestureArea(leftOffset: 5, topOffset: 5, rightOffset: 5, bottomOffset: 5)
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: tapMoreHandler)
                .disposed(by: disposeBag)

        descriptionText.rx
                .anyGesture(.swipe([.down]))
                .when(.recognized)
                .subscribe(onNext: scrollSwipeDownHandler)
                .disposed(by: disposeBag)

        swipeUpForDescriptionArea.rx
                .anyGesture(.swipe([.up]))
                .when(.recognized)
                .subscribe(onNext: swipeUpDescriptionAreaHandler)
                .disposed(by: disposeBag)

        self.rx
                .anyGesture(.swipe([.left, .right]))
                .when(.recognized)
                .subscribe(onNext: leftRightSwipeForBack)
                .disposed(by: disposeBag)

        look.apply(Style.shareDetailView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String?, endDate: String?) {
        shareImage.alpha = 0
        shareImage.pin_clearImages()
        shareImage.pin_cancelImageDownload()

        shareName.text = title
        dateExpireLabel.text = endDate

        setDescription(value: "")
    }

}

// -- Animations

extension ShareDetailView {

    func fadeOutShareImg(_ any: Any) {
        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.shareImage.alpha = 1
        })
    }

    func showDescriptionText(isShow: Bool, animate: Bool) {
        descriptionText.snp.remakeConstraints { descriptionText in
            descriptionText.height.equalToSuperview().offset(-80)
            descriptionText.width.equalToSuperview()
            descriptionText.centerX.equalToSuperview()
            if isShow {
                descriptionText.bottom.equalToSuperview()
            } else {
                descriptionText.top.equalTo(self.snp.bottom)
            }
        }

        if animate {
            UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
                self.layoutIfNeeded()
            })
            UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
                self.dateExpireLabel.alpha = isShow ? 0.0 : 1.0
            })
        }
    }

}

// -- Gestures

extension ShareDetailView {

    func tapMoreHandler(arg: Any) {
        showDescriptionText(isShow: true, animate: true)
    }

    func scrollSwipeDownHandler(arg: Any) {
        if descriptionText.contentOffset.y <= 0 {
            showDescriptionText(isShow: false, animate: true)
        }
    }

    func swipeUpDescriptionAreaHandler(arg: Any) {
        showDescriptionText(isShow: true, animate: true)
    }

    func leftRightSwipeForBack(arg: Any) {
        backSwipe.onNext(())
    }

}

extension ShareDetailView: DTAttributedTextContentViewDelegate {

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

    static var shareDetailView: Change<ShareDetailView> {
        return { (view: ShareDetailView) in
            view.backgroundColor = .black
            view.swipeUpForDescriptionArea.backgroundColor = Palette.Common.transparentBackground.color

            view.placeHolder.image = UIImage(named: "placeholder_big")
            view.placeHolder.contentMode = .scaleAspectFill
            view.placeHolder.clipsToBounds = true

            view.shareImage.contentMode = .scaleAspectFill
            view.shareImage.clipsToBounds = true

            view.underShareBlack.backgroundColor = Palette.ShareDetailView.underImageBlack.color

            view.dateExpireLabel.text = ""
            view.dateExpireLabel.textColor = Palette.ShareDetailView.dateExpire.color
            view.dateExpireLabel.font = UIFont(name: "ProximaNova-Bold", size: 12)
            view.dateExpireLabel.textAlignment = .right

            view.shareName.text = ""
            view.shareName.setLineSpacing(lineHeightMultiple: 0.8)
            view.shareName.textColor = Palette.ShareDetailView.shareName.color
            view.shareName.font = UIFont(name: "ProximaNova-Bold", size: 37)
            view.shareName.lineBreakMode = .byWordWrapping
            view.shareName.numberOfLines = 0

            view.moreLabel.text = "ПОДРОБНЕЕ"
            view.moreLabel.textColor = Palette.ShareDetailView.more.color
            view.moreLabel.font = UIFont(name: "DINPro-Bold", size: 9)

            view.moreImg.image = UIImage(named: "ic_more")

            view.descriptionText.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }
    }

}

extension ShareDetailView {

    func setDescription(value: String?) {
        guard let description = value else {
            return
        }

        DispatchQueue.global(qos: .userInteractive).async {
            let htmlBuilder = DTHTMLAttributedStringBuilder(html: description.utfData,
                    options: [
                        DTDefaultFontName: "ProximaNova-Regular",
                        DTDefaultFontSize: 14,
                        DTDefaultTextColor: Palette.FaqDetailView.answerText.color,
                        DTDefaultLinkColor: Palette.FaqDetailView.link.color
                    ],
                    documentAttributes: nil)
            let htmlText = htmlBuilder?.generatedAttributedString()
            DispatchQueue.main.async { [weak self] () in
                self?.descriptionText.attributedString = htmlText
            }
        }
    }

}

extension Reactive where Base == ShareDetailView {

    var shareObserver: AnyObserver<(imgSrc: String?, description: String?)> {
        return Binder(base, binding: { (view: ShareDetailView, input: (imgSrc: String?, description: String?)) in
            view.shareImage.pin_setImage(from: URL(string: input.imgSrc ?? ""), completion: view.fadeOutShareImg)
            view.setDescription(value: input.description)
        }).asObserver()
    }

}
