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

class FaqView: UIView {

    lazy var title = UILabel()
    lazy var faqLabel = UILabel()
    lazy var questionsTable = getTableView()
    lazy var questionsTableHeader = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(title)
        addSubview(faqLabel)
        addSubview(questionsTable)

        title.text = "ВОПРОСЫ\nИ ОТВЕТЫ"
        faqLabel.text = "Часто\nзадаваемые\nвопросы"

        title.snp.makeConstraints { title in
            title.top.equalToSuperview().offset(16)
            title.trailing.equalToSuperview().offset(-18)
        }

        faqLabel.snp.makeConstraints { faqLabel in
            faqLabel.leading.equalToSuperview().offset(14)
            faqLabel.bottom.equalTo(self.snp.top).offset(Consts.IPHONE_5_HALF_HEIGHT)
        }
        faqLabel.isShown = false
        questionsTable.isShown = false

        questionsTable.snp.makeConstraints { questions in
            questions.edges.equalToSuperview()
        }

        look.apply(Style.faqView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateHeaderViewFrame() {
        let newFrame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(Consts.IPHONE_5_HALF_HEIGHT))
        questionsTableHeader.frame = newFrame
        questionsTable.tableHeaderView = questionsTableHeader
    }

}


fileprivate extension FaqView {

    func getTableView() -> UITableView {
        let tableView = UITableView(frame: frame, style: .grouped)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.showsScrollIndicator = false

        tableView.estimatedSectionFooterHeight = 0
        tableView.sectionFooterHeight = 0

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 7))

        tableView.register(FaqTableViewCell.self, forCellReuseIdentifier: FaqTableViewCell.identifier)
        return tableView
    }

}

fileprivate extension Style {

    static var faqView: Change<FaqView> {
        return { (view: FaqView) -> Void in
            view.backgroundColor = Palette.FaqView.background.color

            view.questionsTable.backgroundColor = Palette.FaqView.collectionBackground.color

            view.title.textColor = Palette.Common.whiteText.color
            view.title.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.title.textAlignment = .right
            view.title.numberOfLines = 2

            view.faqLabel.textColor = Palette.FaqView.faqText.color
            view.faqLabel.font = UIFont(name: "ProximaNova-Semibold", size: 22)
            view.faqLabel.textAlignment = .left
            view.faqLabel.numberOfLines = 3
        }
    }

}


extension Reactive where Base == FaqView {

    var scrollObserver: AnyObserver<CGFloat> {
        return Binder(base, binding: { (view: FaqView, offset: CGFloat) in
            view.faqLabel.transform = CGAffineTransform(translationX: offset * -3, y: 0)
            view.title.transform = CGAffineTransform(translationX: 0, y: offset / -8.0)
        }).asObserver()
    }


    var didLoadOffersObserver: AnyObserver<Bool> {
        return Binder(base, binding: { (view: FaqView, isShown: Bool) in
            if view.faqLabel.isShown != isShown {
                view.faqLabel.isShown = isShown
                if isShown {
                    view.faqLabel.transform = CGAffineTransform(translationX: view.frame.width, y: 0)
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                        view.faqLabel.transform = CGAffineTransform.identity
                    })
                }
            }
            if view.questionsTable.isShown != isShown {
                view.questionsTable.isShown = isShown
                if isShown {
                    view.questionsTable.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
                    UIView.animate(withDuration: Consts.TABLE_APPEAR_DURATION, animations: { [unowned view] () in
                        view.questionsTable.transform = CGAffineTransform.identity
                    })
                }
            }
        }).asObserver()
    }

}
