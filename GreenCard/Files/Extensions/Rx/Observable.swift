//
//  Observable.swift
//  wrun-ios
//
//  Created by Appril on 19.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import RxSwift

protocol ObservableType {

  associatedtype ElementType

  var wrapped: Observable<ElementType> { get }
}

extension Observable: ObservableType {

  typealias ElementType = E

  var wrapped: Observable {
    return self
  }
}

extension Optional where Wrapped: ObservableType {

  var observableOrEmpty: Observable<Wrapped.ElementType> {
    switch self?.wrapped {
    case .none:
      return Observable<Wrapped.ElementType>.empty()
    case .some(let wrapped):
      return wrapped
    }
  }

  var observableOrNever: Observable<Wrapped.ElementType> {
    switch self?.wrapped {
    case .none:
        return Observable<Wrapped.ElementType>.never()
    case .some(let wrapped):
      return wrapped
    }
  }
}

extension Observable {
    
    func mapError(_ transform: @escaping (Error) throws -> Error) -> Observable<Element> {
        return catchError({ (error) -> Observable<Element> in
            return try Observable.error(transform(error))
        })
    }
}
