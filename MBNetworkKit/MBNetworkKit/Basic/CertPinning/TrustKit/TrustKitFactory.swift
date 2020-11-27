//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import TrustKit
import MBCommonKit

#if canImport(MBCommonKitLogger)
import MBCommonKitLogger
#endif

protocol TrustKitFactoryRepresentable {
    func build() -> TrustKit
}

class TrustKitFactory: TrustKitFactoryRepresentable {

    private let domainMapper: DomainMapping
    private let config: CertPinnningConfig
    
    init(config: CertPinnningConfig = DefaultCertPinningConfig(),
         domainMapper: DomainMapping = TrustKitDomainMapper()) {
        
        self.config = config
        self.domainMapper = domainMapper
    }
    
    func build() -> TrustKit {
        
        let mappedDomains = self.config.domains.map { domain -> TrustKitCertPinnedDomain in
            
            return TrustKitCertPinnedDomain(domain: domain.domain, enforcePinning: self.config.enforcePinning, includeSubDomains: self.config.includeSubDomains, hashes: domain.hashes)
        }
        
        guard let trustKitDomains = domainMapper.map(domains: mappedDomains) else {
            MBLogger.shared.E("!! Cert Pinning configuration is invalid. !!")
            fatalError("!! Cert Pinning configuration is invalid. !!")
        }
        
        return TrustKit.init(configuration: trustKitDomains)
    }
}
