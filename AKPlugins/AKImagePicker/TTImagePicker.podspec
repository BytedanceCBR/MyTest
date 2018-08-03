#
# Be sure to run `pod lib lint TTShare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTImagePicker'
  s.version          = '1.1.6'
  s.summary          = '头条图片/视频选择器'
  s.description      = <<-DESC
                        图片视频选择器。
                        UI手势，交互，图片视频gif选择全部封装。
                       DESC
  s.homepage         = 'https://code.byted.org/TTIOS/tt_pods_image_picker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '柴淞' => 'chaisong@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:TTIOS/tt_pods_image_picker.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

  s.subspec 'Category' do |ss|
    ss.requires_arc = true
    ss.source_files = 'TTImagePicker/Classes/Category/*.{h,m}'
    ss.public_header_files = 'TTImagePicker/Classes/Category/*.h'
  end

  s.subspec 'Model' do |ss|
    ss.requires_arc = true
    ss.source_files = 'TTImagePicker/Classes/Model/*.{h,m}'
    ss.public_header_files = 'TTImagePicker/Classes/Model/*.h'
  end

  # ARC
  s.requires_arc = true
  # 全局依赖
  s.dependency "TTBaseLib"
  s.dependency "TTUIWidget" 

  s.source_files = 'TTImagePicker/Classes/**/*.{m,h,mm}'
  
  s.resources = 'TTImagePicker/Assets.xcassets'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
