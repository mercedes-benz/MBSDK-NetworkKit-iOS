//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import TrustKit

protocol DomainMapping {
    
    func map(domains: [TrustKitCertPinnedDomain]) -> [String: Any]?
}

class TrustKitDomainMapper: DomainMapping {
    
    private let minAmountOfHashesPerDomain = 2
    
    func map(domains: [TrustKitCertPinnedDomain]) -> [String: Any]? {
        
        guard hasRequiredAmountOfDomains(domains) else {
            // TrustKit crashes when we supply a config without domains
            return nil
        }
        
        guard hasRequiredAmountOfHashes(domains: domains) else {
            // TrustKit crashes when we don't supply at least two hashes per domain
            return nil
        }
        
        var result: [String: Any] = [kTSKSwizzleNetworkDelegates: false]
        result[kTSKPinnedDomains] = mapDomains(trustKitCertPinnedDomains: domains)
        return result
    }
    
    private func mapDomains(trustKitCertPinnedDomains: [TrustKitCertPinnedDomain]) -> [String: Any] {
        
        var domains: [String: Any] = [:]
        trustKitCertPinnedDomains.forEach { domain in
            domains[domain.domain] = [kTSKEnforcePinning: domain.enforcePinning, kTSKIncludeSubdomains: domain.includeSubDomains, kTSKPublicKeyHashes: domain.hashes]
        }
        
        return domains
    }
    
    private func hasRequiredAmountOfDomains(_ domains: [TrustKitCertPinnedDomain]) -> Bool {
        return !domains.isEmpty
    }
    
    private func hasRequiredAmountOfHashes(domains: [TrustKitCertPinnedDomain]) -> Bool {
        return domains.allSatisfy { domain -> Bool in
            return domain.hashes.count >= self.minAmountOfHashesPerDomain
        }
    }
}
