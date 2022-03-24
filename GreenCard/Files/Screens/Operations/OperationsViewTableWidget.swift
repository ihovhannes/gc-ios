//
// Created by Hovhannes Sukiasian on 05/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look

class OperationsViewTableWidget: UIView {


    let stackView = UIStackView()
    let manageRow = OperationsManageTableRow()
    let blockCardRow = OperationsBlockCardTableRow()

    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .vertical
        stackView.spacing = 14
        addSubview(stackView)

        let height: Double = Consts.getTableHeaderHeight()

        stackView.snp.makeConstraints { stackView in
            stackView.edges.equalToSuperview().inset(UIEdgeInsets(top: CGFloat(height - 100), left: 14, bottom: 14, right: 14))
        }

        stackView.addArrangedSubview(manageRow)
        stackView.addArrangedSubview(blockCardRow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension Style {

    static var operationsManageTableRow: Change<OperationsManageTableRow> {
        return { (view: OperationsManageTableRow) in
            view.backgroundColor = Palette.OperationsView.tableRowBackground.color
            view.layer.cornerRadius = 5

            view.label.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.label.textColor = Palette.OperationsView.tableRowTitle.color
            view.label.numberOfLines = 2
            view.label.text = "Управление\nсемейным счетом"

            view.leftIcon.image = UIImage(named: "ic_add_card")
            view.gotoButton.image = UIImage(named: "ic_go")
        }
    }

    static var operationsBlockCardTableRow: Change<OperationsBlockCardTableRow> {
        return { (view: OperationsBlockCardTableRow) in
            view.backgroundColor = Palette.OperationsView.tableRowBackground.color
            view.layer.cornerRadius = 5

            view.blockCardIcon.image = UIImage(named: "ic_block_card")
            view.blockHelpIcon.image = UIImage(named: "ic_question")

            view.blockCardLabel.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            view.blockCardLabel.textColor = Palette.OperationsView.tableRowTitle.color
            view.blockCardLabel.text = "Блокировка карты"

            view.currentNumberText.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.currentNumberText.textColor = Palette.OperationsView.currentNumberText.color
            view.currentNumberText.text = "Номер текущей карты"

            view.currentNumberValue.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.currentNumberValue.textColor = Palette.OperationsView.currentNumberValue.color
            view.currentNumberValue.text = "3000   0125   1019   6377"

            view.typePasswordText.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.typePasswordText.textColor = Palette.OperationsView.typePasswordText.color
            view.typePasswordText.text = "Введите пароль"

            view.typePasswordField.font = UIFont(name: "ProximaNova-Semibold", size: 10)
            view.typePasswordField.textColor = Palette.OperationsView.typePasswordField.color
            view.typePasswordField.isSecureTextEntry = true
            view.typePasswordField.keyboardType = .alphabet
            view.typePasswordField.returnKeyType = .done
            view.typePasswordField.clearsOnBeginEditing = false

            view.typePasswordLine.backgroundColor = Palette.OperationsView.typePasswordLine.color

            view.typePasswordWarn.font = UIFont(name: "ProximaNova-Regular", size: 10)
            view.typePasswordWarn.textColor = Palette.OperationsView.typePasswordWarn.color
            view.typePasswordWarn.text = "Это поле не должно быть пустым"

            view.blockButton.font = UIFont(name: "ProximaNova-Bold", size: 9)
            view.blockButton.textColor = Palette.OperationsView.blockButton.color
            view.blockButton.text = "ЗАБЛОКИРОВАТЬ"
        }
    }

}


class OperationsManageTableRow: UIView {

    let leftIcon = UIImageView()
    let label = UILabel()
    let gotoButton = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.snp.makeConstraints { selfSize in
            selfSize.height.equalTo(83)
        }

        addSubview(leftIcon)
        addSubview(label)
        addSubview(gotoButton)

        leftIcon.snp.makeConstraints { leftIcon in
            leftIcon.width.equalTo(24)
            leftIcon.height.equalTo(19)
            leftIcon.centerY.equalToSuperview()
            leftIcon.leading.equalToSuperview().offset(30)
        }

        label.snp.makeConstraints { label in
            label.leading.equalToSuperview().offset(80)
            label.centerY.equalToSuperview()
        }

        gotoButton.snp.makeConstraints { gotoButton in
            gotoButton.leading.equalTo(self.snp.trailing).offset(-36)
            gotoButton.height.equalTo(15)
            gotoButton.width.equalTo(9)
            gotoButton.centerY.equalToSuperview()
        }

        look.apply(Style.operationsManageTableRow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class OperationsBlockCardTableRow: UIView {

    let blockCardIcon = UIImageView()
    let blockCardLabel = UILabel()

    let blockHelpIcon = UIImageView()

    let currentNumberText = UILabel()
    let currentNumberValue = UILabel()

    let typePasswordText = UILabel()
    let typePasswordField = UITextField()
    let typePasswordLine = UIView()
    let typePasswordWarn = UILabel()

    let blockButton = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.snp.makeConstraints { selfSize in
            selfSize.height.equalTo(235)
        }

        addSubview(blockCardIcon)
        addSubview(blockCardLabel)
        addSubview(blockHelpIcon)

        addSubview(currentNumberText)
        addSubview(currentNumberValue)

        addSubview(typePasswordText)
        addSubview(typePasswordField)
        addSubview(typePasswordLine)
        addSubview(typePasswordWarn)

        addSubview(blockButton)

        blockCardIcon.snp.makeConstraints { blockCardIcon in
            blockCardIcon.leading.equalToSuperview().offset(30)
            blockCardIcon.top.equalToSuperview().offset(22)
            blockCardIcon.width.equalTo(23)
            blockCardIcon.height.equalTo(23)
        }

        blockCardLabel.snp.makeConstraints { blockCardLabel in
            blockCardLabel.leading.equalToSuperview().offset(80)
            blockCardLabel.centerY.equalTo(blockCardIcon.snp.centerY)
        }

        blockHelpIcon.snp.makeConstraints { blockHelpIcon in
            blockHelpIcon.leading.equalTo(self.snp.trailing).offset(-36)
            blockHelpIcon.centerY.equalTo(blockCardIcon.snp.centerY)
            blockHelpIcon.width.equalTo(12)
            blockHelpIcon.height.equalTo(12)
        }

        currentNumberText.snp.makeConstraints { currentNumberLabel in
            currentNumberLabel.leading.equalToSuperview().offset(80)
            currentNumberLabel.top.equalTo(blockCardLabel.snp.bottom).offset(30)
        }

        currentNumberValue.snp.makeConstraints { currentNumberValue in
            currentNumberValue.leading.equalToSuperview().offset(80)
            currentNumberValue.top.equalTo(currentNumberText.snp.bottom).offset(3)
        }

        typePasswordField.snp.makeConstraints { typePasswordField in
            typePasswordField.leading.equalToSuperview().offset(80)
            typePasswordField.trailing.equalToSuperview().offset(-40)
            typePasswordField.top.equalTo(currentNumberValue.snp.bottom).offset(38)
        }

        typePasswordLine.snp.makeConstraints { typePasswordLine in
            typePasswordLine.height.equalTo(1)
            typePasswordLine.leading.equalToSuperview().offset(80)
            typePasswordLine.trailing.equalToSuperview().offset(-40)
            typePasswordLine.top.equalTo(typePasswordField.snp.bottom).offset(8)
        }

        typePasswordText.snp.makeConstraints { typePasswordText in
            typePasswordText.leading.equalToSuperview().offset(80)
            typePasswordText.centerY.equalTo(typePasswordField.snp.centerY)
        }

        typePasswordWarn.snp.makeConstraints { typePasswordWarn in
            typePasswordWarn.leading.equalToSuperview().offset(80)
            typePasswordWarn.top.equalTo(typePasswordLine.snp.bottom).offset(5)
        }

        blockButton.snp.makeConstraints { blockButton in
            blockButton.leading.equalToSuperview().offset(32)
            blockButton.bottom.equalToSuperview().offset(-25)
        }

        typePasswordWarn.isShown = false

        look.apply(Style.operationsBlockCardTableRow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension OperationsBlockCardTableRow {

    func switchToPasswordWarn(text: String) {
        self.typePasswordText.textColor = Palette.OperationsView.typePasswordText.color
        self.typePasswordLine.backgroundColor = Palette.OperationsView.typePasswordWarn.color
        self.typePasswordWarn.text = text

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.typePasswordText.transform = CGAffineTransform(translationX: 0, y: -16)
            self.typePasswordWarn.isShown = true
        })
    }

    func switchToPasswordTyping() {
        self.typePasswordText.textColor = Palette.OperationsView.typePasswordTextActive.color
        self.typePasswordLine.backgroundColor = Palette.OperationsView.typePasswordLineActive.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            self.typePasswordText.transform = CGAffineTransform(translationX: 0, y: -16)
            self.typePasswordWarn.isShown = false
        })
    }

    func resetState() {
        self.typePasswordText.textColor = Palette.OperationsView.typePasswordText.color
        self.typePasswordLine.backgroundColor = Palette.OperationsView.typePasswordLine.color

        UIView.animate(withDuration: 0.2, animations: { [unowned self] () in
            if self.typePasswordField.text.isEmpty() {
                self.typePasswordText.transform = CGAffineTransform.identity
            } else {
                self.typePasswordText.transform = CGAffineTransform(translationX: 0, y: -16)
            }
            self.typePasswordWarn.isShown = false
        })
    }

}
