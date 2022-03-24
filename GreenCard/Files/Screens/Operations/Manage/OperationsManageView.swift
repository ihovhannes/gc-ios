//
// Created by Hovhannes Sukiasian on 08/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit

class OperationsManageView: UIView {

    lazy var titleLabel = UILabel()

    lazy var rulesLabel = UILabel()
    lazy var rulesUnderline = UIView()

    lazy var scrollView = UIScrollView.init()
    lazy var tableWidget = OperationsManageViewTableWidget.init()

    lazy var visibleComponent: UIView? = nil

    lazy var totalCardNum: Int = 0
    lazy var currentCardNum: Int = 0
    lazy var mainCards: [Bool] = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)

        addSubview(scrollView)
        scrollView.addSubview(tableWidget)

        addSubview(rulesLabel)
        addSubview(rulesUnderline)

        titleLabel.snp.makeConstraints { title in
            title.top.equalToSuperview().offset(12)
            title.trailing.equalToSuperview().offset(-18)
        }

        rulesLabel.snp.makeConstraints { archiveShares in
            archiveShares.top.equalToSuperview().offset(16)
            archiveShares.leading.equalToSuperview().offset(100)
        }

        rulesUnderline.snp.makeConstraints { archiveSharesUnderline in
            archiveSharesUnderline.top.equalToSuperview().offset(62)
            archiveSharesUnderline.left.equalTo(rulesLabel.snp.left)
            archiveSharesUnderline.height.equalTo(1)
            archiveSharesUnderline.width.equalTo(20)
        }

        scrollView.snp.makeConstraints { scrollView in
            scrollView.edges.equalToSuperview()
        }

        tableWidget.snp.makeConstraints { tableWidget in
            tableWidget.edges.equalToSuperview()
            tableWidget.width.equalToSuperview()
        }

        tableWidget.mainCardHeader.isShown = false
        tableWidget.cardsHolder.isShown = false
        tableWidget.stackView.isShown = false
//        tableWidget.addCardRow.isShown = false
//        tableWidget.cardDetailsRow.isShown = false

        scrollView.showsScrollIndicator = false

        look.apply(Style.operationsManageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

extension OperationsManageView {

    var cardNumberWrapper: OperationsManageTextWrapper {
        return tableWidget.cardDetailsRow.cardNumberWrapper
    }

    var cardCodeWrapper: OperationsManageTextWrapper {
        return tableWidget.cardDetailsRow.cardCodeWrapper
    }

    var codeInputWrapper: OperationsManageTextWrapper {
        return tableWidget.cardDetailsRow.codeInputWrapper
    }

    var cardNumberField: UITextField {
        return tableWidget.cardDetailsRow.cardNumberField
    }

    var cardCodeField: UITextField {
        return tableWidget.cardDetailsRow.cardCodeField
    }

    var cardUserName: UITextField {
        return tableWidget.cardDetailsRow.cardOwnerField
    }

    var cardUserPhone: UITextField {
        return tableWidget.cardDetailsRow.phoneNumberField
    }

    var codeInputField: UITextField {
        return tableWidget.cardDetailsRow.codeInputField
    }

}

extension OperationsManageView {

    func startupAnim() {
        tableWidget.mainCardHeader.isShown = true
        tableWidget.cardsHolder.isShown = true
        tableWidget.stackView.isShown = true

        tableWidget.mainCardHeader.transform = CGAffineTransform(translationX: self.frame.width, y: 0)
        tableWidget.cardsHolder.transform = CGAffineTransform(translationX: self.frame.width, y: 0)
        tableWidget.addCardRow.transform = CGAffineTransform(translationX: 0, y: self.frame.height)

        UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned self] () in
            self.tableWidget.mainCardHeader.transform = CGAffineTransform.identity
            self.tableWidget.cardsHolder.transform = CGAffineTransform.identity
            self.tableWidget.addCardRow.transform = CGAffineTransform.identity
        })
    }

    func animAddCard() {
        relaxMode()
        relaxAnimMode()

        tableWidget.stackView.addArrangedSubview(tableWidget.cardDetailsRow)
        self.layoutIfNeeded()
        let scrollRect = tableWidget.stackView.convert(CGRect(x: 0, y: tableWidget.cardDetailsRow.frame.height, width: 10, height: 14), to: scrollView)

        tableWidget.cardDetailsRow.transform = CGAffineTransform(translationX: 0, y: self.frame.height)

        UIView.animate(withDuration: 0.1, animations: { [unowned self] () in
            self.scrollView.scrollRectToVisible(scrollRect, animated: false)
        }, completion: { [weak self] finished in
            if finished {
                self?.animAddCardStep2()
            }
        })

    }

    func animAddCardStep2() {

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.tableWidget.addCardRow.transform = CGAffineTransform(translationX: self.frame.width, y: 0)

            let detailsTransformY = -1 * (self.tableWidget.addCardRow.frame.height + 14)
            self.tableWidget.cardDetailsRow.transform = CGAffineTransform(translationX: 0, y: detailsTransformY)
        }, completion: { [weak self] finished in
            if finished, let selfIt = self {
                selfIt.tableWidget.stackView.removeArrangedSubview(selfIt.tableWidget.addCardRow)
                selfIt.tableWidget.addCardRow.removeFromSuperview()
                selfIt.tableWidget.cardDetailsRow.transform = CGAffineTransform.identity
            }
        })
    }

    func animCancelCard() {
        tableWidget.stackView.insertArrangedSubview(tableWidget.addCardRow, at: 0)
        let detailsTransformY = -1 * (self.tableWidget.addCardRow.frame.height + 14)
        self.tableWidget.cardDetailsRow.transform = CGAffineTransform(translationX: 0, y: detailsTransformY)
        self.tableWidget.addCardRow.transform = CGAffineTransform(translationX: self.frame.width, y: 0)

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.tableWidget.cardDetailsRow.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
            self.tableWidget.addCardRow.transform = CGAffineTransform.identity
        }, completion: { [weak self] finished in
            if finished, let selfIt = self {
                selfIt.animCancelCardStep2()
            }
        })
    }

    func animCancelCardStep2() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.tableWidget.stackView.removeArrangedSubview(self.tableWidget.cardDetailsRow)
            self.tableWidget.cardDetailsRow.removeFromSuperview()
            self.layoutIfNeeded()
        })
    }

}

