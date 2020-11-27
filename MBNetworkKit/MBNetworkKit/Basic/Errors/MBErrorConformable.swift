//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

/// Presentation of conformable error
public protocol MBErrorConformable: Decodable {
    
    /// Description of the error
    var errorDescription: String? { get }
}
