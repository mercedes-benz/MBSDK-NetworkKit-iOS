Pod::Spec.new do |s|
  s.name          = "MBNetworkKit"
  s.version       = "3.0.0"
  s.summary       = "MBNetworkKit is a public Pod of MBition GmbH"
  s.description   = "This module handles the communication from the MBSDK-Modules to the endpoints. It requests the required data and returns it, download images and handles the socketConnection."
  s.homepage      = "https://mbition.io"
  s.license       = 'MIT'
  s.author        = { "MBition GmbH" => "info_mbition@daimler.com" }
  s.source        = { :git => "https://github.com/Daimler/MBSDK-NetworkKit-iOS.git", :tag => String(s.version) }
  s.platform      = :ios, '12.0'
  s.swift_version = ['5.0', '5.1', '5.2', '5.3']

  s.source_files = 'MBNetworkKit/MBNetworkKit/**/**/*.{swift,xib}'
  s.resource = 'MBNetworkKit/MBNetworkKit/**/**/CertPinnedDomainHashes.plist'

  # dependencies to MBCommonKit
  s.dependency 'MBCommonKit/Logger', '~> 3.0'
  s.dependency 'MBCommonKit/Protocols', '~> 3.0'

  # public dependencies
  s.dependency 'Alamofire', '~> 5.0'
  s.dependency 'AlamofireImage', '~> 4.0'
  s.dependency 'Starscream', '~> 4.0'
  s.dependency 'TrustKit', '~> 1.6'
end
