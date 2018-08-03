#
# Be sure to run `pod lib lint TOTFactoryConfigurator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'BDTSharedHeaders'
    s.version          = '0.1.0'
    s.summary          = 'BDTSharedHeaders是用来存放跨pod调用的Header，只包含Header'

    s.description      = <<-DESC
    BDTSharedHeaders是用来存放跨pod调用的Header，只包含Header
    DESC

    s.homepage         = 'https://code.byted.org/TTIOS/BDTSharedHeaders'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'peiyun007' => 'peiyun@bytedance.com' }
    s.source           = { :git => 'git@code.byted.org:TTIOS/BDTSharedHeaders.git', :tag => s.version.to_s }

    s.ios.deployment_target = '7.0'

    s.source_files = 'BDTSharedHeaders/Classes/**/*'

end

