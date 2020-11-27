//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation

enum DecodableError: Error {
	case emptyKeyPath
	case invalidKeyPath(keyPath: String)
	case invalidJson
}
