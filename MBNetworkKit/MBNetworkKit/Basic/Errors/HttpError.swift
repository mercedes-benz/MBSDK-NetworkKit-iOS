//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

/// Type that represents http request related errors
public enum HttpError: Error {
    case badGateway(data: Data?)
    case badRequest(data: Data?)
    case conflict(data: Data?)
    case forbidden(data: Data?)
    case internalServerError(data: Data?)
    case locked(data: Data?)
    case notAllowed(data: Data?)
    case notFound(data: Data?)
    case notRecognized(data: Data?)
    case preconditionFailed(data: Data?)
    case tooManyRequests(data: Data?)
    case unauthorized(data: Data?)
    case unavailableLegalReasons(data: Data?)
    case unspecific(data: Data?)
}


// MARK: - Extension

extension HttpError {
    
    public var data: Data? {
        switch self {
        case .badGateway(let data):					return data
        case .badRequest(let data):					return data
        case .conflict(let data):					return data
        case .forbidden(let data):					return data
        case .internalServerError(let data):		return data
        case .locked(data: let data):               return data
        case .notAllowed(let data):					return data
        case .notFound(let data):					return data
        case .notRecognized(let data):				return data
        case .preconditionFailed(let data):			return data
        case .tooManyRequests(let data):			return data
        case .unauthorized(let data):				return data
        case .unavailableLegalReasons(let data):	return data
        case .unspecific(let data):					return data
        }
    }
    
    
    // MARK: - Helper
    
    static func map(statusCode: Int, data: Data?) -> HttpError {
        
        switch statusCode {
        case 400:	return .badRequest(data: data)
        case 401:	return .unauthorized(data: data)
        case 403:	return .forbidden(data: data)
        case 404:	return .notFound(data: data)
        case 405:	return .notAllowed(data: data)
        case 409:   return .conflict(data: data)
        case 412:	return .preconditionFailed(data: data)
        case 422:	return .notRecognized(data: data)
        case 423:   return .locked(data: data)
        case 429:	return .tooManyRequests(data: data)
        case 451:	return .unavailableLegalReasons(data: data)
        case 500:	return .internalServerError(data: data)
        case 502:	return .badGateway(data: data)
        default:	return .unspecific(data: data)
        }
    }
}


// MARK: - Equatable

extension HttpError: Equatable {
    
    /// Equatable implementation. Check if two values of type HttpError are equal
    ///
    /// - Parameters:
    ///   - lhs: lhs value
    ///   - rhs: rhs value
    /// - Returns: true or false
    public static func == (lhs: HttpError, rhs: HttpError) -> Bool {
        
        switch (lhs, rhs) {
        case (.badGateway, .badGateway):							return true
        case (.badRequest, .badRequest):							return true
        case (.conflict, .conflict):                        		return true
        case (.forbidden, .forbidden):								return true
        case (.internalServerError, .internalServerError):			return true
        case (.locked, .locked):                                    return true
        case (.notAllowed, .notAllowed):							return true
        case (.notFound, .notFound):								return true
        case (.notRecognized, .notRecognized):						return true
        case (.preconditionFailed, .preconditionFailed):			return true
        case (.tooManyRequests, .tooManyRequests):					return true
        case (.unauthorized, .unauthorized):						return true
        case (.unavailableLegalReasons, unavailableLegalReasons):	return true
        case (.unspecific, .unspecific):							return true
        default: 													return false
        }
    }
}
