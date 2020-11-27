//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

extension NetworkLayer {
    
    public static func errorDecodable<T: MBErrorConformable>(error: Error, parsingType: T.Type) -> MBError {
        
        var errorParams: (description: String?, type: MBErrorType)? {
            
            switch error {
            case let decodableError as DecodableError:
                switch decodableError {
                case .emptyKeyPath:                 return (nil, .network(.parsing(description: "empty key path")))
                case .invalidKeyPath(let keyPath):  return (nil, .network(.parsing(description: "invalid key path: \(keyPath)")))
                case .invalidJson:					return (nil, .network(.parsing(description: "invalid json")))
                }
                
            case let httpError as HttpError:
                let parsedError: T? = NetworkLayer.parse(httpError: httpError)
                return (parsedError?.errorDescription, .http(httpError))
                
            case let networkError as NetworkError:
                return (networkError.localizedDescription, .network(networkError))
                
            default:
                return (nil, .unknown)
            }
        }
        
        return MBError(description: errorParams?.description, type: errorParams?.type ?? .unknown)
    }
    
    public static func parse<T: Decodable>(httpError: HttpError, decoder: JSONDecoder = JSONDecoder()) -> T? {
        
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
    
    private static func parse<T: Decodable>(decoder: JSONDecoder, data: Data?) -> T? {
        
        guard let data = data else {
            return nil
        }
        
        return try? decoder.decode(T.self, from: data)
    }
}
