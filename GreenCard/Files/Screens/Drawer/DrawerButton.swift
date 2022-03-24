//
//  DrawerButton.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 05.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Look

enum ButtonState {
    case main
    case menu
    case back
}

class DrawerButton: UIButton {
    
    typealias IconPaths = (
        start: CGPath?,
        finish: CGPath
    )
    
    static let animIdentifier = "IconAnimation"
    
    static let instance = DrawerButton(initialState: .main)
    
    fileprivate lazy var animationLayer = CAShapeLayer()
    
    init(initialState: ButtonState) {
        super.init(frame: .zero)
        
        look.apply(Style.corners(rounded: true, size: CGSize(width: 50, height: 50), radius: 25))
        
        layer.addSublayer(animationLayer)
        animationLayer.frame = CGRect(x: 15, y: 15, width: 20, height: 20)
        animationLayer.lineCap = kCALineCapRound
        animationLayer.lineWidth = 2.0
        
        setState(state: initialState, animated: false)
    }
    
    var currentState: ButtonState = .back
    var currentStrokeColor: UIColor? = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setState(state: ButtonState, animated: Bool, strokeColor: UIColor? = nil) {
        if (state == currentState && currentStrokeColor == strokeColor ) { return }
        defer {
            currentState = state
            currentStrokeColor = strokeColor
        }
        switch state {
        case .main:
            look.apply(Style.main)
            let paths = createMainPaths(animated: animated)
            animationLayer.path = paths.finish
            if (animated) {
                let animation = createAnimation(from: paths.start, to: paths.finish)
                animationLayer.add(animation, forKey: DrawerButton.animIdentifier)
            }
        case .menu:
            look.apply(Style.menu)
            let paths = createMenuPaths(animated: animated)
            animationLayer.path = paths.finish
            if (animated) {
                let animation = createAnimation(from: paths.start, to: paths.finish)
                animationLayer.add(animation, forKey: DrawerButton.animIdentifier)
            }
        case .back:
            if let strokeColor = strokeColor {
                look.apply(Style.customStroke(color: strokeColor))
            } else {
                look.apply(Style.main)
            }
            let paths = createBackPaths(animated: animated)
            animationLayer.path = paths.finish
            if (animated) {
                log("animated not implemented")
            }
        }
    }
}

fileprivate extension DrawerButton {

    func createAnimation(from startPath: CGPath?, to finishPath: CGPath) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 0.2
        animation.fromValue = startPath
        animation.toValue = finishPath
        animation.isRemovedOnCompletion = true
        return animation
    }

    func createMenuPaths(animated: Bool) -> IconPaths {
        let finishPath = UIBezierPath()
        finishPath.move(to: CGPoint(x: 18, y: 2))
        finishPath.addLine(to: CGPoint(x: 2, y: 18))
        finishPath.move(to: CGPoint(x: 18, y: 18))
        finishPath.addLine(to: CGPoint(x: 2, y: 2))

        if (!animated) {
            return (nil, finishPath.cgPath)
        }

        let startPath = UIBezierPath()
        startPath.move(to: CGPoint(x: 18, y: 2))
        startPath.addLine(to: CGPoint(x: 2, y: 2))
        startPath.move(to: CGPoint(x: 18, y: 18))
        startPath.addLine(to: CGPoint(x: 2, y: 18))

        return (startPath.cgPath, finishPath.cgPath)
    }

    func createMainPaths(animated: Bool) -> IconPaths {
        let finishPath = UIBezierPath()
        finishPath.move(to: CGPoint(x: 0, y: 5))
        finishPath.addLine(to: CGPoint(x: 20, y: 5))
        finishPath.move(to: CGPoint(x: 0, y: 10))
        finishPath.addLine(to: CGPoint(x: 20, y: 10))
        finishPath.move(to: CGPoint(x: 0, y: 15))
        finishPath.addLine(to: CGPoint(x: 20, y: 15))

        if (!animated) {
            return (nil, finishPath.cgPath)
        }

        let startPath = UIBezierPath()
        startPath.move(to: CGPoint(x: 4, y: 9))
        startPath.addLine(to: CGPoint(x: 16, y: 9))
        startPath.move(to: CGPoint(x: 0, y: 10))
        startPath.addLine(to: CGPoint(x: 20, y: 10))
        startPath.move(to: CGPoint(x: 4, y: 11))
        startPath.addLine(to: CGPoint(x: 16, y: 11))

        return (startPath.cgPath, finishPath.cgPath)
    }

    func createBackPaths(animated: Bool) -> IconPaths {
        let finishPath = UIBezierPath()
        finishPath.move(to: CGPoint(x: 13, y: 0))
        finishPath.addLine(to: CGPoint(x: 2, y: 10))
        finishPath.move(to: CGPoint(x: 2, y: 10))
        finishPath.addLine(to: CGPoint(x: 13, y: 20))

        return (nil, finishPath.cgPath)
    }
}

fileprivate extension Style {
    static var menu: Change<DrawerButton> {
        return { (view: DrawerButton) -> Void in
            view.backgroundColor = Palette.Common.whiteText.color
            view.animationLayer.strokeColor = Palette.Common.greenText.color.cgColor
        }
    }
    
    static var main: Change<DrawerButton> {
        return { (view: DrawerButton) -> Void in
            view.backgroundColor = Palette.Common.greenText.color
            view.animationLayer.strokeColor = Palette.Common.whiteText.color.cgColor
        }
    }

    static func customStroke(color: UIColor) -> Change<DrawerButton> {
        return { [color] (view: DrawerButton) -> Void in
            view.backgroundColor = Palette.Common.whiteText.color
            view.animationLayer.strokeColor = color.cgColor
        }
    }
}
