#
# Be sure to run `pod lib lint TTAvatar.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTAvatar'
  s.version          = '0.1.0'
  s.summary          = '爱看头像组件库'
  s.description      = '爱看头像组件库'

  s.homepage         = 'https://github.com/fengjingjun/TTAvatar'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/TTAvatar.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'Classes/**/*'
  


end
