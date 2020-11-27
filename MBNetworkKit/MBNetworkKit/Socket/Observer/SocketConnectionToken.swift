//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// Representation of the conection token for the socket
public class SocketConnectionToken: NSObject {
	
	// MARK: Properties
	private let connectionStateObserver: SocketProtocol.SocketConnectionStateObserver
	
	
	// MARK: - Public
	
	func notify(connectionState: SocketConnectionState) {
		self.connectionStateObserver(connectionState)
	}
	
	
	// MARK: - Init
	
	init(connectionStateObserver: @escaping SocketProtocol.SocketConnectionStateObserver) {
		self.connectionStateObserver = connectionStateObserver
	}
}
