//
// Created by Hovhannes Sukiasian on 16/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxSwift
import DTCoreText

class FaqDetailViewController: UIViewController, DisposeBagProvider {

    fileprivate var faqDetailView: FaqDetailView {
        return view as? FaqDetailView ?? FaqDetailView()
    }

    fileprivate var viewModel: FaqDetailViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = FaqDetailView()
        type = .faqDetail

        viewModel = FaqDetailViewModel(bindingsFactory: getBindingsFactory())

        viewModel
                .updateQuestionAnswerObservable
                .bind(to: faqDetailView.rx.questionAnswerObserver)
                .disposed(by: disposeBag)

        viewModel
                .menuRoutingObservable
                .bind(to: rx.observerRouting)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(question: String, answer: String) -> FaqDetailViewController {
        viewModel.questionAnswer.value = (question: question, answer: answer)
        return self
    }
}



fileprivate extension FaqDetailViewController {

    func getBindingsFactory() -> FaqDetailViewControllerBindingsFactory {
        return { [unowned self] () -> FaqDetailViewControllerBindings in
            return FaqDetailViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}

