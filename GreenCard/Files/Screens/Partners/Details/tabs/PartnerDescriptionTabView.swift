//
// Created by Hovhannes Sukiasian on 22/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import DTCoreText
import SnapKit
import Look
import PINRemoteImage

class DescriptionTabView: UIView {

    static let TAB_NAME = "Описание"

    lazy var textView = DTAttributedTextContentView.init()

    lazy var onePhoto = UIImageView()
    lazy var scrollPhoto = UIScrollView.init()
    lazy var stackPhotos = UIStackView.init()

    lazy var webView = UIWebView.init()
    var webViewWasDownloaded = false

    lazy var stackView = UIStackView()

    lazy var lastPhotoScrollPos: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 40

        stackPhotos.axis = .horizontal
        stackPhotos.spacing = 10

        stackView.snp.makeConstraints { stackView in
            stackView.top.equalToSuperview()
            stackView.leading.equalToSuperview().offset(14)
            stackView.bottom.equalToSuperview().offset(-14)
            stackView.trailing.equalToSuperview().offset(-14)
        }

        webView.delegate = self
        webView.scalesPageToFit = true
        webView.alpha = 0

        webView.snp.remakeConstraints { webView in
            webView.height.equalTo(1)
        }

//        scrollPhoto.bounces = false
        scrollPhoto.showsHorizontalScrollIndicator = false
        scrollPhoto.showsVerticalScrollIndicator = false
        webView.scrollView.isScrollEnabled = false

        look.apply(Style.descriptionTabView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(text: String?, photosSrc: [String]?, descriptionVideoSrc: String?) -> DescriptionTabView {
        if let descrText = text {
            stackView.addArrangedSubview(textView)

            DispatchQueue.global(qos: .userInteractive).async {
                let htmlBuilder = DTHTMLAttributedStringBuilder(html: descrText.utfData,
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
        }
        if let photos = photosSrc {
            if photos.count == 1 {
                stackView.addArrangedSubview(stackPhotos)

                stackPhotos.addArrangedSubview(onePhoto)
                onePhoto.snp.makeConstraints { onePhoto in
                    onePhoto.edges.equalToSuperview()
                    onePhoto.height.equalTo(150)
                }

                onePhoto.pin_clearImages()
                onePhoto.pin_cancelImageDownload()
                onePhoto.pin_setImage(from: URL(string: photos[0]), completion: { [weak onePhoto, weak self] _ in
                    if let onePhoto = onePhoto {
                        self?.fadeOutScrollPhoto(onePhoto)
                    }
                })
            } else if photos.count > 1 {
                stackView.addArrangedSubview(scrollPhoto)
                scrollPhoto.snp.makeConstraints { scrollPhoto in
                    scrollPhoto.height.equalTo(150)
                }

                let scrollPhotoSize = UIView()
                scrollPhoto.addSubview(scrollPhotoSize)
                scrollPhotoSize.snp.makeConstraints { scrollPhotoSize in
                    scrollPhotoSize.edges.equalToSuperview()
                }

                scrollPhoto.addSubview(stackPhotos)
                stackPhotos.snp.makeConstraints { stackPhotos in
                    stackPhotos.left.top.equalToSuperview()
                    stackPhotos.height.equalTo(scrollPhotoSize.snp.height)
                    stackPhotos.width.equalTo(scrollPhotoSize.snp.width)
                }

                for photoSrc in photos {
                    let imageView = UIImageView()
                    stackPhotos.addArrangedSubview(imageView)

                    imageView.snp.makeConstraints { imageView in
                        imageView.width.equalTo(225)
                        imageView.height.equalTo(150)
                    }

                    imageView.contentMode = .scaleAspectFit

                    imageView.pin_setImage(from: URL(string: photoSrc), completion: { [weak imageView, weak self] _ in
                        if let imageView = imageView {
                            self?.fadeOutScrollPhoto(imageView)
                        }
                    })
                }
            }
        }
        if let videoSrc = descriptionVideoSrc, videoSrc.isEmpty == false {
            stackView.addArrangedSubview(webView)
            DispatchQueue.main.async { [weak self] () in
                let src = "<html><head><style>body{margin:0px;}</style></head><body>\(videoSrc)</body></html>"
                self?.webView.loadHTMLString(src, baseURL: nil)
            }
        }
        return self
    }

    func blockSwipe() -> (() -> Bool) {
        return { [weak self] in
            guard let selfExist = self else {
                return false
            }
            return selfExist.scrollPhoto.isTracking && selfExist.scrollPhoto.isDragging
                    && selfExist.scrollPhoto.contentOffset.x + selfExist.scrollPhoto.frame.width < selfExist.scrollPhoto.contentSize.width
        }
    }

}

fileprivate extension DescriptionTabView {

    func fadeOutScrollPhoto(_ result: UIImageView) {
        result.alpha = 0
        UIView.animate(withDuration: 0.2, animations: { [unowned result] () in
            result.alpha = 1
        })
    }

}

extension DescriptionTabView: UIWebViewDelegate {

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let widthStr = webView.stringByEvaluatingJavaScript(from: "document.body.scrollWidth") ?? "100"
        let heightStr = webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight") ?? "100"

        var width: Float = Float(widthStr) ?? 100
        let height: Float = Float(heightStr) ?? 100

        width = width > 0 ? width : 100

        let screenWidth = webView.frame.size.width
        let webHeight = CGFloat(height) * (screenWidth / CGFloat(width))

        webView.snp.remakeConstraints { webView in
            webView.height.equalTo(webHeight)
        }

        webView.scrollView.zoom(to: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), animated: false)

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.webView.alpha = 1
        })
    }

}


fileprivate extension Style {

    static var descriptionTabView: Change<DescriptionTabView> {
        return { (view: DescriptionTabView) in
            view.textView.backgroundColor = Palette.PartnerDetailTabView.textBackground.color

            view.onePhoto.contentMode = .scaleAspectFit

            view.webView.backgroundColor = Palette.PartnerDetailBonusesView.videoBackground.color
        }
    }

}
