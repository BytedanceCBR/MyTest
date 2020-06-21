#
# Be sure to run `pod lib lint AKWDPlugin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AKWDPlugin'
  s.version          = '0.1.0'
  s.summary          = '爱看问答业务插件'
  s.description      = '爱看问答业务插件'

  s.ios.deployment_target = '8.0'
  s.homepage         = 'https://code.byted.org/TTIOS/tt_business_wenda'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/AKWDPlugin.git', :tag => s.version.to_s }
  s.source_files     =  'Common/**/*.{h,m}',
                        'Model/**/*.{h,m}',
                        'Pages/**/*.{h,m}',
                        'HelpManager/**/*.{h,m}'
                        # 'Kuaida/**/*.{h,m}',
                        # 'Module/**/*.{h,m}'


  s.resources        =  'Resources/WDResource.xcassets',
                        'Resources/wd_iconfont.ttf',
                        'Resources/WDDebugViewController.storyboard'

#-------二方------


end
