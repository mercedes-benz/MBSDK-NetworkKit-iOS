//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Quick
import Nimble
@testable import MBNetworkKit
@testable import TrustKit

class DomainMapperTests: QuickSpec {
    
    override func spec() {
        
        var subject: TrustKitDomainMapper!
        
        beforeEach() {
            subject = TrustKitDomainMapper()
        }
        
        describe("when supplied empty domains") {
            it("should return with nil since TrustKit crashes when initialized with a config with no pinned domains") {
                expect(subject.map(domains: [])).to(beNil())
            }
        }
        
        context("when supplied 1 domain") {
            
            describe("with 0 hashes") {
                let domain = TrustKitCertPinnedDomain(domain: "Testdomain", enforcePinning: true, includeSubDomains: true, hashes: [])
                it("should return with nil since TrustKit crashes when initialized with a config with zero hashes for a domain") {
                    expect(subject.map(domains: [domain])).to(beNil())
                }
            }
            
            describe("with 1 hash") {
                let domain = TrustKitCertPinnedDomain(domain: "Testdomain", enforcePinning: true, includeSubDomains: true, hashes: ["HXXQgxueCIU5TTLHob/bPbwcKOKw6DkfsTWYHbxbqTY="])
                
                it("should return with nil since TrustKit crashes when initialized with a config with only one hash for a domain") {
                    expect(subject.map(domains: [domain])).to(beNil())
                }
            }
            
            describe("with 2 hashes") {
                let hashes = ["HXXQgxueCIU5TTLHob/bPbwcKOKw6DkfsTWYHbxbqTY=", "0SDf3cRToyZJaMsoS17oF72VMavLxj/N7WBNasNuiR8="]
                let domain = TrustKitCertPinnedDomain(domain: "Testdomain", enforcePinning: true, includeSubDomains: true, hashes: hashes)
                
                it("should map to a valid TrustKit config with 1 domain") {
                    guard let result = subject.map(domains: [domain]) else {
                        fail()
                        return
                    }
                    
                    let swizzling = result[kTSKSwizzleNetworkDelegates]
                    expect(swizzling as? Bool).toNot(beNil())
                    expect(swizzling as? Bool).to(beFalse())
                    
                    guard let domains = result[kTSKPinnedDomains] as? [String: Any] else {
                        fail()
                        return
                    }
                    
                    expect(domains.count).to(equal(1))
                    
                    guard let domainConfig = domains["Testdomain"] as? [String: Any] else {
                        fail()
                        return
                    }
                    
                    expect(domainConfig[kTSKEnforcePinning] as? Bool).to(equal(domain.enforcePinning))
                    expect(domainConfig[kTSKIncludeSubdomains] as? Bool).to(equal(domain.includeSubDomains))
                    
                    guard let publicKeyHashes = domainConfig[kTSKPublicKeyHashes] as? [String] else {
                        fail()
                        return
                    }
                    
                    expect(publicKeyHashes).to(contain(hashes))
                    expect(publicKeyHashes.count).to(equal(hashes.count))
                }
            }
        }
    }

}
