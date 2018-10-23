#
# Be sure to run `pod lib lint TTPlatformUIModel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTPlatformUIModel'
  s.version          = '0.2.39'
  s.summary          = '平台化UIModel库'
  s.description      = '平台化UIModel库'


  s.homepage         = 'https://code.byted.org/TTIOS/tt_pod_platformUIModel'
  s.license          = 'MIT'
  s.author           = { 'xuzichao' => 'xuzichao@bytedance.com' }
  s.source           = { :git => "git@code.byted.org:TTIOS/tt_pod_platformUIModel.git", :tag => s.version.to_s }
  s.source_files     = 'TTPlatformUIModel/Classes/**/*.{h,m}'
#  s.resources        = 'TTPlatformUIModel/Classes/image.xcassets'
#  s.vendored_frameworks = 'Fabric', 'Crashlytics'


s.subspec 'TTActionSheet' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTActionSheet/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTActionSheet/*.h'
end

s.subspec 'TTModel' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTModel/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTModel/*.h'
end

s.subspec 'TTBackButtonView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTBackButtonView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTBackButtonView/*.h'
end

s.subspec 'TTBubbleView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTBubbleView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTBubbleView/*.h'
end

s.subspec 'TTFeedDislikeView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTFeedDislikeView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTFeedDislikeView/*.h'
end

s.subspec 'TTLabel' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTLabel/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTLabel/*.h'
end

s.subspec 'TTSeachBarView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTSeachBarView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTSeachBarView/*.h'
end

s.subspec 'HPGrowingTextView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/HPGrowingTextView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/HPGrowingTextView/*.h'
end

s.subspec 'TTAssetView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTAssetView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTAssetView/*.h'
end

s.subspec 'TTHeaderScrollView' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTHeaderScrollView/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTHeaderScrollView/*.h'
end

s.subspec 'TTImageDetectorViewController' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTImageDetectorViewController/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTImageDetectorViewController/*.h'
end

s.subspec 'TTCategory' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTCategory/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTCategory/*.h'
end

s.subspec 'TTDetailViewController' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformUIModel/TTDetailViewController/*.{h,m}'
    ss.public_header_files = 'TTPlatformUIModel/TTDetailViewController/*.h'
end

  s.ios.deployment_target = '7.0'

# s.public_header_files = 'TTPlatformUIModel/Classes/**/*.h'
# s.frameworks      = 'Crashlytics', 'Fabric'
    s.dependency 'TTBaseLib'
    s.dependency 'TTUIWidget'
    s.dependency 'TTImage'
    s.dependency 'MJExtension'
    s.dependency 'TTRoute'
    s.dependency 'TTEntityBase'
    s.dependency 'JSONModel'
    s.dependency 'TTDialogDirector/Core'
end
