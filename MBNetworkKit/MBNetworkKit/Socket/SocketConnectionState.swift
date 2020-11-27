//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// Socket state for the socket connection
public enum SocketConnectionState {
	
	/// Socket is closed and has no listener
	case closed
	/// Socket is connected
	case connected
	/// The socket connection start to establish
	case connecting
	/// Socket lost the connection with the indication of wheter a refresh of the jwt is needed
	case connectionLost(needsTokenUpdate: Bool)
	/// Socket is disconnected with all available listeners
	case disconnected
}


// MARK: - Equatable

extension SocketConnectionState: Equatable {

	public static func == (lhs: SocketConnectionState, rhs: SocketConnectionState) -> Bool {
		
		switch (lhs, rhs) {
		case (.closed, .closed):					return true
		case (.connected, .connected):				return true
		case (.connecting, .connecting):			return true
		case (.connectionLost, .connectionLost):	return true
		case (.disconnected, .disconnected):		return true
		default: 									return false
		}
	}
}