extension OperationsManageView {

    func moveUpComponentsByKeyboard(keyboardHeight: CGFloat, keyboardAnimDuration: TimeInterval) {
        scrollView.snp.remakeConstraints { scrollView in
            scrollView.leading.top.trailing.equalToSuperview()
            scrollView.bottom.equalToSuperview().offset(-1 * keyboardHeight)
        }

        UIView.animate(withDuration: keyboardAnimDuration, animations: { [unowned self] () in
            self.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if finished {
                self?.showVisibleComponent()
            }
        })
    }

    func moveDownComponentsByKeyboard(duration: TimeInterval) {
        scrollView.snp.remakeConstraints { scrollView in
            scrollView.edges.equalToSuperview()
        }
        UIView.animate(withDuration: duration, animations: { [unowned self] () in
            self.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if finished {
                self?.showVisibleComponent()
            }
        })
    }

    func showVisibleComponent() {
        if let visibleComponent = visibleComponent {
            let visibleRect = visibleComponent.convert(visibleComponent.bounds, to: tableWidget)
            scrollView.scrollRectToVisible(visibleRect, animated: true)
        }
    }

}

extension OperationsManageView {

    func isSwipeEnabled() -> Bool {
        return scrollView.contentOffset.y <= 0 || scrollView.contentOffset.y + scrollView.bounds.height >= tableWidget.bounds.height
    }

}

extension OperationsManageView {

    func addCards(cardList: [CardsListItem]?) {
        log("update cards")
        totalCardNum = 0
        currentCardNum = 0
        mainCards = []
        for child in tableWidget.cardsHolder.subviews {
            child.removeFromSuperview()
        }

        if let cardList = cardList {
            totalCardNum = cardList.count
            for card in cardList {
                var cardItemView = OperationsManageCardItem.init()
                        .configure(ownerName: card.ownerFirstName, ownerStatus: card.ownerStatus, ownerPhone: card.ownerPhone, cardNumber: card.cardNum, isMain: card.isMain)
                tableWidget.cardsHolder.addSubview(cardItemView)
                cardItemView.snp.makeConstraints { cardItemView in
                    cardItemView.leading.top.equalToSuperview()
                }

                mainCards.append(card.isMain ?? false)
            }
        }

        tableWidget.cardPaging.setTotalCount(value: totalCardNum)
        tableWidget.cardPaging.setCurrent(value: currentCardNum)
        layoutCards()
    }

    func layoutCards() {
        for i in 0..<totalCardNum {
            let card: UIView = tableWidget.cardsHolder.subviews[i]
            card.transform = CGAffineTransform(translationX: CGFloat((i - currentCardNum ) * (280 + 7)), y: 0)
        }

        var isMain = currentCardNum < mainCards.count ? mainCards[currentCardNum] : true
//        tableWidget.mainCardHeader.text = isMain ? "Основная\nкарта" : "Дополнительная\nкарта"
        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.tableWidget.mainCardHeader.alpha = isMain ? 1 : 0
            self.tableWidget.additionalCardHeader.alpha = isMain ? 0 : 1
        })
    }

    func swipeCardsLeft() {
        guard currentCardNum + 1 < totalCardNum else {
            return
        }
        currentCardNum += 1
        tableWidget.cardPaging.setCurrent(value: currentCardNum)

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.layoutCards()
        })
    }

    func swipeCardsRight() {
        guard currentCardNum - 1 >= 0 else {
            return
        }
        currentCardNum -= 1
        tableWidget.cardPaging.setCurrent(value: currentCardNum)

        UIView.animate(withDuration: 0.4, animations: { [unowned self] () in
            self.layoutCards()
        })
    }

}

