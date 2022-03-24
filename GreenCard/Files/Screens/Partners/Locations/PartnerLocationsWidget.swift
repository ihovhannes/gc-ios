//
// Created by Hovhannes Sukiasian on 02/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import RxGesture

class PartnerLocationsWidget: UIView, DisposeBagProvider {

    let selectionTrigger = PublishSubject<Int>()

    let contactInfoText = UILabel()

    let prevBtn = UIImageView()
    let nextBtn = UIImageView()

    let swipeArea = UIView()
    var vendorInfoViews: [UIView] = []
    var currentVendor = 0

    fileprivate let dotsWidget = PartnerLocationsDotsWidget()

    var isSwipeAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(contactInfoText)
        self.addSubview(prevBtn)
        self.addSubview(nextBtn)

        self.addSubview(swipeArea)
        self.addSubview(dotsWidget)

        contactInfoText.snp.makeConstraints { contactInfoText in
            contactInfoText.leading.top.equalToSuperview().offset(18)
        }

        nextBtn.snp.makeConstraints { nextBtn in
            nextBtn.centerY.equalTo(contactInfoText.snp.centerY)
            nextBtn.trailing.equalToSuperview().offset(-18)

            nextBtn.width.equalTo(11)
            nextBtn.height.equalTo(18)
        }

        prevBtn.snp.makeConstraints { prevBtn in
            prevBtn.centerY.equalTo(contactInfoText.snp.centerY)
            prevBtn.trailing.equalTo(nextBtn.snp.leading).offset(-22)

            prevBtn.width.equalTo(11)
            prevBtn.height.equalTo(18)
        }

        swipeArea.snp.makeConstraints { swipeArea in
            swipeArea.top.equalToSuperview().offset(70)
            swipeArea.bottom.equalToSuperview().offset(-50)
            swipeArea.leading.equalToSuperview().offset(18)
            swipeArea.trailing.equalToSuperview().offset(-18)
        }

        dotsWidget.snp.makeConstraints { dotsWidget in
            dotsWidget.leading.equalToSuperview().offset(18)
            dotsWidget.trailing.equalToSuperview().offset(-18)
            dotsWidget.bottom.equalToSuperview().offset(-11)
        }

        prevBtn.gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: prevBtnTapHandler)
                .disposed(by: disposeBag)

        nextBtn.gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: nextBtnTapHandler)
                .disposed(by: disposeBag)

        swipeArea.rx
                .anyGesture(.swipe([.left]))
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: nextBtnTapHandler)
                .disposed(by: disposeBag)

        swipeArea.rx
                .anyGesture(.swipe([.right]))
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: prevBtnTapHandler)
                .disposed(by: disposeBag)

        dotsWidget.subscribeOnTapDot(callback: self.tapOnDotHandler)

        look.apply(Style.partnerLocationsWidget)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension Style {

    static var partnerLocationsWidget: Change<PartnerLocationsWidget> {
        return { (view: PartnerLocationsWidget) in
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
            view.swipeArea.layer.masksToBounds = true

            view.contactInfoText.numberOfLines = 2
            view.contactInfoText.text = "Контактная\nинформация"
            view.contactInfoText.font = UIFont(name: "ProximaNova-Regular", size: 14)
            view.contactInfoText.textColor = Palette.PartnerLocationsView.contactInfoText.color

            view.prevBtn.image = UIImage(named: "ic_map_prev")
            view.nextBtn.image = UIImage(named: "ic_map_next")
        }
    }

    static var vendorName: Change<UILabel> {
        return { (label: UILabel) in
            label.textColor = Palette.PartnerLocationsView.vendorName.color
            label.font = UIFont(name: "ProximaNova-Bold", size: 37)
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
//            label.adjustsFontSizeToFitWidth = true
        }
    }

    static var addressField: Change<UILabel> {
        return { (label: UILabel) in
            label.textColor = Palette.PartnerLocationsView.addressField.color
            label.font = UIFont(name: "ProximaNova-Regular", size: 10)
        }
    }

}

extension PartnerLocationsWidget {

