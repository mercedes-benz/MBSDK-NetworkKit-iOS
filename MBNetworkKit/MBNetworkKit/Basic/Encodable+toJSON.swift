//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

extension Encodable {

    /// Convenience helper to map Encodable/Codable objects to JSON
    ///
    /// - Parameters:
    ///   - encoder: custom JSONEncoder if needed (default == JSONEncoder())
    ///   - options: (default == [])
    /// - Returns: object of type Any
    /// - Throws: _
    public func toJson(using encoder: JSONEncoder = JSONEncoder(), options: JSONSerialization.ReadingOptions = []) throws -> Any {

        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: options)
    }

    
    /// Convenience helper to map Encodable/Codable objects a String
    ///
    /// - Parameters:
    ///   - encoder: custom JSONEncoder if needed (default == JSONEncoder())
    ///   - encoding: String encoding (default == .utf8)
    /// - Returns: String (optional)
    /// - Throws: _
    public func toJsonString(using encoder: JSONEncoder = JSONEncoder(), encoding: String.Encoding = .utf8) throws -> String? {

        let data = try encoder.encode(self)

        return String(data: data, encoding: encoding)
    }
}
