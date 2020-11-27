//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

extension EndpointRouter {
	
	// MARK: - Properties
    
    /// Get the generated URLRequest with all necessary information (Get only)
	public var urlRequest: URLRequest? {
		
		guard let url = try? self.baseURL.asURL() else {
			return nil
		}
		
		return self.getUrlRequest(with: url, headers: self.httpHeaders)
	}

	public func getUrlRequest(with url: URL, headers: [String: String]? = nil) -> URLRequest? {

		var urlRequest             = URLRequest(url: url.appendingPathComponent(self.path))
		urlRequest.httpMethod      = self.method.rawValue.uppercased()
		urlRequest.timeoutInterval = self.timeout
		urlRequest.cachePolicy     = self.cachePolicy ?? urlRequest.cachePolicy

		if let headers = headers {
			self.setupHTTPHeaders(headers, for: &urlRequest)
		}

		guard let encodedRequest = self.setupDefaultEncoding(for: urlRequest) else {
			return nil
		}

		if let bodyEncodedRequest = self.setupBodyEncoding(for: encodedRequest) {
			return bodyEncodedRequest
		}

		return encodedRequest
	}
	
	
	// MARK: - Helper
	
	private static func map(encode: ParameterEncodingType, isQueryEncoding: Bool) -> ParameterEncoding {
		
		switch encode {
		case .json:				return JSONEncoding.default
		case .url(let urlType):	return isQueryEncoding ? self.map(urlType: urlType) : URLEncoding.default
		}
	}
	
    
	private static func map(urlType: URLEncodingType) -> ParameterEncoding {
		
		switch urlType {
		case .standard:	return URLEncoding.default
		case .query:	return URLEncoding(destination: .queryString)
		}
	}
    
	
	private func setupBodyEncoding(for urlRequest: URLRequest) -> URLRequest? {
		
		guard self.bodyParameters != nil else {
			return nil
		}
		
		let encoding = Self.map(encode: self.bodyEncoding, isQueryEncoding: false)
		return try? encoding.encode(urlRequest, with: self.bodyParameters)
	}
	
    
	private func setupDefaultEncoding(for urlRequest: URLRequest) -> URLRequest? {
		
		let encoding = Self.map(encode: self.parameterEncoding, isQueryEncoding: true)
		return try? encoding.encode(urlRequest, with: self.parameters)
	}
	
    
	private func setupHTTPHeaders(_ headers: [String: String], for urlRequest: inout URLRequest) {
		
		for (key, value) in headers {
			
			if urlRequest.allHTTPHeaderFields?[key] == nil {
				urlRequest.addValue(value, forHTTPHeaderField: key)
			} else {
				urlRequest.setValue(value, forHTTPHeaderField: key)
			}
		}
	}
}