    func addVendors(vendors: [PartnerVendorItem]) {
        for vendor in vendors {
            let vendorInfo = UIView()
            vendorInfoViews.append(vendorInfo)

            swipeArea.addSubview(vendorInfo)
            vendorInfo.snp.makeConstraints { vendorInfo in
                vendorInfo.edges.equalToSuperview()
            }

            let vendorName = UILabel()
            vendorInfo.addSubview(vendorName)
            vendorName.snp.makeConstraints { vendorName in
                vendorName.top.equalToSuperview()
                vendorName.leading.equalToSuperview()
                vendorName.trailing.equalToSuperview()
//                vendorName.height.lessThanOrEqualTo(100)
            }
            vendorName.text = vendor.vendorName ?? " "
            vendorName.look.apply(Style.vendorName)

            var lastLabel = vendorName
            var lastOffset = 20

            for addressCouple in [("Адрес: ", vendor.address), ("Телефон: ", vendor.phone), ("Эл. почта: ", vendor.email)] {
                if let text = addressCouple.1 {
                    let label = UILabel()

                    label.look.apply(Style.addressField)
                    label.text = addressCouple.0 + text

                    vendorInfo.addSubview(label)
                    label.snp.makeConstraints { label in
                        label.top.equalTo(lastLabel.snp.bottom).offset(lastOffset)
                        label.leading.equalTo(vendorName.snp.leading)
                        label.trailing.equalTo(vendorName.snp.trailing)
                    }

                    lastLabel = label
                    lastOffset = 2
                    vendorInfo.isShown = false
                }
            }
        }

        dotsWidget.fillDots(for: vendors.count)
        initVendor()
    }

    func initVendor() {
        if currentVendor < vendorInfoViews.count {
            vendorInfoViews[currentVendor].isShown = true
        }
        prevBtn.isShown = vendorInfoViews.count > 1
        nextBtn.isShown = vendorInfoViews.count > 1
    }

}

extension PartnerLocationsWidget {

    func prevBtnTapHandler(_ any: Any) {
        let from = currentVendor
        currentVendor = (currentVendor - 1 + vendorInfoViews.count) % vendorInfoViews.count

        swipeVendors(from: from, to: currentVendor, direction: -1)
    }

    func nextBtnTapHandler(_ any: Any) {
        let from = currentVendor
        currentVendor = (currentVendor + 1 + vendorInfoViews.count) % vendorInfoViews.count
        swipeVendors(from: from, to: currentVendor, direction: 1)
    }

    func tapOnDotHandler(index: Int) {
        gotoIndex(index: index)
    }

    func gotoIndex(index: Int) {
        guard !isSwipeAnimating && currentVendor != index && index < vendorInfoViews.count else {
            return
        }
        let from = currentVendor
        currentVendor = index
        swipeVendors(from: from, to: currentVendor, direction: from < currentVendor ? 1 : -1)
    }

    func swipeVendors(from: Int, to: Int, direction: Int) {
        guard from < vendorInfoViews.count, to < vendorInfoViews.count else {
            return
        }
        selectionTrigger.on(.next(to))
        dotsWidget.indicate(page: to)
        let fromView = vendorInfoViews[from]
        let toView = vendorInfoViews[to]

        fromView.isShown = true
        toView.isShown = true

        fromView.alpha = 1
        toView.alpha = 0

        let transformX = self.frame.width
        fromView.transform = CGAffineTransform.identity
        toView.transform = CGAffineTransform(translationX: CGFloat(direction) * transformX, y: 0)

        self.isSwipeAnimating = true

        UIView.animate(withDuration: 0.2, animations: { [unowned fromView, unowned toView] () in
            fromView.alpha = 0
            toView.alpha = 1

            fromView.transform = CGAffineTransform(translationX: -1 * CGFloat(direction) * transformX, y: 0)
            toView.transform = CGAffineTransform.identity
        }, completion: { [weak fromView, weak toView, weak self] isFinished in
            fromView?.isShown = false
            toView?.isShown = true
            self?.isSwipeAnimating = false
        })
    }

}

