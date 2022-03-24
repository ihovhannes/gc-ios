import UIKit

enum Palette {

    enum Window: Colorable {
        case tint

        var color: UIColor {
            switch self {
            case .tint:
                return Colors.green.color
            }
        }
    }

    enum Common: Colorable {
        case whiteText
        case greenText
        case blackText
        case transparentBackground

        var color: UIColor {
            switch self {
            case .whiteText:
                return Colors.white.color
            case .greenText:
                return Colors.green.color
            case .blackText:
                return Colors.blackWithAlpha50.color
            case .transparentBackground:
                return Colors.transparent.color
            }
        }
    }

    enum LoadingIndicator: Colorable {
        case background

        var color: UIColor {
            switch self {
            case .background:
                return Colors.loadingTintBlack.color
            }
        }
    }

    enum SplashView: Colorable {
        case background
        case text
        case highlight
        case semiTransparent

        var color: UIColor {
            switch self {
            case .background:
                return Colors.green.color
            case .text:
                return Colors.white.color
            case .highlight:
                return Colors.yellow.color
            case .semiTransparent:
                return Colors.semiTransparentWhite.color
            }
        }
    }

    enum CheckerWidget: Colorable {
        case background
        case circleOn
        case circleOff
        case label

        var color: UIColor {
            switch self {
            case .background:
                return Colors.darkGray.color
            case .circleOn:
                return Colors.green.color
            case .circleOff:
                return Colors.carminePink.color
            case .label:
                return Colors.taupeGray.color
            }
        }
    }

