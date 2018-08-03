 #
# Be sure to run `pod lib lint TTPushAuthorizationManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTPushAuthorizationManager'
  s.version          = '0.1.3'
  s.summary          = 'TTPushAuthorizationManager'
  s.description      = 'TTPushAuthorizationManager'


  s.homepage         = 'https://code.byted.org/TTIOS/TTPushAuthorizationManager'
  s.license          = 'MIT'
  s.author           = { 'xuzichao' => 'xuzichao@bytedance.com' }
  s.source           = { :git => "git@code.byted.org:TTIOS/TTPushAuthorizationManager.git", :tag => s.version.to_s }
  s.source_files     = 'TTPushAuthorizationManager/Classes/**/*'
#  s.resources        = 'TTPushAuthorizationManager/Classes/image.xcassets'
#  s.vendored_frameworks = 'Fabric', 'Crashlytics'
  s.ios.deployment_target = '7.0'

# s.public_header_files = 'TTPushAuthorizationManager/Classes/**/*.h'
# s.frameworks      = 'Crashlytics', 'Fabric'
    
    s.dependency 'TTUIWidget'
    s.dependency 'TTTracker'
    s.dependency 'TTBaseLib'
    s.dependency 'TTPlatformBaseLib'
    s.dependency 'TTImage'
    s.dependency 'TTNewsAccountBusiness'
    s.dependency 'TTNetworkManager'
    
end
