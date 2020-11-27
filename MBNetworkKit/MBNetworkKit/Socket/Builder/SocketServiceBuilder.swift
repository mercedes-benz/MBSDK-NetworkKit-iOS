//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

protocol SocketServiceBuilderRepresentable {
    func buildService() -> SocketProtocol
}

struct SocketServiceBuilder {
	
	private let socketRequestBuilder: SocketRequestBuilderRepresentable
	
	
	// MARK: - Init
	
	init(socketRequestBuilder: SocketRequestBuilderRepresentable = SocketRequestBuilder()) {
		self.socketRequestBuilder = socketRequestBuilder
	}
}


// MARK: - SocketServiceBuilderRepresentable

extension SocketServiceBuilder: SocketServiceBuilderRepresentable {
	
	func buildService() -> SocketProtocol {
		
		let socketToken = SocketToken(accessToken: "",
									  expiredDate: Date())
		
		return SocketService(socketToken: socketToken,
							 socketRequestBuilder: self.socketRequestBuilder)
	}
}
