Pod::Spec.new do |s|

  s.name         = "BaiduMapKit"
  s.version      = "5.3.0"
  s.summary      = "百度地图iOS SDK（CocoaPods百度地图官方库）"

  s.description  = <<-DESC
                   百度地图iOS SDK：百度地图官方CocoaPods.\n百度地图iOS SDK是一套基于iOS 7.0及以上版本设备的应用程序接口，不仅提供展示地图的基本接口，还提供POI检索、路径规划、地图标注、离线地图、步骑行导航等丰富的LBS能力
                   DESC

  s.homepage    = "https://github.com/BaiduLBS/BaiduMapKit"

  s.license     = {:type => 'MIT'}

  s.author      = { "Xie Lei" => "xielei.233@bytedance.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/BaiduLBS/BaiduMapKit.git", :tag => "#{s.version}" }

  # s.source_files  = "Classes", "Classes/**/*.{h,m}"

  # s.exclude_files = "Classes/Exclude"

  s.source_files = 'BaiduMapKit/*.framework/Headers/*.{h}'
  s.public_header_files = 'BaiduMapKit/*.framework/Headers/*.h'

  s.resources = 'BaiduMapKit/*.framework/*.bundle'
  s.vendored_frameworks = 'BaiduMapKit/*.framework'

end
