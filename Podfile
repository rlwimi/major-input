use_frameworks!
inhibit_all_warnings!
ENV['COCOAPODS_DISABLE_STATS'] = "true"

def app_pods
  pod 'Anchorage'
  pod 'HTMLEntities', :git => 'https://github.com/IBM-Swift/swift-html-entities.git'
  pod 'Kingfisher'
  pod 'ReactiveCocoa'
  pod 'ReactiveSwift'
  pod 'STRegex'
  pod 'Strongify'
  pod 'SwiftyJSON'
end

def testing_pods
  pod 'Quick'
  pod 'Nimble'
end

target 'MajorInput' do

  platform :ios, '11.0'

  app_pods
end

target 'MajorInputTests' do

  platform :ios, '11.0'

  inherit! :search_paths

  app_pods
  testing_pods
end

post_install do |installer|

  # Mark older-Swift-compatible dependencies as Swift 5, to prevent Xcode from
  # suggesting a Swift 5 migration is available because of these targets.
  installer.pods_project.targets.each do |target|
    next unless [
      'Nimble',
      'ReactiveSwift',
      'Result'
    ].include? target.name

    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end

  # Generate dependencies' license acknowledgements settings bundle
  system("sh Tools/Scripts/generate-acknowledgements.sh")
end
