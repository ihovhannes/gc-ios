//
//  AppDelegate.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 27.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Look
import IQKeyboardManagerSwift
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = AppDelegate.getWindow()

    private static func getWindow() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.look.apply(Style.window)
        return window
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if Config.sharedInstance.shouldUseFabric() {
            Fabric.with([Crashlytics.self])
        }

        DatabaseService.instance.pool.setupMemoryManagement(in: application)
        
        IQKeyboardManager.sharedManager().enable = true
//        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        RootNavigationControllerHolder.navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = RootNavigationControllerHolder.navigationController
        window?.makeKeyAndVisible()

        GMSServices.provideAPIKey("AIzaSyD1fUMWmSR1stvye4ASGySZUfySAX9mIJk")
        return true
    }
}

extension AppDelegate: DisposeBagProvider {

    static func getDisposeBagProvider() -> DisposeBagProvider? {
        return UIApplication.shared.delegate as? DisposeBagProvider
    }
}
