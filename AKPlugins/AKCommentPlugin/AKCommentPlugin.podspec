#
# Be sure to run `pod lib lint AKCommentPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKCommentPlugin'
  s.version          = '0.1.0'
  s.summary          = '爱看评论业务插件'
  s.description      = '爱看评论业务插件'

  s.homepage         = 'https://github.com/fengjingjun/AKCommentPlugin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/AKCommentPlugin.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Classes/**/*'
  

end
