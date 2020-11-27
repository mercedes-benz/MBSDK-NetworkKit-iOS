//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import Starscream
import TrustKit

class SocketCertificatePinner: CertificatePinning {
    
    private let trustKit: TrustKit
    
    init(trustKitFactory: TrustKitFactoryRepresentable = TrustKitFactory()) {
        self.trustKit = trustKitFactory.build()
    }
    
    func evaluateTrust(trust: SecTrust, domain: String?, completion: ((PinningState) -> Void)) {
        
        guard let domain = domain else {
            LOG.E("Trying to pin websocket but the provided domain is nil.")
            completion(.success)
            return
        }
        
        let trustDecision = self.trustKit.pinningValidator.evaluateTrust(trust, forHostname: domain)
        
        switch trustDecision {
        case .domainNotPinned:
            LOG.I("Websocket for domain \(domain) not pinned.")
            completion(.success)
            
        case .shouldAllowConnection:
            LOG.D("Websocket for domain \(domain) passed cert pinning verification or cert pinning is disabled.")
            completion(.success)
            
        case .shouldBlockConnection:
            LOG.E("Websocket for domain \(domain) did FAIL cert pinning verification.")
            
            // ignoring the cert result for now..
            completion(.success)
            
        @unknown default:
            LOG.E("TrustKit pinning validator returned unkown trustDecision: \(trustDecision).")
            completion(.success)
        }
    }
}
