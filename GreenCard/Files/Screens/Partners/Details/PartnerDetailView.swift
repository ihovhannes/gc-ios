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


//descriptionView
//advantagesView
//benefitsView
//bonusesView

class PartnerDetailView: UIView, DisposeBagProvider {

    let PAGE_TOP_OFFSET = 280
    let SHARES_BUTTON_HEIGHT = 45.0

    let headerView = UIView()

    let logo = UIImageView()

    let sharesButton = UIView()
    let sharesLabel = UILabel()

    let locationButton = UIView()
    let locationLabel = UILabel()
    let locationIcon = UIImageView()

    let tabsScroll = UIScrollView.init()
    let tabsStack = UIStackView.init()

    let swipeView = UIView()
    let pageSizeView = UIView()
    let scrollView = UIScrollView()

    var tabsLabels: [UILabel] = []
    var pageViews: [UIView] = []

    var pagesNum = 0
    let tabNames: [String] = []
    let pageColors: [UIColor] = []

    var currentPage: Int = 0
    var isSwipeAnimating: Bool = false

    var blockSwipe: (() -> Bool)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        scrollView.addSubview(pageSizeView)
        scrollView.addSubview(swipeView)

        addSubview(logo)
        addSubview(headerView)
        headerView.addSubview(sharesButton)
        sharesButton.addSubview(sharesLabel)

        headerView.addSubview(locationButton)
        locationButton.addSubview(locationLabel)
        locationButton.addSubview(locationIcon)

        headerView.addSubview(tabsScroll)
        tabsScroll.addSubview(tabsStack)

        scrollView.delegate = self

        headerView.snp.makeConstraints { headerView in
            headerView.leading.top.trailing.equalToSuperview()
            headerView.height.equalTo(245)
        }

        logo.snp.makeConstraints { logo in
            logo.width.equalTo(106)
            logo.height.equalTo(52)
            logo.trailing.equalToSuperview().offset(-14)
            logo.top.equalToSuperview().offset(14)
        }

        sharesLabel.snp.makeConstraints { sharesLabel in
            sharesLabel.leading.equalToSuperview().offset(25)
            sharesLabel.trailing.equalToSuperview().offset(-25)
            sharesLabel.centerY.equalToSuperview()
        }

        sharesButton.snp.makeConstraints { sharesButton in
            sharesButton.leading.equalToSuperview().offset(14)
//            sharesButton.width.equalTo(180)
            sharesButton.height.equalTo(SHARES_BUTTON_HEIGHT)
        }

        locationIcon.snp.makeConstraints { locationIcon in
            locationIcon.width.equalTo(19)
            locationIcon.height.equalTo(20)
            locationIcon.trailing.equalToSuperview()
            locationIcon.centerY.equalToSuperview()
        }

        locationLabel.snp.makeConstraints { locationLabel in
            locationLabel.leading.equalToSuperview()
            locationLabel.trailing.equalTo(locationIcon.snp.leading).offset(-14)
            locationLabel.centerY.equalToSuperview()
        }

        locationButton.snp.makeConstraints { locationButton in
            locationButton.top.equalToSuperview().offset(110)
            locationButton.centerY.equalTo(sharesButton.snp.centerY)
            locationButton.trailing.equalToSuperview().offset(-14)
            locationButton.height.equalTo(SHARES_BUTTON_HEIGHT)
        }

        tabsScroll.snp.makeConstraints { tabsScroll in
            tabsScroll.bottom.equalToSuperview()
            tabsScroll.leading.equalToSuperview().offset(14)
            tabsScroll.trailing.equalToSuperview().offset(-14)
        }

        scrollView.snp.makeConstraints { scrollView in
            scrollView.top.left.equalToSuperview()
            scrollView.width.equalToSuperview()
            scrollView.height.equalToSuperview()
        }

        swipeView.snp.makeConstraints { swipeView in
            swipeView.edges.equalToSuperview()
            swipeView.width.equalToSuperview()
        }

        tabsStack.snp.makeConstraints { tabsStack in
            tabsStack.leading.trailing.equalToSuperview()
            tabsStack.top.equalToSuperview()
            tabsStack.bottom.equalToSuperview()
            tabsStack.height.equalToSuperview()
            tabsStack.height.equalTo(50)
        }

        // -- Subscribe on taps

