//
//  DrawerViewController.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 05.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import SnapKit
import MMDrawerController

class DrawerViewController: MMDrawerController {
    
    let button = DrawerButton.instance
    
    override init(center centerViewController: UIViewController!, leftDrawerViewController: UIViewController!) {
        let navigationController = UINavigationController(rootViewController: centerViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        super.init(center: navigationController, leftDrawerViewController: leftDrawerViewController, rightDrawerViewController: nil)
        
        let width = UIApplication.shared.keyWindow?.frame.width ?? 0.0
        setHovhannes SukiasianumLeftDrawerWidth(width, animated: false, completion: nil)
        setHovhannes SukiasianumRightDrawerWidth(width, animated: false, completion: nil)
        setDrawerVisualStateBlock(MMDrawerVisualState.slideVisualStateBlock())
        showsShadow = false
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        button.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.leading.equalToSuperview().offset(14)
            maker.size.equalTo(50)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubview(toFront: button)
    }
    
    override func setCenterView(_ centerViewController: UIViewController!,
                                withCloseAnimation closeAnimated: Bool,
                                completion: ((Bool) -> Void)!) {
        fatalError("use setCenterView(_ centerViewController: UIViewController!, isInner: Bool)")
    }
    
    override func setCenterView(_ newCenterViewController: UIViewController!,
                                withFullCloseAnimation fullCloseAnimated: Bool,
                                completion: ((Bool) -> Void)!) {
        fatalError("use setCenterView(_ centerViewController: UIViewController!, isInner: Bool)")
    }

    func setCenterView(_ centerViewController: UIViewController!, isInner: Bool) {
        let navigationController = UINavigationController(rootViewController: centerViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        super.setCenterView(navigationController, withCloseAnimation: false, completion: nil)
    }

    func setRightView(rightController: UIViewController, animated: Bool = true, strokeColor: UIColor? = nil) {
        if let centerViewController = centerViewController as? UINavigationController {
            centerViewController.pushViewController(rightController, animated: animated)
            button.setState(state: centerViewController.viewControllers.count > 1 ? .back : .main, animated: true, strokeColor: strokeColor)
        }
    }

    func popRightView(animated: Bool = true, strokeColor: UIColor? = nil) {
        if let centerViewController = centerViewController as? UINavigationController {
            centerViewController.popViewController(animated: animated)
            button.setState(state: centerViewController.viewControllers.count > 1 ? .back : .main, animated: true, strokeColor: strokeColor)
        }
    }
    
    func switchMenu() {
        switch openSide {
        case .left:
            button.setState(state: .main, animated: true)
            closeDrawer(animated: true, completion: nil)
        case .none:
            button.setState(state: .menu, animated: true)
            open(.left, animated: true, completion: nil)
        default:
            fatalError("Right side is not avalable here")
        }
    }
}
