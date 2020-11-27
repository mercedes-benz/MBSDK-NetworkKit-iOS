//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

/// Type that represents network related errors
public enum NetworkError: LocalizedError {
	
    /// The url is not valid (unsupported url, can't connect to host, can't find host)
	case invalidUrl
	
    /// Device has no internet connection
	case noConnection(description: String?)
    
    /// Response not parsable
	case parsing(description: String?)
	
    /// Request timed out
	case timeOut(description: String?)
    
    /// Unknown error
	case unknown
}


// MARK: - NetworkError

extension NetworkError {
	
	 public var errorDescription: String? {
		switch self {
		case.invalidUrl:
			return nil
			
		case .noConnection(let description),
			 .parsing(let description),
			 .timeOut(let description):
			return description
			
		case .unknown:
			return nil
		}
	}
	
	
	// MARK: - Helper
	
	static func map(urlError: URLError) -> NetworkError {

		guard let errorDomain = ErrorDomain(rawValue: urlError.errorCode) else {
			return .unknown
		}
		
		switch errorDomain {
		case .cannotConnectToHost,
			 .cannotFindHost,
			 .unsupportedURL:			return .invalidUrl
		case .notConnectedToInternet:	return .noConnection(description: urlError.localizedDescription)
		case .timedOut:					return .timeOut(description: urlError.localizedDescription)
		default:						return .unknown
		}
	}
}
