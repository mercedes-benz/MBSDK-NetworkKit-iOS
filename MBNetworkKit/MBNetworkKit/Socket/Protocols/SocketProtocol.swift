//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// Protocol to implement the socket handling
public protocol SocketProtocol {
	
	// MARK: Typealias
	
	/// Completion for empty closue
	typealias Completion = () -> Void
	
	/// Completion for socket conection status
	///
	/// Returns a SocketConnectionState
	typealias SocketConnectionStateObserver = (SocketConnectionState) -> Void
	
	/// Completion for receiving data via
	///
	/// Returns data
	typealias SocketReceiveDataObserver = (Data) -> Void
	
	
	// MARK: Properties
	
	/// Returns whether the socket is connected
	var isConnected: Bool { get }
	
	
	// MARK: Functions
	
	/// Close the socket connection and remove all observable tokens
	func close()
	
	/// Connect your service with the socket
	///
	/// - Parameters:
	///   - socketToken: SocketToken object
	///   - connectionState: Closure with SocketConnectionStateObserver
	/// - Returns: A valid SocketConnectionToken
	func connect(socketToken: SocketToken, connectionState: @escaping SocketConnectionStateObserver) -> SocketConnectionToken

	/// Disconnect the socket
	/// - Parameters:
	///   - forced: Force the disconnect wihtout any delay
	func disconnect(forced: Bool)
	
	/// Register service to receive socket data
	///
	/// - Parameters:
	///   - observer: Closure with SocketReceiveDataObserver
	func receiveData(observer: @escaping SocketReceiveDataObserver) -> SocketReceiveDataToken
	
	/// Try to reconnect the socket
	func reconnect()
	
	/// Send some data to the socket
	///
	/// - Parameters:
	///   - data: Data to be sent
	///   - completion: Optional closure when finished
	func send(data: Data, completion: Completion?)
	
	/// Update the socket enviroment
	///
	/// - Parameters:
	///   - socketToken: SocketToken object
	///   - needsReconnect: Needs the socket a reconnect because the connection was lost after expired credentials
	///   - reconnectManually: Takes the reconnect manually
	func update(socketToken: SocketToken, needsReconnect: Bool, reconnectManually: Bool)

	/// This method is used to unregister a token from the observation of the socket connection status
	///
	/// - Parameters: Optional SocketConnectionToken
	func unregister(token: SocketConnectionToken?)
	
	/// This method is used to unregister a token from the observation of the socket connection status
	///
	/// - Parameters: Optional SocketReceiveDataToken
	func unregister(token: SocketReceiveDataToken?)
	
	/// This method is used to unregister a token from the observation of the socket connection status and try to disconnect the socket
	///
	/// - Parameters: Optional SocketConnectionToken
	///   - connectionToken: Optional SocketConnectionToken
	///   - receiveDataToken: Optional SocketReceiveDataToken
	func unregisterAndDisconnectIfPossible(connectionToken: SocketConnectionToken?, receiveDataToken: SocketReceiveDataToken?)
	
	/// This method is used to unregister an array of tokens from the observation of the socket connection status and try to disconnect the socket
	///
	/// - Parameters: Optional SocketConnectionToken
	///   - connectionTokens: Array of SocketConnectionToken
	///   - receiveDataToken: Optional SocketReceiveDataToken
	func unregisterAndDisconnectIfPossible(connectionTokens: [SocketConnectionToken], receiveDataToken: SocketReceiveDataToken?)
}
