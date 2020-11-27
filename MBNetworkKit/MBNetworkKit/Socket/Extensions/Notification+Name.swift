//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

public extension Notification.Name {
	
	/// Notification for socket connect event
	static let didConnected = Notification.Name("CarKit.Connected")
    /// Notification for socket lost connection event
    static let didConnectionLost = Notification.Name("CarKit.DidConnectionLost")
    /// Notification for socket disconnect event
    static let didDisconnect = Notification.Name("CarKit.Disconnect")
    /// Notification for socket starting to reconnect event
    static let didStartReconnecting = Notification.Name("CarKit.StartReconnecting")
}


// MARK: - Deprecated

public extension Notification.Name {
	/// Notification for socket reconnect event
    @available(*, deprecated, message: "Use Notification.Name.didConnected instead.")
	static let didReconnected = Notification.Name("CarKit.Reconnected")
}
