//
//  Routing.swift
//  wrun-ios
//
//  Created by Appril on 05.06.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import RxCocoa
import RxSwift
import MMDrawerController
import GRDB

var lastDrawerController: UIViewController? = nil

enum Routing {
    case back
    case dismiss(animated: Bool)

    case preparedRoot(isLoggedIn: Bool)
    case loginSuccess
    case splashScreen(isLoggedIn: Bool)
    case switchMenu
    case backWithMenuColor(color: UIColor?)

    case alertView(title: String?, body: String?, repeatCallback: (() -> ())?)
    case toastView(msg: String?)

    case registration
    case registrationDetails(cardNumber: String, cardCode: String)
    case oferta(type: UIViewController.ViewType, header: String, acceptCallback: (() -> ())?)
    case registrationChangePassword

    case restorePasswordPhone
    case restorePasswordSms(phone: String)
    case restorePasswordConfirm(phone: String, smsCode: String)
    case restorePasswordDone

    case main
    case dismissOfertaAndRefreshMain
    case shares
    case shareDetail(id: Int64?, title: String?, endDate: String?, partnerColor: UIColor?, isArchive: Bool)
    case archiveShares
    case partners
    case partnerDetail(id: Int64?, logoSrc: String?, pageColor: String?)
    case partnerShares(partnerId: Int64, color: UIColor, logoSrc: String?, vendors: PartnerVendorsResponse?, mapLogoSrc: String?)
    case partnerLocations(partnerId: Int64, color: UIColor, vendors: PartnerVendorsResponse?, mapLogoSrc: String?)
    case balance
    case operationDetails(operationId: String?)
    case notifications
    case settings
    case faq
    case faqDetail(faqItem: FaqListItem)
    case operations
    case operationsManage
    case about
    case logout
}

extension Routing: NotificationDescriptable {

    static var descriptor: NotificationDescriptor<Routing> {
        return NotificationDescriptor<Routing> { (notification) -> Routing? in
            return notification.object as? Routing
        }
    }

    static var name: Notification.Name {
        return Notification.Name("\(#file)+\(#line)")
    }
}

extension UIViewController {

    enum ViewType {
        case abstract
        case root0
        case splash

        case login
        case registration
        case registrationDetails
        case registrationOfertaAccept
        case activationOfertaAccept
        case registrationChangPassword

        case restorePasswordPhone
        case restorePasswordSms
        case restorePasswordConfirm

        case menu
        case alertView
        case main
        case shares
        case shareDetail
        case archiveShares
        case partners
        case partnerDetail
        case partnerShares
        case partnerLocations
        case balance
        case operationDetails
        case notifications
        case settings
        case faq
        case faqDetail
        case operations
        case operationsManage
        case about
    }

    private struct UIViewControllerRuntimeKeys {
        static var key = "\(#file)+\(#line)"
    }

