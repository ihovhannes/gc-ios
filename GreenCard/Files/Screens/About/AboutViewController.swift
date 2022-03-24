//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift
import RxGesture

class AboutViewController: UIViewController, DisposeBagProvider {

    fileprivate var aboutView: AboutView {
        return view as? AboutView ?? AboutView()
    }

    fileprivate var viewModel: AboutViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = AboutView()
        type = .about

        viewModel = AboutViewModel(bindingsFactory: getBindingsFactory())

        viewModel.routingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)

        setAppVersion()

        // -- Buttons

        aboutView.ratingContainer
                .rx
                .tapGesture()
                .when(.recognized)
                .subscribe(onNext: { [unowned self] _ in self.onStarsTap() })
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log("deinit")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        aboutView.starsAnim.play()
    }

    func setAppVersion() {
        let appVersionStr = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        aboutView.versionLabel.text = "\(appVersionStr)"
    }

    func onStarsTap() {
        let APP_ID = "1336362530";
        let urlString = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";

        guard let url = URL(string: urlString) else {
            log("URL failed");
            return;
        }

        UIApplication.shared.openURL(url);
    }
}

fileprivate extension AboutViewController {

    func getBindingsFactory() -> AboutViewControllerBindingsFactory {
        return { [unowned self] () -> AboutViewControllerBindings in
            return AboutViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}
