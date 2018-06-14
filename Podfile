source "https://github.com/CocoaPods/Specs.git"
#source 'git@code.byted.org:iOS_Library/publicthird_binary_repo.git'
source 'git@code.byted.org:iOS_Library/publicthird_source_repo.git'
#source 'git@code.byted.org:iOS_Library/privatethird_binary_repo.git'
source 'git@code.byted.org:iOS_Library/privatethird_source_repo.git'
#source 'git@code.byted.org:iOS_Library/toutiao_binary_repo.git'
source 'git@code.byted.org:iOS_Library/toutiao_source_repo.git'
source 'git@code.byted.org:TTVideo/ttvideo-pods.git'
source 'git@code.byted.org:ugc/UGCSpecs.git'

platform :ios, '8.0'
#use_frameworks!
use_modular_headers!
target 'Bubble' do
  pod 'Bubble', :path => './'
  pod 'BDStartUp', :path => './BDStartUp'

  pod 'AFNetworking', '2.5.4'
  
  #owner  -> wusizhen.arch'
  #sumary -> 获取用户首次安装后的一些信息，如installID、deviceID 
  pod 'TTInstallService', '1.1.3.2'
  #owner  -> wusizhen.arch'
  #sumary -> 头条网络 基础网络库 
  pod 'TTNetworkManager', '2.2.8.35'
  #owner  -> wusizhen.arch'
  #sumary -> Reachability统一库，业务插件方接入 
  pod 'TTReachability', '0.1.18'
  #owner  -> wusizhen.arch'
  #sumary -> 头条推送SDK,用于上报一些数据 
  pod 'TTPushSDK', '0.1.6'
  #owner  -> fengyadong'
  #sumary -> 头条共用日志监测和上报库 
  pod 'TTTracker', '1.1.5'
  #owner  -> wusizhen.arch'
  #sumary -> TODO:,Add,long,description,of,the,pod,here. 
  pod 'TTMonitor', '0.7.9.49'
  #owner  -> wusizhen.arch'
  #sumary -> 类似NSUserDefaults的key-value存储库，支持plist和keychain。 
  pod 'TTPersistence', '0.2.3'
  #owner  -> wusizhen.arch'
  #sumary -> 基于GYDataCenter，封装了一个数据存储对象的基类，增加了keymapping，类型校验，数据库大小，版本升级等功能 
  pod 'TTEntityBase', '0.2.3'
  #owner  -> shengxuanwei'
  #sumary -> [Foundation] 头条定位基础库 
  pod 'TTLocationManager', '1.0.4'
  #owner  -> jiangjingtao'
  #sumary -> 新版账号库，实现了网络接口和流操作 
  #owner  -> wusizhen.arch'
  #sumary -> 头条分享库。\n封装第三方分享SDK，提供一致的分享接口。 
  #pod 'TTShare', '0.3.4'
  #owner  -> wusizhen.arch'
  #sumary -> 头条分享关系服务头条分享关系服务 
  #pod 'TTShareService', '0.6.19'
  #owner  -> xiejunyi'
  #owner  -> wusizhen.arch'
  #sumary -> 头条路由 
  pod 'TTRoute', '0.2.26'
  #owner  -> wusizhen.arch'
  #sumary -> 头条通用Hybrid容器 
  pod 'TTRexxar', '0.8.5'

  #owner  -> xiejunyi'
  #sumary -> 头条iOS通用基础图片库
  pod 'BDWebImage', '0.2.8'

  pod 'RxSwift', '4.1.2'
  pod 'RxCocoa', '4.1.2'
  pod 'SnapKit', '4.0.0'
  pod 'Alamofire'
  pod 'RxAlamofire'
  pod 'SwiftyJSON', '4.1.0'
  pod 'ObjectMapper'

  target 'BubbleTests' do
    inherit! :search_paths
  end
  target 'BubbleUITests' do
    inherit! :search_paths
  end
end

pre_install do |installer|
   def installer.verify_no_static_framework_transitive_dependencies; end
end

post_install do |installer|

    installer.aggregate_targets.each do |target|
        copy_pods_resources_path = "Pods/Target Support Files/#{target.name}/#{target.name}-resources.sh"
        string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
        assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
        text = File.read(copy_pods_resources_path)
        new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
        File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
    end

    PREPROCESSOR_DEFINITIONS = ['$(inherited)']
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['WARNING_CFLAGS'] ||= ['$(inherited)', '-Wno-documentation']
        end

        PREPROCESSOR_DEFINITIONS << "BD_" + target.name + "=1"
    end

    installer.pods_project.targets.each do |target|
        if target.name == "BDStartUp"
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= PREPROCESSOR_DEFINITIONS
            end
        end
    end
    system("sudo python ./post_install.py")
end
