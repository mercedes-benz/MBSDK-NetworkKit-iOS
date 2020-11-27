//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Quick
import Nimble
@testable import MBNetworkKit
@testable import TrustKit

class DefaultCertPinningConfigTests: QuickSpec {
    
    override func spec() {
        
        var config: DefaultCertPinningConfig!
        
        beforeEach {
            config = DefaultCertPinningConfig()
        }
        
        it("should include all required domains") {
            expect(config.domains.map { $0.domain }).to(contain(
                "risingstars.daimler.com",
                "risingstars-int.daimler.com",
                "risingstars-ap.daimler.com",
                "risingstars-int-ap.daimler.com",
                "risingstars-amap.daimler.com",
                "risingstars-int-amap.daimler.com",
                "risingstars-cn.daimler.com",
                "risingstars-int-cn.daimler.com"))
        }
        
        it("should have enforcePinning disabled") {
            expect(config.enforcePinning) == false
        }
        
        it("should include subdomains") {
            expect(config.includeSubDomains) == true
        }
        
    }
}
