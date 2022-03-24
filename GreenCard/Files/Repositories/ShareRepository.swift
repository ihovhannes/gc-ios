//
//  ShareRepository.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 10.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import RxSwift
import GRDB

class ShareRepository {
    
    static let lifetime: TimeInterval = 24 * 60 * 60
    static let pageSize = 10
    
    func getShares(page: Int, refresh: Bool) -> Observable<([ShareEntity], Int)> {
        if (Reachability.isConnectedToNetwork()) {
            if (refresh) {
                return getSharesFromApi(page: page)
            }
            return didExceedLifetime(page: page)
                .flatMapLatest({ didExceed -> Observable<([ShareEntity], Int)> in
                    if (didExceed) {
                        return self.getSharesFromApi(page: page)
                    }
                    return self.getSharesFromDb(page: page)
                })
        }
        return Observable.error(GreencardError.network)
    }
    
    func didExceedLifetime(page: Int) -> Observable<Bool> {
        return ShareEntity
            .limit(ShareRepository.pageSize, offset: (page - 1) * ShareRepository.pageSize)
            .rx
            .fetchAll(in: DatabaseService.instance.pool)
            .take(1)
            .errorOnEmpty()
            .flatMapLatest({ shares -> Observable<ShareEntity> in
                return Observable.from(shares)
            })
            .map({ share -> Date in
                return share.updateDate
            })
            .toArray()
            .map({ dates -> Date in
                return dates.min() ?? Date(timeIntervalSince1970: 0.0)
            })
            .map({ date -> Bool in
                return Date().timeIntervalSince(date) > ShareRepository.lifetime
            })
            .catchErrorJustReturn(true)
            .subscribeOn(SchedulerManager.instance.databaseScheduler)
    }
    
    func getSharesFromDb(page: Int) -> Observable<([ShareEntity], Int)> {
        let rowid = Column("rowid")
        let sharesObservable = ShareEntity
            .order(rowid)
            .limit(ShareRepository.pageSize, offset: (page - 1) * ShareRepository.pageSize)
            .rx
            .fetchAll(in: DatabaseService.instance.pool)
        let countId = Column("id")
        let countObservable = CountEntity
            .filter(countId == CountEntity.shareCountId)
            .rx
            .fetchOne(in: DatabaseService.instance.pool)
            .replaceNilWith(CountEntity(id: CountEntity.shareCountId, count: 0))
        
        return Observable.combineLatest(
            sharesObservable,
            countObservable,
            resultSelector: { (shares, count) -> ([ShareEntity], Int) in
                return (shares, count.count)
            })
            .subscribeOn(SchedulerManager.instance.databaseScheduler)
    }
    
    func getSharesFromApi(page: Int) -> Observable<([ShareEntity], Int)> {
        let responseObservable = TokenService
            .instance
            .tokenOrErrorObservable()
            .flatMapLatest({ token -> Observable<OfferListResponse> in
                return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<OfferListResponse> in
                    let request: Request<OfferListStrategy> = service.request()
                    return request.observe(page)
                })
            })
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
        
        let sharesObservable = responseObservable
            .map({ response -> [ShareResponse?] in
                return response.results ?? []
            })
            .flatMapLatest({ offers -> Observable<ShareResponse?> in
                return Observable.from(offers)
            })
            .errorOnNil(GreencardError.unknown)
            .map({ item -> ShareEntity in
                return ShareEntity(responseItem: item)
            })
            .toArray()
        
        let countObservable = responseObservable
            .map({ response -> Int in
                return response.count ?? 0
            })
        
        return Observable
            .combineLatest(sharesObservable, countObservable, resultSelector: { (shares, count) -> ([ShareEntity], Int) in
                return (shares, count)
            })
            .observeOn(SchedulerManager.instance.databaseScheduler)
            .do(onNext: { (shares, count) in
                try DatabaseService.instance.pool.writeInTransaction { db -> Database.TransactionCompletion in
                    do {
                        if (page == 1) {
                            try print(String(ShareEntity.deleteAll(db)) + " records deleted")
                        }
                        try shares.forEach({ share in
                            try share.insert(db)
                        })
                        try CountEntity(id: CountEntity.shareCountId, count: count).insert(db)
                    } catch {
                        print("Unsuccessful insert")
                        return Database.TransactionCompletion.rollback
                    }
                    print("Successful insert")
                    return Database.TransactionCompletion.commit
                }
            })
            .subscribeOn(SchedulerManager.instance.networkScheduler)
    }
    
    func getShare(id: Int64, isArchive: Bool ) -> Observable<ShareEntity?> {
        return getShareFromDb(id: id)
            .flatMapLatest({ [unowned self] shareEntity -> Observable<ShareEntity?> in
                guard let shareEntity = shareEntity else {
                    return self.getShareFromApi(id: id, isArchive: isArchive)
                }
                guard shareEntity.content != nil && shareEntity.content!.isNotEmpty else {
                    return self.getShareFromApi(id: id, isArchive: isArchive)
                }
                guard Date().timeIntervalSince(shareEntity.updateDate) <= ShareRepository.lifetime else {
                    return self.getShareFromApi(id: id, isArchive: isArchive)
                }
                return Observable.just(shareEntity)
            })
    }
    
    func getShareFromDb(id: Int64) -> Observable<ShareEntity?> {
        let idColumn = Column("id")
        return ShareEntity
            .filter(idColumn == id)
            .rx
            .fetchOne(in: DatabaseService.instance.pool)
            .take(1)
            .subscribeOn(SchedulerManager.instance.databaseScheduler)
    }
    
    func getShareFromApi(id: Int64, isArchive: Bool) -> Observable<ShareEntity?> {
        return TokenService
            .instance
            .tokenOrErrorObservable()
            .flatMapLatest({ (token: String) -> Observable<ShareResponse> in
                return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<ShareResponse> in
                    let request: Request<ShareStrategy> = service.request()
                    return request.observe((shareId: id, isArchive: isArchive))
                })
            })
            .observeOn(SchedulerManager.instance.databaseScheduler)
            .map({ response -> ShareEntity in
                return ShareEntity(responseItem: response)
            })
            .do(onNext: { share in
                try DatabaseService.instance.pool.writeInTransaction { db -> Database.TransactionCompletion in
                    do {
                        try share?.insert(db)
                        return Database.TransactionCompletion.commit
                    } catch {
                        print("Unsuccessful insert")
                        return Database.TransactionCompletion.rollback
                    }
                }
            })
            .subscribeOn(SchedulerManager.instance.networkScheduler)
    }
    
    deinit {
        print("DEinit")
    }
}
