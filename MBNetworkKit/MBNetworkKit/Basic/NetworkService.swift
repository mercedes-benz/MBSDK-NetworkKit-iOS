//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

/// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
public class NetworkService: Networking {
    
    var sessionManager: Session
    
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
    public convenience init() {
        
        let config = SessionManagerConfig()
        let factory = SessionManagerFactory(config: config)
        
        self.init(sessionManagerBuilder: factory)
    }

    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
    public init(sessionManagerBuilder: SessionManagerBuilder) {
        self.sessionManager = sessionManagerBuilder.build()
    }
    
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
	public func request<T: Decodable>(router: EndpointRouter, keyPath: String?, completion: @escaping (Swift.Result<T, MBError>) -> Void) -> URLSessionTask? {
		return self.rq(router: router, completion: completion)?
			.responseDecodable(keyPath: keyPath, completionHandler: self.dataResponseHandler(errorType: APIError.self, completion: completion))
			.task
	}
    
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
    public func request<T: Decodable, S: MBErrorConformable>(
        router: EndpointRouter,
        errorType: S.Type,
        completion: @escaping (Swift.Result<T, MBError>) -> Void) -> URLSessionTask? {
        
		return self.rq(router: router, completion: completion)?
            .responseDecodable(completionHandler: self.dataResponseHandler(errorType: errorType, completion: completion))
            .task
    }
     
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
    public func request(router: EndpointRouter,
                        completion: @escaping (Swift.Result<Void, MBError>) -> Void) -> URLSessionTask? {

		return self.rq(router: router, completion: completion)?
			.response(completionHandler: self.defaultDataResponseHandler(completion: completion))
            .task
    }
    
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
    public func request(router: EndpointRouter,
                        completion: @escaping (Swift.Result<Data, MBError>) -> Void) -> URLSessionTask? {
        
		return self.rq(router: router, completion: completion)?
            .responseData(completionHandler: self.dataResponseHandlerIgnoringNilData(errorType: APIError.self, completion: completion))
            .task
    }
    
    
    public func request<T: Decodable>(router: EndpointRouter,
                               completion: @escaping (Swift.Result<(value: T, headers: [AnyHashable: Any]), MBError>) -> Void) -> URLSessionTask? {
        
		return self.rq(router: router, completion: completion)?
            .responseDecodable(completionHandler: self.dataResponseHandler(errorType: APIError.self, completion: completion))
            .task
    }
    
	
    // MARK: - Private
    
    func dataResponseHandler<T, S: MBErrorConformable>(errorType: S.Type, completion: @escaping (Swift.Result<(value: T, headers: [AnyHashable: Any]), MBError>) -> Void) -> (DataResponse<T, AFError>) -> Void {
        
        return { response in
            switch response.result {
            case .failure(let error):
                let err = self.errorDecodable(error: error, parsingType: errorType)
                completion(Swift.Result.failure(err))
            case .success(let value):
                let headers = response.response?.allHeaderFields
                completion(Swift.Result.success((value, headers ?? [:])))
            }
        }
    }
    
    func dataResponseHandlerIgnoringNilData<S: MBErrorConformable>(errorType: S.Type, completion: @escaping (Swift.Result<Data, MBError>) -> Void) -> (DataResponse<Data, AFError>) -> Void {
        return { response in
            switch response.result {
            case .failure(let error):
                switch error {
                case .responseSerializationFailed(reason: .inputDataNilOrZeroLength):
                    completion(Swift.Result.success(Data()))
                default:
                    let err = self.errorDecodable(error: error, parsingType: errorType)
                    completion(Swift.Result.failure(err))
                }
            case .success(let value):
                completion(Swift.Result.success(value))
            }
        }
    }
    
	func dataResponseHandler<T, S: MBErrorConformable>(errorType: S.Type, completion: @escaping (Swift.Result<T, MBError>) -> Void) -> (DataResponse<T, AFError>) -> Void {
        return { response in
            switch response.result {
            case .failure(let error):
                let err = self.errorDecodable(error: error, parsingType: errorType)
                completion(Swift.Result.failure(err))
            case .success(let value):
                completion(Swift.Result.success(value))
            }
        }
    }
    
    func dataResponseHandler<T, S: MBErrorConformable>(errorType: S.Type, completion: @escaping (Swift.Result<(value: T, eTag: String?), MBError>) -> Void) -> (DataResponse<T, AFError>) -> Void {
        return { response in
            switch response.result {
            case .failure(let error):
                let err = self.errorDecodable(error: error, parsingType: errorType)
                completion(Swift.Result.failure(err))
            case .success(let value):
                let eTag = response.response?.allHeaderFields["Etag"] as? String
                completion(Swift.Result.success((value, eTag)))
            }
        }
    }
    
	private func defaultDataResponseHandler(completion: @escaping (Swift.Result<Void, MBError>) -> Void) -> (AFDataResponse<Data?>) -> Void {
        return { result in
            if let error = result.error {
                let err = self.errorDecodable(error: error, parsingType: APIError.self)
                completion(Swift.Result.failure(err))
            } else {
                completion(Swift.Result.success(()))
            }
        }
    }
    
	func rq<T>(router: EndpointRouter, completion: @escaping (Swift.Result<T, MBError>) -> Void) -> DataRequest? {
        
        guard let urlRequest = router.urlRequest else {
            completion(.failure(self.invalidUrlError(router: router)))
            return nil
        }
    
        NetworkServiceLogHelper.log(request: urlRequest, router: router)
        
		return self.sessionManager
            .request(urlRequest)
			.validate(self.validateHttpResponse())
    }
	
    private func invalidUrlError(router: EndpointRouter) -> MBError {
        return MBError(description: nil, type: .network(.invalidUrl))
    }

	func validateHttpResponse() -> DataRequest.Validation {
        return { request, response, data -> Request.ValidationResult in
            NetworkServiceLogHelper.log(response: response, data: data)
            
			return self.validationResult(request: request,
										 response: response,
										 data: data)
        }
    }
	
	func validationResult(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
		switch response.statusCode {
		case 200..<400:
			return .success(())
			
		default:
			let httpError = HttpError.map(statusCode: response.statusCode, data: data)
			return .failure(httpError)
		}
	}
}
