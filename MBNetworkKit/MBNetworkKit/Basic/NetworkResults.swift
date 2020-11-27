//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

// MARK: - NetworkResult

/// Default network result
///
/// - success: request specific object
/// - failure: error object
public enum NetworkResult<T> {
    
	case success(T)
	case failure(Error)
	
	var isSuccess: Bool {
		switch self {
		case .failure:	return false
		case .success:	return true
		}
	}
    
	var value: T? {
		switch self {
		case .failure:				return nil
		case .success(let value):	return value
		}
	}
}
