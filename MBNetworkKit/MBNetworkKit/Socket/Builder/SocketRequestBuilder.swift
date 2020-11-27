//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

protocol SocketRequestBuilderRepresentable {
    func buildRequest(accessToken: String) -> URLRequest
}

class SocketRequestBuilder: SocketRequestBuilderRepresentable {
    
    private var fallbackSessionId = UUID().uuidString
    
    private struct Constants {
        static let requestTimeoutInterval: TimeInterval = 5
        static let headerAuthKey = "Authorization"
        static let headerXSessionIdKey = "X-SessionId"
    }
    
    // MARK: Properties
    private var baseUrl: URL {
        guard let url = URL(string: Socket.socketBaseUrl) else {
            fatalError("configure the socket url")
        }
        return url
    }
    
    func buildRequest(accessToken: String) -> URLRequest {
        
        var request = URLRequest(url: self.baseUrl)
        
        request.setValue(accessToken,
                         forHTTPHeaderField: self.authHeaderKey())
        request.timeoutInterval = Constants.requestTimeoutInterval
        
        for (field, value) in self.requestHeaders() {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        return request
    }
    
    private func authHeaderKey() -> String {
        return Socket.headerParamProvider?.authorizationHeaderParamKey ?? Constants.headerAuthKey
    }
    
    private func requestHeaders() -> [String: String] {
        if let defaults = Socket.headerParamProvider?.defaultHeaderParams {
            return defaults
        } else {
            LOG.I("Header param provider not set, using fallback session id, so we're able to connect: \(self.fallbackSessionId)")
            return [Constants.headerXSessionIdKey: self.fallbackSessionId]
        }
    }
}
