//
// Created by Hovhannes Sukiasian on 30/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift

class ShareDetailViewController: UIViewController, DisposeBagProvider {

    fileprivate var shareDetailView: ShareDetailView {
        return view as? ShareDetailView ?? ShareDetailView()
    }

    fileprivate var viewModel: ShareDetailViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = ShareDetailView()
        type = .shareDetail

        viewModel = ShareDetailViewModel(bindingsFactory: getBindingsFactory())

        // -- Navigation

        viewModel.routingObservable
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel
                .updateShareObservable
                .bind(to: shareDetailView.rx.shareObserver)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(id: Int64?, title: String?, endDate: String?, partnerColor: UIColor?, isArchive: Bool) -> ShareDetailViewController {
        viewModel.isArchive = isArchive // TODO: костыль
        viewModel.shareId.value = id // TODO: обязательно после isArchive
        viewModel.partnerColor.value = partnerColor

        shareDetailView.configure(title: title, endDate: endDate)
        return self
    }

}

fileprivate extension ShareDetailViewController {

    func getBindingsFactory() -> ShareDetailViewControllerBindingsFactory {
        return { [unowned self] () -> ShareDetailViewControllerBindings in
            return ShareDetailViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    backSwipe: self.shareDetailView.backSwipe.asObservable()
            )
        }
    }

}
