//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

public struct TrustKitCertPinnedDomain {
    let domain: String
    let enforcePinning: Bool
    let includeSubDomains: Bool
    let hashes: [String]
    
    public init(domain: String,
                enforcePinning: Bool,
                includeSubDomains: Bool,
                hashes: [String]) {
        self.domain = domain
        self.enforcePinning = enforcePinning
        self.includeSubDomains = includeSubDomains
        self.hashes = hashes
    }
}
