//
//  TokenService.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 26.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation
import KeychainSwift
import RxSwift

class TokenService {
    
    private static let didSaveTokenKey = "ru.Appril.GreenCard.didSaveToken"
    private static let tokenKey = "ru.Appril.GreenCard.Token"
    static let instance = TokenService()
    
    fileprivate lazy var keychain = KeychainSwift()
    fileprivate lazy var defaults = UserDefaults.standard
    
    func saveTokenObservable(token: String) -> Observable<Void> {
        
        return Observable<Void>.create({ [unowned self] (observer) -> Disposable in
            if (self.keychain.set(token, forKey: TokenService.tokenKey)) {
                self.defaults.set(true, forKey: TokenService.didSaveTokenKey)
                observer.onNext(())
                observer.onCompleted()
            } else {
                observer.onError(KeychainError())
            }
            return Disposables.create()
        })
    }

    func saveToken(token : String) throws {
        if (self.keychain.set(token, forKey: TokenService.tokenKey)) {
            self.defaults.set(true, forKey: TokenService.didSaveTokenKey)
        } else {
            throw KeychainError()
        }
    }

    func tokenObservable() -> Observable<String?> {
        guard defaults.bool(forKey: TokenService.didSaveTokenKey) == true
            else { return Observable.just(nil) }
        
        return Observable.just(keychain.get(TokenService.tokenKey))
    }
    
    func tokenOrErrorObservable() -> Observable<String> {
        guard defaults.bool(forKey: TokenService.didSaveTokenKey) == true
            else { return Observable.error(GreencardError.unauthorized) }
        
        return Observable.just(keychain.get(TokenService.tokenKey)).errorOnNil(GreencardError.unauthorized)
    }
}