    enum LoginView: Colorable {
        case background
        case text
        case highlight
        case placeholder
        case warn

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .text:
                return Colors.white.color
            case .highlight:
                return Colors.green.color
            case .placeholder:
                return Colors.almostTransparentWhite.color
            case .warn:
                return Colors.red.color
            }
        }
    }

    enum AccountView: Colorable {
        case background
        case title
        case text
        case textBackground

        var color: UIColor {
            switch self {
            case .background:
                return Colors.transparent.color
            case .title:
                return Colors.darkGreen.color
            case .text:
                return Colors.white.color
            case .textBackground:
                return Colors.transparent.color
            }
        }
    }

    enum AlertView: Colorable {
        case background
        case container
        case button

        var color: UIColor {
            switch self {
            case .background:
                return Colors.loadingTintBlack.color
            case .container:
                return Colors.white.color
            case .button:
                return Colors.green.color
            }
        }

    }

    enum ToastView: Colorable {
        case background
        case text

        var color: UIColor {
            switch self {
            case .background:
//                return Colors.grayWithAlpha.color
                return Colors.dimGray.color
            case .text:
                return Colors.white.color
            }
        }
    }

    enum MainView: Colorable {
        case background
        case collectionBackground

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .collectionBackground:
                return Colors.transparent.color
            }
        }
    }

    enum MainTableHeaderView: Colorable {
        case title
        case text

        var color: UIColor {
            switch self {
            case .title:
                return Colors.darkGreen.color
            case .text:
                return Colors.white.color
            }
        }
    }

    enum SharesView: Colorable {
        case background
        case collectionBackground

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .collectionBackground:
                return Colors.transparent.color
            }
        }
    }

    enum SharesTableHeaderView: Colorable {
        case title
        case text
        case filter

        var color: UIColor {
            switch self {
            case .title:
                return Colors.darkGreen.color
            case .text:
                return Colors.white.color
            case .filter:
                return Colors.white.color
            }
        }
    }

    enum ShareDetailView: Colorable {
        case underImageBlack
        case dateExpire
        case shareName
        case more

        var color: UIColor {
            switch self {
            case .underImageBlack:
                return Colors.blackWithAlpha27.color
            case .dateExpire:
                return Colors.white.color
            case .shareName:
                return Colors.white.color
            case .more:
                return Colors.white.color
            }
        }
    }

    enum ArchiveSharesView: Colorable {
        case background
        case collectionBackground

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .collectionBackground:
                return Colors.transparent.color
            }
        }
    }

    enum OfferCollectionViewCell: Colorable {
        case cellBackground
        case containerBackground
        case expiryDateText
        case timeLeftText
        case markBackground

        var color: UIColor {
            switch self {
            case .cellBackground:
                return Colors.transparent.color
            case .containerBackground:
                return Colors.white.color
            case .expiryDateText:
                return Colors.gray.color
            case .timeLeftText:
                return Colors.green.color
            case .markBackground:
                return Colors.yellow.color
            }
        }
    }

    enum PartnersView: Colorable {
        case background
        case tableBackground
        case tableSeparator

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .tableBackground:
                return Colors.transparent.color
            case .tableSeparator:
                return Colors.whiteWithAlpha34.color
            }
        }
    }

    enum PartnersTableViewCell: Colorable {
        case cellBackground
        case containerBackground
        case partnerName

        var color: UIColor {
            switch self {
            case .cellBackground:
                return Colors.transparent.color
            case .containerBackground:
                return Colors.transparent.color
            case .partnerName:
                return Colors.white.color
            }
        }
    }

    enum PartnerDetailView: Colorable {
        case background
        case nonSelectedTab
        case selectedTab
        case headerView
        case shares
        case sharesBorder
        case location

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .nonSelectedTab:
                return Colors.whiteWitAlpha60.color
            case .selectedTab:
                return Colors.white.color
            case .headerView:
                return Colors.transparent.color
            case .shares:
                return Colors.white.color
            case .sharesBorder:
                return Colors.whiteWithAlpha34.color
            case .location:
                return Colors.white.color
            }
        }
    }

    enum PartnerDetailTabView: Colorable {
        case text
        case textBackground
        case link

        var color: UIColor {
            switch self {
            case .text:
                return Colors.white.color
            case .textBackground:
                return Colors.transparent.color
            case .link:
                return Colors.greenAccent.color
            }
        }
    }

    enum PartnerDetailBonusesView: Colorable {
        case title
        case text
        case line
        case videoBackground

        var color: UIColor {
            switch self {
            case .title:
                return Colors.whiteWitAlpha60.color
            case .text:
                return Colors.white.color
            case .line:
                return Colors.white.color
            case .videoBackground:
                return Colors.transparent.color
            }
        }
    }


    enum PartnerSharesView: Colorable {
        case tableBackground
        case countValue
        case sharesText

        var color: UIColor {
            switch self {
            case .tableBackground:
                return Colors.transparent.color
            case .countValue:
                return Colors.white.color
            case .sharesText:
                return Colors.whiteWitAlpha60.color
            }
        }
    }

    enum PartnerLocationsView: Colorable {
        case countText
        case background
        case contactInfoText
        case vendorName
        case addressField

        var color: UIColor {
            switch self {
            case .countText:
                return Colors.blackOpacity.color
            case .background:
                return Colors.eerieBlack.color
            case .contactInfoText:
                return Colors.white.color
            case .vendorName:
                return Colors.white.color
            case .addressField:
                return Colors.white.color
            }
        }
    }

    enum BalanceView: Colorable {
        case background
        case tableBackground
        case cellBackground
        case containerBackground
        case columnsBackground
        case topTitle
        case bottomText
        case line
        case time
        case bonusesPlus
        case bonusesMinus

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .tableBackground:
                return Colors.transparent.color
            case .cellBackground:
                return Colors.transparent.color
            case .containerBackground:
                return Colors.transparent.color
            case .columnsBackground:
                return Colors.white.color
            case .topTitle:
                return Colors.blackWithAlpha50.color
            case .bottomText:
                return Colors.blackOpacity.color
            case .line:
                return Colors.blackWithAlpha27.color
            case .time:
                return Colors.whiteWitAlpha60.color
            case .bonusesPlus:
                return Colors.green.color
            case .bonusesMinus:
                return Colors.red.color
            }
        }
    }

    enum OperationDetailView: Colorable {
        case background
        case title

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .title:
                return Colors.white.color
            }
        }

    }

    enum OperationDetailHeaderWidget: Colorable {
        case title
        case text

        var color: UIColor {
            switch self {
            case .title:
                return Colors.darkGreen.color
            case .text:
                return Colors.white.color
            }
        }
    }

    enum OperationDetailTableWidget: Colorable {
        case title
        case background
        case headerLabel
        case line
        case itemLabel
        case footerLabel
        case footerBackground
        case footerLine

        var color: UIColor {
            switch self {
            case .title:
                return Colors.white.color
            case .background:
                return Colors.white.color
            case .headerLabel:
                return Colors.blackWithAlpha50.color
            case .line:
                return Colors.blackWithAlpha27.color
            case .itemLabel:
                return Colors.blackOpacity.color
            case .footerLabel:
                return Colors.white.color
            case .footerBackground:
                return Colors.green.color
            case .footerLine:
                return Colors.white.color
            }
        }
    }

    enum NotificationsView: Colorable {
        case background
        case title
        case text
        case buttonText
        case buttonBorder

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .title:
                return Colors.white.color
            case .text:
                return Colors.white.color
            case .buttonText:
                return Colors.white.color
            case .buttonBorder:
                return Colors.green.color
            }
        }
    }

    enum SettingsView: Colorable {
        case background

        case legendLabel
        case passwordWidgetBackground
        case passwordWidgetTitle

        case passwordWidgetTextField
        case passwordWidgetUnderline

        case passwordWidgetTextFieldInput
        case passwordWidgetUnderlineInput

        case passwordWidgetLabelWarn
        case passwordWidgetUnderlineWarn

        case passwordWidgetSaveButton
        case passwordWidgetCancelButton

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .legendLabel:
                return Colors.white.color
            case .passwordWidgetBackground:
                return Colors.darkGray.color
            case .passwordWidgetTitle:
                return Colors.white.color
            case .passwordWidgetUnderline:
                return Colors.almostTransparentWhite.color
            case .passwordWidgetTextFieldInput:
                return Colors.green.color
            case .passwordWidgetUnderlineInput:
                return Colors.green.color
            case .passwordWidgetTextField:
                return Colors.almostTransparentWhite.color
            case .passwordWidgetLabelWarn:
                return Colors.red.color
            case .passwordWidgetUnderlineWarn:
                return Colors.red.color
            case .passwordWidgetSaveButton:
                return Colors.green.color
            case .passwordWidgetCancelButton:
                return Colors.almostTransparentWhite.color
            }
        }
    }

    enum FaqView: Colorable {
        case background
        case faqText
        case collectionBackground
        case cellBackground
        case containerBackground
        case questionText

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .collectionBackground:
                return Colors.transparent.color
            case .faqText:
                return Colors.white.color
            case .cellBackground:
                return Colors.transparent.color
            case .containerBackground:
                return Colors.white.color
            case .questionText:
                return Colors.androidDefault.color
            }
        }
    }

    enum FaqDetailView: Colorable {
        case background
        case containerBackground
        case questionText
        case answerText
        case link

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .containerBackground:
                return Colors.white.color
            case .questionText:
                return Colors.androidDefault.color
            case .answerText:
                return Colors.androidDefault.color
            case .link:
                return Colors.greenAccent.color
            }
        }
    }

    enum OperationsView: Colorable {
        case title
        case background
        case tableRowTitle
        case tableRowBackground
        case currentNumberText
        case currentNumberValue
        case typePasswordText
        case typePasswordTextActive
        case typePasswordField
        case typePasswordLine
        case typePasswordLineActive
        case typePasswordWarn
        case blockButton

        var color: UIColor {
            switch self {
            case .title:
                return Colors.white.color
            case .background:
                return Colors.eerieBlack.color
            case .tableRowTitle:
                return Colors.white.color
            case .tableRowBackground:
                return Colors.darkGray.color
            case .currentNumberText:
                return Colors.whiteWitAlpha60.color
            case .currentNumberValue:
                return Colors.greenAccent.color
            case .typePasswordText:
                return Colors.whiteWitAlpha60.color
            case .typePasswordTextActive:
                return Colors.greenAccent.color
            case .typePasswordField:
                return Colors.whiteWitAlpha60.color
            case .typePasswordLine:
                return Colors.whiteWithAlpha34.color
            case .typePasswordLineActive:
                return Colors.greenAccent.color
            case .typePasswordWarn:
                return Colors.red.color
            case .blockButton:
                return Colors.greenAccent.color
            }
        }
    }

    enum OperationsManageView: Colorable {
        case background
        case tableHeader
        case addCard
        case textField
        case placeholder
        case warn
        case sendCode
        case addButton
        case cancelButton
        case cardGreenBackground
        case cardWhiteBackground
        case cardGreenText
        case cardWhiteText
        case cardGrayText
        case highlight
        case whitePlaceholder
        case greenDot
        case grayDot

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .tableHeader:
                return Colors.white.color
            case .addCard:
                return Colors.white.color
            case .textField:
                return Colors.white.color
            case .placeholder:
                return Colors.almostTransparentWhite.color
            case .warn:
                return Colors.red.color
            case .sendCode:
                return Colors.white.color
            case .addButton:
                return Colors.green.color
            case .cancelButton:
                return Colors.almostTransparentWhite.color
            case .cardGreenBackground, .cardGreenText:
                return Colors.green.color
            case .cardWhiteBackground, .cardWhiteText:
                return Colors.white.color
            case .cardGrayText:
                return Colors.dimGray.color
            case .highlight:
                return Colors.green.color
            case .whitePlaceholder:
                return Colors.white.color
            case .greenDot:
                return Colors.green.color
            case .grayDot:
                return Colors.grayAlpha30.color
            }
        }
    }

    enum FilterWidget: Colorable {
        case background
        case line
        case leftLabel
        case rightLabel


        var color: UIColor {
            switch self {
            case .background:
                return Colors.green.color
            case .line:
                return Colors.whiteWitAlpha60.color
            case .leftLabel:
                return Colors.white.color
            case .rightLabel:
                return Colors.whiteWitAlpha60.color
            }
        }
    }

    enum AboutView: Colorable {
        case background
        case container
        case logo
        case description
        case line
        case version

        var color: UIColor {
            switch self {
            case .background:
                return Colors.eerieBlack.color
            case .container:
                return Colors.white.color
            case .logo:
                return Colors.green.color
            case .description:
                return Colors.androidDefault.color
            case .line:
                return Colors.blackWithAlpha27.color
            case .version:
                return Colors.androidDefault.color
            }
        }
    }
}

