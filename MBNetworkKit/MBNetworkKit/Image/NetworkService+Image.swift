//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension NetworkService: NetworkingImage {
	
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
	public func request(router: EndpointRouter, completion: @escaping (Swift.Result<UIImage, MBError>) -> Void) -> URLSessionTask? {
		
		ImageResponseSerializer.addAcceptableImageContentTypes(["image/jpg"])
		return self.rq(router: router, completion: completion)?
			.responseImage(completionHandler: dataResponseHandler(errorType: APIError.self, completion: completion))
			.task
	}
    
    /// NetworkService is an MBMobileSDK internal Networking abstraction. Do not use in your own app!
    public func request(router: EndpointRouter, completion: @escaping (Swift.Result<(value: Data, eTag: String?), MBError>) -> Void) -> URLSessionTask? {
        
		ImageResponseSerializer.addAcceptableImageContentTypes(["image/jpg"])
		return self.rq(router: router, completion: completion)?
            .responseData(completionHandler: dataResponseHandler(errorType: APIError.self, completion: completion))
            .task
    }
}
