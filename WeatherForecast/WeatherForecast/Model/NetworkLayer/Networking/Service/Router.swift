//
//  Routher.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/27.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()

protocol NetworkRouter: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, _ session: URLSession)
    func cancel()
}


class Router<EndPoint: EndPointType>: NetworkRouter {

    private var task: URLSessionDataTask?
    
    func request(_ route: EndPoint, _ session: URLSession) {
        do {
            var request = try self.buildRequest(from: route)
            task = session.dataTask(with: request.url!)
        } catch {
            //
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    private func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10.0)
        request.httpMethod = route.httpMethod.rawValue
        
        do {
            switch route.task {
            case .requestWithUrlParameters(urlParameters: let urlParameters):
                try self.configureParameter(request: &request, urlParameter: urlParameters)
            }
        }
        
        return request
    }
    
    private func configureParameter(request: inout URLRequest, urlParameter: Parameters?) throws {
        do {
            if let urlParameter = urlParameter {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameter)
            }
        } catch {
            error.localizedDescription
        }
    }
}
