# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

target 'Yamb' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Yamb

pod 'Firebase'
pod 'Firebase/Core'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Messaging'
pod 'ChartboostSDK'
pod 'Fabric'
pod 'Crashlytics'
pod 'SwiftyStoreKit'
pod 'Bolts'
pod 'FBSDKCoreKit'
pod 'FBSDKShareKit'
pod 'FBSDKLoginKit'
pod 'Starscream', '~> 2.0.0'
pod 'SwiftyJSON'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
