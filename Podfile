# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def metastones_pods
  pod 'IQKeyboardManagerSwift'
  pod 'Kingfisher'
  pod 'KeychainAccess'
  pod 'FSPagerView'
  pod 'HandyJSON', '~> 5.0.0'
  pod 'Codextended'
  pod 'FittedSheets'
  pod 'ZXingObjC'
  pod 'ScrollableSegmentedControl'
  pod 'lottie-ios'
  pod 'SVProgressHUD'
end

target '[D]Metastones' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for [D]Metastones
  metastones_pods
end

target 'Metastones' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Metastones
  metastones_pods

  target 'MetastonesTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MetastonesUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
