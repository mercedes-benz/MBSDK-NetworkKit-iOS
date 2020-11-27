//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Alamofire
import MBCommonKit

public class SessionManagerFactory: SessionManagerBuilder {

    private let trustKitFactory: TrustKitFactoryRepresentable
    
    required public convenience init(config: SessionManagerConfig) {
        self.init(config: config, trustKitFactory: TrustKitFactory())
    }

    init(config: SessionManagerConfig, trustKitFactory: TrustKitFactoryRepresentable) {
        self.trustKitFactory = trustKitFactory
    }

    public func build() -> Session {
        return Session()
    }
}
