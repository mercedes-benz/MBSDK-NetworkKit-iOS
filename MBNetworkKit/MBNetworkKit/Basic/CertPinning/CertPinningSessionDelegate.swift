//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import TrustKit
import MBCommonKit

#if canImport(MBCommonKitLogger)
import MBCommonKitLogger
#endif

class CertPinningSessionDelegate: NSObject, URLSessionDelegate {

    private let trustKit: TrustKit
    
    init(trustKit: TrustKit) {
        self.trustKit = trustKit
    }
    
	func urlSession(_ session: URLSession,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        let didHandleChallenge = self.trustKit.pinningValidator.handle(challenge, completionHandler: { challengeDisposition, credential in
            if challengeDisposition == .cancelAuthenticationChallenge {
                MBLogger.shared.E("SSL certificate has been rejected. Posting 'SSLCertificateRejected' notification")
                
                NotificationCenter.default.post(name: Notification.Name.SSLCertificateRejected, object: nil)
            }
            
            completionHandler(challengeDisposition, credential)
        })

        if !didHandleChallenge {
            
            MBLogger.shared.E(
                """
                    TrustKit did not handle this challenge: perhaps it was not for server trust
                    or the domain was not pinned. Fall back to the default behavior.
                """)
            
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
