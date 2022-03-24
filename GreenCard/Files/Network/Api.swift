//
//  Api.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 26.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Moya

enum Api {
    case checkCard(number: String, code: String)
    case userRegistration(cardNumber: String, cardCode: String, firstName: String, gender: String, birthDate: String, phone: String, email: String, agreement: Bool)
    case oferta
    case userActivate
    case login(phone: String, password: String)
    case offerList(page: Int)
    case share(id: Int64)
    case sharesArchive(page: Int?)
    case sharesArchiveDetail(id: Int64)
    case partners(page: Int?)
    case partnerDetails(id: Int64)
    case partnerShares(partnerId: Int64, page: Int?)
    case partnerVendors(partnerId: Int64, page: Int?)
    case operations(page: Int?)
    case operationDetails(id: String)
    case user
    case faqList
    case updateUserSubscribed(push: Bool, sms: Bool, email: Bool)
    case changePassword(password: String)
    case cardsList
    case cardChangeState(cardId: Int64, password: String)
    case cardGetUserInfo(cardNumber: String, cardCode: String)
    case cardSmsToAppend(userId: String)
    case cardAppendNew(userId: String, smsCode: String)

    case restorePasswordPhone(phone: String)
    case restorePasswordSms(phone: String, sms: String)
    case restorePasswordChange(phone: String, sms: String, password: String)
}

extension Api: TargetType {

    private static var apiVersion = 1.0 // For local saves in realm
    private static var pageSize: Int = 30

    var baseURL: URL {
        return Config.sharedInstance.apiUrl()
    }

    var path: String {
        switch self {
        case .checkCard:
            return "/cards/validate/"
        case .userRegistration:
            return "/user/registration/"
        case .oferta:
            return "/help/pages/oferta/"
        case .userActivate:
            return "/user/activate/"
        case .login:
            return "/user/auth/"
        case .offerList:
            return "/shares/"
        case .share(let id):
            return "/shares/\(id)/"
        case .sharesArchive:
            return "/shares/archive/"
        case .sharesArchiveDetail(let id):
            return "/shares/archive/\(id)/"
        case .partners:
            return "/partners/"
        case .partnerDetails(let id):
            return "/partners/\(id)/"
        case .partnerVendors:
            return "/vendors/"
        case .partnerShares:
            return "/shares/"
        case .operations:
            return "operations/"
        case .operationDetails(let id):
            return "/operations/\(id)/"
        case .user:
            return "/user/"
        case .faqList:
            return "/faq/"
        case .updateUserSubscribed:
            return "/user/"
        case .changePassword:
            return "/user/change_password/"
        case .cardsList:
            return "/cards/"
        case .cardChangeState(let cardId, _):
            return "cards/\(cardId)/change_state/"
        case .cardGetUserInfo:
            return "/user/search_by_card_number/"
        case .cardSmsToAppend:
            return "/cards/"
        case .cardAppendNew:
            return "/cards/verify_attached_card/"

        case .restorePasswordPhone:
            return "/user/restore_password/"
        case .restorePasswordSms:
            return "/user/validate_sms_code/"
        case .restorePasswordChange:
            return "/user/set_new_password/"
        }
    }

    var method: Method {
        switch self {
        case .checkCard, .restorePasswordPhone, .restorePasswordSms, .restorePasswordChange, .userRegistration, .userActivate, .login, .updateUserSubscribed, .changePassword, .cardChangeState, .cardGetUserInfo, .cardSmsToAppend, .cardAppendNew:
            return Method.post
        case .oferta, .offerList, .user, .faqList, .partners, .partnerDetails, .partnerShares, .partnerVendors, .operations, .operationDetails, .share, .sharesArchive, .sharesArchiveDetail, .cardsList:
            return Method.get
        }
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding()
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .checkCard(let number, let code):
            return Task.requestParameters(parameters: ["card_num": number, "card_code": code], encoding: URLEncoding())
        case .userRegistration(let cardNumber, let cardCode, let firstName, let gender, let birthDate, let phone, let email, let agreement):
            return Task.requestParameters(parameters: [
                "card_num": cardNumber,
                "card_code": cardCode,
                "first_name": firstName,
                "gender": gender,
                "birth_date": birthDate,
                "phone": phone,
                "email": email,
                "agreement": agreement
            ], encoding: URLEncoding())
        case .offerList(let page):
            return Task.requestParameters(parameters: ["page": page, "page_size": Api.pageSize], encoding: URLEncoding())
        case .login(let phone, let password):
            return Task.requestParameters(parameters: ["username": phone, "password": password], encoding: URLEncoding())
        case .partners(let page):
            if let page = page {
                return Task.requestParameters(parameters: ["page": page, "page_size": Api.pageSize], encoding: URLEncoding())
            } else {
                return Task.requestPlain
            }
        case .sharesArchive(let page):
            if let page = page {
                return Task.requestParameters(parameters: ["page": page, "page_size": Api.pageSize], encoding: URLEncoding())
            } else {
                return Task.requestPlain
            }
        case .partnerShares(let partnerId, let page):
            if let page = page {
                return Task.requestParameters(parameters: ["partner_id": partnerId, "page": page, "page_size": Api.pageSize], encoding: URLEncoding())
            } else {
                return Task.requestParameters(parameters: ["partner_id": partnerId], encoding: URLEncoding())
            }
        case .partnerVendors(let partnerId, let page):
            if let page = page {
                return Task.requestParameters(parameters: ["partner_id": partnerId, "page": page, "page_size": Api.pageSize], encoding: URLEncoding())
            } else {
                return Task.requestParameters(parameters: ["partner_id": partnerId], encoding: URLEncoding())
            }
        case .operations(let page):
            if let page = page {
                return Task.requestParameters(parameters: ["page": page, "page_size": Api.pageSize], encoding: URLEncoding())
            } else {
                return Task.requestPlain
            }
        case .updateUserSubscribed(let push, let sms, let email):
            return Task.requestParameters(parameters: ["subscribed_to_push": push, "subscribed_to_sms": sms, "subscribed_to_email": email], encoding: URLEncoding())
        case .changePassword(let password):
            return Task.requestParameters(parameters: ["password": password], encoding: URLEncoding())
        case .cardChangeState(_, let password):
            return Task.requestParameters(parameters: ["password": password], encoding: URLEncoding())
        case .cardGetUserInfo(let cardNumber, let cardCode) :
            return Task.requestParameters(parameters: ["card_num": cardNumber, "card_code": cardCode], encoding: URLEncoding())
        case .cardSmsToAppend(let userId):
            return Task.requestParameters(parameters: ["user_id": userId], encoding: URLEncoding())
        case .cardAppendNew(let userId, let smsCode):
            return Task.requestParameters(parameters: ["user_id": userId, "sms_code": smsCode], encoding: URLEncoding())

        case .restorePasswordPhone(let phone):
            return Task.requestParameters(parameters: ["phone": phone], encoding: URLEncoding())
        case .restorePasswordSms(let phone, let sms):
            return Task.requestParameters(parameters: ["phone": phone, "sms_code": sms], encoding: URLEncoding())
        case .restorePasswordChange(let phone, let sms, let password):
            return Task.requestParameters(parameters: ["phone": phone, "sms_code": sms, "password": password], encoding: URLEncoding())
        default:
            return Task.requestPlain
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var validate: Bool {
        return false
    }

}
