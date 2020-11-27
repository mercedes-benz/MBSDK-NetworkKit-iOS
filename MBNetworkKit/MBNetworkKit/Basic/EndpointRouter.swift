//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

// MARK: - HTTPMethodType

/// Supported types of http-request methods
public enum HTTPMethodType: String {
	case options
	case get
	case head
	case post
	case put
	case patch
	case delete
	case trace
	case connect
}


// MARK: - ParameterEncodingType

/// Supported types of parameter encoding
public enum ParameterEncodingType {
	case json
	case url(type: URLEncodingType)
}


extension ParameterEncodingType: Equatable {
	
    /// Equatable implementation to check if two ParameterEncodingType values are equal
    ///
    /// - Parameters:
    ///   - lhs: lhs value
    ///   - rhs: rhs value
    /// - Returns: true or false
	public static func == (lhs: ParameterEncodingType, rhs: ParameterEncodingType) -> Bool {
		
		switch (lhs, rhs) {
		case (.json, .json): 					return true
		case let (.url(l), .url(r)): 			return l == r
		default: return false
		}
	}
}


// MARK: - URLEncodingType

// Supported types of URL encoding
public enum URLEncodingType {
	case standard
	case query
}


// MARK: - EndpointRouter

/// Protocol for the request factory
///
/// All NetworkLayer functions require an EndpointRouter conforming object
///
/// An instance of this type contains all necessary information about the request
public protocol EndpointRouter {
	
    /// Base url of the endpoint/backend service
	var baseURL: String { get }
    
    /// HTTP request method type
	var method: HTTPMethodType { get }
    
    /// Path/url
	var path: String { get }
    
    /// Dictionary of URL parameters (optional)
	var parameters: [String: Any]? { get }
    
    /// URL parameter encoding-type
	var parameterEncoding: ParameterEncodingType { get }
    
    /// Dictionary of body parameters (optional)
    ///
    /// Default == nil
	var bodyParameters: [String: Any]? { get }
    
    /// Body parameter encoding-type
    ///
    /// Default == .parameterEncoding
	var bodyEncoding: ParameterEncodingType { get }
    
    /// Cache-policy for URLRequest (optional)
	var cachePolicy: URLRequest.CachePolicy? { get }
    
    /// Request timeout interval. Default == 30s
	var timeout: TimeInterval { get }
    
    /// Dictionary of http headers (optional)
	var httpHeaders: [String: String]? { get }
}


// Default implementation
public extension EndpointRouter {
	
	var bodyEncoding: ParameterEncodingType {
		return self.parameterEncoding
	}
    
	var bodyParameters: [String: Any]? {
		return nil
	}
    
	var timeout: TimeInterval {
		return 30
	}
}
