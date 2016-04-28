source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'MMDrawerController', :git => 'https://github.com/osjup/MMDrawerController.git'
    pod 'RealmSwift', '~> 0.98.5'
    pod 'Alamofire', '~> 3.0'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'Swifternalization', '~> 1.3.1'
end

target 'StudyBox_iOS' do
    shared_pods
    
    pod 'Fabric', '~> 1.6.7'
    pod 'Crashlytics', '~> 3.7.0'
    pod 'Reachability', '~> 3.2'
end

target 'StudyBox_iOSTests' do
    shared_pods
end

