#
# Be sure to run `pod lib lint TTFriendRelation.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTFriendRelation'
  s.version          = '0.2.10'
  s.summary          = '好友关系库'
  s.description      = '朋友关系库'


  s.homepage         = 'https://code.byted.org/TTIOS/tt_pod_friendRelation'
  s.license          = 'MIT'
  s.author           = { 'chaisong' => 'chaisong@bytedance.com' }
  s.source           = { :git => "git@code.byted.org:TTIOS/tt_pod_friendRelation.git", :tag => s.version.to_s }
  s.source_files     = 'TTFriendRelation/classes/**/*.{h,m}'
#  s.resources        = 'TTFriendRelation/classes/image.xcassets'
#  s.vendored_frameworks = 'Fabric', 'Crashlytics'


  s.ios.deployment_target = '7.0'
# s.public_header_files = 'TTFriendRelation/Classes/**/*.h'
# s.frameworks      = 'Crashlytics', 'Fabric'

  s.dependency 'TTPushAuthorizationManager'
  s.dependency 'TTNewsAccountBusiness'
  s.dependency 'TTPlatformBaseLib'
  s.dependency 'TTNetworkManager'
  s.dependency 'TTPlatformUIModel'
  s.dependency 'TTThemed'
  s.dependency 'Crashlytics'
  s.dependency 'TTEntry'
  s.dependency 'TTUGCFoundation/RequestMonitor'

# s.dependency 'TTEntry' 相互依赖了，先去掉
end