fileprivate extension Style {

    static var operationsManageView: Change<OperationsManageView> {
        return { (view: OperationsManageView) -> Void in
            view.backgroundColor = Palette.OperationsManageView.background.color

            view.titleLabel.text = "СЕМЕЙНЫЙ\nСЧЕТ"
            view.titleLabel.textColor = Palette.Common.whiteText.color
            view.titleLabel.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.titleLabel.textAlignment = .right
            view.titleLabel.numberOfLines = 2

            view.rulesLabel.text = "ПРАВИЛА\nСЕМЕЙНОГО\nСЧЕТА"
            view.rulesLabel.textColor = Palette.Common.whiteText.color
            view.rulesLabel.font = UIFont(name: "ProximaNova-Bold", size: 10)
            view.rulesLabel.textAlignment = .left
            view.rulesLabel.numberOfLines = 3

            view.rulesUnderline.backgroundColor = Palette.Common.whiteText.color
        }
    }

}

extension OperationsManageView {

    var details: OperationsManageCardDetailsRow {
        return tableWidget.cardDetailsRow
    }

    func relaxMode() {
        details.cardNumberWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color
        details.cardNumberWarn.isShown = false
        details.cardNumberPlaceholder.textColor = Palette.OperationsManageView.placeholder.color

        details.codeInputWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color
        details.codeInputWarn.isShown = false
        details.codeInputPlaceholder.textColor = Palette.OperationsManageView.placeholder.color

        details.cardCodeWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color
        details.cardCodeWarn.isShown = false
        details.cardCodePlaceholder.textColor = Palette.OperationsManageView.placeholder.color

        self.layoutIfNeeded()
    }

    func relaxAnimMode() {
        details.cardNumberPlaceholder.transform = details.cardNumberField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)

        details.cardCodePlaceholder.transform = details.cardCodeField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)

        details.codeInputPlaceholder.transform = details.codeInputField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)

        details.cardOwnerPlaceholder.transform = details.cardOwnerField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)

        details.phoneNumberPlaceholder.transform = details.phoneNumberField.text.isEmpty() ?
                CGAffineTransform.identity :
                CGAffineTransform(translationX: 0, y: -20)
    }

    func cardNumberInputMode() {
        visibleComponent = details.cardNumberWrapper
        relaxMode()

        details.cardNumberWrapper.underline.backgroundColor = Palette.OperationsManageView.highlight.color
        details.cardNumberWarn.isShown = false
        details.cardNumberPlaceholder.textColor = Palette.OperationsManageView.whitePlaceholder.color

        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.details.cardNumberPlaceholder.transform =  CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func cardNumberWarnMode(text: String) {
        details.cardNumberWarn.text = text
        visibleComponent = details.cardNumberWarn
        relaxMode()

        details.cardNumberWrapper.underline.backgroundColor = Palette.OperationsManageView.warn.color
        details.cardNumberWarn.isShown = true
        details.cardNumberPlaceholder.textColor = Palette.OperationsManageView.whitePlaceholder.color

        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.details.cardNumberPlaceholder.transform =  CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func cardCodeInputMode() {
        visibleComponent = details.cardCodeWrapper
        relaxMode()

        details.cardCodeWrapper.underline.backgroundColor = Palette.OperationsManageView.highlight.color
        details.cardCodeWarn.isShown = false
        details.cardCodePlaceholder.textColor = Palette.OperationsManageView.whitePlaceholder.color

        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.details.cardCodePlaceholder.transform =  CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func cardCodeWarnMode(text: String) {
        details.cardCodeWarn.text = text
        visibleComponent = details.cardCodeWarn
        relaxMode()

        details.cardCodeWrapper.underline.backgroundColor = Palette.OperationsManageView.warn.color
        details.cardCodeWarn.isShown = true
        details.cardCodePlaceholder.textColor = Palette.OperationsManageView.whitePlaceholder.color

        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.details.cardCodePlaceholder.transform =  CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func smsCodeInputMode() {
        visibleComponent = details.codeInputWrapper
        relaxMode()

        details.codeInputWrapper.underline.backgroundColor = Palette.OperationsManageView.highlight.color
        details.codeInputWarn.isShown = false
        details.codeInputPlaceholder.textColor = Palette.OperationsManageView.whitePlaceholder.color

        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.details.codeInputPlaceholder.transform =  CGAffineTransform(translationX: 0, y: -20)
        })
    }

    func smsCodeWarnMode(text: String) {
        details.codeInputWarn.text = text
        visibleComponent = details.codeInputWarn
        relaxMode()

        details.codeInputWrapper.underline.backgroundColor = Palette.OperationsManageView.warn.color
        details.codeInputWarn.isShown = true
        details.codeInputPlaceholder.textColor = Palette.OperationsManageView.whitePlaceholder.color

        self.layoutIfNeeded()

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.relaxAnimMode()
            self.details.codeInputPlaceholder.transform =  CGAffineTransform(translationX: 0, y: -20)
        })
    }

}
