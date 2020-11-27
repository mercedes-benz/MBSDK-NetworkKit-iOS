//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

extension NetworkLayer {
	
	// MARK: - Decodable Object
	
    /// Create and fire a request and parse the response in decodable objects/models for a given EndpointRouter-object
    ///
    /// Objects/models have to conform the Decodable-protocol. Supports single objects, arrays, etc.
    ///
    /// - Parameters:
    ///   - router: EndpointRouter object
    ///   - sessionManager: Alamofire's Session (optional)
    ///   - keyPath: (default == nil)
    ///   - decoder: custom JSONDecoder if needed (default == JSONDecoder())
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a decodable object
    /// - Returns: URLSessionTask (optional, discardable)
	@discardableResult
	public static func requestDecodable<T: Decodable>(router: EndpointRouter,
                                                      sessionManager: Session? = nil,
                                                      keyPath: String? = nil,
                                                      decoder: JSONDecoder = JSONDecoder(),
													  queue: DispatchQueue = .main,
                                                      completion: @escaping (NetworkResult<T>) -> Void) -> URLSessionTask? {
		
		guard let urlRequest = router.urlRequest else {
			
			completion(NetworkResult<T>.failure(self.invalidUrlError(router: router)))
			return nil
		}
		
		return self.requestDecodable(urlRequest: urlRequest, sessionManager: sessionManager, keyPath: keyPath, decoder: decoder, queue: queue, completion: completion)
	}
	
    
    /// Create and fire a request and parse the response in decodable objects/models for a given url
    ///
    /// Objects/models have to conform the Decodable-protocol. Supports single objects, arrays, etc.
    ///
    /// - Parameters:
    ///   - url: The URL
    ///   - sessionManager: Alamofire's Session (optional)
    ///   - method: HTTPMethodType  (default == .get)
    ///   - parameters: Dictionary of request-parameters (default == nil)
    ///   - encoding: ParameterEncodingType (default == .url)
    ///   - headers: Dictionary of request-header parameters (default == nil)
    ///   - keyPath: (default == nil)
    ///   - decoder: Custom JSONDecoder if needed (default == JSONDecoder())
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a decodable object
    /// - Returns: URLSessionTask (optional, discardable)
	@discardableResult
	public static func requestDecodable<T: Decodable>(url: URL,
                                                      sessionManager: Session? = nil,
                                                      method: HTTPMethodType = .get,
                                                      parameters: [String: Any]? = nil,
                                                      encoding: ParameterEncodingType = .url(type: .standard),
                                                      headers: [String: String]? = nil,
                                                      keyPath: String? = nil,
                                                      decoder: JSONDecoder = JSONDecoder(),
													  queue: DispatchQueue = .main,
                                                      completion: @escaping (NetworkResult<T>) -> Void) -> URLSessionTask? {
		
		let request = self.request(url: url, sessionManager: sessionManager, method: method, parameters: parameters, encoding: encoding, headers: headers)
			.responseDecodable(decoder: decoder, keyPath: keyPath, queue: queue) { (response: DataResponse<T, AFError>) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
	
    
    /// Create and fire a request and parse the response in decodable objects/models for a given URLRequest-object
    ///
    /// Objects/models have to conform the Decodable-protocol. Supports single objects, arrays, etc.
    ///
    /// - Parameters:
    ///   - urlRequest: Instance of URLRequest
    ///   - sessionManager: Alamofire's Session (optional)
    ///   - keyPath: (default == nil)
    ///   - decoder: Custom JSONDecoder if needed (default == JSONDecoder())
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a decodable object
    /// - Returns: URLSessionTask (optional, discardable)
	@discardableResult
	public static func requestDecodable<T: Decodable>(urlRequest: URLRequest,
                                                      sessionManager: Session? = nil,
                                                      keyPath: String? = nil,
                                                      decoder: JSONDecoder = JSONDecoder(),
													  queue: DispatchQueue = .main,
                                                      completion: @escaping (NetworkResult<T>) -> Void) -> URLSessionTask? {
		
		let request = self.request(urlRequest: urlRequest, sessionManager: sessionManager)
			.responseDecodable(decoder: decoder, keyPath: keyPath, queue: queue) { (response: DataResponse<T, AFError>) in

				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
}
