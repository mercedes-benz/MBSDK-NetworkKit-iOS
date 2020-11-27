//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

// MARK: - Networking

public protocol Networking {
    
    @discardableResult
    func request<T: Decodable>(router: EndpointRouter,
                               completion: @escaping (Swift.Result<T, MBError>) -> Void) -> URLSessionTask?
    
    @discardableResult
    func request<T: Decodable>(router: EndpointRouter,
                               completion: @escaping (Swift.Result<T?, MBError>) -> Void) -> URLSessionTask?
    
	@discardableResult
    func request<T: Decodable>(router: EndpointRouter,
							   keyPath: String?,
                               completion: @escaping (Swift.Result<T, MBError>) -> Void) -> URLSessionTask?
	
    @discardableResult
    func request<T: Decodable, S: MBErrorConformable>(
        router: EndpointRouter,
        errorType: S.Type,
        completion: @escaping (Swift.Result<T, MBError>) -> Void) -> URLSessionTask?
    
    @discardableResult
    func request(router: EndpointRouter,
                 completion: @escaping (Swift.Result<Void, MBError>) -> Void) -> URLSessionTask?
    
    @discardableResult
    func request(router: EndpointRouter,
                 completion: @escaping (Swift.Result<Data, MBError>) -> Void) -> URLSessionTask?
    
    @discardableResult
    func request<T: Decodable>(router: EndpointRouter,
                                  completion: @escaping (Swift.Result<(value: T, headers: [AnyHashable: Any]), MBError>) -> Void) -> URLSessionTask?
}

public extension Networking {
	
    func request<T: Decodable>(router: EndpointRouter,
							   completion: @escaping (Swift.Result<T, MBError>) -> Void) -> URLSessionTask? {
		return self.request(router: router,
							keyPath: nil,
							completion: completion)
	}
    
    func request<T: Decodable>(router: EndpointRouter,
                               completion: @escaping (Swift.Result<T?, MBError>) -> Void) -> URLSessionTask? {
        
        self.request(router: router) { (result: Result<Data, MBError>) in
            switch result {
            case .success(let data):
                guard let decodedModel = try? JSONDecoder().decode(T.self, from: data) else {
                    completion(.success(nil))
                    return
                }
                
                completion(.success(decodedModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


// MARK: - NetworkingError

protocol NetworkingError {
	
	func errorDecodable<T: MBErrorConformable>(error: Error, parsingType: T.Type) -> MBError
	func parse<T: Decodable>(httpError: HttpError) -> T?
	func parse<T: Decodable>(httpError: HttpError, decoder: JSONDecoder) -> T?
}

extension NetworkingError {
	
	func parse<T: Decodable>(httpError: HttpError) -> T? {
		self.parse(httpError: httpError,
				   decoder: JSONDecoder())
	}
}


// MARK: - NetworkingDownload

public protocol NetworkingDownload {
	
    @discardableResult
	func download(urlRequest: URLRequest, completion: @escaping (Swift.Result<URL, MBError>) -> Void) -> URLSessionTask?
}


// MARK: - NetworkingUpload

public protocol NetworkingUpload {
	
    @discardableResult
	func upload(urlReqeust: URLRequest, data: Data, completion: @escaping (Swift.Result<Void, MBError>) -> Void) -> URLSessionTask?
}
