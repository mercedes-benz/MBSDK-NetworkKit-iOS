//
//  Copyright © 2020 MBition GmbH. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - NetworkingDownload

extension NetworkService: NetworkingDownload {
    
	public func download(urlRequest: URLRequest, completion: @escaping (Swift.Result<URL, MBError>) -> Void) -> URLSessionTask? {
		return download(urlRequest: urlRequest)?
			.response { (response) in
				
				if let error = response.error {
					completion(.failure(MBError(description: error.localizedDescription, type: .unknown)))
				} else if let url = response.fileURL {
					completion(.success(url))
				}
			}
			.task
	}
	
	
	// MARK: - Helper
	
	private func download(urlRequest: URLRequest) -> DownloadRequest? {
		
		let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
		return sessionManager
			.download(urlRequest, to: destination)
			.validate { (request, response, _) -> Request.ValidationResult in
				return self.validationResult(request: request,
											 response: response,
											 data: nil)
			}
	}
}


// MARK: - NetworkingUpload

extension NetworkService: NetworkingUpload {
	
    public func upload(urlReqeust: URLRequest, data: Data, completion: @escaping (Swift.Result<Void, MBError>) -> Void) -> URLSessionTask? {
		return upload(urlReqeust: urlReqeust, data: data)?
			.response { (response) in
				if let error = response.error {
					completion(.failure(MBError(description: error.localizedDescription, type: .unknown)))
				} else {
					completion(.success(()))
				}
			}
			.task
	}
	
	
	// MARK: - Helper

	private func upload(urlReqeust: URLRequest, data: Data) -> UploadRequest? {
		return sessionManager
			.upload(data, with: urlReqeust)
			.validate(validateHttpResponse())
	}
}
