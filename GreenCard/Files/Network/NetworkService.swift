//
//  NetworkService.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 26.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Result
import RxSwift
import Moya

protocol NetworkStrategy: Strategy {
    
    static func api(_ object: StrategyObject) -> Api
    static func error(_ error: MoyaError?) -> Observable<StrategyResult>
    static func map(_ data: Data, object: StrategyObject?) -> StrategyResult
}

class NetworkService: Disposable {
    
    let token: String?
    
    init(token: String? = nil) {
        self.token = token
    }
    
    fileprivate lazy var provider: MoyaProvider<Api> = self.getApiProvider(token: self.token, logs: true)
    
    func request<S: NetworkStrategy>() -> Request<S> {
        return Request<S>(provider)
    }
    
    func dispose() {
        //
    }
}

private extension NetworkService {
    
    private enum MoyaPluginType {
        case none
        case debug
    }
    
    func getApiProvider(token: String?, logs: Bool) -> MoyaProvider<Api> {
        guard let token = token else {
            return MoyaProvider<Api>(plugins: logs ? [RequestPluginType()] : [])
        }
        let endpointClosure = { (target: Api) -> Endpoint<Api> in
            let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            let authorization = "Token \(token)"
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": authorization])
        }
        return MoyaProvider<Api>(endpointClosure: endpointClosure,
                                 manager: DefaultAlamofireManager.sharedManager,
                                 plugins: logs ? [RequestPluginType()] : [])
    }
    
    private static func plugins(_ forType: MoyaPluginType) -> [PluginType] {
        switch forType {
        case .none:                 return []
        case .debug:                return [NetworkLoggerPlugin(verbose: true)]
        }
    }
}

class Request<S: NetworkStrategy> {
    
    fileprivate weak var provider: MoyaProvider<Api>?
    
    fileprivate init(_ provider: MoyaProvider<Api>) {
        self.provider = provider
    }
    
    fileprivate func with(target: Api, object: S.StrategyObject? = nil) -> Observable<S.StrategyResult> {
        guard let provider = provider else { return S.error(nil) }
        return provider.rx.request(target)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .asObservable()
            .mapError({ (moyaError) -> Error in
                return GreencardError.network
            })
            .map({ (response: Response) -> S.StrategyResult in
                return S.map(response.data, object: object)
            })
    }
}

extension Request {
    
    func observe(_ object: S.StrategyObject) -> Observable<S.StrategyResult> {
        return with(target: S.api(object), object: object)
    }
}

struct RequestPluginType: PluginType {
    
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ seperator: String, _ terminator: String, _ items: Any...) -> Void
    fileprivate let responseDataFormatter: ((Data) -> (Data))?
    fileprivate let onlyRequest: Bool
    
    /// If true, also logs response body data.
    let verbose: Bool
    let cURL: Bool
    
    init(onlyRequest: Bool = false, verbose: Bool = false, cURL: Bool = false, output: @escaping (_ seperator: String, _ terminator: String, _ items: Any...) -> Void
        = RequestPluginType.reversedPrint, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.verbose = verbose
        self.output = output
        self.responseDataFormatter = responseDataFormatter
        self.onlyRequest = onlyRequest
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        if let request = request as? CustomDebugStringConvertible, cURL {
            output(separator, terminator, request.debugDescription)
        } else {
            outputItems(logNetworkRequest(request.request as URLRequest?))
        }
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard onlyRequest == false else { return }
        if case .success(let response) = result {
            outputItems(logNetworkResponse(response.response, data: response.data, target: target))
        } else {
            outputItems(logNetworkResponse(nil, data: nil, target: target))
        }
    }
    
    fileprivate func outputItems(_ items: [String]) {
        if verbose {
            items.forEach { output(separator, terminator, $0) }
        } else {
            output(separator, terminator, items)
        }
    }
}

private extension RequestPluginType {
    
    func format(_ identifier: String, message: String) -> String {
        return "---> \(identifier): \(message)"
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> [String] {
        var output = [String]()
        output += [format("Request", message: request?.description ?? "(invalid request)")]
        if let headers = request?.allHTTPHeaderFields {
            output += [format("Headers", message: headers.description)]
        }
        if let bodyStream = request?.httpBodyStream {
            output += [format("Request Body Stream", message: bodyStream.description)]
        }
        if let httpMethod = request?.httpMethod {
            output += [format("Method", message: httpMethod)]
        }
        if let body = request?.httpBody {
            if let stringOutput = String(data: body, encoding: .utf8) {
                output += [format("Body", message: stringOutput)]
            }
        }
        output += [format("TimeStamp", message: "\(Date().timeIntervalSince1970)")]
        return output
    }
    
    func logNetworkResponse(_ response: URLResponse?, data: Data?, target: TargetType) -> [String] {
        guard let response = response else {
            return [format("Response", message: "Received empty network response for \(target).")]
        }
        var output = [String]()
        output += [format("Response", message: response.description)]
        if let data = data, verbose == true {
            if let stringData = String(data: responseDataFormatter?(data) ?? data, encoding: String.Encoding.utf8) {
                output += [stringData]
            }
        }
        output += [format("TimeStamp", message: "\(Date().timeIntervalSince1970)")]
        return output
    }
}

fileprivate extension RequestPluginType {
    
    static func reversedPrint(seperator: String, terminator: String, items: Any...) {
        print(items, separator: seperator, terminator: terminator)
    }
}
