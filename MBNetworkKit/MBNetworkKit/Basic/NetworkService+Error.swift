//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - NetworkingError

extension NetworkService: NetworkingError {
    
    func errorDecodable<T: MBErrorConformable>(error: Error, parsingType: T.Type) -> MBError {
        LOG.D("Trying to decode encountered network response error \(error)")
        
        let errorParams = self.specify(error: error, parsingType: parsingType)
        LOG.D("Decoding results: \(errorParams)")
        
        return MBError(description: errorParams.description, type: errorParams.type)
    }
    
    func parse<T: Decodable>(httpError: HttpError, decoder: JSONDecoder) -> T? {
        
        switch httpError {
        case .badGateway(let data),
             .badRequest(let data),
             .conflict(let data),
             .forbidden(let data),
             .internalServerError(let data),
             .locked(let data),
             .notAllowed(let data),
             .notFound(let data),
             .notRecognized(let data),
             .preconditionFailed(let data),
             .tooManyRequests(let data),
             .unauthorized(let data),
             .unavailableLegalReasons(let data),
             .unspecific(let data):
            return self.parse(decoder: decoder, data: data)
        }
    }
    
    
    // MARK: - Helper
    
    /// Specifys a generic AF Error to a MBErrorType and a corresponding description by e.g. decoding
    /// the error payload or trying to cast it to differnt error types
    private func specify<T: MBErrorConformable>(error: Error, parsingType: T.Type) -> (description: String?, type: MBErrorType) {
        
        guard let afError = error as? AFError else {
            LOG.E("Encountered a request error that is not an AFError: \(error), parsingType: \(parsingType)")
            return (nil, .unknown)
        }
        
        // "unwrap" the nested AFError enums
        guard case .responseValidationFailed(reason: let validationError) = afError,
              case .customValidationFailed(error: let customValidationError) = validationError else {
            LOG.E("Encountered an AFError that does not contain our custom validation error: \(afError), parsingType: \(parsingType)")
            return (nil, .unknown)
        }
        
        switch customValidationError {
        
        case let decodableError as DecodableError:
            switch decodableError {
            case .emptyKeyPath:                 return (nil, .network(.parsing(description: "empty key path")))
            case .invalidKeyPath(let keyPath):  return (nil, .network(.parsing(description: "invalid key path: \(keyPath)")))
            case .invalidJson:                  return (nil, .network(.parsing(description: "invalid json")))
            }
            
        case let httpError as HttpError:
            let parsedError: T? = self.parse(httpError: httpError)
            return (parsedError?.errorDescription, .http(httpError))
            
        case let networkError as NetworkError:
            return (networkError.localizedDescription, .network(networkError))
            
        default:
            return (nil, .unknown)
        }
    }
    
    private func parse<T: Decodable>(decoder: JSONDecoder, data: Data?) -> T? {
        
        guard let data = data else {
            return nil
        }
        
        return try? decoder.decode(T.self, from: data)
    }
}
