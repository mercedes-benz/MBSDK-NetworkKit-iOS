//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension NetworkLayer {
	
	// MARK: - Download
	
    /// Download an image for the given url
    ///
    /// - Parameter url: url of the image
	public static func downloadImage(url: URL) {
		
		let request = URLRequest(url: url)
		self.downloadImages(requests: [request])
	}
	
    
    /// Download an image for the given URLRequest
    ///
    /// - Parameter request: instance of URLRequest
	public static func downloadImage(request: URLRequest) {
		self.downloadImages(requests: [request])
	}
	
    
    /// Download multiple images from an array of urls
    ///
    /// - Parameter urls: array of URL
	public static func downloadImages(urls: [URL]) {
		
		let requests = urls.map { URLRequest(url: $0) }
		ImageDownloader.default.download(requests)
	}
	
    
    /// Download multiple images from an array of URLRequest
    ///
    /// - Parameter urls: array of URLRequest
	public static func downloadImages(requests: [URLRequest]) {
		ImageDownloader.default.download(requests)
	}
	
	
	// MARK: - Request
	
    /// Creates a DataRequest for the given EndpointRouter object
    ///
    /// - Parameters:
    ///   - router: Instance of EndpointRouter
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - imageScale: Scale for the image (default == scale from device)
    ///   - inflateResponseImage: (default == true)
    ///   - queue: (default == nil)
    ///   - completion: NetworkResult with an UIImage
    /// - Returns: URLSessionTask (optional, discardable)
	@discardableResult
	public static func requestImage(router: EndpointRouter,
                                    sessionManager: Session? = nil,
                                    imageScale: CGFloat = DataRequest.imageScale,
                                    inflateResponseImage: Bool = true,
									queue: DispatchQueue = .main,
                                    completion: @escaping (NetworkResult<UIImage>) -> Void) -> URLSessionTask? {
		
		guard let urlRequest = router.urlRequest else {
			
			completion(.failure(self.invalidUrlError(router: router)))
			return nil
		}
		
		return self.requestImage(urlRequest: urlRequest, sessionManager: sessionManager, imageScale: imageScale, inflateResponseImage: inflateResponseImage, queue: queue, completion: completion)
	}
	
    
    /// Creates a DataRequest for the given url
    ///
    /// - Parameters:
    ///   - url: Url of the requested image
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - method: HTTPMethodType (default == .get)
    ///   - parameters: Dictionary of request-parameters (default == nil)
    ///   - encoding: ParameterEncodingType (default == .url)
    ///   - headers: Dictionary of request headers (default == nil)
    ///   - imageScale: Scale for the image (default == scale from device)
    ///   - inflateResponseImage: (default == true)
    ///   - queue: (default == nil)
    ///   - completion: NetworkResult with an UIImage
    /// - Returns: URLSessionTask (optional, discardable)
	@discardableResult
	public static func requestImage(url: URL,
                                    sessionManager: Session? = nil,
                                    method: HTTPMethodType = .get,
                                    parameters: [String: Any]? = nil,
                                    encoding: ParameterEncodingType = .url(type: .standard),
                                    headers: [String: String]? = nil,
                                    imageScale: CGFloat = DataRequest.imageScale,
                                    inflateResponseImage: Bool = true,
                                    queue: DispatchQueue = .main,
                                    completion: @escaping (NetworkResult<UIImage>) -> Void) -> URLSessionTask? {
		
		ImageResponseSerializer.addAcceptableImageContentTypes(["image/jpg"])
		let request = self.request(url: url, sessionManager: sessionManager, method: method, parameters: parameters, encoding: encoding, headers: headers)
			.responseImage(imageScale: imageScale, inflateResponseImage: inflateResponseImage, queue: queue) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(.failure(error))
				case .success(let value):	completion(.success(value))
				}
		}
		
		return request.task
	}
	
    
    /// Creates a DataRequest for the given URLRequest object
    ///
    /// - Parameters:
    ///   - urlRequest: Instance of URLRequest
    ///   - sessionManager: Alamofire's Session (default == nil)
    ///   - imageScale: Scale for the image (default == scale from device)
    ///   - inflateResponseImage: (default == true)
    ///   - queue: (default == nil)
    ///   - completion: NetworkResult with an UIImage
    /// - Returns: URLSessionTask (optional, discardable)
	@discardableResult
	public static func requestImage(urlRequest: URLRequest,
                                    sessionManager: Session? = nil,
                                    imageScale: CGFloat = DataRequest.imageScale,
                                    inflateResponseImage: Bool = true,
                                    queue: DispatchQueue = .main,
                                    completion: @escaping (NetworkResult<UIImage>) -> Void) -> URLSessionTask? {
		
		ImageResponseSerializer.addAcceptableImageContentTypes(["image/jpg"])
		let request = self.request(urlRequest: urlRequest, sessionManager: sessionManager)
			.responseImage(imageScale: imageScale, inflateResponseImage: inflateResponseImage, queue: queue) { (response) in
				
				switch response.result {
				case .failure(let error):	completion(.failure(error))
				case .success(let value):	completion(.success(value))
				}
		}
		
		return request.task
	}
    
    /// Upload an image
    ///
    /// - Parameters:
    ///   - urlRequest: URLRequest object
    ///   - data: The data of the image
    ///   - sessionManager: Alamofire's Session
    ///   - completion: ProgressNonValueResult
    public static func uploadImage(urlRequest: URLRequest,
                                   data: Data,
                                   sessionManager: Session? = nil,
                                   completion: @escaping (ProgressResult) -> Void) {
        
        let uploadRequest: UploadRequest = sessionManager?.upload(data, with: urlRequest) ?? AF.upload(data, with: urlRequest)
        uploadRequest.validate { (request, response, data) -> Request.ValidationResult in
            return NetworkLayer.validation(request: request, response: response, data: data)
        }.uploadProgress { (progress) in
            completion(.progress(progress.fractionCompleted))
        }.response { (response) in
                
            if let error = response.error {
                completion(.failure(MBError(description: error.localizedDescription, type: .unknown)))
            } else {
                completion(.success)
            }
        }
    }
}
