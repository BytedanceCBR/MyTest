Pod::Spec.new do |s|
  s.name             = 'FHMapSearch'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FHMapSearch.'
  s.homepage         = 'https://code.byted.org/fproject/ios_map_search'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'guchunhui' => 'guchunhui@bytedance.com' }
  s.source           = { :git => 'git@code.byted.org:fproject/ios_map_search.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'FHMapSearch/Classes/**/*.{h,m,mm}'

  s.resources = ['FHMapSearch/Assets/*.xcassets']
    

  # s.resource_bundles = {
  #   ' FHMapSearch' => [' FHMapSearch/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'TTKitchen'
end
