#
# Be sure to run `pod lib lint TTUIWidget.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTUIWidget'
  s.version          = '0.1.0'
  s.summary          = '爱看ui组件库'
  s.description      = '爱看ui组件库'

  s.homepage         = 'http://code.byted.org/TTIOS/tt_pods_ui'
  s.license          = 'MIT'
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => "git@code.byted.org:TTIOS/tt_pods_ui.git", :tag => s.version.to_s }
  s.source_files     = 'Classes/**/*.{h,m}'
#  s.vendored_frameworks = 'Fabric', 'Crashlytics'

  s.ios.deployment_target = '8.0'
#  s.public_header_files = 'TTUIWidget/Classes/**/*.h'

s.subspec 'TTIndicatorView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/UIWidget/TTIndicatorView/*.{h,m}'
    ss.public_header_files = 'Classes/UIWidget/TTIndicatorView/*.h'
end

  s.ios.resource_bundle = {
    'TTUIWidgetResources' => ['Assets/**/*.{xib,png,bundle,json}']
  }

#s.frameworks      = 'Crashlytics', 'Fabric'
  s.dependency 'TTBaseLib'
  s.dependency 'TTThemed'
  s.dependency 'TTImage'
  s.dependency 'TTRoute'
  s.dependency 'TTVerifyKit'
  s.dependency 'KVOController'
  s.dependency 'Masonry', '1.0.1'
  s.dependency "TTKitchen"
  s.dependency 'lottie-ios'
end
