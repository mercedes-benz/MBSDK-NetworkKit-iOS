//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import Starscream
import TrustKit

public class SocketService: NSObject {

	// MARK: Constants
	private struct SocketTimeInterval {
		static let connectionViewTimeout: TimeInterval = 10
		static let pingPongTimeout = 5
		static let reconnect = 5
	}
	
	// MARK: Properties
	public var isConnected: Bool {
		return self.socketConnectionState == .connected
	}
	
	private var connectionLostWorkItem: DispatchWorkItem?
    
    // timer to wait for a hopefull reconnect after e.g. a network related disconnect
    // before we consider the connection as truely dead.
    private var disconnectNotificationTimer: Timer?
    private var socket: WebSocket?
    private var socketConnectionState: SocketConnectionState {
        didSet {
			self.sendNotificationIfNeeded(comparedValue: oldValue)
            self.connectionObservableTokens.forEach {
                $0.notify(connectionState: self.socketConnectionState)
            }
        }
    }
	private var socketNetworkReachability: SocketNetworkReachabilityRepresentable?
	private var socketToken: SocketToken
	
    // Observers
    private var receiveDataObservableTokens = [SocketReceiveDataToken]()
    private var connectionObservableTokens = [SocketConnectionToken]()
    
    // Dependencies
    private let socketRequestBuilder: SocketRequestBuilderRepresentable
	
	
	// MARK: - Init
	
    init(socketToken: SocketToken,
         socketRequestBuilder: SocketRequestBuilderRepresentable = SocketRequestBuilder()) {
        
        self.socketRequestBuilder = socketRequestBuilder
		
		// properties
		self.socketToken = socketToken
		self.socketConnectionState = .disconnected
		
		super.init()
		
		guard self.socketToken.accessToken.isEmpty == false,
			self.socketToken.isExpired == false else {
				return
		}
		self.initWebSocket()
	}
	
	
	// MARK: - WebSocket
	
    private func forceDisconnectSocket() {
		
        self.socket?.forceDisconnect()
		
        // reset and clean up socket (rebuild socket do reset internal starscream state)
		self.socket = nil
		self.socketNetworkReachability = nil
    }
	
	private func handleReachabilityStatusChanged() {
		
		let needsTokenUpdate = self.socketToken.isExpired
		
		LOG.D("Web socket reachability status changed -> needs token update: \(needsTokenUpdate)")
		
		if needsTokenUpdate {
			if self.socketConnectionState == .connectionLost(needsTokenUpdate: needsTokenUpdate) {
				self.connectionObservableTokens.forEach {
					$0.notify(connectionState: self.socketConnectionState)
				}
			} else {
				self.socketConnectionState = .connectionLost(needsTokenUpdate: needsTokenUpdate)
			}
		}
		
		self.socketNetworkReachability?.statusChangedToReachable = nil
	}
	
