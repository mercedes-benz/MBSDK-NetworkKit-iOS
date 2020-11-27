//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import UIKit
import AlamofireImage

public protocol ImageLoadable {
	
	var imageLoadableView: UIImageView { get }
	
	func cancel()
	func loadImage(url: URL?, placeholderImage: UIImage?, runImageTransitionIfCached: Bool)
}


// MARK: - Extension

public extension ImageLoadable {
	
	func cancel() {
		self.imageLoadableView.af.cancelImageRequest()
	}
	
	func loadImage(url: URL?, placeholderImage: UIImage?, runImageTransitionIfCached: Bool = true) {
		
		self.cancel()
		
		guard let url = url else {
			return
		}
		
		self.imageLoadableView.af.setImage(withURL: url,
										   placeholderImage: placeholderImage,
										   imageTransition: .crossDissolve(0.5),
										   runImageTransitionIfCached: runImageTransitionIfCached)
	}
}
