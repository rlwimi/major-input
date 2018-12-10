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
  system("sh Tools/Scripts/generate-acknowledgements.sh")
end
