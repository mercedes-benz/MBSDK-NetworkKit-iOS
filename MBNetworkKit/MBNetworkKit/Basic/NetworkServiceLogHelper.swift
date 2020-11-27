//
//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation


class NetworkServiceLogHelper {
    
    static func log(request: URLRequest, router: EndpointRouter) {
        var logStringSegments = [String]()
        logStringSegments.append("\n\(request.httpMethod ?? "<NO HTTP METHOD SET>") \(request.url?.absoluteString ?? "<INVALID URL>")")
        logStringSegments.append("Header: \(self.logStringForHeaders(request.allHTTPHeaderFields))")
        
        if request.httpBody != nil {
            logStringSegments.append("Body: \(router.bodyParameters?.description ?? "[]")")
        }

        LOG.D("Performing HTTP request: \(logStringSegments.joined(separator: "\n"))")
    }
    
    static func log(response: HTTPURLResponse, data: Data?) {
        var logStringSegments = [String]()
        logStringSegments.append("\(response.statusCode) - \(response.url?.absoluteString ?? "<INVALID URL>")")
        logStringSegments.append("Header: \(self.logStringForHeaders(response.allHeaderFields))")
        
        if let data = data {
            if let jsonBody = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                let str = "Body: \(jsonBody.map { "\($0.key): \($0.value)" }.joined(separator: ", "))"
                logStringSegments.append(self.cleanBodyString(str))
            } else {
                let body = self.concatIfNeeded(String(decoding: data, as: UTF8.self))
                logStringSegments.append("Body: \(body)...")
            }
        }
        LOG.D("Received HTTP response: \(logStringSegments.joined(separator: "\n"))")
    }
    
    private static func cleanBodyString(_ string: String) -> String {
        var cleanedString = string
        ["\\", "   ", "\n", "\""].forEach {
            cleanedString = cleanedString.replacingOccurrences(of: $0, with: "", options: NSString.CompareOptions.literal, range: nil)
        }
        return self.concatIfNeeded(cleanedString)
    }
    
    private static func logStringForHeaders(_ headers: [AnyHashable: Any]?) -> String {
        guard let headers = headers else {
            return "<NO HTTP HEADER SET>"
        }
        
        let headerStrings = headers.map { "\($0.key): \(self.headerLogValue($0.value))" }
        return "[\(headerStrings.joined(separator: ", "))]"
    }
    
    private static func headerLogValue(_ value: Any) -> String {
        if let stringVal = value as? String {
            return self.concatIfNeeded(stringVal)
        } else {
            return "\(value)"
        }
    }
    
    private static func concatIfNeeded(_ string: String, maxLength: Int = 500) -> String {
        return string.count > maxLength ? "\(String(string.prefix(maxLength)))..." : string
    }
}
