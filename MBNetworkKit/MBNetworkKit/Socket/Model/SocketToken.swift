//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

public struct SocketToken {
	
	let accessToken: String
	let expiredDate: Date
	
	
	// MARK: - Init
	
	public init(accessToken: String, expiredDate: Date) {
		
		self.accessToken = accessToken
		self.expiredDate = expiredDate
	}
}


extension SocketToken {
	
	var isExpired: Bool {
		return Date().compare(self.expiredDate) == .orderedDescending
	}
}
