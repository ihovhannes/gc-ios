import RxSwift
import UIKit

typealias RootViewControllerBindings = (
        Observable<UIViewController.AppearanceState>
)

typealias RootViewControllerBindingsFactory = () -> RootViewControllerBindings

final class RootViewModel: DisposeBagProvider, ReactiveCompatible {

    fileprivate let bindingsFactory: RootViewControllerBindingsFactory
    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    required init(bindingsFactory: @escaping RootViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let didAppearObservable = self.rx.didAppearObservable()
        routingObservable = self.rx.routeToSplashObservable(didAppearObservable)
    }
}

fileprivate extension Reactive where Base == RootViewModel {
    func routeToSplashObservable(_ observableAppeared: Observable<Void>) -> Observable<Routing> {
        return observableAppeared
                .take(1)
                .flatMap({ (_) -> Observable<Bool> in
                    return Observable.just(false)
                })
                .flatMapLatest({ (_) -> Observable<String?> in
                    return TokenService.instance.tokenObservable()
                })
                .map({ token in token != nil && token!.isNotEmpty })
                .map({ isLoggedIn in
                    return Routing.splashScreen(isLoggedIn: isLoggedIn)
                })
    }
}

fileprivate extension Reactive where Base == RootViewModel {

    func didAppearObservable() -> Observable<Void> {
        return base.bindingsFactory()
                .filter({ $0 == .willAppear })
                .map({ _ in () })
                .take(1)
                .shareReplay(1)
    }
}