    var type: ViewType {
        get {
            return objc_getAssociatedObject(self, &UIViewControllerRuntimeKeys.key) as? ViewType ?? .abstract
        }
        set {
            objc_setAssociatedObject(self,
                    &UIViewControllerRuntimeKeys.key,
                    newValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController {

    func routing(with routing: Routing) {
        switch type {
        case .abstract:
            log("case \(routing) is not implemented")
        case .alertView:
            switch routing {
            case .dismiss:
//                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                dismiss(animated: false)
            case _:
                log("case \(routing) is not implemented")
            }
        case .root0:
            switch routing {
            case .splashScreen:
                splashScreen(with: routing)
            case .preparedRoot:
                preparedRoot(with: routing)
            case _:
                log("case \(routing) is not implemented")
            }
        case .splash:
            preparedRoot(with: routing)
        case .login:
            switch routing {
            case .alertView, .toastView, .registration, .restorePasswordPhone:
                showModal(with: routing)
            case _:
                loginSuccess(with: routing)
            }
        case .registration:
            switch routing {
            case .alertView:
                showModal(with: routing)
            case .registrationDetails:
                showModal(with: routing)
            case .dismiss:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
            case _:
                log("case \(routing) is not implemented")
            }
        case .registrationDetails:
            switch routing {
            case .alertView:
                showModal(with: routing)
            case .oferta:
                showModal(with: routing)
            case .toastView:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                showModal(with: routing)
            case .dismiss(let animated):
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
            case _:
                log("case \(routing) is not implemented")
            }
        case .registrationOfertaAccept:
            switch routing {
            case .alertView:
                showModal(with: routing)
            case .registrationChangePassword:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
            case _:
                log("case \(routing) is not implemented")
            }
        case .activationOfertaAccept:
            switch routing {
            case .alertView:
                showModal(with: routing)
            case .registrationChangePassword:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                showModal(with: routing)
            case _:
                log("case \(routing) is not implemented")
            }
        case .registrationChangPassword:
            switch routing {
            case .alertView:
                showModal(with: routing)
            case .dismissOfertaAndRefreshMain:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                if let mainViewController = lastDrawerController as? MainViewController {
                    mainViewController.configure(needRefresh: true)
                }
            case .logout:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                fromMenu(with: routing)
            case _:
                log("case \(routing) is not implemented")
            }

        case .restorePasswordConfirm, .restorePasswordPhone, .restorePasswordSms:
            switch routing {
            case .restorePasswordSms(let phone):
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                showModal(with: routing)
                showModal(with: Routing.toastView(msg: "Смс с кодом отправлена на номер\n+\(phone)"))
            case .restorePasswordConfirm:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                showModal(with: routing)
            case .dismiss:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
            case .restorePasswordDone:
                RootNavigationControllerHolder.navigationController.popViewController(animated: false)
                showModal(with: Routing.toastView(msg: "Пароль успешно изменен"))
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case _:
                log("case \(routing) is not implemented")
            }

        case .menu:
            fromMenu(with: routing)
        case .main, .shares, .partners, .balance, .notifications, .settings, .faq, .operations, .about:
            switch routing {
            case .switchMenu:
                switchMenu(with: routing)
            case .faqDetail, .shareDetail, .partnerDetail, .operationDetails, .operationsManage, .archiveShares:
                showDetail(with: routing)
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case .oferta:
                showModal(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }
        case .faqDetail, .operationDetails, .operationsManage:
            switch routing {
            case .switchMenu:
                backFromDetail(type: type)
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }
        case .partnerDetail:
            switch routing {
            case .switchMenu:
                backFromDetail(type: type)
            case .partnerShares:
                showModal(with: routing)
            case .partnerLocations:
                showDetail(with: routing)
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }

        case .partnerShares:
            switch routing {
            case .backWithMenuColor(let color):
                backFromDetail(type: type, animated: true, buttonColor: color)
            case .shareDetail, .partnerLocations:
                showDetail(with: routing)
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }

        case .partnerLocations:
            switch routing {
            case .backWithMenuColor(let color):
                backFromDetail(type: type, animated: true, buttonColor: color)
            case .alertView:
                showModal(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }

        case .shareDetail:
            switch routing {
            case .backWithMenuColor(let color):
                backFromDetail(type: type, animated: true, buttonColor: color)
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }
        case .archiveShares:
            switch routing {
            case .switchMenu:
                backFromDetail(type: type, animated: true, buttonColor: nil)
            case .alertView:
                showModal(with: routing)
            case .toastView:
                showModal(with: routing)
            case .shareDetail:
                showDetail(with: routing)
            case _:
                log("Unknown combination type=\(type) with routing=\(routing)")
            }
        }
    }
}

fileprivate extension UIViewController {

    func loginSuccess(with routing: Routing) {
        guard case .loginSuccess = routing else {
            log("unhandled \(routing)")
            return
        }
        dismiss(animated: true, completion: nil)

        let mainController = MainViewController()
        let drawerController = DrawerViewController(center: mainController,
                leftDrawerViewController: MenuViewController())
        lastDrawerController = mainController
        Routing.setRoot(with: drawerController)
    }

    func splashScreen(with routing: Routing) {
        guard case .splashScreen(let isLoggedIn) = routing else {
            return
        }
        Routing.setRoot(with: SplashViewController().configure(isLoggedIn: isLoggedIn))
    }

    func preparedRoot(with routing: Routing) {
        guard case .preparedRoot(let isLoggedIn) = routing else {
            return
        }
        if (isLoggedIn) {
            let mainController = MainViewController()
            let drawerController = DrawerViewController(center: mainController,
                    leftDrawerViewController: MenuViewController())
            lastDrawerController = mainController
            Routing.setRoot(with: drawerController)
        } else {
            let controller = LoginViewController()
            Routing.setRoot(with: controller)
        }
    }

    func switchMenu(with routing: Routing) {
        guard case .switchMenu = routing else {
            return
        }
        guard let drawer = RootViewController.getDrawerController() else {
            return
        }
        drawer.switchMenu()
    }

    func back(with routing: Routing) {
        guard case .back = routing else {
            return
        }
        guard let navig = self.navigationController else {
            return
        }
        navig.popViewController(animated: true)
    }

    func dismiss(with routing: Routing) {
        guard case .dismiss(let animated) = routing else {
            return
        }
        dismiss(animated: animated, completion: nil)
    }

    func fromMenu(with routing: Routing) {
        log("tap from menu: \(routing)")

        lastDrawerController = nil

        // TODO: controller cache
        switch routing {
        case .main:
            lastDrawerController = MainViewController()
        case .shares:
            lastDrawerController = SharesViewController()
        case .partners:
            lastDrawerController = PartnersViewController()
        case .balance:
            lastDrawerController = BalanceViewController()
        case .notifications:
            lastDrawerController = NotificationsViewController()
        case .settings:
            lastDrawerController = SettingsViewController()
        case .faq:
            lastDrawerController = FaqViewController()
        case .operations:
            lastDrawerController = OperationsViewController()
        case .about:
            lastDrawerController = AboutViewController()

        case .logout:
            // TODO: сделать нормально
            TokenService.instance.saveTokenObservable(token: "").subscribe { [unowned self] _ in
                do {
                    try DatabaseService.instance.pool.writeInTransaction { db -> Database.TransactionCompletion in
                        try ShareEntity.deleteAll(db)
                        try UserEntity.deleteAll(db)
                        try CountEntity.deleteAll(db)
                        return .commit
                    }
                } catch {
                    print("cant clear db")
                }
                RootViewController.getDrawerController()?.button.setState(state: .main, animated: true)
                Routing.setRoot(with: LoginViewController().configure(animateLogoAndTitle: false))
            }
        case _:
            log("case \(routing) is not implemented");
        }

        if let controller = lastDrawerController, let drawer = RootViewController.getDrawerController() {
            drawer.setCenterView(controller, isInner: false)
            drawer.switchMenu()
        }
    }

    func showDetail(with routing: Routing) {
        log("show detail: \(routing)")

        var controller: UIViewController? = nil
        var customMenuButton: UIColor? = nil

        switch routing {
        case .operationDetails(let operationId):
            controller = OperationDetailViewController().configure(operationId: operationId)
        case .faqDetail(let faqItem):
            controller = FaqDetailViewController()
                    .configure(question: faqItem.question ?? "", answer: faqItem.answer ?? "")
        case .partnerDetail(let id, let logo, let pageColor):
            controller = PartnerDetailViewController().configure(id: id, logoSrc: logo, pageColor: pageColor)
            customMenuButton = UIColor(hex: pageColor)
        case .partnerLocations(let id, let pageColor, let vendors, let mapLogo):
            controller = PartnerLocationsViewController()
                    .configure(partnerId: id, pageColor: pageColor, vendors: vendors, mapLogoSrc: mapLogo)
        case .shareDetail(let id, let title, let endDate, let color, let isArchive):
            controller = ShareDetailViewController().configure(id: id, title: title, endDate: endDate, partnerColor: color, isArchive: isArchive)
        case .operationsManage:
            controller = OperationsManageViewController()
        case .archiveShares:
            controller = ArchiveSharesViewController()
        case _:
            log("case \(routing) is not implemented")
        }

        if let controller = controller, let drawer = RootViewController.getDrawerController() {
            drawer.setRightView(rightController: controller, animated: true, strokeColor: customMenuButton)
        }
    }

    func showModal(with routing: Routing) {
        log("show modal: \(routing)")

        switch routing {
        case .registration:
            RootNavigationControllerHolder
                    .navigationController
                    .pushViewController(RegistrationViewController(), animated: false)

        case .registrationDetails(let cardNumber, let cardCode):
            RootNavigationControllerHolder
                    .navigationController
                    .popViewController(animated: false)
            let controller = RegistrationDetailsViewController().configure(cardNumber: cardNumber, cardCode: cardCode)
            RootNavigationControllerHolder
                    .navigationController
                    .pushViewController(controller, animated: false)


        case .oferta(let type, let header, let acceptCallback):
            let controller = RegistrationOfertaViewController().configure(type: type, header: header, acceptCallback: acceptCallback)
            RootNavigationControllerHolder
                    .navigationController
                    .pushViewController(controller, animated: false)

        case .registrationChangePassword:
            let controller = RegistrationPasswordViewController()
            RootNavigationControllerHolder
                    .navigationController
                    .pushViewController(controller, animated: false)

        case .restorePasswordPhone:
            let controller = RestorePasswordPhoneViewController()
            RootNavigationControllerHolder.navigationController.pushViewController(controller, animated: false)

        case .restorePasswordSms(let phoneNumber):
            let controller = RestorePasswordSmsViewController().configure(phone: phoneNumber)
            RootNavigationControllerHolder
                    .navigationController
                    .pushViewController(controller, animated: false)

        case .restorePasswordConfirm(let phone, let sms):
            let controller = RestorePasswordConfirmViewController().configure(phone: phone, sms: sms)
            RootNavigationControllerHolder
                    .navigationController
                    .pushViewController(controller, animated: false)

        case .partnerShares(let partnerId, let color, let logoSrc, let vendors, let mapLogoSrc):
            let controller = PartnerSharesViewController()
                    .configure(partnerId: partnerId, pageColor: color, logoSrc: logoSrc, vendors: vendors, mapLogo: mapLogoSrc)
            if let drawer = RootViewController.getDrawerController() {
                drawer.setRightView(rightController: controller, animated: false, strokeColor: color)
            }
        case .alertView(let title, let body, let repeatCallback):
            var controller: AlertViewController = AlertViewController().configure(title: title, body: body, repeatCallback: repeatCallback)
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve
            showModal(controller: controller)
//            RootNavigationControllerHolder
//                    .navigationController
//                    .pushViewController(controller, animated: false)
        case .toastView(let msg):
            if let rootView = RootViewController.getRootView(), let msg = msg {
                let toastView = ToastView.instance
                rootView.addSubview(toastView)
                toastView.frame = rootView.frame
                toastView.show(text: msg)
            }
        case _:
            log("case \(routing) is not implemented")
        }
    }

    func showModal(controller: UIViewController) {
        let rootViewController = RootNavigationControllerHolder.rootViewController

        var presentedViewController: UIViewController? = rootViewController

        while presentedViewController?.presentedViewController != nil {
            presentedViewController = presentedViewController?.presentedViewController
        }
        presentedViewController?.present(controller, animated: false)
    }

    func backFromDetail(type: ViewType, animated: Bool = true, buttonColor: UIColor? = nil) {
        log("back from detail: \(type)")

        if let drawer = RootViewController.getDrawerController() {
            drawer.popRightView(animated: animated, strokeColor: buttonColor)
        }
    }
}

// MARK: - External Reactive

extension Reactive where Base: UIViewController {

    var observerRouting: AnyObserver<Routing> {
        return Binder(base, binding: { (view: UIViewController, routing: Routing) in
            DispatchQueue.main.async { [unowned view, routing] () in
                view.routing(with: routing)
            }
        }).asObserver()
    }
}

fileprivate extension Routing {

    static func setRoot(with viewController: UIViewController) {
        let rootViewController = RootNavigationControllerHolder.rootViewController
        rootViewController.childViewControllers.forEach { (controller) in
            controller.removeFromParentViewController()
        }
        rootViewController.view.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        rootViewController.addChildViewController(viewController)
        rootViewController.view.addSubview(viewController.view)
        rootViewController.view.bringSubview(toFront: viewController.view)
        viewController.view.frame = rootViewController.view.frame
    }

    static func setCenterController(with viewController: UIViewController) {

        guard let drawerController = RootViewController.getDrawerController() else {
            return
        }
        drawerController.centerViewController = viewController
        drawerController.closeDrawer(animated: true, completion: nil)
    }
}

extension Routing {
    static func open(with url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil) //9pvNJHCHRa2jKj
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

extension RootViewController {

    static func getRootView() -> UIView? {
        return UIApplication.shared.keyWindow
    }

    static func getRootViewController() -> RootViewController? {
        return UIApplication.shared.keyWindow?.rootViewController as? RootViewController
    }

    static func getDrawerController() -> DrawerViewController? {
        return RootNavigationControllerHolder.rootViewController
                .childViewControllers
                .first(where: { controller in controller.isKind(of: DrawerViewController.self) }) as? DrawerViewController
    }
}
