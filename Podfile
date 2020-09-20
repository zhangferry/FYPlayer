# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = "NO"
      end
  end
end

target 'FYPlayer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'SnapKit'
  pod 'Masonry'
  pod 'NSObject+Rx'
  
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Kingfisher'
  
  # Debug
  pod 'FLEX', :configurations => ['Debug']
  pod 'LookinServer', :configurations => ['Debug']
  pod 'SwiftLint', :configurations => ['Debug']

  target 'FYPlayerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
