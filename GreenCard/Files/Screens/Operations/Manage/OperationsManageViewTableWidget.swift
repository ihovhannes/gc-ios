//
// Created by Hovhannes Sukiasian on 30/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Look
import InputMask

class OperationsManageViewTableWidget: UIView {

    let mainCardHeader = UILabel()
    let additionalCardHeader = UILabel()
    let cardsHolder = UIView()
    let cardPaging = OperationsManagePagingWidget()

    let hideKeyboardBackground = UIView()

    let stackView = UIStackView()
    let addCardRow = OperationsManageAddCardRow()
    let cardDetailsRow = OperationsManageCardDetailsRow.init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(hideKeyboardBackground)

        hideKeyboardBackground.addSubview(mainCardHeader)
        hideKeyboardBackground.addSubview(additionalCardHeader)
        hideKeyboardBackground.addSubview(cardPaging)
        hideKeyboardBackground.addSubview(cardsHolder)

        stackView.axis = .vertical
        stackView.spacing = 14
        addSubview(stackView)

        hideKeyboardBackground.snp.makeConstraints { hideKeyboardBackground in
            hideKeyboardBackground.leading.top.trailing.equalToSuperview()
        }

        mainCardHeader.snp.makeConstraints { mainCardHeader in
            mainCardHeader.top.equalToSuperview().offset(174.5)
            mainCardHeader.leading.equalToSuperview().offset(14)
        }

        additionalCardHeader.snp.makeConstraints { additionalCardHeader in
            additionalCardHeader.leading.equalTo(mainCardHeader.snp.leading)
            additionalCardHeader.lastBaseline.equalTo(mainCardHeader.snp.lastBaseline)
        }

        cardPaging.snp.makeConstraints { cardPaging in
            cardPaging.bottom.equalTo(mainCardHeader.snp.bottom)
            cardPaging.trailing.equalToSuperview().offset(-14)
        }

