//
//  SplashViewController.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit
import Look
import RxSwift
import RxCocoa

class SplashViewController: UIViewController, DisposeBagProvider {

    fileprivate var isLoggedIn: Bool = false

    fileprivate var viewModel: SplashViewModel!
    fileprivate lazy var didFinishLoading = PublishSubject<Void>()
    fileprivate var splashView: SplashView {
        return view as! SplashView
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        view = SplashView(styleObservable: didFinishLoading)
        viewModel = SplashViewModel(bindingsFactory: getbindingsFactory())
        viewModel.routingObservable.bind(to: rx.observerRouting).disposed(by: disposeBag)
        type = .splash
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        splashView.bottomTimeline.transform = CGAffineTransform(translationX: -1 * splashView.bottomTimeline.bounds.width, y: 0)

        let animationTime = isLoggedIn ? 0.1 : 1.0
        splashView.bottomTimeline.alpha = isLoggedIn ? 0.0 : 1.0

        UIView.animate(withDuration: animationTime, animations: { [unowned splashView] () -> Void in
            splashView.bottomTimeline.transform = CGAffineTransform.identity
        }, completion: { [weak self] (finished) -> Void in
            if finished {
                self?.didFinishLoading.onNext(())
            }
        })
    }

    deinit {
        debugPrint("deinit \(#file)+\(#line)")
    }

    func configure(isLoggedIn: Bool) -> SplashViewController {
        self.isLoggedIn = isLoggedIn
        return self
    }
}

fileprivate extension SplashViewController {
    func getbindingsFactory() -> () -> SplashViewControllerBindings {

        return { [unowned self] () -> SplashViewControllerBindings in
            return self.didFinishLoading.asObserver()
        }
    }
}
