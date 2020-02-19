#
# Be sure to run `pod lib lint BDTBasePlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BDTBasePlayer'
  s.version          = '0.3.47'
  s.summary          = '主端视频基本播放器封装 BDTBasePlayer.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

    s.homepage         = 'https://code.byted.org/TTIOS/BDTBasePlayer'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'pxx914' => 'panxiang@bytedance.com' }
    s.source           = { :git => 'git@code.byted.org:TTIOS/BDTBasePlayer', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
    s.source_files = 'BDTBasePlayer/Classes/**/*.{h,m,mm}'
    s.resources        = 'BDTBasePlayer/Assets/**/*.{png,plist}'
    s.prefix_header_contents = '#import "TTPlayerPCHHeader.h"'
    s.compiler_flags = '-Wno-nullability-completeness', '-Werror=incompatible-pointer-types'
end
