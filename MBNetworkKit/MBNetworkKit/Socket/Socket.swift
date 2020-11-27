//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import MBCommonKit

#if canImport(MBCommonKitLogger)
import MBCommonKitLogger
#endif

let LOG = MBLogger.shared

/// Main part of the MBRSSocket-module
///
/// Fascade to communicate with all provided services
public class Socket {
	
	// MARK: Properties
	private static let shared = Socket()
	private let socketService: SocketProtocol

	
	// MARK: - Public
	
	/// Access to socket service
	public static var service: SocketProtocol {
		return self.shared.socketService
	}
	
	/// Socket base url string
	public static var socketBaseUrl: String = ""
	
	/// Default header values to pass to the websocket upgrade
	public static var headerParamProvider: HeaderParamProviding?
	
	
	// MARK: - Initializer
	
	private init(socketServiceBuilder: SocketServiceBuilderRepresentable = SocketServiceBuilder()) {
		self.socketService = socketServiceBuilder.buildService()
	}
}
