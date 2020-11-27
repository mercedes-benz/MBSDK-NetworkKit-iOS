//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import UIKit.UIImage

// MARK: - NetworkingImage

public protocol NetworkingImage {
	
	@discardableResult
	func request(router: EndpointRouter, completion: @escaping (Swift.Result<UIImage, MBError>) -> Void) -> URLSessionTask?
    
    @discardableResult
    func request(router: EndpointRouter, completion: @escaping (Swift.Result<(value: Data, eTag: String?), MBError>) -> Void) -> URLSessionTask?
}
