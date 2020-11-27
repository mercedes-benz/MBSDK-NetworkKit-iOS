//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

/// Representation of MBNetworkKit error
public struct MBError: Error, Equatable {
    
	// MARK: - Public
    
	/// Description of the error
    public var localizedDescription: String? {
        return self.description
    }
    
	/// Type of the error as MBErrorType
    public let type: MBErrorType
	
    // MARK: - Properties
    
    private var description: String?
	
    
    // MARK: - Initializer
    
    public init(description: String?, type: MBErrorType) {
        
        self.description = description
        self.type = type
    }
}


// MARK: - MBErrorType

/// Type that represents network related errors
public enum MBErrorType {
    case network(NetworkError)
    case http(HttpError)
    case specificError(Error)
    case unknown
}


// MARK: - Extension

public extension MBErrorType {
    
	var data: Data? {
        switch self {
        case .network,
             .specificError,
             .unknown:          return nil
        case .http(let error):  return error.data
        }
    }
}

// MARK: - Equatable

extension MBErrorType: Equatable {
    
    /// Equatable implementation. Check if two values of type MBErrorType are equal
    ///
    /// - Parameters:
    ///   - lhs: lhs value
    ///   - rhs: rhs value
    /// - Returns: true or false
    public static func == (lhs: MBErrorType, rhs: MBErrorType) -> Bool {
        
        switch (lhs, rhs) {
        case (.specificError, .specificError):    return true
        case (.network, .network):              return true
        case (.http, .http):                    return true
        case (.unknown, .unknown):              return true
        default:                                return false
        }
    }
}
