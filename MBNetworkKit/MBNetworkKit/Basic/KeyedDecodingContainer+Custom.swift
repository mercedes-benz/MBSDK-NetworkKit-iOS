//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {

    /// Decode values safely and do not fail if value is missing or unkown
    ///
    /// - Parameters:
    ///   - type: Type of the decodable object
    ///   - key: KeyedDecodingContainer.Key
    /// - Returns: Decodable object of given type
	public func decodeSafelyIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
		
		let item = try? self.decodeIfPresent(T.self, forKey: key)
		#if swift(>=5.0)
		return item.flatMap({ $0 })
		#else
		return item?.flatMap({ $0 })
		#endif
	}
	
    
    /// Decode array of values safely and do not fail if value is missing or unkown
    ///
    /// - Parameters:
    ///   - type: Type of the decodable object
    ///   - key: KeyedDecodingContainer.Key
    /// - Returns: Arry of decodable object of given type
	public func decodeArraySafelyIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> [T]? {
		
		guard let array = try? self.decodeIfPresent([FailableDecodable<T>].self, forKey: key) else {
			return nil
		}
		
		#if swift(>=5.0)
		return array.compactMap({ $0.base })
		#else
		return array?.compactMap({ $0.base })
		#endif
	}
	
	
	// MARK: - Helper
	
	/// helper struct to decode arrays even if one element cant be decoded
	private struct FailableDecodable<Base: Decodable>: Decodable {
		
		let base: Base?
		
		init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			self.base = try? container.decode(Base.self)
		}
	}
}
