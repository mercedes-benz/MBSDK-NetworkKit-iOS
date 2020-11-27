//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// Representation of the receive data token for the socket
public class SocketReceiveDataToken: NSObject {
	
	// MARK: Properties
	private let receiveDataObserver: SocketProtocol.SocketReceiveDataObserver
	
	
	// MARK: - Init
	
	init(receiveDataObserver: @escaping SocketProtocol.SocketReceiveDataObserver) {
		self.receiveDataObserver = receiveDataObserver
	}
	
	
	// MARK: - Public
	
	func notify(data: Data) {
		self.receiveDataObserver(data)
	}
}