fileprivate class PartnerLocationsDotsWidget: UIView, DisposeBagProvider {

    let GESTURE_WIDTH = 30
    let HEIGHT = 40
    let BIG_RADIUS = 10
    let SMALL_RADIUS = 20 / 4

    let scrollView = UIScrollView.init()
    let scrollingContent = UIView()

    let dotsStack = UIStackView()
    var dotsArray: [UIView] = []

    let bigDot = UIView()
    var currentPage = 0

    var tapOnDotCallback: ((Int) -> Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        scrollView.addSubview(scrollingContent)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: CGFloat(BIG_RADIUS - GESTURE_WIDTH / 2), bottom: 0, right: CGFloat(BIG_RADIUS - GESTURE_WIDTH / 2))

        scrollingContent.addSubview(dotsStack)

        dotsStack.alignment = .center
        dotsStack.spacing = 0

        self.snp.makeConstraints { selfSnp in
            selfSnp.height.equalTo(HEIGHT)
        }

        scrollView.bounces = false
        scrollView.showsScrollIndicator = false
        scrollView.snp.makeConstraints { scrollView in
            scrollView.edges.equalToSuperview()
            scrollView.height.equalToSuperview()
        }

//        scrollingContent.backgroundColor = .red
        scrollingContent.snp.makeConstraints { scrollingContent in
            scrollingContent.edges.equalToSuperview()
            scrollingContent.height.equalToSuperview()
            scrollingContent.width.greaterThanOrEqualTo(self.snp.width)
            scrollingContent.width.greaterThanOrEqualTo(dotsStack.snp.width)
        }

        dotsStack.snp.makeConstraints { dotsStack in
            dotsStack.height.equalTo(HEIGHT)
            dotsStack.centerX.centerY.equalToSuperview()
        }

        scrollingContent.addSubview(bigDot)
        bigDot.snp.makeConstraints { bigDot in
            bigDot.width.height.equalTo(BIG_RADIUS * 2)
            bigDot.centerY.equalToSuperview()
            bigDot.centerX.equalTo(dotsStack.snp.leading).offset(SMALL_RADIUS)
        }
        bigDot.transform = CGAffineTransform(translationX: CGFloat(GESTURE_WIDTH / 2 - SMALL_RADIUS), y: 0)
        bigDot.layer.cornerRadius = CGFloat(BIG_RADIUS)
        bigDot.backgroundColor = .white
//        bigDot.alpha = 0.8
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // -----------

    func fillDots(for count: Int) {
        guard count > 0 else {
            self.isShown = false
            return
        }
        self.isShown = true
        for i in 0..<count {
            let dot = UIView()
//            dotsStack.addArrangedSubview(dot)
            dotsArray.append(dot)
            dot.layer.cornerRadius = CGFloat(SMALL_RADIUS)
            dot.backgroundColor = .white

            let dotGesture = UIView()
//            dotGesture.backgroundColor = .blue
            dotGesture.snp.makeConstraints { dotGesture in
                dotGesture.width.equalTo(GESTURE_WIDTH)
                dotGesture.height.equalTo(HEIGHT)
            }

            dotGesture.addSubview(dot)
            dot.snp.makeConstraints { dot in
                dot.width.height.equalTo(SMALL_RADIUS * 2)
                dot.center.equalToSuperview()
            }

            dotsStack.addArrangedSubview(dotGesture)

            dotGesture
                    .rx
                    .tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { [i, unowned self] _ in
                        self.tapOnDot(index: i)
                    })
                    .disposed(by: disposeBag)
        }
    }

    // ------------

    func indicate(page: Int) {
        guard page < dotsArray.count else {
            return
        }
        defer {
            currentPage = page
        }

        let nextDot = dotsArray[page]

        let dotOffset = nextDot.convert(CGPoint(x: 0, y: 0), to: dotsStack)
        UIView.animate(withDuration: 0.2, animations: { [unowned bigDot] () in
            bigDot.transform = CGAffineTransform(translationX: dotOffset.x, y: 0)
        })

        if let dotParent = nextDot.superview {
            let visibleRect = dotParent.convert(dotParent.bounds, to: scrollingContent)
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }

    // ---------------

    func subscribeOnTapDot(callback: @escaping (Int) -> Void) {
        self.tapOnDotCallback = callback
    }

    private func tapOnDot(index: Int) {
        tapOnDotCallback?(index)
    }

}
