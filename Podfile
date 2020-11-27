source 'https://github.com/CocoaPods/Specs.git'

platform :ios,'12.0'
use_frameworks!
inhibit_all_warnings!
workspace 'MBNetworkKit'


def pods
  # code analyser
  pod 'SwiftLint', '~> 0.30'

  # public libs
  pod 'Alamofire', '~> 5.0'
  pod 'AlamofireImage', '~> 4.0'
  pod 'Starscream', '~> 4.0'
  pod 'TrustKit', '~> 1.6'

  # module
  pod 'MBCommonKit/Logger', '~> 3.0'
  pod 'MBCommonKit/Protocols', '~> 3.0'
end


target 'Example' do
	project 'Example/Example'
	
  pods
end

target 'MBNetworkKit' do
	project 'MBNetworkKit/MBNetworkKit'
	
  pods

	target 'MBNetworkKitTests' do
    pod 'Nimble', '~> 8.0'
		pod 'Quick', '~> 2.0'
  end
end