        swipeView.rx
                .anyGesture(.swipe([.left]))
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: swipeLeftHandler)
                .disposed(by: disposeBag)

        swipeView.rx
                .anyGesture(.swipe([.right]))
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: swipeRightHandler)
                .disposed(by: disposeBag)

        // --
        locationButton.isShown = false

        look.apply(Style.partnerDetailView)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addTab(tabName: String, pageView: UIView) {
        defer  {
            pagesNum += 1
        }
        let tabLabel = UILabel()
        tabLabel.text = tabName
        tabLabel.look.apply(Style.tabLabel)

        tabsLabels.append(tabLabel)
        pageViews.append(pageView)

        tabsStack.addArrangedSubview(tabLabel)
        swipeView.addSubview(pageView)

        pageView.snp.makeConstraints { innerView in
            innerView.top.equalToSuperview().offset(PAGE_TOP_OFFSET)
            innerView.leading.trailing.equalToSuperview()
        }

        let index = pagesNum

        tabLabel.rx
                .tapGesture()
                .when(.recognized)
                .filter({ [unowned self] _ in !self.isSwipeAnimating })
                .subscribe(onNext: { [index, unowned self] _ in
                    self.tapOnTab(index: index)
                })
                .disposed(by: disposeBag)
    }

    func initState() {
        logo.pin_clearImages()
        logo.pin_cancelImageDownload()

        logo.alpha = 0
        scrollView.alpha = 0
        tabsScroll.alpha = 0
        locationButton.alpha = 0
    }

    func configure(logoSrc: String?, pageColor: UIColor) {
        initState()
        logo.pin_setImage(from: URL(string: logoSrc ?? ""), completion: fadeOutLogo)

        self.backgroundColor = pageColor
    }

}

extension PartnerDetailView {

    func addDescription(text: String?, photosSrc: [String]?, descriptionVideoSrc: String?) {
        let descriptionView = DescriptionTabView()
                .configure(text: text, photosSrc: photosSrc, descriptionVideoSrc: descriptionVideoSrc)
        self.addTab(tabName: DescriptionTabView.TAB_NAME, pageView: descriptionView)
        self.blockSwipe = descriptionView.blockSwipe()
    }

    func addAdvantages(text: String) {
        let advantagesView = AdvantagesTabView()
                .configure(text: text)
        self.addTab(tabName: AdvantagesTabView.TAB_NAME, pageView: advantagesView)
    }

    func addBenefits(text: String) {
        let benefitsView = BenefitsTabView()
                .configure(text: text)
        self.addTab(tabName: BenefitsTabView.TAB_NAME, pageView: benefitsView)
    }

    func addBonuses(items: [PartnerDetailsBonus]) {
        let bonusesView = BonusesTabView()
                .configure(items: items)
        self.addTab(tabName: BonusesTabView.TAB_NAME, pageView: bonusesView)
    }

    func initTabs() {
        self.initSelectionState()
        self.setScrollSize()
        self.initAnimation()
    }

}

extension PartnerDetailView {

    func showLocationButton() {
        self.locationButton.isShown = true
        self.locationButton.alpha = 0
        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.locationButton.alpha = 1
        })
    }

}

fileprivate extension Style {

    static var partnerDetailView: Change<PartnerDetailView> {
        return { (view: PartnerDetailView) in
            view.backgroundColor = Palette.PartnerDetailView.background.color

            view.headerView.backgroundColor = Palette.PartnerDetailView.headerView.color

            view.scrollView.bounces = false
            view.scrollView.showsHorizontalScrollIndicator = false
            view.scrollView.showsVerticalScrollIndicator = false
            view.tabsStack.distribution = .equalSpacing
            view.tabsStack.alignment = .fill
            view.tabsStack.spacing = 30

            view.tabsScroll.bounces = false
            view.tabsScroll.showsHorizontalScrollIndicator = false
            view.tabsScroll.showsVerticalScrollIndicator = false

            view.sharesButton.layer.borderWidth = 1
            view.sharesButton.layer.borderColor = Palette.PartnerDetailView.sharesBorder.color.cgColor
            view.sharesButton.layer.allowsEdgeAntialiasing = true
            view.sharesButton.layer.cornerRadius = CGFloat(view.SHARES_BUTTON_HEIGHT / 2.0)

            view.sharesLabel.text = "ПОСМОТРЕТЬ АКЦИИ ПАРТНЕРА"
            view.sharesLabel.font = UIFont(name: "ProximaNova-Bold", size: 8)
            view.sharesLabel.textColor = Palette.PartnerDetailView.shares.color

            view.locationLabel.text = "Магазины\nна карте"
            view.locationLabel.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.locationLabel.textColor = Palette.PartnerDetailView.location.color
            view.locationLabel.numberOfLines = 2
            view.locationLabel.textAlignment = .right

            view.locationIcon.image = UIImage(named: "ic_location")
            view.locationIcon.contentMode = .scaleAspectFill

            view.logo.contentMode = .scaleAspectFit
        }
    }

    static var tabLabel: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Bold", size: 10)
            label.textColor = Palette.PartnerDetailView.nonSelectedTab.color
        }
    }

}