        cardsHolder.snp.makeConstraints { cardsHolder in
            cardsHolder.top.equalTo(mainCardHeader.snp.bottom).offset(20)
            cardsHolder.leading.equalToSuperview().offset(14)
            cardsHolder.trailing.equalToSuperview()
            cardsHolder.height.equalTo(156)
            cardsHolder.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints { stackView in
            stackView.top.equalTo(hideKeyboardBackground.snp.bottom).offset(14)
            stackView.leading.equalToSuperview().offset(14)
            stackView.width.equalTo(280)
            stackView.bottom.equalToSuperview().offset(-14)
        }

        stackView.addArrangedSubview(addCardRow)
//        stackView.addArrangedSubview(cardDetailsRow)

        mainCardHeader.text = "Основная\nкарта"
        mainCardHeader.look.apply(Style.operationsManageHeader)

        additionalCardHeader.text = "Дополнительная\nкарта"
        additionalCardHeader.look.apply(Style.operationsManageHeader)
        additionalCardHeader.alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class OperationsManageCardItem: UIView {

    let logo = UIImageView()
    let greenCard = UILabel()
    let ownerName = UILabel()
    let ownerStatus = UILabel()
    let ownerPhone = UITextField()
    let cardNumber = UITextField()

    let phoneMasked = PolyMaskTextFieldDelegate()
    let cardNumberMasked = PolyMaskTextFieldDelegate()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(logo)
        addSubview(greenCard)
        addSubview(ownerName)
        addSubview(ownerStatus)
        addSubview(ownerPhone)
        addSubview(cardNumber)

        self.snp.makeConstraints { selfSize in
            selfSize.width.equalTo(280)
            selfSize.height.equalTo(156)
        }

        logo.snp.makeConstraints { logo in
            logo.leading.equalToSuperview().offset(17)
            logo.top.equalToSuperview().offset(15)
            logo.width.height.equalTo(37)
        }

        greenCard.snp.makeConstraints { greenCard in
            greenCard.trailing.equalToSuperview().offset(-16)
            greenCard.top.equalToSuperview().offset(14)
        }

        ownerName.snp.makeConstraints { ownerName in
            ownerName.leading.equalToSuperview().offset(16)
            ownerName.trailing.equalToSuperview().offset(-16)
        }

        ownerStatus.snp.makeConstraints { ownerStatus in
            ownerStatus.top.equalTo(ownerName.snp.bottom)
            ownerStatus.leading.equalToSuperview().offset(16)
        }

        ownerPhone.snp.makeConstraints { ownerPhone in
            ownerPhone.top.equalTo(ownerStatus.snp.bottom).offset(10)
            ownerPhone.leading.equalToSuperview().offset(16)
            ownerPhone.bottom.equalToSuperview().offset(-21)
        }

        cardNumber.snp.makeConstraints { cardNumber in
            cardNumber.trailing.equalToSuperview().offset(-16)
            cardNumber.bottom.equalToSuperview().offset(-21)
        }

        phoneMasked.affineFormats = ["+{7} [000] [000] [00] [00]"]
        cardNumberMasked.affineFormats = ["[0000] [0000] [0000] [0000]"]

        ownerPhone.delegate = phoneMasked
        cardNumber.delegate = cardNumberMasked
        ownerPhone.isUserInteractionEnabled = false
        cardNumber.isUserInteractionEnabled = false

        greenCard.isShown = false

        look.apply(Style.operationsManageCardItemCommon)
        look.apply(Style.operationsManageCardItemGreen)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(ownerName: String?, ownerStatus: String?, ownerPhone: String?, cardNumber: Int64?, isMain: Bool?) -> Self {
        self.ownerName.text = ownerName ?? ""
        self.ownerStatus.text = (ownerStatus ?? "").lowercased()
        phoneMasked.put(text: ownerPhone ?? "", into: self.ownerPhone)
        cardNumberMasked.put(text: String(cardNumber ?? 0), into: self.cardNumber)

        if let isMain = isMain {
            look.apply(isMain ? Style.operationsManageCardItemGreen : Style.operationsManageCardItemWhite)
        }

        return self
    }

}


class OperationsManageAddCardRow: UIView {

    let border = OperationsManageBorderView()
    let plusIcon = UIImageView()
    let addCardText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(border)
        addSubview(plusIcon)
        addSubview(addCardText)

        self.snp.makeConstraints { selfSize in
            selfSize.height.equalTo(155)
        }

        border.snp.makeConstraints { border in
            border.edges.equalToSuperview()
        }

        plusIcon.snp.makeConstraints { plusIcon in
            plusIcon.width.equalTo(15)
            plusIcon.height.equalTo(15)
            plusIcon.top.equalToSuperview().offset(18)
            plusIcon.leading.equalToSuperview().offset(18)
        }

        addCardText.snp.makeConstraints { addCardText in
            addCardText.leading.equalToSuperview().offset(18)
            addCardText.bottom.equalToSuperview().offset(-18)
        }

        look.apply(Style.operationsManageAddCardRow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class OperationsManageCardDetailsRow: UIView {

    let border = OperationsManageBorderView()
    let stackView = UIStackView()

    // -- Card number

    lazy var cardNumberWrapper = OperationsManageTextWrapper()
    lazy var cardNumberPlaceholder = UILabel()
    lazy var cardNumberField = UITextField()
    lazy var cardNumberWarn = UILabel()

    // -- Card code

    lazy var cardCodeWrapper = OperationsManageTextWrapper()
    lazy var cardCodePlaceholder = UILabel()
    lazy var cardCodeField = UITextField()
    lazy var cardCodeWarn = UILabel()

    // -- Card owner

    lazy var cardOwnerWrapper = OperationsManageTextWrapper()
    lazy var cardOwnerPlaceholder = UILabel()
    lazy var cardOwnerField = UITextField()

    // -- Phone number

    lazy var phoneNumberWrapper = OperationsManageTextWrapper()
    lazy var phoneNumberPlaceholder = UILabel()
    lazy var phoneNumberField = UITextField()

    // -- Send code

    lazy var sendCodeContainer = UIView()
    lazy var sendCodeIcon = UIImageView()
    lazy var sendCodeLabel = UILabel()

    // -- Code input

    lazy var codeInputWrapper = OperationsManageTextWrapper()
    lazy var codeInputPlaceholder = UILabel()
    lazy var codeInputField = UITextField()
    lazy var codeInputWarn = UILabel()

    // -- Buttons

    lazy var addButton = UILabel()
    lazy var cancelButton = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .vertical
        stackView.spacing = 5

        addSubview(border)
        addSubview(stackView)
        addSubview(sendCodeContainer)

        sendCodeContainer.addSubview(sendCodeIcon)
        sendCodeContainer.addSubview(sendCodeLabel)

        border.snp.makeConstraints { border in
            border.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { stackView in
            stackView.leading.equalToSuperview().offset(18)
            stackView.trailing.equalToSuperview().offset(-18)
            stackView.top.equalToSuperview().offset(18)
        }

        _ = cardNumberWrapper
                .add(text: cardNumberField)
                .add(placeholder: cardNumberPlaceholder)

        stackView.addArrangedSubview(cardNumberWrapper)
        stackView.addArrangedSubview(cardNumberWarn)

        _ = cardCodeWrapper
                .setWidthDivider(value: 3.0)
                .add(text: cardCodeField)
                .add(placeholder: cardCodePlaceholder)

        stackView.addArrangedSubview(cardCodeWrapper)
        stackView.addArrangedSubview(cardCodeWarn)

        _ = cardOwnerWrapper
                .add(text: cardOwnerField)
                .add(placeholder: cardOwnerPlaceholder)

        stackView.addArrangedSubview(cardOwnerWrapper)

        _ = phoneNumberWrapper
                .add(text: phoneNumberField)
                .add(placeholder: phoneNumberPlaceholder)

        stackView.addArrangedSubview(phoneNumberWrapper)

        sendCodeContainer.snp.makeConstraints { sendCodeContainer in
            sendCodeContainer.leading.equalTo(stackView.snp.leading)
            sendCodeContainer.top.equalTo(stackView.snp.bottom).offset(30)
        }

        sendCodeIcon.snp.makeConstraints { sendCodeIcon in
            sendCodeIcon.leading.equalToSuperview()
            sendCodeIcon.centerY.equalTo(sendCodeLabel.snp.centerY).offset(-2)
            sendCodeIcon.width.equalTo(12)
            sendCodeIcon.height.equalTo(8)
        }

        sendCodeLabel.snp.makeConstraints { sendCodeLabel in
            sendCodeLabel.leading.equalTo(sendCodeIcon.snp.trailing).offset(10)
            sendCodeLabel.trailing.equalToSuperview().offset(-20)
            sendCodeLabel.top.equalToSuperview().offset(10)
            sendCodeLabel.bottom.equalToSuperview().offset(-10)
        }

        _ = codeInputWrapper
                .add(text: codeInputField)
                .add(placeholder: codeInputPlaceholder)

        addSubview(codeInputWrapper)
        addSubview(codeInputWarn)

        codeInputWrapper.snp.makeConstraints { codeInputWrapper in
            codeInputWrapper.leading.equalTo(stackView.snp.leading)
            codeInputWrapper.trailing.equalTo(stackView.snp.trailing)
            codeInputWrapper.top.equalTo(sendCodeContainer.snp.bottom).offset(0)
        }

        codeInputWarn.snp.makeConstraints { codeInputWarn in
            codeInputWarn.leading.equalTo(stackView.snp.leading)
            codeInputWarn.top.equalTo(codeInputWrapper.snp.bottom)
        }

        addSubview(addButton)
        addSubview(cancelButton)

        addButton.snp.makeConstraints { addButton in
            addButton.leading.equalTo(stackView.snp.leading)
            addButton.top.equalTo(codeInputWrapper.snp.bottom).offset(30)
            addButton.bottom.equalToSuperview().offset(-20)
        }

        cancelButton.snp.makeConstraints { cancelButton in
            cancelButton.trailing.equalTo(stackView.snp.trailing)
            cancelButton.lastBaseline.equalTo(addButton.snp.lastBaseline)
        }

        look.apply(Style.operationsManageCardDetailsRow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class OperationsManageBorderView: UIView {

    let dashedBorder = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.dashedBorder.strokeColor = UIColor.white.cgColor
        self.dashedBorder.lineWidth = 1
        self.dashedBorder.lineDashPattern = [3, 4]
        self.dashedBorder.fillColor = nil

//        self.transform = CGAffineTransform(rotationAngle: .pi)

        self.layer.addSublayer(dashedBorder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        dashedBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
        dashedBorder.frame = self.bounds
    }

}

class OperationsManageTextWrapper: UIView {

    let underline = UIView()
    var text: UIView?
    let textFieldBlocker = UIView()
    var widthDivider: Float = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setWidthDivider(value: Float) -> OperationsManageTextWrapper {
        self.widthDivider = value
        return self
    }

    func add(text: UIView, topPad: Int = 20, bottomPad: Int = 14) -> OperationsManageTextWrapper {
        self.text = text

        let scrollView = UIScrollView()
        addSubview(scrollView)

        scrollView.addSubview(text)
        addSubview(underline)

        scrollView.snp.makeConstraints { scrollView in
            scrollView.leading.equalToSuperview()
            scrollView.width.equalToSuperview().dividedBy(widthDivider)
            scrollView.top.equalToSuperview().offset(topPad)
            scrollView.bottom.equalToSuperview().offset(-1 * bottomPad)
        }

        underline.snp.makeConstraints { underline in
            underline.leading.equalToSuperview()
            underline.width.equalToSuperview().dividedBy(widthDivider)
            underline.top.equalTo(text.snp.bottom).offset(12)
            underline.height.equalTo(1)
        }

        text.snp.makeConstraints { text in
            text.edges.equalToSuperview()
            text.width.height.equalToSuperview()
        }

        addSubview(textFieldBlocker)
        textFieldBlocker.snp.makeConstraints { textFieldBlocker in
            textFieldBlocker.leading.top.bottom.equalToSuperview()
            textFieldBlocker.width.equalToSuperview().dividedBy(widthDivider)
        }
        textFieldBlocker.backgroundColor = .clear

        underline.backgroundColor = Palette.LoginView.placeholder.color

//        backgroundColor = .blue

        return self
    }

    func add(placeholder: UILabel) -> OperationsManageTextWrapper {
        guard let text = self.text else {
            return self
        }
        insertSubview(placeholder, at: 0)

        placeholder.snp.makeConstraints { placeholder in
            placeholder.leading.equalToSuperview()
            placeholder.centerY.equalTo(text.snp.centerY)
        }

        return self
    }

}


fileprivate extension Style {

    static var operationsManageHeader: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Semibold", size: 14)
            label.textColor = Palette.OperationsManageView.tableHeader.color
            label.numberOfLines = 2
        }
    }

    static var operationsManageCardItemCommon: Change<OperationsManageCardItem> {
        return { (view: OperationsManageCardItem) in
            view.layer.cornerRadius = 5

            view.greenCard.text = "GREEN\nCARD"
            view.greenCard.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.greenCard.textColor = Palette.OperationsManageView.cardWhiteText.color
            view.greenCard.numberOfLines = 2
            view.greenCard.textAlignment = .right

            view.ownerName.text = "Константин"
            view.ownerName.font = UIFont(name: "ProximaNova-Bold", size: 14)

            view.ownerStatus.text = "участник"
            view.ownerStatus.font = UIFont(name: "ProximaNova-Regular", size: 10)

            view.ownerPhone.text = "+7 905 555 55 55"
            view.ownerPhone.font = UIFont(name: "ProximaNova-Bold", size: 10)

            view.cardNumber.text = "1234 5678 9012 3456"
            view.cardNumber.font = UIFont(name: "ProximaNova-Bold", size: 14)
        }
    }

    static var operationsManageCardItemGreen: Change<OperationsManageCardItem> {
        return { (view: OperationsManageCardItem) in
            view.backgroundColor = Palette.OperationsManageView.cardGreenBackground.color
            view.logo.image = UIImage(named: "logo_37_white")
            view.ownerName.textColor = Palette.OperationsManageView.cardWhiteText.color
            view.ownerStatus.textColor = Palette.OperationsManageView.cardWhiteText.color
            view.ownerPhone.textColor = Palette.OperationsManageView.cardWhiteText.color
            view.cardNumber.textColor = Palette.OperationsManageView.cardWhiteText.color
        }
    }

    static var operationsManageCardItemWhite: Change<OperationsManageCardItem> {
        return { (view: OperationsManageCardItem) in
            view.backgroundColor = Palette.OperationsManageView.cardWhiteBackground.color
            view.logo.image = UIImage(named: "logo_37_green")
            view.ownerName.textColor = Palette.OperationsManageView.cardGrayText.color
            view.ownerStatus.textColor = Palette.OperationsManageView.cardGrayText.color
            view.ownerPhone.textColor = Palette.OperationsManageView.cardGrayText.color
            view.cardNumber.textColor = Palette.OperationsManageView.cardGrayText.color
        }
    }

    static var operationsManageAddCardRow: Change<OperationsManageAddCardRow> {
        return { (view: OperationsManageAddCardRow) in
            view.plusIcon.image = UIImage(named: "ic_plus")

            view.addCardText.font = UIFont(name: "ProximaNova-SemiBold", size: 14)
            view.addCardText.text = "Добавление\nкарты"
            view.addCardText.numberOfLines = 2
            view.addCardText.textColor = Palette.OperationsManageView.addCard.color
        }
    }

    static var operationsManageCardDetailsRow: Change<OperationsManageCardDetailsRow> {
        return { (view: OperationsManageCardDetailsRow) in
            view.cardNumberPlaceholder.text = "Номер карты"
            view.cardNumberWarn.text = "Это поле не должно быть пустым"

            view.cardNumberField.look.apply(Style.textField)
            view.cardNumberPlaceholder.look.apply(Style.placeholder)
            view.cardNumberWarn.look.apply(Style.warn)
            view.cardNumberWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color

            view.cardNumberField.keyboardType = .numberPad
            view.cardNumberField.returnKeyType = .next

            view.cardCodePlaceholder.text = "Код карты"
            view.cardCodeWarn.text = "Это поле не должно быть пустым"

            view.cardCodeField.look.apply(Style.textField)
            view.cardCodePlaceholder.look.apply(Style.placeholder)
            view.cardCodeWarn.look.apply(Style.warn)
            view.cardCodeWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color

            view.cardCodeField.keyboardType = .numberPad
            view.cardCodeField.returnKeyType = .go

            view.cardOwnerPlaceholder.text = "Держатель карты"

            view.cardOwnerField.look.apply(Style.textField)
            view.cardOwnerPlaceholder.look.apply(Style.placeholder)
            view.cardOwnerWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color

            view.phoneNumberPlaceholder.text = "Номер телефона"

            view.phoneNumberField.look.apply(Style.textField)
            view.phoneNumberPlaceholder.look.apply(Style.placeholder)
            view.phoneNumberWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color

            view.sendCodeIcon.image = UIImage(named: "ic_send_code")

            view.sendCodeLabel.font = UIFont(name: "DINPro-Bold", size: 10)
            view.sendCodeLabel.textColor = Palette.OperationsManageView.sendCode.color
            view.sendCodeLabel.text = "ОТПРАВИТЬ ПРОВЕРОЧНЫЙ КОД"

            view.codeInputPlaceholder.text = "Проверочный код"
            view.codeInputWarn.text = "Это поле не должно быть пустым"

            view.codeInputField.look.apply(Style.textField)
            view.codeInputPlaceholder.look.apply(Style.placeholder)
            view.codeInputWarn.look.apply(Style.warn)
            view.codeInputWrapper.underline.backgroundColor = Palette.OperationsManageView.placeholder.color

            view.codeInputField.keyboardType = .default
            view.codeInputField.returnKeyType = .done
            view.codeInputField.autocorrectionType = .no

            view.addButton.font = UIFont(name: "ProximaNova-Bold", size: 9)
            view.addButton.textColor = Palette.OperationsManageView.addButton.color
            view.addButton.text = "ДОБАВИТЬ"

            view.cancelButton.font = UIFont(name: "ProximaNova-Bold", size: 9)
            view.cancelButton.textColor = Palette.OperationsManageView.cancelButton.color
            view.cancelButton.text = "ОТМЕНИТЬ"
        }
    }

    static var textField: Change<UITextField> {
        return { (field: UITextField) in
            field.font = UIFont(name: "ProximaNova-Regular", size: 10)
            field.textColor = Palette.OperationsManageView.textField.color
        }
    }

    static var placeholder: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Regular", size: 10)
            label.textColor = Palette.OperationsManageView.placeholder.color
        }
    }

    static var warn: Change<UILabel> {
        return { (label: UILabel) in
            label.font = UIFont(name: "ProximaNova-Regular", size: 10)
            label.textColor = Palette.OperationsManageView.warn.color
        }
    }

}

class OperationsManagePagingWidget: UIView {

    var totalCount: Int = 0
    var currentPage: Int = 0

    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        stackView.axis = .horizontal
        stackView.spacing = 15

        addSubview(stackView)

        self.snp.makeConstraints { selfSize in
            selfSize.height.equalTo(10)
        }

        stackView.snp.makeConstraints { stackView in
            stackView.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setTotalCount(value: Int) {
        totalCount = value
        for view in stackView.subviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for i in 0..<value {
            let dot = Dot()
            stackView.addArrangedSubview(dot)
            dot.snp.makeConstraints { dot in
                dot.width.height.equalTo(10)
            }
        }
    }

    public func setCurrent(value: Int) {
        guard value < totalCount else {
            return
        }

        (self.stackView.subviews[self.currentPage] as? Dot)?.setActive(isActive: false)
        self.currentPage = value
        (self.stackView.subviews[self.currentPage] as? Dot)?.setActive(isActive: true)
    }


}

extension OperationsManagePagingWidget {

    class Dot: UIView {

        let active = UIView()
        let notActive = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)

            active.backgroundColor = Palette.OperationsManageView.greenDot.color
            active.layer.cornerRadius = 5
            notActive.backgroundColor = Palette.OperationsManageView.grayDot.color
            notActive.layer.cornerRadius = 5

            addSubview(active)
            addSubview(notActive)

            active.snp.makeConstraints { active in
                active.edges.equalToSuperview()
            }

            notActive.snp.makeConstraints { notActive in
                notActive.edges.equalToSuperview()
            }

            active.alpha = 0
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setActive(isActive: Bool) {
            UIView.animate(withDuration: 0.4, animations: { [unowned self] in
                self.active.alpha = isActive ? 1 : 0
                self.notActive.alpha = isActive ? 0 : 1
            })
        }

    }

}
