// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "MBNetworkKit",
	platforms: [
		.iOS(.v12),
	],
	products: [
		.library(name: "MBNetworkKit",
				 targets: ["MBNetworkKit"])
	],
	dependencies: [
		.package(name: "MBCommonKit",
				 url: "https://github.com/Daimler/MBSDK-CommonKit-iOS.git",
				 .upToNextMajor(from: "3.0.0")),
		.package(url: "https://github.com/Alamofire/Alamofire.git",
				 .upToNextMajor(from: "5.0.0")),
		.package(url: "https://github.com/Alamofire/AlamofireImage.git",
				 .upToNextMajor(from: "4.0.0")),
		.package(url: "https://github.com/daltoniam/Starscream",
				 .upToNextMajor(from: "4.0.0")),
		.package(url: "https://github.com/datatheorem/TrustKit.git",
				 .upToNextMajor(from: "1.7.0")),
		.package(url: "https://github.com/Quick/Nimble.git",
				 .upToNextMajor(from: "8.0.0")),
		.package(url: "https://github.com/Quick/Quick.git",
				 .upToNextMajor(from: "2.0.0"))
	],
	targets: [
		.target(name: "MBNetworkKit",
				dependencies: [
					.byName(name: "MBCommonKit"),
					.product(name: "Alamofire", package: "Alamofire"),
					.product(name: "AlamofireImage", package: "AlamofireImage"),
					.product(name: "Starscream", package: "Starscream"),
					.product(name: "TrustKit", package: "TrustKit")
				],
				path: "MBNetworkKit/MBNetworkKit",
				exclude: ["Info.plist"],
				resources: [
					.copy("Basic/CertPinning/CertPinnedDomainHashes.plist")
				]),
		.testTarget(name: "MBNetworkKitTests",
					dependencies: [
						.byName(name: "Nimble"),
						.byName(name: "Quick"),
					],
					path: "MBNetworkKit/MBNetworkKitTests",
					exclude: ["Info.plist"])
	],
	swiftLanguageVersions: [.v5]
)
