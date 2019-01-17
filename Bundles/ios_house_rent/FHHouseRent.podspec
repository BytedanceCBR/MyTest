Pod::Spec.new do |s|
  s.name             = 'FHHouseRent'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHHouseRent.'
  s.homepage         = 'https://code.byted.org/fproject/ios_house_rent'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/ios_house_rent.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHHouseRent/**/*.{h,m,mm}'

  s.resources = ['FHHouseRent/Assets/*.xcassets']
    

  # s.resource_bundles = {
  #   'FHHouseRent' => ['FHHouseRent/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
