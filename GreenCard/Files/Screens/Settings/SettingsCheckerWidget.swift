//
// Created by Hovhannes Sukiasian on 13/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxGesture

class SettingsCheckerWidget: UIView, DisposeBagProvider {

    var stateIsOn = false

    fileprivate var isAnimating: Bool = false

    fileprivate let SELF_WIDTH: CGFloat = 70.0
    fileprivate let SELF_HEIGHT: CGFloat = 33.0

    fileprivate let CIRCLE_SIZE: CGFloat = 29.0
    fileprivate let PAD: CGFloat = (33.0 - 29.0) / 2.0

    fileprivate let ANIMATION_TIME = 0.2

    fileprivate let container = UIView()
    fileprivate let circle = UIView()
    fileprivate let labelOn = UILabel()
    fileprivate let labelOff = UILabel()

    fileprivate var callback: ((Bool) -> Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)

        container.addSubview(circle)
        container.addSubview(labelOn)
        container.addSubview(labelOff)

        circle.frame = CGRect(x: PAD, y: PAD, width: CIRCLE_SIZE, height: CIRCLE_SIZE)
        circle.layer.cornerRadius = (CIRCLE_SIZE / 2.0)

        container.layer.cornerRadius = (SELF_HEIGHT * 0.5)
        container.clipsToBounds = true

        container.snp.makeConstraints { container in
            container.height.equalTo(SELF_HEIGHT)
            container.width.equalTo(SELF_WIDTH)
            container.edges.equalToSuperview()
        }

        labelOn.isShown = false
        labelOn.snp.makeConstraints { labelOn in
            labelOn.centerY.equalToSuperview()
            labelOn.leading.equalToSuperview()
            labelOn.width.equalToSuperview().offset(-1 * CIRCLE_SIZE)
        }

        labelOff.snp.makeConstraints { labelOff in
            labelOff.centerY.equalToSuperview()
            labelOff.trailing.equalToSuperview()
            labelOff.width.equalToSuperview().offset(-1 * CIRCLE_SIZE)
        }

        container.gestureArea(leftOffset: 10, topOffset: 10, rightOffset: 10, bottomOffset: 10)
                .rx.tapGesture()
                .when(.recognized)
                .subscribe(onNext: onTap)
                .disposed(by: disposeBag)

        look.apply(Style.settingsCheckerWidget)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func onTap(args: Any) {
        guard !isAnimating else {
            return
        }
        toggleIt()
        callback?(stateIsOn)
    }

    fileprivate func toggleIt() {
        defer {
            stateIsOn = !stateIsOn
        }
        labelOn.isShown = false
        labelOff.isShown = false
        if stateIsOn {
            animateToOff()
        } else {
            animateToOn()
        }
    }

    fileprivate func animateToOn() {
        isAnimating = true
        circle.backgroundColor = Palette.CheckerWidget.circleOn.color
        circle.frame.origin.x = (PAD)
        UIView.animate(withDuration: ANIMATION_TIME, animations: { [unowned self] in
            self.circle.frame.origin.x = (self.SELF_WIDTH - self.PAD - self.CIRCLE_SIZE)
        }, completion: { [weak self] (complete) in
            self?.isAnimating = false
            self?.labelOn.isShown = true
        })
    }

    fileprivate func animateToOff() {
        isAnimating = true
        circle.backgroundColor = Palette.CheckerWidget.circleOff.color
        circle.frame.origin.x = (SELF_WIDTH - PAD - CIRCLE_SIZE)
        UIView.animate(withDuration: ANIMATION_TIME, animations: { [unowned self] in
            self.circle.frame.origin.x = (self.PAD)
        }, completion: { [weak self] (complete) in
            self?.isAnimating = false
            self?.labelOff.isShown = true
        })
    }

}

extension SettingsCheckerWidget {

    func turnIt(isOn: Bool) {
        if stateIsOn != isOn {
            toggleIt()
        }
    }

    func subscribeOnTap(callback: @escaping(Bool) -> Void) {
        self.callback = callback
    }

    func isOn() -> Bool {
        return stateIsOn
    }

}

fileprivate extension Style {

    static var settingsCheckerWidget: Change<SettingsCheckerWidget> {
        return { (view: SettingsCheckerWidget) in
            view.container.backgroundColor = Palette.CheckerWidget.background.color

            view.circle.backgroundColor = Palette.CheckerWidget.circleOff.color

            view.labelOn.text = "ВКЛ"
            view.labelOn.font = UIFont(name: "ProximaNova-Regular", size: 9)
            view.labelOn.textColor = Palette.CheckerWidget.label.color
            view.labelOn.textAlignment = .center

            view.labelOff.text = "ВЫКЛ"
            view.labelOff.font = UIFont(name: "ProximaNova-Regular", size: 9)
            view.labelOff.textColor = Palette.CheckerWidget.label.color
            view.labelOff.textAlignment = .center
        }
    }

}
