import UIKit
import RxSwift
import RxCocoa
import Look

class RootViewController: UIViewController, DisposeBagProvider {
    
    fileprivate var viewModel: RootViewModel!
    
    init() {
        super.init(nibName: nil, bundle: nil)

        let view = UIView()
        view.backgroundColor = Palette.Common.greenText.color

        self.view = view

        viewModel = RootViewModel.init(bindingsFactory: getbindingsFactory())
        type = .root0
        viewModel.routingObservable.bind(to: rx.observerRouting).addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(#file)+\(#line)")
    }
}

fileprivate extension RootViewController {
    
    func getbindingsFactory() -> () -> RootViewControllerBindings {
        
        return { [unowned self] () -> RootViewControllerBindings in
            return self.rx.observableAppearanceState()
        }
    }
}
