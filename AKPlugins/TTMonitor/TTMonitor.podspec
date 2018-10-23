#
# Be sure to run `pod lib lint TTMonitor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTMonitor'
  s.version          = '0.7.9.44'
  s.summary          = '爱看监控库'
  s.description      = '爱看监控库'

  s.homepage         = 'http://toutiao.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'suruiqiang' => 'suruiqiang@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_monitor.git', :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Classes/**/*'

  s.dependency 'TTNetworkManager'
  s.dependency 'FMDB', '2.6.2'
  s.dependency 'TTReachability'
end
