//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

final class DefaultCertPinningConfig: CertPinnningConfig {
    
    let domains: [CertPinnedDomain]
    
    var enforcePinning: Bool
    
    var includeSubDomains: Bool
    
    private static let certPinnedDomainHashesPlistName = "CertPinnedDomainHashes"
    private static let certPinnedDomainHashesPlistExtension = "plist"
    
    /// reads default domains from CertPinnedDomainHashes.plist and initializes config with default values
    convenience init() {
        
        let podBundle = Bundle(for: DefaultCertPinningConfig.self)
        guard let url = podBundle.url(forResource: Self.certPinnedDomainHashesPlistName,
                                      withExtension: Self.certPinnedDomainHashesPlistExtension) else {
            fatalError("!! Could not load Cert Pinning configuration file !!")
        }
        
        let plistDecoder = PropertyListDecoder()
        
        do {
            let data = try Data.init(contentsOf: url)
            let decodedDomains = try plistDecoder.decode([CertPinnedDomain].self, from: data)
            self.init(domains: decodedDomains)
        } catch {
            fatalError("!! Could not decode Cert Pinning configuration file !!")
        }
    }
    
    init(domains: [CertPinnedDomain], enforcePinning: Bool = false, includeSubDomains: Bool = true) {
        self.domains = domains
        self.enforcePinning = enforcePinning
        self.includeSubDomains = includeSubDomains
    }
}
