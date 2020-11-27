//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

public class NetworkLayer {
	
	// MARK: - Data

    /// Create a data-request with a given EndpointRouter-object
    ///
    /// - Parameters:
    ///   - router: EndpointRouter object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a data object
    /// - Returns: URLSessionTask object (optional, discardable)
    @discardableResult
    public static func requestData(router: EndpointRouter,
                                   sessionManager: Session? = nil,
                                   queue: DispatchQueue = .main,
                                   completion: @escaping (NetworkResult<Data>) -> Void) -> URLSessionTask? {

        guard let urlRequest = router.urlRequest else {

            completion(NetworkResult<Data>.failure(self.invalidUrlError(router: router)))
            return nil
        }

        return self.requestData(urlRequest: urlRequest, sessionManager: sessionManager, queue: queue, completion: completion)
    }
    
    /// Create a data-request with a given url
    ///
    /// - Parameters:
    ///   - url: The Url
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - method: HTTPMethodType  (default == .get)
    ///   - parameters: Dictionary with request parameters (default == nil)
    ///   - encoding: ParameterEncodingType (default == .url)
    ///   - headers: Dictionary with request-header parameters (default == nil)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a data object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestData(url: URL,
                                   sessionManager: Session? = nil,
                                   method: HTTPMethodType = .get,
                                   parameters: [String: Any]? = nil,
                                   encoding: ParameterEncodingType = .url(type: .standard),
                                   headers: [String: String]? = nil,
                                   queue: DispatchQueue = .main,
                                   completion: @escaping (NetworkResult<Data>) -> Void) -> URLSessionTask? {
		
		let request = self.request(url: url, sessionManager: sessionManager, method: method, parameters: parameters, encoding: encoding, headers: headers)
			.responseData(queue: queue) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
    
    /// Create a data-request with a given url
    ///
    /// - Parameters:
    ///   - urlRequest: URLRequest object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a data object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestData(urlRequest: URLRequest,
                                   sessionManager: Session? = nil,
                                   queue: DispatchQueue = .main,
                                   completion: @escaping (NetworkResult<Data>) -> Void) -> URLSessionTask? {
		
		let request = self.request(urlRequest: urlRequest, sessionManager: sessionManager)
            .responseData(queue: queue) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
	
	
	// MARK: - Head
	
    /// Create a HEAD-request with a given EndpointRouter object
    ///
    /// - Parameters:
    ///   - router: EndpointRouter object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - completion: NetworkResult with a HTTPURLResponse object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestHead(router: EndpointRouter,
                                   sessionManager: Session? = nil,
                                   completion: @escaping (NetworkResult<HTTPURLResponse>) -> Void) -> URLSessionTask? {
		
		guard let urlRequest = router.urlRequest else {
			
			completion(NetworkResult<HTTPURLResponse>.failure(self.invalidUrlError(router: router)))
			return nil
		}
		
		return self.requestHead(urlRequest: urlRequest, sessionManager: sessionManager, completion: completion)
	}
    
    /// Create a HEAD-request with a given url
    ///
    /// - Parameters:
    ///   - url: The URL
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - parameters: Dictionary with request parameters (default == nil)
    ///   - encoding: ParameterEncodingType (default == .url)
    ///   - headers: Dictionary with request-header parameters (default == nil)
    ///   - completion: NetworkResult with a HTTPURLResponse object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestHead(url: URL,
                                   sessionManager: Session? = nil,
                                   parameters: [String: Any]? = nil,
                                   encoding: ParameterEncodingType = .url(type: .standard),
                                   headers: [String: String]? = nil,
                                   completion: @escaping (NetworkResult<HTTPURLResponse>) -> Void) -> URLSessionTask? {
		
		let request = self.request(url: url, sessionManager: sessionManager, method: .head, parameters: parameters, encoding: encoding, headers: headers)
			.response { (response) in
				self.processHead(response: response, completion: completion)
		}
		
		return request.task
	}
    
    /// Create a HEAD-request with a given URLRequest-object
    ///
    /// - Parameters:
    ///   - urlRequest: URLRequest object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - completion: NetworkResult with a HTTPURLResponse object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestHead(urlRequest: URLRequest,
                                   sessionManager: Session? = nil,
                                   completion: @escaping (NetworkResult<HTTPURLResponse>) -> Void) -> URLSessionTask? {
		
		let request = self.request(urlRequest: urlRequest, sessionManager: sessionManager)
			.response { (response) in
			self.processHead(response: response, completion: completion)
		}
		
		return request.task
	}
	
	
	// MARK: - JSON
	
    /// Request a JSON with a given EndpointRouter object
    ///
    /// - Parameters:
    ///   - router: EndpointRouter object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - options: JSONSerialization.ReadingOptions (default == .allowFragments)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with an object of type Any
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestJSON(router: EndpointRouter,
                                   sessionManager: Session? = nil,
                                   options: JSONSerialization.ReadingOptions = .allowFragments,
                                   queue: DispatchQueue = .main,
                                   completion: @escaping (NetworkResult<Any>) -> Void) -> URLSessionTask? {
		
		guard let urlRequest = router.urlRequest else {
			
			completion(NetworkResult<Any>.failure(self.invalidUrlError(router: router)))
			return nil
		}
		
		return self.requestJSON(urlRequest: urlRequest, sessionManager: sessionManager, options: options, queue: queue, completion: completion)
	}
    
    /// Request a JSON with a given url
    ///
    /// - Parameters:
    ///   - url: The URL
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - method: HTTPMethodType (default == .get)
    ///   - parameters: Dictionary of request-parameters (default == nil)
    ///   - encoding: ParameterEncodingType (default == .url)
    ///   - headers: Dictionary of request-header parameters (default == nil)
    ///   - options: JSONSerialization.ReadingOptions (default == .allowFragments)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with an object of type Any
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestJSON(url: URL,
                                   sessionManager: Session? = nil,
                                   method: HTTPMethodType = .get,
                                   parameters: [String: Any]? = nil,
                                   encoding: ParameterEncodingType = .url(type: .standard),
                                   headers: [String: String]? = nil,
                                   options: JSONSerialization.ReadingOptions = .allowFragments,
                                   queue: DispatchQueue = .main,
                                   completion: @escaping (NetworkResult<Any>) -> Void) -> URLSessionTask? {
		
		let request = self.request(url: url, sessionManager: sessionManager, method: method, parameters: parameters, encoding: encoding, headers: headers)
			.responseJSON(queue: queue, options: options) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
    
    /// Request a JSON with a given URLRequest object
    ///
    /// - Parameters:
    ///   - urlRequest: URLRequest object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - options: JSONSerialization.ReadingOptions (default == .allowFragments)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with an object of type Any
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestJSON(urlRequest: URLRequest,
                                   sessionManager: Session? = nil,
                                   options: JSONSerialization.ReadingOptions = .allowFragments,
                                   queue: DispatchQueue = .main,
                                   completion: @escaping (NetworkResult<Any>) -> Void) -> URLSessionTask? {
		
		let request = self.request(urlRequest: urlRequest, sessionManager: sessionManager)
			.responseJSON(queue: queue, options: options) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
	
	
	// MARK: - String
    
    /// Request a string with given EndpointRouter object
    ///
    /// - Parameters:
    ///   - router: EndpointRouter object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - encoding: String encoding (default == nil)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a String object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestString(router: EndpointRouter,
                                     sessionManager: Session? = nil,
                                     encoding: String.Encoding? = nil,
                                     queue: DispatchQueue = .main,
                                     completion: @escaping (NetworkResult<String>) -> Void) -> URLSessionTask? {
		
		guard let urlRequest = router.urlRequest else {
			
			completion(NetworkResult<String>.failure(self.invalidUrlError(router: router)))
			return nil
		}
		
		return self.requestString(urlRequest: urlRequest, sessionManager: sessionManager, stringEncoding: encoding, queue: queue, completion: completion)
	}
    
    /// Request a string with given url
    ///
    /// - Parameters:
    ///   - url: The URL
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - method: HTTPMethodType (default == .get)
    ///   - parameters: Dictionary of request-parameters (default == nil)
    ///   - encoding: ParameterEncodingType (default == .url)
    ///   - headers: Dictionary of request-header parameters (default == nil)
    ///   - stringEncoding: String encoding (default == nil)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a String object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestString(url: URL,
                                     sessionManager: Session? = nil,
                                     method: HTTPMethodType = .get,
                                     parameters: [String: Any]? = nil,
                                     encoding: ParameterEncodingType = .url(type: .standard),
                                     headers: [String: String]? = nil,
                                     stringEncoding: String.Encoding? = nil,
									 queue: DispatchQueue = .main,
                                     completion: @escaping (NetworkResult<String>) -> Void) -> URLSessionTask? {
		
		let request = self.request(url: url, sessionManager: sessionManager, method: method, parameters: parameters, encoding: encoding, headers: headers)
			.responseString(queue: queue, encoding: stringEncoding) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
    
    /// Request a string with given URLRequest object
    ///
    /// - Parameters:
    ///   - urlRequest: URLRequest object
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - stringEncoding: tring encoding (default == nil)
    ///   - queue: DispatchQueue (default == nil)
    ///   - completion: NetworkResult with a String object
    /// - Returns: URLSessionTask object (optional, discardable)
	@discardableResult
	public static func requestString(urlRequest: URLRequest,
                                     sessionManager: Session? = nil,
                                     stringEncoding: String.Encoding? = nil,
                                     queue: DispatchQueue = .main,
                                     completion: @escaping (NetworkResult<String>) -> Void) -> URLSessionTask? {
		
		let request = self.request(urlRequest: urlRequest, sessionManager: sessionManager)
			.responseString(queue: queue, encoding: stringEncoding) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(NetworkResult.failure(error))
				case .success(let value):	completion(NetworkResult.success(value))
				}
			}
		
		return request.task
	}
    
	
    // MARK: - Alamofire wrapper
    
    public static func download(urlRequest: URLRequest,
                                sessionManager: Session? = nil) -> DownloadRequest {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        guard let sessionManager = sessionManager else {
            return AF.download(urlRequest, to: destination)
                .validate { (request, response, _) -> Request.ValidationResult in
                    return self.validation(request: request, response: response, data: nil)
            }
        }
        
        return sessionManager.download(urlRequest, to: destination)
            .validate { (request, response, _) -> Request.ValidationResult in
                return self.validation(request: request, response: response, data: nil)
        }
    }
    
    public static func request(urlRequest: URLRequest, sessionManager: Session?) -> DataRequest {
        
        guard let sessionManager = sessionManager else {
            return AF.request(urlRequest)
                .validate { (request, response, data) -> Request.ValidationResult in
                    return self.validation(request: request, response: response, data: data)
            }
        }
        
        return sessionManager.request(urlRequest)
            .validate { (request, response, data) -> Request.ValidationResult in
                return self.validation(request: request, response: response, data: data)
        }
    }
    
    // swiftlint:disable function_parameter_count
	static func request(url: URL,
						sessionManager: Session?,
						method: HTTPMethodType,
						parameters: [String: Any]?,
						encoding: ParameterEncodingType,
						headers: [String: String]?) -> DataRequest {
        
		let httpMethod = HTTPMethod(rawValue: method.rawValue.uppercased())
        var encoder: ParameterEncoding {
            switch encoding {
            case .json:		return JSONEncoding.default
            case .url:		return URLEncoding.default
            }
        }
        
        guard let sessionManager = sessionManager else {
            return AF.request(url, method: httpMethod, parameters: parameters, encoding: encoder, headers: HTTPHeaders(headers ?? [:]))
                .validate { (request, response, data) -> Request.ValidationResult in
                    return self.validation(request: request, response: response, data: data)
            }
        }
        
        return sessionManager.request(url, method: httpMethod, parameters: parameters, encoding: encoder, headers: HTTPHeaders(headers ?? [:]))
            .validate { (request, response, data) -> Request.ValidationResult in
                return self.validation(request: request, response: response, data: data)
        }
    }
    // swiftlint:enable function_parameter_count
    
    public static func validation(request: URLRequest?,
                           response: HTTPURLResponse,
                           data: Data?) -> Request.ValidationResult {
        
        switch response.statusCode {
        case 200..<400:
            return .success(())
            
        default:
            let httpError = HttpError.map(statusCode: response.statusCode, data: data)
            return .failure(httpError)
        }
    }
    
    
	// MARK: - Helper
	
	static func invalidUrlError(router: EndpointRouter) -> Error {
		return AFError.invalidURL(url: router.baseURL)
	}
	
    
	private static func processHead(response: AFDataResponse<Data?>, completion: @escaping (NetworkResult<HTTPURLResponse>) -> Void) {

		guard let urlResponse = response.response else {

			if let error = response.error {
				completion(NetworkResult.failure(error))
			}
			return
		}

		completion(NetworkResult.success(urlResponse))
	}
}
