//
//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Quick
import Nimble

import Alamofire

@testable import MBNetworkKit

class NetworkServiceErrorTests: QuickSpec {
    
    override func spec() {
        
        var networkService: NetworkService!
        
        beforeEach {
            networkService = NetworkService()
        }
        
        describe("errorDecodable correctly decodes network response errors") {
            
            it("should fallback to an unkown error if the response error is not an AFErrro") {
                let result = networkService.errorDecodable(error: MockError.mock,
                                                           parsingType: MockErrorConformable.self)
                expect(result.localizedDescription).to(beNil())
                expect(result.type) == .unknown
            }
            
            it("should fallback if the response error does not contain a custom validation error") {
                // any non-custom-validation AFError
                let error = AFError.explicitlyCancelled
                
                let result = networkService.errorDecodable(error: error,
                                                           parsingType: MockErrorConformable.self)
                expect(result.localizedDescription).to(beNil())
                expect(result.type) == .unknown
            }
            
            context("for a DecodableError") {
                it("should handle empty key path errors") {
                    let result = networkService.errorDecodable(error: self.afError(for: DecodableError.emptyKeyPath),
                                                               parsingType: MockErrorConformable.self)
                    expect(result.localizedDescription).to(beNil())
                    
                    if case .network(let networkError) = result.type,
                       case .parsing(description: let description) = networkError {
                        expect(description) == "empty key path"
                    } else {
                        fail()
                    }
                }
                
                it("should handle invalid key path errors") {
                    let result = networkService.errorDecodable(
                        error: self.afError(for: DecodableError.invalidKeyPath(keyPath: "path")),
                        parsingType: MockErrorConformable.self)
                    
                    expect(result.localizedDescription).to(beNil())

                    if case .network(let networkError) = result.type,
                       case .parsing(description: let description) = networkError {
                        expect(description) == "invalid key path: path"
                    } else {
                        fail()
                    }
                }
                
                it("should handle invalid json errors") {
                    let result = networkService.errorDecodable(error: self.afError(for: DecodableError.invalidJson),
                                                               parsingType: MockErrorConformable.self)
                    expect(result.localizedDescription).to(beNil())

                    if case .network(let networkError) = result.type,
                       case .parsing(description: let description) = networkError {
                        expect(description) == "invalid json"
                    } else {
                        fail()
                    }
                }
            }
            
            context("for a HttpError") {
                it("should correctly decode the error payload") {
                    let identifier = "a-identifier"
                    let result = networkService.errorDecodable(error: self.httpError(identifier: identifier),
                                                               parsingType: MockErrorConformable.self)
                    
                    expect(result.localizedDescription) == "errorDescription"
                    
                    if case .http(let errorObj) = result.type,
                       case .badGateway(let data) = errorObj {
                        let json = try! JSONDecoder().decode(MockErrorConformable.self, from: data!)
                        
                        expect(json.errorDescription) == "errorDescription"
                        expect(json.identifier) == identifier
                    } else {
                        fail()
                    }
                }
            }
            
            context("for a NetworkError") {
                it("should handle the error") {
                    let errMsg = "no-connection"
                    let result = networkService.errorDecodable(
                        error: self.afError(for: NetworkError.noConnection(description: errMsg)),
                        parsingType: MockErrorConformable.self)
                    
                    expect(result.localizedDescription) == errMsg

                    if case .network(let networkError) = result.type,
                       case .noConnection(let description) = networkError {
                        expect(description) == errMsg
                    } else {
                        fail()
                    }
                }
            }
            
        }
    }
    
    private func afError(for error: Error) -> Error {
        return AFError.responseValidationFailed(reason:
                AFError.ResponseValidationFailureReason.customValidationFailed(error: error))
    }
    
    private func httpError(identifier: String) -> Error {
        let mockObj = MockErrorConformable(errorDescription: "errorDescription", identifier: identifier)
        let httpError = HttpError.badGateway(data: try! JSONEncoder().encode(mockObj))
        return afError(for: httpError)
    }
    
    private enum MockError: Error {
        case mock
    }
    
    private struct MockErrorConformable: MBErrorConformable, Encodable {
        var errorDescription: String?
        let identifier: String
    }
}
