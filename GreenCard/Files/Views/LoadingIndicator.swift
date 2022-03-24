//
//  LoadingIndicator.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 25.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Lottie
import Look
import SnapKit

class LoadingIndicator: UIView {

    private static let aspectRatio: CGFloat = 0.75

    static let instance = LoadingIndicator(frame: .zero)

    fileprivate let spinner = LOTAnimationView(name: "loading_indicator")
    fileprivate var isShowing = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(spinner)

        spinner.snp.makeConstraints { maker in
            maker.width.equalTo(150)
            maker.height.equalTo(150 * 0.75)
            maker.center.equalToSuperview()
        }

        look.apply(Style.indicatorStyle)

//        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func containerView() -> UIView? {
        return UIApplication.shared.keyWindow
    }

    public static func show() {
        DispatchQueue.main.async { () in
            let view = LoadingIndicator.instance
            guard let superView = LoadingIndicator.containerView() else {
                fatalError("No window found, that's ridiculous!")
            }

//        superView.isUserInteractionEnabled = false
            superView.addSubview(view)

            view.frame = superView.frame
            view.spinner.loopAnimation = true
            //UIView.animate(withDuration: 0.2) { [unowned view] () in
            view.alpha = 1.0
            //}
            view.spinner.play()
        }
    }

    public static func hide() {
        DispatchQueue.main.async { () in
            guard let superView = LoadingIndicator.containerView() else {
                fatalError("No window found, that's ridiculous!")
            }

//        superView.isUserInteractionEnabled = true

            let view = LoadingIndicator.instance
            //UIView.animate(withDuration: 0.2, animations: { [unowned view] () in
            view.alpha = 0.0
            //}) { (finished) in
            view.spinner.pause()
            view.spinner.loopAnimation = false
            view.removeFromSuperview()
            //}
        }
    }
}

fileprivate extension Style {
    static var indicatorStyle: Change<LoadingIndicator> {
        return { (view: LoadingIndicator) -> Void in
            view.backgroundColor = Palette.LoadingIndicator.background.color
            view.alpha = 0.0
        }
    }
}
