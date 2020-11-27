//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

public protocol SessionManagerBuilder {
    
    init(config: SessionManagerConfig)
    func build() -> Session
}

public struct SessionManagerConfig {

    public init() {
    }

}
