platform :ios, '14.0'

# ignore all warnings from all pods
# inhibit_all_warnings!
use_frameworks!

source 'https://github.com/VIPAAR/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

# pod 'AdaptiveCards', '2000.9.8'

pod 'MicrosoftFluentUI', '0.3.9'

target 'vipaar-MicrosoftFluentUI' do
  project 'vipaar-MicrosoftFluentUI.xcodeproj'
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
              config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
              config.build_settings['SWIFT_INSTALL_OBJC_HEADER'] = 'YES'
            end
        end
    end
end
