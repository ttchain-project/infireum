# Uncomment the next line to define a global platform for your project

platform :ios, '11.0'

def my_pods

    pod 'IQKeyboardManagerSwift'
    pod 'AlamofireImage'
    pod 'SwiftMoment'
    pod 'SwifterSwift'
    pod 'Cartography'
    pod 'HockeySDK'
    pod 'Moya/RxSwift'
    pod 'SwiftyJSON'
    pod 'RxCocoa'
    pod 'RxGesture'
    pod 'Firebase'
    pod 'ReachabilitySwift'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Toast-Swift', '~> 3.0.1'
    pod 'SkyFloatingLabelTextField'
    pod 'NVActivityIndicatorView'
    pod 'CryptoSwift'
    pod 'RxDataSources'
    pod 'Tabman'
    pod 'RxOptional'
    pod 'MZFormSheetPresentationController'
    pod 'Flurry-iOS-SDK/FlurrySDK'
    # pod 'Flurry-iOS-SDK/FlurryAds'
#    pod 'GzipSwift'
    pod 'EliteFramework'
    pod 'HDWalletKit'
    pod 'FLAnimatedImage', '~> 1.0'
    pod 'Starscream', '~> 3.0.2'
    pod 'JCore', '2.1.4-noidfa'
    pod 'JPush', '3.2.4-noidfa'
    pod 'libjingle_peerconnection'
    pod 'SocketRocket'
    pod 'GZIP', '~> 1.2'
end

target 'TTChain' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OfflineWallet
  my_pods

  target 'TTChainTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'TTChain_SIT' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OfflineWallet
   my_pods
end

target 'TTChain_UAT' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OfflineWallet
    my_pods
end

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

post_install do |installer|
    puts("Update debug pod settings to speed up build time 1")

    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.name == 'Debug'
                config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
            end
        end
    end

    puts("Update debug pod settings to speed up build time 2")
    Dir.glob(File.join("Pods", "**", "Pods*{debug,Private}.xcconfig")).each do |file|
        File.open(file, 'a') { |f| f.puts "\nDEBUG_INFORMATION_FORMAT = dwarf" }
    end
end
