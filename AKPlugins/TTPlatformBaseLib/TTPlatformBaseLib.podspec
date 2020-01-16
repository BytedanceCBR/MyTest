#
# Be sure to run `pod lib lint TTPlatformBaseLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTPlatformBaseLib'
  s.version          = '0.2.29'
  s.summary          = '平台化基础库'
  s.description      = '平台化基础库'


  s.homepage         = 'https://code.byted.org/TTIOS/tt_pod_platformBaseLib'
  s.license          = 'MIT'
  s.author           = { 'xuzichao' => 'xuzichao@bytedance.com' }
  s.source           = { :git => "git@code.byted.org:TTIOS/tt_pod_platformBaseLib.git", :tag => s.version.to_s }
  s.source_files     = 'TTPlatformBaseLib/Classes/**/*.{h,m}'
  s.resources        = 'TTPlatformBaseLib/Resource/new_icon.ttf','TTPlatformBaseLib/Resource/290-cai978.ttf','TTPlatformBaseLib/Resource/ChatroomIconFont.ttf','TTPlatformBaseLib/Resource/iconfont.ttf'
#  s.vendored_frameworks = 'Fabric', 'Crashlytics'


s.subspec 'TTURLDomainHelper' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformBaseLib/TTURLDomainHelper/*.{h,m}'
    ss.public_header_files = 'TTPlatformBaseLib/TTURLDomainHelper/*.h'
end


s.subspec 'TTProfileFillManager' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformBaseLib/TTProfileFillManager/*.{h,m}'
    ss.public_header_files = 'TTPlatformBaseLib/TTProfileFillManager/*.h'
end

s.subspec 'TTIconFontDefine' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformBaseLib/TTIconFontDefine/*.{h,m}'
    ss.public_header_files = 'TTPlatformBaseLib/TTIconFontDefine/*.h'
end


s.subspec 'TTTrackerWrapper' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'TTPlatformBaseLib/TTTrackerWrapper/*.{h,m}'
    ss.public_header_files = 'TTPlatformBaseLib/TTTrackerWrapper/*.h'
   # ss.dependency 'TTTracker'
end


  s.ios.deployment_target = '9.0'
# s.public_header_files = 'TTPlatformBaseLib/Classes/**/*.h'
# s.frameworks      = 'Crashlytics', 'Fabric'

  #  s.dependency 'SSZipArchive', '~> 1.6.2'
end