    private func handleWebsocketEvent(_ event: WebSocketEvent) {
		
        switch event {
        case .connected:
			LOG.D("Web socket status: connected -> previous state: \(self.socketConnectionState)")
			self.cancelAndInvalidateConnectionLostWorkItem()
			self.socketConnectionState = .connected
            
        case .disconnected(let reason, let code):
			LOG.D("Web socket status: disconnected -> reason: \(reason) | code: \(code) | previous state: \(self.socketConnectionState)")
            self.handleWebsocketDisconnected()
            
        case .text(let string):
            LOG.D("Web socket status: message -> \(string)")
			self.cancelAndInvalidateConnectionLostWorkItem()
			
        case .binary(let data):
			LOG.D("Web socket status: binary -> state: \(self.socketConnectionState) | listener: \(self.receiveDataObservableTokens.count)")
			self.cancelAndInvalidateConnectionLostWorkItem()
            self.handleWebsocketDidReceiveData(data: data)
            
        case .ping:
			LOG.D("Web socket status: ping")
			self.cancelAndInvalidateConnectionLostWorkItem()
			self.socketConnectionState = .connected
			
        case .pong:
			LOG.D("Web socket status: pong")
			self.cancelAndInvalidateConnectionLostWorkItem()
			self.socketConnectionState = .connected
		
        case .viabilityChanged(let isViable):
			LOG.D("Web socket status: viabilityChanged -> \(isViable) | \(self.isConnected)")
			
			if isViable == false || self.isConnected {
				
				self.cancelAndInvalidateConnectionLostWorkItem()
				
				let workItem = self.createConnectionLostWorkItem()
				
				self.socket?.write(ping: Data())
				DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(SocketTimeInterval.pingPongTimeout), execute: workItem)
			}
            
        case .reconnectSuggested(let shouldReconnect):
			LOG.D("Web socket status: reconnectSuggested -> \(shouldReconnect)")
			
			if shouldReconnect {
				
				self.cancelAndInvalidateConnectionLostWorkItem()
				self.forceDisconnectSocket()
				
				self.socketConnectionState = .connecting
				
				self.recreateSocket()
				self.socket?.connect()
			}
            
        case .cancelled:
			LOG.D("Web socket status: cancelled")
            self.handleWebsocketDisconnected()
            
        case .error(let error):
			if let error = error {
				LOG.E("Web socket error: \(error.localizedDescription)")
			} else {
				LOG.E("Web socket error: encountered unknown websocket error")
			}
        }
    }
	
    private func handleWebsocketDidReceiveData(data: Data) {
        
        self.receiveDataObservableTokens.forEach {
            $0.notify(data: data)
        }
    }
    
    private func handleWebsocketDisconnected() {
		
        switch self.socketConnectionState {
        case .closed,
			 .disconnected:
			break
			
        case .connected,
			 .connecting,
			 .connectionLost:
			let needsTokenUpdate = self.socketToken.isExpired
			self.socketConnectionState = .connectionLost(needsTokenUpdate: needsTokenUpdate)
			if needsTokenUpdate == false {
				Timer.scheduledTimer(withTimeInterval: TimeInterval(SocketTimeInterval.reconnect), repeats: false) { [weak self] (_) in
					self?.socket?.connect()
				}
			} else {
				LOG.D("Web socket needs token update")
				
				self.initReachibilityObserver()
			}
        }
    }
    
	private func initReachibilityObserver() {
		
		guard self.socketNetworkReachability?.statusChangedToReachable == nil else {
			return
		}
		
		LOG.D("Web socket initialized the handler for reachibility change")
		
		self.socketNetworkReachability?.statusChangedToReachable = { [weak self] in
			self?.handleReachabilityStatusChanged()
		}
	}
	
	private func initWebSocket() {
		
		let request = self.socketRequestBuilder.buildRequest(accessToken: self.socketToken.accessToken)
		self.socket = WebSocket(request: request)
		self.socket?.onEvent = self.handleWebsocketEvent(_:)
		
		if let host = request.url?.host {
			self.socketNetworkReachability = SocketNetworkReachability(host: host)
		}
	}
	
	
	// MARK: - Helper
	
	private func cancelAndInvalidateConnectionLostWorkItem() {
		
		self.connectionLostWorkItem?.cancel()
		self.connectionLostWorkItem = nil
	}
	
	private func createConnectionLostWorkItem() -> DispatchWorkItem {
		
		let workItem = DispatchWorkItem { [weak self] in
			
			let needsTokenUpdate = self?.socketToken.isExpired ?? true
			LOG.D("Web socket connection state changed to connection lost -> needs token update: \(needsTokenUpdate)")
			self?.socketConnectionState = .connectionLost(needsTokenUpdate: needsTokenUpdate)
		}
		self.connectionLostWorkItem = workItem
		
		return workItem
	}
	
	private func diconnectIfPossible(receiveDataToken: SocketReceiveDataToken?) {
		
		self.unregister(token: receiveDataToken)
		
		guard self.connectionObservableTokens.isEmpty,
			self.receiveDataObservableTokens.isEmpty else {
				return
			}
		
		self.close()
	}
    
	private func recreateSocket() {
		
		if self.socket == nil {
			self.initWebSocket()
		} else {
			self.socket?.request = self.socketRequestBuilder.buildRequest(accessToken: self.socketToken.accessToken)
		}
	}
	
	private func sendNotificationIfNeeded(comparedValue oldValue: SocketConnectionState) {
        
		guard self.socketConnectionState != oldValue else {
			return
		}
		
        switch self.socketConnectionState {
        case .closed,
             .disconnected:
			LOG.D("Web socket connection status: didDisconnect")
            NotificationCenter.default.post(name: Notification.Name.didDisconnect, object: nil)
			
        case .connected:
			LOG.D("Web socket connection status: didConnected")
            NotificationCenter.default.post(name: Notification.Name.didConnected, object: nil)
			// TODO: remove with deprecation of this notification
            NotificationCenter.default.post(name: Notification.Name.didReconnected, object: nil)
            self.disconnectNotificationTimer?.invalidate()
            self.disconnectNotificationTimer = nil
            
        case .connecting:
			break
            
        case .connectionLost:
            guard self.disconnectNotificationTimer == nil else {
                return
            }
			
			LOG.D("Web socket connection status: didStartReconnecting")
			
            NotificationCenter.default.post(name: Notification.Name.didStartReconnecting, object: nil)
            self.disconnectNotificationTimer = Timer.scheduledTimer(withTimeInterval: SocketTimeInterval.connectionViewTimeout, repeats: false, block: { [weak self] _ in
				LOG.D("Web socket connection status: didConnectionLost")
				
				self?.disconnectNotificationTimer = nil
                NotificationCenter.default.post(name: Notification.Name.didConnectionLost, object: nil)
            })
        }
    }
	
	private func startReconnecting() {
		LOG.D("Web socket start reconnecting -> isConnected: \(self.isConnected)")
		
		if self.isConnected == false {
			
			let workItem = self.createConnectionLostWorkItem()
			self.socketConnectionState = .connecting
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(SocketTimeInterval.reconnect), execute: workItem)
		}
	}
}


