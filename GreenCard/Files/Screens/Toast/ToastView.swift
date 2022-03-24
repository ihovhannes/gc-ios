//
// Created by Hovhannes Sukiasian on 10/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Look
import UIKit
import SnapKit

class ToastView: UIView, DisposeBagProvider {

    let HEIGHT = 52
    let container = UIView()
    let msg = UILabel()

    static var instance = ToastView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)
        container.addSubview(msg)

        container.snp.makeConstraints { container in
            container.centerX.equalToSuperview()
            container.bottom.equalToSuperview().offset(-100)
            container.width.lessThanOrEqualToSuperview().offset(-60).priority(.high)
            container.width.equalTo(msg.snp.width).offset(HEIGHT).priority(.high)
            container.height.greaterThanOrEqualTo(HEIGHT)
            container.height.greaterThanOrEqualTo(msg.snp.height).offset(28)
        }

        msg.snp.makeConstraints { msg in
            msg.center.equalToSuperview()
        }

        isUserInteractionEnabled = false

        look.apply(Style.toastView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(text: String) {
        if msg.text == text && self.superview != nil {
            return
        }
        msg.text = text

        container.alpha = 0
        container.transform = CGAffineTransform(translationX: 0, y: self.frame.size.height)

        UIView.animate(withDuration: 0.4, animations: { [unowned container] () in
            container.transform = CGAffineTransform.identity
            container.alpha = 1
        }, completion: onShowCompletion)
    }

    fileprivate func onShowCompletion(isFinished: Bool) {
        if isFinished {
            UIView.animate(withDuration: 0.4, delay: 3, options: [], animations: { [unowned container] () in
                container.alpha = 0
            }, completion: { [weak self] isFinished in
                if isFinished {
                    self?.removeFromSuperview()
                    self?.msg.text = nil
                }
            })
        }
    }

}


fileprivate extension Style {

    static var toastView: Change<ToastView> {
        return { (view: ToastView) -> Void in
            view.container.layer.cornerRadius = CGFloat(view.HEIGHT / 2)
            view.container.backgroundColor = Palette.ToastView.background.color

            view.msg.font = UIFont(name: "ProximaNova-Regular", size: 18)
            view.msg.textColor = Palette.ToastView.text.color
            view.msg.numberOfLines = 0
            view.msg.lineBreakMode = .byWordWrapping
        }
    }

}
