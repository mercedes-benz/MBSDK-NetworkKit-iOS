//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Alamofire

protocol SocketNetworkReachabilityRepresentable {
	typealias StatusChange = () -> Void
	
	var statusChangedToReachable: StatusChange? { get set }
	
	init(host: String)
}

class SocketNetworkReachability: SocketNetworkReachabilityRepresentable {
	
	let manager: NetworkReachabilityManager?
	var statusChangedToReachable: StatusChange?
	
	
	// MARK: - Init
	
	required init(host: String) {
		
		self.manager = NetworkReachabilityManager(host: host)
		self.manager?.startListening(onUpdatePerforming: { [weak self] (status) in
			self?.handle(status: status)
		})
	}
	
	
	// MARK: - Helper
	
	private func handle(status: NetworkReachabilityManager.NetworkReachabilityStatus) {
		
		switch status {
		case .notReachable:
			LOG.D("Web socket network status -> notReachable")
			
		case .reachable(let connectionType):
			switch connectionType {
			case .ethernetOrWiFi:	LOG.D("Web socket network status -> reachable ethernet or wifi")
			case .cellular:			LOG.D("Web socket network status -> reachable cellular")
			}
			
			self.statusChangedToReachable?()
			
		case .unknown:
			LOG.D("Web socket network status -> unknown")
		}
	}
}
