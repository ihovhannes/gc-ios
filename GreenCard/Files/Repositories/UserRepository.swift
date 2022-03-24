//
//  UserRepository.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 09.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import RxSwift

class UserRepository {
    
    static let lifetime: TimeInterval = 4 * 60 * 60
    
    func getUser(refresh: Bool) -> Observable<UserEntity?> {
        if (Reachability.isConnectedToNetwork()) {
            if (refresh) {
                return getUserFromApi()
            }
            return getUserFromDb()
                .flatMapLatest({ userOrNil -> Observable<UserEntity?> in
                    guard let user = userOrNil else {
                        return self.getUserFromApi()
                    }
                    guard Date().timeIntervalSince(user.updateDate) <= UserRepository.lifetime else {
                        return self.getUserFromApi()
                    }
                    return Observable.just(user)
                })
        }
        return Observable.error(GreencardError.network)
    }
    
    func getUserFromDb() -> Observable<UserEntity?> {
        return UserEntity
            .all()
            .rx
            .fetchOne(in: DatabaseService.instance.pool)
            .take(1)
            .subscribeOn(SchedulerManager.instance.databaseScheduler)
    }
    
    func getUserFromApi() -> Observable<UserEntity?> {
        return TokenService
            .instance
            .tokenOrErrorObservable()
            .flatMapLatest({ token -> Observable<UserResponse> in
                return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<UserResponse> in
                    let request: Request<UserStrategy> = service.request()
                    return request.observe(())
                })
            })
            .map({ response -> UserEntity in
                return UserEntity(response: response)
            })
            .do(onNext: { user in
                try DatabaseService.instance.pool.write({ db in
                    try user?.insert(db)
                })
            })
            .do(onNext: nil, onError: { (error) in
                print(error)
            })
            .subscribeOn(SchedulerManager.instance.networkScheduler)
    }
}
