//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

extension DataRequest {
    
    @discardableResult
    func responseDecodable<T: Decodable>(decoder: JSONDecoder = JSONDecoder(),
                                         keyPath: String? = nil,
										 queue: DispatchQueue = .main,
                                         completionHandler: @escaping (DataResponse<T, AFError>) -> Void) -> Self {
		return self.response(queue: queue,
							 responseSerializer: KeyPathDataResponseSerializer<T>(keyPath: keyPath,
																				  decoder: decoder),
							 completionHandler: completionHandler)
    }
}


// MARK: - KeyPathDataResponseSerializer

fileprivate final class KeyPathDataResponseSerializer<T: Decodable> {
	
	// Properties
	
	private let decoder: JSONDecoder
	private let keyPath: String?
	
	
	// MARK: - Init
	
	init(keyPath: String?, decoder: JSONDecoder = JSONDecoder()) {
		
		self.decoder = decoder
		self.keyPath = keyPath
	}
}


// MARK: - DataResponseSerializerProtocol

extension KeyPathDataResponseSerializer: DataResponseSerializerProtocol {
	
	func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
		
		if let error = error {
			throw error
		}
		
		if let keyPath = self.keyPath,
		   keyPath.isEmpty == false {
			
			let json = try JSONResponseSerializer().serialize(request: nil,
															  response: response,
															  data: data,
															  error: nil)
			
			if let nestedJson = (json as AnyObject).value(forKeyPath: keyPath) {
				
				guard JSONSerialization.isValidJSONObject(nestedJson) else {
					throw AFError.responseSerializationFailed(reason: .decodingFailed(error: DecodableError.invalidJson))
				}
				
				let data = try JSONSerialization.data(withJSONObject: nestedJson)
				return try decoder.decode(T.self, from: data)
			} else {
				throw AFError.responseSerializationFailed(reason: .decodingFailed(error: DecodableError.invalidKeyPath(keyPath: keyPath)))
			}
		} else {
			
			let data = try DataResponseSerializer().serialize(request: nil,
															  response: response,
															  data: data,
															  error: nil)
			return try self.decoder.decode(T.self, from: data)
		}
	}
}
