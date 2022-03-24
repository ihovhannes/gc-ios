import RxSwift
import UIKit

private typealias ObservableState = Observable<UIViewController.AppearanceState>
private typealias SelectorAndState = (Selector, UIViewController.AppearanceState)

extension Reactive where Base: UIViewController {

  private func observableAppearance(_ selector: Selector, state: UIViewController.AppearanceState) -> ObservableState {
    return (base as UIViewController).rx.sentMessage(selector).map { _ in state }
  }

  func observableAppearanceState() -> Observable<UIViewController.AppearanceState> {
    let statesAndSelectors: [SelectorAndState] = [
      (#selector(UIViewController.viewDidAppear(_:)), .didAppear),
      (#selector(UIViewController.viewDidDisappear(_:)), .didDisappear),
      (#selector(UIViewController.viewWillAppear(_:)), .willAppear),
      (#selector(UIViewController.viewWillDisappear(_:)), .willDisappear)
    ]
    let observables = statesAndSelectors.map({ observableAppearance($0.0, state: $0.1) })
    return Observable
      .from(observables)
      .merge()
      .startWith(.unknown)
      .distinctUntilChanged()
  }

  var observableState: Observable<UIViewController.AppearanceState> {
    let statesAndSelectors: [SelectorAndState] = [
      (#selector(UIViewController.viewDidAppear(_:)), .didAppear),
      (#selector(UIViewController.viewDidDisappear(_:)), .didDisappear),
      (#selector(UIViewController.viewWillAppear(_:)), .willAppear),
      (#selector(UIViewController.viewWillDisappear(_:)), .willDisappear)
    ]
    let observables = statesAndSelectors.map({ observableAppearance($0.0, state: $0.1) })
    return Observable
      .from(observables)
      .merge()
      .distinctUntilChanged()
  }
}