extension PartnerDetailView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        self.headerView.alpha = max(0.0, 1.0 - (offset / 60))
        self.headerView.isUserInteractionEnabled = offset <= 30
    }

}

fileprivate extension PartnerDetailView {

    func initSelectionState() {
        for i in 0..<pagesNum {
            pageViews[i].isShown = i == currentPage
            tabsLabels[i].textColor = i == currentPage ? Palette.PartnerDetailView.selectedTab.color : Palette.PartnerDetailView.nonSelectedTab.color
        }
    }

    func initAnimation() {
        scrollView.alpha = 0
        tabsScroll.alpha = 0

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.scrollView.alpha = 1.0
            self.tabsScroll.alpha = 1.0
        })
    }

    func fadeOutLogo(_ any: Any) {
        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.logo.alpha = 1
        })
    }

    func setScrollSize(animate: Bool = false) {
        let minHeight = Consts.getScreenHeight()

        pageSizeView.snp.remakeConstraints { pageSizeView in
            pageSizeView.edges.equalToSuperview()
            for pageView in pageViews {
                pageSizeView.height.greaterThanOrEqualTo(pageView.snp.height).offset(PAGE_TOP_OFFSET)
            }
            pageSizeView.height.greaterThanOrEqualTo(Int(minHeight) + PAGE_TOP_OFFSET - 80)
        }
    }

    func swipeLeftHandler(args: Any) {
        if let blockSwipe = self.blockSwipe, blockSwipe() {
            return
        }
        let nextPage = (currentPage + 1) % pagesNum
        if nextPage > currentPage {
            animateToPage(page: nextPage)
        }
    }

    func swipeRightHandler(args: Any) {
        if let blockSwipe = self.blockSwipe, blockSwipe() {
            return
        }
        let prevPage = (currentPage - 1 + pagesNum) % pagesNum
        if prevPage < currentPage {
            animateToPage(page: prevPage)
        }
    }

    func tapOnTab(index: Int) {
        if index != currentPage {
            animateToPage(page: index)
        }
    }

    func animateToPage(page: Int) {
        defer {
            currentPage = page
        }
        let currentView = pageViews[currentPage]
        let switchView = pageViews[page]

        let direction: CGFloat = page < currentPage ? -1 : 1

        tabsLabels[currentPage].textColor = Palette.PartnerDetailView.nonSelectedTab.color

        let selectedTab = tabsLabels[page]
        selectedTab.textColor = Palette.PartnerDetailView.selectedTab.color
        tabsScroll.scrollRectToVisible(selectedTab.convert(selectedTab.bounds, to: tabsScroll), animated: true)

        currentView.isShown = true
        switchView.isShown = true

        currentView.alpha = 1.0
        switchView.alpha = 0.0

        currentView.transform = CGAffineTransform.identity
        switchView.transform = CGAffineTransform(translationX: direction * switchView.frame.width, y: 0)
        scrollView.isScrollEnabled = false

        isSwipeAnimating = true

        UIView.animate(withDuration: 0.4, animations: { [unowned currentView, unowned switchView] () in
            currentView.transform = CGAffineTransform(translationX: -1 * direction * switchView.frame.width, y: 0)
            switchView.transform = CGAffineTransform.identity

            currentView.alpha = 0.0
            switchView.alpha = 1.0
        }, completion: { [weak currentView, weak self] finished in
            currentView?.isShown = false
            self?.scrollView.isScrollEnabled = true
            self?.setScrollSize()
            self?.isSwipeAnimating = false
        })
    }

}
