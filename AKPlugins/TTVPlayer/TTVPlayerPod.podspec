#
# Be sure to run `pod lib lint TTVPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
      s.name             = 'TTVPlayerPod'
      s.version          = '1.1.62'
      s.summary          = '西瓜播放器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

      s.description      = <<-DESC
    TODO: Add long description of the pod here.
                           DESC

      s.homepage         = 'git@code.byted.org:video_iOS/TTVPlayer.git'
      s.license          = { :type => 'B', :file => 'LICENSE' }
      s.author           = { 'pxx914' => 'panxiang@bytedance.com' }
      s.source           = { :git => 'git@code.byted.org:video_iOS/TTVPlayer.git', :tag => s.version.to_s }
      s.ios.deployment_target = '8.0'
      s.resource_bundles = {'TTVPlayerResource' => ['TTVPlayer/Assets/**/*.{xib,storyboard,imageset,xcassets,png}', 'TTVPlayer/Assets/**/*.json','TTVPlayer/Assets/**/*.plist']}
      s.source_files = 'TTVPlayer/Classes/TTVPlayer{,+Engine,+Part,+CacheProgress,+BecomeResignActive}.{h,m}','TTVPlayer/Classes/TTVPlayerCustomPartDelegate.h','TTVPlayer/Classes/TTVPlayerCustomViewDelegate.h','TTVPlayer/Classes/TTVPlayerDefine.h','TTVPlayer/Classes/TTVPlayerKitHeader.h'
      s.subspec 'Base' do |ss|
          ss.source_files = 'TTVPlayer/Classes/Base/**/*'
          end
      s.subspec 'Parts' do |ss|
          ss.source_files = 'TTVPlayer/Classes/Parts/**/*'
          end
      s.subspec 'ReduxKit' do |ss|
          ss.source_files = 'TTVPlayer/Classes/ReduxKit/*'
          end
      s.compiler_flags = '-Werror=protocol', '-Werror=objc-protocol-property-synthesis', '-Werror=objc-property-implementation', '-Werror=incompatible-pointer-types', '-Werror=return-type'
      s.prefix_header_contents = [
        '#import "TTVPlayerPrefix.h"'
    ]
    
end
