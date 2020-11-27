![MBNetworkKit](logo.jpg "Banner")

[![swift 5](https://img.shields.io/badge/swift-5-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![swift 5.1](https://img.shields.io/badge/swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![swift 5.2](https://img.shields.io/badge/swift-5.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![swift 5.3](https://img.shields.io/badge/swift-5.3-orange.svg?style=flat)](https://developer.apple.com/swift/)
![License](https://img.shields.io/cocoapods/l/MBNetworkKit)
![Platform](https://img.shields.io/cocoapods/p/MBNetworkKit)
![Version](https://img.shields.io/cocoapods/v/MBNetworkKit)
[![swift-package-manager](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://github.com/apple/swift-package-manager)

## Requirements

- Xcode 10.3 / 11.x / 12.x
- Swift 5.x
- iOS 12.0+

## Intended Usage

This module handles the communication from the MBSDK-Modules to the endpoints. It requests the required data and returns it, download images and handles the socketConnection.

## Installation

### CocoaPods

MBNetworkKit is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your `Podfile`:

```ruby
pod 'MBNetworkKit', '~> 3.0'
```

### Swift Package Manager

MBNetworkKit is available through [Swift Package Manager](https://swift.org/package-manager/). Once you have your Swift package set up, adding MBNetworkKit as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(name: "MBNetworkKit",
             url: "https://github.com/Daimler/MBSDK-NetworkKit-iOS.git",
			 .upToNextMajor(from: "3.0.0"))
]
```

## Contributing

We welcome any contributions.
If you want to contribute to this project, please read the [contributing guide](CONTRIBUTING.md).

## Code of Conduct

Please read our [Code of Conduct](https://github.com/Daimler/daimler-foss/blob/master/CODE_OF_CONDUCT.md) as it is our base for interaction.

## License

This project is licensed under the [MIT LICENSE](LICENSE).

## Provider Information

Please visit <https://mbition.io/en/home/index.html> for information on the provider.

Notice: Before you use the program in productive use, please take all necessary precautions,
e.g. testing and verifying the program with regard to your specific use.
The program was tested solely for our own use cases, which might differ from yours.
