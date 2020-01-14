#
# Be sure to run `pod lib lint TTOldModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTCompatibleModule'
  s.version          = '0.0.1'
  s.summary          = 'TT旧版本兼容库'
  s.description      = 'TT旧版本兼容库'

  s.homepage         = 'http://toutiao.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'suruiqiang' => 'suruiqiang@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_monitor.git', :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Classes/**/*'

end
