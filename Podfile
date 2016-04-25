source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'MMDrawerController', '~> 0.6.0'
    pod 'RealmSwift', '~> 0.98.5'
    pod 'Alamofire', '~> 3.0'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
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

target 'StudyBox Watch App Extension' do
    platform :watchos, '2.0'
    pod 'RealmSwift', '~> 0.98.5'
end