// MARK: - SocketProtocol

extension SocketService: SocketProtocol {

	public func close() {
		
		self.socketConnectionState = .closed
		self.connectionObservableTokens.removeAll()
		self.receiveDataObservableTokens.removeAll()
		self.forceDisconnectSocket()
	}

	public func connect(socketToken: SocketToken, connectionState: @escaping SocketConnectionStateObserver) -> SocketConnectionToken {
		
		self.socketToken = socketToken
        
		let connectionToken = SocketConnectionToken(connectionStateObserver: connectionState)
		self.connectionObservableTokens.append(connectionToken)
		
		self.update(socketToken: self.socketToken,
					needsReconnect: false,
					reconnectManually: false)
		
		switch self.socketConnectionState {
		case .closed,
			 .disconnected:
			self.socketConnectionState = .connecting
			self.socket?.connect()
			
		case .connected:
			connectionToken.notify(connectionState: self.socketConnectionState)

		case .connecting:
			connectionToken.notify(connectionState: self.socketConnectionState)

		case .connectionLost:
			self.socket?.connect()
		}
		
		return connectionToken
	}
	
	public func disconnect(forced: Bool) {
		
		self.socketConnectionState = .disconnected
		if forced {
			self.forceDisconnectSocket()
		} else {
			self.socket?.disconnect()
		}
	}
	
	public func receiveData(observer: @escaping SocketReceiveDataObserver) -> SocketReceiveDataToken {
		
		let token = SocketReceiveDataToken(receiveDataObserver: observer)
		self.receiveDataObservableTokens.append(token)
		return token
	}
	
	public func reconnect() {
		
		LOG.D("Web socket reconnect -> isConnected: \(self.isConnected)")
		
		self.recreateSocket()
		self.startReconnecting()
	}
	
	public func send(data: Data, completion: Completion?) {
		
		if self.socket == nil {
			LOG.E("Web socket was not initialized -> no data could be sent")
		}
		
		self.socket?.write(data: data) {
			LOG.D("Web socket send data successfully")
			
			completion?()
		}
	}
	
	public func update(socketToken: SocketToken, needsReconnect: Bool, reconnectManually: Bool) {
		
		// properties
		self.socketToken = socketToken
		
		self.recreateSocket()
		
		LOG.D("Web socket was updated -> needs reconnect: \(needsReconnect) | reconnect manually: \(reconnectManually)")
		if needsReconnect {
			if reconnectManually {
				self.startReconnecting()
			} else {
				self.socket?.connect()
			}
		}
	}
	
	public func unregister(token: SocketConnectionToken?) {
		
		guard let token = token,
			let index = self.connectionObservableTokens.firstIndex(where: { $0 == token }) else {
				return
			}
		
		self.connectionObservableTokens.remove(at: index)
	}
	
	public func unregister(token: SocketReceiveDataToken?) {
		
		guard let token = token,
			let index = self.receiveDataObservableTokens.firstIndex(where: { $0 == token }) else {
				return
		}
		
		self.receiveDataObservableTokens.remove(at: index)
	}
	
	public func unregisterAndDisconnectIfPossible(connectionToken: SocketConnectionToken?, receiveDataToken: SocketReceiveDataToken?) {
		
		self.unregister(token: connectionToken)
		self.diconnectIfPossible(receiveDataToken: receiveDataToken)
	}
	
	public func unregisterAndDisconnectIfPossible(connectionTokens: [SocketConnectionToken], receiveDataToken: SocketReceiveDataToken?) {
		
		connectionTokens.forEach {
			self.unregister(token: $0)
		}
		
		self.diconnectIfPossible(receiveDataToken: receiveDataToken)
	}
}
