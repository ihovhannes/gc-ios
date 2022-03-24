//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import Lottie

class OperationsView: UIView {

    fileprivate let cardAnim = LOTAnimationView(name: "card")
    fileprivate let cardAnimHolder = UIView()

    lazy var title = UILabel()
    lazy var scrollView = UIScrollView.init()
    lazy var tableWidget = OperationsViewTableWidget.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(cardAnimHolder)
        cardAnimHolder.addSubview(cardAnim)

        addSubview(title)
        addSubview(scrollView)
        scrollView.addSubview(tableWidget)

        scrollView.delegate = self
        scrollView.keyboardDismissMode = .onDrag

        title.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-18)
        }

        cardAnim.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        cardAnim.contentMode = .scaleAspectFill
        cardAnim.clipsToBounds = false

        let height: Double = Consts.getTableHeaderHeight() / 2
        cardAnimHolder.snp.makeConstraints { cardAnimHolder in
            cardAnimHolder.width.equalTo(100)
            cardAnimHolder.height.equalTo(100)
            cardAnimHolder.centerX.equalToSuperview()
            cardAnimHolder.centerY.equalTo(self.snp.top).offset(height * 0.88)
        }

        scrollView.snp.makeConstraints { scrollView in
            scrollView.edges.equalToSuperview()
        }

        tableWidget.snp.makeConstraints { tableWidget in
            tableWidget.edges.equalToSuperview()
            tableWidget.width.equalToSuperview()
        }

        scrollView.isShown = false
        look.apply(Style.operationsView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension Style {

    static var operationsView: Change<OperationsView> {
        return { (view: OperationsView) -> Void in
            view.backgroundColor = Palette.OperationsView.background.color

            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.textAlignment = .right
            view.title.numberOfLines = 2
            view.title.text = "ОПЕРАЦИИ\nС КАРТОЙ"

            view.scrollView.showsScrollIndicator = false
        }
    }

}

extension OperationsView: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        cardAnimHolder.transform = CGAffineTransform(translationX: offset * Consts.HEADER_ANIMATION_VELOCITY * 1.15, y: 0)
        title.transform = CGAffineTransform(translationX: 0, y: offset / Consts.TITLE_ANIMATION_VELOCITY)
    }

}

extension Reactive where Base == OperationsView {

    var startAnimObserver: AnyObserver<Void> {
        return Binder(base, binding: { (view: OperationsView, input: ()) in
            view.scrollView.isShown = true
            view.scrollView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
            view.cardAnim.play(completion: { finished in
                if finished {
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [weak view] () in
                        view?.scrollView.transform = CGAffineTransform.identity
                    })
                }
            })
        }).asObserver()
    }

    var mainCardObserver: AnyObserver<CardsListItem?> {
        return Binder(base, binding: { (view: OperationsView, input: CardsListItem?) in
            if let cardData = input, let cardNumber = cardData.cardNum  {
                let formatter = NumberFormatter()
                formatter.groupingSeparator = " "
                formatter.numberStyle = .decimal
                formatter.groupingSize = 4
                let formattedString = formatter.string(from: NSNumber(value: cardNumber))
                view.tableWidget.blockCardRow.currentNumberValue.text = formattedString

                view.tableWidget.blockCardRow.blockButton.text = cardData.isLocked ? "РАЗБЛОКИРОВАТЬ" : "ЗАБЛОКИРОВАТЬ"
            } else {
                view.tableWidget.blockCardRow.currentNumberValue.text = "ОТСУТСВУЕТ"
            }
        }).asObserver()
    }

}

extension OperationsView {

    var manageRow: UIView {
        return tableWidget.manageRow
    }

    var typePasswordField: UITextField {
        return tableWidget.blockCardRow.typePasswordField
    }

    var blockButton: UILabel {
        return tableWidget.blockCardRow.blockButton
    }

    var blockHelpButton: UIView {
        return tableWidget.blockCardRow.blockHelpIcon
    }

    func switchToPasswordTyping() {
        tableWidget.blockCardRow.switchToPasswordTyping()
    }

    func switchToPasswordWarn(text: String) {
        tableWidget.blockCardRow.switchToPasswordWarn(text: text)
    }

    func resetPasswordState() {
        tableWidget.blockCardRow.resetState()
    }
}

extension OperationsView {

    func getKeyboardOffset(field: UITextField) -> CGFloat {
        let inWidgetPosition = field.convert(CGPoint(x: 0, y: 0), to: tableWidget.blockCardRow).y
        let offset = tableWidget.blockCardRow.frame.size.height - inWidgetPosition
        return offset
    }

}
