//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

protocol CertPinnningConfig {
    
    var domains: [CertPinnedDomain] { get }
    var enforcePinning: Bool { get }
    var includeSubDomains: Bool { get }
}

struct CertPinnedDomain: Decodable {
    let domain: String
    let hashes: [String]
}