private enum Colors: Colorable {

    case green
    case greenAccent
    case yellow
    case white
    case whiteWithAlpha34
    case whiteWitAlpha60
    case semiTransparentWhite
    case blackWithAlpha50
    case blackWithAlpha27
    case blackOpacity
    case eerieBlack
    case almostTransparentWhite
    case loadingTintBlack
    case darkGreen
    case transparent
    case gray
    case grayAlpha30
    case red
    case darkGray
    case taupeGray
    case carminePink
    case grayWithAlpha
    case dimGray
    case androidDefault

    var color: UIColor {
        switch self {
        case .green:
            return #colorLiteral(red: 0.2117647059, green: 0.7215686275, blue: 0, alpha: 1)
        case .greenAccent:
            return #colorLiteral(red:0.36, green:0.7230222821, blue:0, alpha:1)
        case .yellow:
            return #colorLiteral(red:0.968627451, green:0.831372549, blue:0.07450980392, alpha:1)
        case .white:
            return #colorLiteral(red:1, green:1, blue:1, alpha:1)
        case .whiteWithAlpha34:
            return #colorLiteral(red:1, green:1, blue:1, alpha:0.34)
        case .whiteWitAlpha60:
            return #colorLiteral(red:1, green:1, blue:1, alpha:0.60)
        case .semiTransparentWhite:
            return #colorLiteral(red:1, green:1, blue:1, alpha:0.4518595951)
        case .blackWithAlpha50:
            return #colorLiteral(red:0.1058823529, green:0.1058823529, blue:0.1058823529, alpha:0.4518595951)
        case .blackWithAlpha27:
            return #colorLiteral(red:0.0, green:0.0, blue:0.0, alpha:0.27)
        case .blackOpacity:
            return #colorLiteral(red:0.0, green:0.0, blue:0.0, alpha:1.0)
        case .eerieBlack:
            return #colorLiteral(red:27.0 / 255.0, green:27.0 / 255.0, blue:27.0 / 255.0, alpha:1.0)
        case .almostTransparentWhite:
            return #colorLiteral(red:1, green:1, blue:1, alpha:0.3466384243)
        case .loadingTintBlack:
            return #colorLiteral(red:0, green:0, blue:0, alpha:0.5)
        case .darkGreen:
            return #colorLiteral(red:94.0 / 255.0, green:169.0 / 255.0, blue:72.0 / 255.0, alpha:1.0)
        case .transparent:
            return #colorLiteral(red:0, green:0, blue:0, alpha:0)
        case .gray:
            return #colorLiteral(red:0.7764705882, green:0.7764705882, blue:0.7764705882, alpha:1)
        case .grayAlpha30:
            return #colorLiteral(red:184.0 / 255, green:184.0 / 255, blue:184.0 / 255, alpha:0.3)
        case .red:
            return #colorLiteral(red:247.0 / 255, green:58.0 / 255, blue:58.0 / 255, alpha:1)
        case .darkGray:
            return #colorLiteral(red:47.0 / 255.0, green:47.0 / 255.0, blue:47.0 / 255.0, alpha:1)
        case .taupeGray:
            return #colorLiteral(red:145.0 / 255.0, green:145.0 / 255.0, blue:145.0 / 255.0, alpha:1)
        case .carminePink:
            return #colorLiteral(red:234.0 / 255.0, green:84.0 / 255.0, blue:84.0 / 255.0, alpha:1)
        case .grayWithAlpha:
            return #colorLiteral(red:0.4756349325, green:0.4756467342, blue:0.4756404161, alpha:0.6138873922)
        case .dimGray:
            return #colorLiteral(red:98.0 / 255.0, green:98.0 / 255.0, blue:98.0 / 255.0, alpha:1)
        case .androidDefault:
            return #colorLiteral(red:128.0 / 255.0, green:128.0 / 255.0, blue:128.0 / 255.0, alpha:1)
        }
    }
}
