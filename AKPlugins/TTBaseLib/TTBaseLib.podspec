#
# Be sure to run `pod lib lint TTBaseLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTBaseLib'
  s.version          = '0.1.0'
  s.summary          = '爱看基础库'
  s.description      = '爱看基础库'

  s.homepage         = 'https://github.com/fengjingjun/TTBaseLib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fengjingjun' => 'fengjingjun@bytedance.com' }
  s.source           = { :git => 'https://github.com/fengjingjun/TTBaseLib.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  
  s.subspec 'TTDeviceHelper' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTDeviceHelper/*.{h,m}'
    ss.public_header_files = 'Classes/TTBaseLib/TTDeviceHelper/*.h'
end

s.subspec 'TTNetworkHelper' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTNetworkHelper/*.{h,m}'
    ss.public_header_files = 'Classes/TTNetworkHelper/*.h'
    ss.dependency 'TTReachability'
end

s.subspec 'TTSandBoxHelper' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTSandBoxHelper/*.{h,m}'
    ss.public_header_files = 'Classes/TTSandBoxHelper/*.h'
end

s.subspec 'TTUIResponderHelper' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTUIResponderHelper/*.{h,m}'
    ss.public_header_files = 'Classes/TTUIResponderHelper/*.h'
end

s.subspec 'TTBaseTool' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTBaseTool/**/*.{h,m}'
    ss.public_header_files = 'Classes/TTBaseTool/*.h'
    ss.dependency 'TTServiceKit'
end

s.subspec 'TTBusinessManager' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTBusinessManager/*.{h,m}'
    ss.public_header_files = 'Classes/TTBusinessManager/*.h'

end

s.subspec 'TTCategory' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTCategory/**/*.{h,m}'
    ss.public_header_files = 'Classes/TTCategory/**/*.h'
end

s.subspec 'TTRobust' do |ss|
    ss.requires_arc =   true
    ss.source_files =   'Classes/TTRobust/*.{h,m}'
    ss.public_header_files = 'Classes/TTRobust/*.h'
end

end
