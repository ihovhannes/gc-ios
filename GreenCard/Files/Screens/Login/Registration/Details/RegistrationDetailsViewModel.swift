//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift

class RegistrationDetailsViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate(set) lazy var userRegistration = PublishSubject<(cardNumber: String, cardCode: String, firstName: String, gender: String, birthDate: String, phone: String, email: String, agreement: Bool)>()

    lazy var routingObservable = Observable<Routing>.never()

    var phoneNumber: String = ""

    required init() {
        let sendObservable = rx_sendUserRegistrationObservable(userRegistrationObservable: userRegistration.asObservable())

        routingObservable = rx_transformUserRegistrationObservable(sendUserRegistrationObservable: sendObservable)
    }

}

fileprivate extension RegistrationDetailsViewModel {

    func rx_sendUserRegistrationObservable(userRegistrationObservable: Observable<(cardNumber: String, cardCode: String, firstName: String, gender: String, birthDate: String, phone: String, email: String, agreement: Bool)>) -> Observable<UserRegistrationResponse> {
        return userRegistrationObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .do(onNext: {[unowned self] arg in self.phoneNumber = arg.phone})
                .flatMapLatest { args -> Observable<UserRegistrationResponse> in
                    return Observable.using({ NetworkService(token: nil) }, observableFactory: { service -> Observable<UserRegistrationResponse> in
                        let request: Request<UserRegistrationStrategy> = service.request()
                        return request.observe((
                                (
                                        cardNumber: args.cardNumber,
                                        cardCode: args.cardCode,
                                        firstName: args.firstName,
                                        gender: args.gender,
                                        birthDate: args.birthDate,
                                        phone: args.phone,
                                        email: args.email,
                                        agreement: args.agreement
                                )
                        ))
                    })
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transformUserRegistrationObservable(sendUserRegistrationObservable: Observable<UserRegistrationResponse>) -> Observable<Routing> {
        return sendUserRegistrationObservable
                .map { [weak self] response in
                    if response.isSuccess {
                        return Routing.toastView(msg: "Смс с временным паролем отправлена на номер +\(self?.phoneNumber ?? "" )")
                    }

                    if let errors = response.errors {
                        if let error = errors.first {
                            return Routing.alertView(title: "Ошибка.", body: error, repeatCallback: nil)
                        }
                        return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)
                    }

                    return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)
                }
                .catchError({ error -> Observable<Routing> in
                    if let greenError = error as? GreencardError {
                        switch greenError {
                        case .inResponse(let msg):
                            return Observable.just(Routing.alertView(title: "Ошибка авторизации.", body: msg, repeatCallback: nil))
                        case .network:
                            return Observable.just(Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: nil))
                        case .unauthorized, .unknown:
                            return Observable.just(Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil))

                        }
                    }
                    return Observable.just(Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil))
                })
    }

}

