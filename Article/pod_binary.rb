# Created by Wusizhen on 3/15/18.
# Copyright (c) 2018 Bytedance. All rights reserved.

#!/usr/bin/env ruby
#!/usr/bin/ruby
# -*- coding: UTF-8 -*-
# encoding: utf-8
require 'xcodeproj'
require 'cocoapods'
require 'rubygems'
require 'json'
require 'pp'
require 'open-uri'
require 'net/http'
BEGIN {
  def get_response(url)
    begin
      url_str = URI.parse(url)
      return Net::HTTP.get_response(url_str)
    rescue Exception => ex
      p ex
    end
  end

  frameworkContainerUri = 'http://tosv.byted.org/obj/staticanalysisresult/ios_frameworks.json'
  html_response_framework = get_response(frameworkContainerUri)
  PODS = JSON.parse(html_response_framework.body)
  SourceContainerUri = 'http://tosv.byted.org/obj/iosbinary/sourcecontainer.framework.json'
  html_response_source = get_response(SourceContainerUri)
  SourceContainer = JSON.parse(html_response_source.body)
  deprecatedContainerUri = 'https://ios.bytedance.net/wlapi/deprecatedInfo/'
  html_response_deprecated = get_response(deprecatedContainerUri)
  Deprecated = JSON.parse(html_response_deprecated.body)
  $NEEDBINARY = 0
  $NEEDSOURCE = 0
  $LOADEDBINARYSOURCE = 0
  $Toutiao = "13"
  $Douyin = "1128"
  $Wenda = "1165"
  $CurrentApp = $Toutiao
  WarningModules = Array.new
  Binary = Array.new

  DevPods = Array.new
  Target_Dev_Pods_Map = Hash.new
  $CurrentDevPodsMap = nil

  EachDevPods = Array.new
  Target_Dev_Pod_Container = Hash.new
  $CurrentDevPods = nil
  $Bd_enable_DevelopMode

  @@recorde = Hash.new
  
  realTime = Deprecated['archRealTime']
  if !realTime
    Now = Time.new.to_i
  else
    Now = realTime
  end
}
def startSpeed()
  load 'speed.rb'
end

def target_patch(name,options = nil)
  DevPods.clear
  yield if block_given?
  Target_Dev_Pods_Map[name] = DevPods.dup
  Target_Dev_Pod_Container[name] = EachDevPods.dup
end

def pod_dev(moduleName,*requirements)
  DevPods << {moduleName => requirements}
  EachDevPods << moduleName
end

def bd_enable_DevelopMode
  if File::exist?('Podfile_Patch')
    $Bd_enable_DevelopMode = true
    load 'Podfile_Patch'
  end
  
end

def pod_install_dev
  if $CurrentDevPodsMap
    $CurrentDevPodsMap.each do |hash|
      hash.each { |key,value|
        case value.size
        when 0
          pod key
        when 1
          pod key,value[0]
        when 2
          pod key,value[0],value[1]
        when 3
          pod key,value[0],value[1],value[2]
        when 4
          pod key,value[0],value[1],value[2],value[3]
        end
      }
    end
  end
end

def bytedanceAnalyzeSpeed(enable=true)
  if enable
    startSpeed
  end
end

def bd_use_app (*appName)
  plugin 'cocoapods-bytedance-transform'
  plugin 'cocoapods-bytedance-Slardar'
  $Apps = Array.new
  for app in 0...appName.length
    each_bd_use_app(appName[app])
  end
end

def each_bd_use_app(appName="toutiao")
  apps = SourceContainer["apps"]
  $CurrentApp = apps["#{appName}"]
  $Apps << $CurrentApp
  allsource = SourceContainer["source"]
  placehold = apps["#{appName}"]
  currentSourceContainer = allsource["#{placehold}"]
  if currentSourceContainer
    currentSourceContainer.each do |eachSource|
      source eachSource;
    end
  else
    source 'git@code.byted.org:iOS_Library/toutiao_binary_repo.git'
    source 'git@code.byted.org:iOS_Library/toutiao_source_repo.git'
    source 'git@code.byted.org:TTIOS/cocoapods-master-specs-mirror.git'
    source 'git@code.byted.org:TTVideo/ttvideo-pods.git'
    source 'git@code.byted.org:ugc/UGCSpecs.git'
  end
end

def bd_use_source!()
  raise "You have already setted bd_use_binary!" unless $NEEDBINARY != 1
  $NEEDSOURCE = 1
end

def bd_use_binary!()
  raise "You have already setted bd_use_source!" unless $NEEDSOURCE != 1
  $NEEDBINARY = 1
end

def bd_source(url)
  if $LOADEDBINARYSOURCE == 0
    source 'git@code.byted.org:wusizhen.arch/ios_frameworks.git'
    $LOADEDBINARYSOURCE = 1
  end
  source url
end

def show_deprecated(moduleName,deprecated)
  deprecated_time = Time.at deprecated['deTime']
  operate_time = Time.at deprecated['opTime']
  user = deprecated['username']
  version = deprecated['version']
  des = deprecated['des']
  level = deprecated['level']
  case level
  when 'error'
    if Now > deprecated_time.to_i
      system ("osascript -e 'display notification \"废弃理由:#{des},\n 组件废弃时间:#{deprecated_time.inspect} \" with title \"#{moduleName}-#{version} 被废弃\" subtitle \"操作人:#{user}\" '")
      raise "#{moduleName} - #{version} 被废弃,原因为:#{des},操作人:#{user},组件废弃时间:#{deprecated_time.inspect},操作废弃时间:#{operate_time.inspect}"
    end

  when 'warning'
    if Now > deprecated_time.to_i
      system ("osascript -e 'display notification \"废弃理由:#{des},\n 组件废弃时间:#{deprecated_time.inspect} \" with title \"#{moduleName}-#{version} 被废弃\" subtitle \"操作人:#{user}\" '")
      raise "#{moduleName} - #{version} 被废弃,原因为:#{des},操作人:#{user},组件废弃时间:#{deprecated_time.inspect}"
    end
    system ("osascript -e 'display notification \"废弃理由:#{des},\n 组件废弃时间:#{deprecated_time.inspect} \" with title \"#{moduleName}-#{version} 被废弃\" subtitle \"操作人:#{user}\" '")
    puts "#{colorize("===============================================================================","red")}"
    puts "#{colorize("#{moduleName} 将于 #{deprecated_time.inspect} 废弃，废弃理由:#{des},操作人:#{user}","red")}"
    puts "#{colorize("===============================================================================","red")}"
  end


end

def pod_binary(moduleName,version=-1,args2=-1,args3=-1,args4=-1)
  argsment = rebuild_pod(version,args2,args3,args4)
  if $NEEDSOURCE == 1
    common_pod_command(moduleName,argsment,-1)
  else
    common_pod_command(moduleName,argsment,1)
  end
end

def pod_source(moduleName,version=-1,args2=-1,args3=-1,args4=-1)
  argsment = rebuild_pod(version,args2,args3,args4)
  if $NEEDBINARY == 1
    common_pod_command(moduleName,argsment,1)
  else
    common_pod_command(moduleName,argsment,-1)
  end
end

def subspecHandle(moduleName, argsment)
  if moduleName.include?"/"
    subspecArray = moduleName.split("/")
    subspecArray.delete_at(0)
    newsubspecs = subspecArray.join("/")
    if containSubspecComponent(argsment)
      argsment.each do |subspec|
        if subspec.class == Hash
          if subspec.keys.include?(:subspecs)
            subspec[:subspecs] = subspec[:subspecs].map { |e|
              newsubspecs + "/" + e
            }
          end
        end
      end
      return [moduleName.split("/")[0], argsment]
    else
      if argsment.empty?
        argsment = Hash.new
        argsment[:subspecs] = [newsubspecs]
        return [moduleName.split("/")[0], [argsment]]
      end
      subspecComponent = Hash.new
      subspecComponent[:subspecs] = [newsubspecs]
      argsment << subspecComponent
      return [moduleName.split("/")[0], argsment]
    end
  end
  [moduleName, argsment]
end

def containSubspecComponent(argsment)
  if !argsment.empty?
    argsment.each do |subspec|
      if subspec.class == Hash
        if subspec.keys.include?(:subspecs)
          return true
        end
      end
    end
  end
  return false
end

def common_pod_command(moduleName,argsment,binary=1)
  
  moduleName,argsment = subspecHandle(moduleName,argsment)
  if $CurrentDevPods
    return unless !$CurrentDevPods.include?(moduleName)
  end
  if argsment.empty?
    puts "#{colorize("===============================================================================","purple")}"
    puts "#{colorize("#{moduleName} undefined the exact version","purple")}"
    puts "#{colorize("===============================================================================","purple")}"
    pod moduleName
  else
    versionTemparray = argsment.reject{ |item|
      item.class != String || item == -1
    }
    newarray = argsment.reject { |item|
      item.class == String || item == -1
    }

    if versionTemparray.empty?
      if newarray.length == 0
        puts "#{colorize("===============================================================================","purple")}"
        puts "#{colorize("#{moduleName} undefined the exact version","purple")}"
        puts "#{colorize("===============================================================================","purple")}"
        pod moduleName
      elsif newarray.length == 1
        pod moduleName,newarray[0]
      elsif newarray.length == 2
        pod moduleName,newarray[0],newarray[1]
      elsif newarray.length == 3
        pod moduleName,newarray[0],newarray[1],newarray[2]
      elsif newarray.length == 4
        pod moduleName,newarray[0],newarray[1],newarray[2],newarray[3]
      end
    else
      if newarray.empty?
        pod moduleName,pod_binary_version_check(moduleName,versionTemparray[0],binary)
      elsif newarray.length == 1
        pod moduleName,pod_binary_version_check(moduleName,versionTemparray[0],binary),newarray[0]
      elsif newarray.length == 2
        pod moduleName,pod_binary_version_check(moduleName,versionTemparray[0],binary),newarray[0],newarray[1]
      elsif newarray.length == 3
        pod moduleName,pod_binary_version_check(moduleName,versionTemparray[0],binary),newarray[0],newarray[1],newarray[2]
      elsif newarray.length == 4
        pod moduleName,pod_binary_version_check(moduleName,versionTemparray[0],binary),newarray[0],newarray[1],newarray[2],newarray[3]
      end
    end
  end

end

def rebuild_pod(version=-1,args2=-1,args3=-1,args4=-1)
  argsment=Array[version,args2,args3,args4]
  return argsment.uniq.reject{ |item|
    item == -1
  };
end

def pod_binary_version_check(moduleName,version,needcheck=-1)
  deprecatedVersions = getDeprecatedContainerByApp($Apps,moduleName)
  if deprecatedVersions
    deprecatedVersions.each do |deprecated|
      if deprecated["version"] == version
        show_deprecated(moduleName,deprecated)
      end
    end
  end
  if needcheck == -1
    return version
  end
  if version.class == Hash
    if (version.keys.include?(:path)) ||  (version.keys.include?(:git))
      return version
    end
  end
  currentModuleVersions = getBinaryContainerByApp($Apps,moduleName)
  if !currentModuleVersions
    return version
  end
  if version.include?"-"
    if currentModuleVersions.include?("#{version}.1.binary")
      recordBinaryPods(moduleName)
      return "#{version}.1.binary"
    end
    if currentModuleVersions.include?("#{version}.1-binary")
      recordBinaryPods(moduleName)
      return "#{version}.1-binary"
    end
  else
    if currentModuleVersions.include?("#{version}.1-binary")
      recordBinaryPods(moduleName)
      return "#{version}.1-binary"
    end
  end

  if currentModuleVersions.include?(version)
    if WarningModules.include?(moduleName)
      return version
    end
    WarningModules << moduleName
    puts "#{colorize("===============================================================================","light red")}"
    puts "#{colorize("Binary Warning:You should not use binary version directly for #{moduleName}","light red")}"
    puts "#{colorize("===============================================================================","light red")}"
    recordBinaryPods(moduleName)
    return version
  end
  if WarningModules.include?(moduleName)
    return version
  end
  WarningModules << moduleName

  puts "#{colorize("===============================================================================","red")}"
  puts "#{colorize("#{moduleName} Binary Warning:Current version:#{version} have no binary version","red")}"
  puts "#{colorize("===============================================================================","red")}"
  return version
end

def recordBinaryPods(moduleName)
  Binary << moduleName;
end

def getDeprecatedContainerByApp(apps=["13"],moduleName)
  raise '不应该在Podfile_Patch使用pod_source or pod_binary' if !apps && $Bd_enable_DevelopMode
  versions = Array.new
  apps.each do |app|
    currentAppVersions = getEachDeprecatedContainerByApp(app,moduleName)
    if currentAppVersions
      versions = versions | currentAppVersions
    end
  end
  return versions
end

def getEachDeprecatedContainerByApp(appName="13",moduleName)

  currentAppBinaryContainer = Deprecated["#{appName}"]

  if !currentAppBinaryContainer
    return nil
  end
  currentModuleVersions = currentAppBinaryContainer["#{moduleName}"]

  return currentModuleVersions;
end

def getBinaryContainerByApp(apps=["13"],moduleName)
  versions = Array.new
  apps.each do |app|
    currentAppVersions = getEachBinaryContainerByApp(app,moduleName)
    if currentAppVersions
      versions = versions | currentAppVersions
    end
  end
  return versions
end

def getEachBinaryContainerByApp(appName="13",moduleName)

  currentAppBinaryContainer = PODS["#{appName}"]

  if !currentAppBinaryContainer
    return nil
  end
  currentModuleVersions = currentAppBinaryContainer["#{moduleName}"]

  if !currentModuleVersions

    currentModuleVersions = PODS["#{moduleName}"]
  end

  return currentModuleVersions;
end

def colorize(text, color = "default", bgColor = "default")
  colors = {"default" => "38","black" => "30","red" => "31","green" => "32","brown" => "33", "blue" => "34", "purple" => "35",
            "cyan" => "36", "gray" => "37", "dark gray" => "1;30", "light red" => "1;31", "light green" => "1;32", "yellow" => "1;33",
            "light blue" => "1;34", "light purple" => "1;35", "light cyan" => "1;36", "white" => "1;37"}
  bgColors = {"default" => "0", "black" => "40", "red" => "41", "green" => "42", "brown" => "43", "blue" => "44",
              "purple" => "45", "cyan" => "46", "gray" => "47", "dark gray" => "100", "light red" => "101", "light green" => "102",
              "yellow" => "103", "light blue" => "104", "light purple" => "105", "light cyan" => "106", "white" => "107"}
  color_code = colors[color]
  bgColor_code = bgColors[bgColor]
  return "\033[#{bgColor_code};#{color_code}m#{text}\033[0m"
end

module Pod
  class Installer
    def ensure_plugins_are_installed!
      require 'claide/command/plugin_manager'

      loaded_plugins = Command::PluginManager.specifications.map(&:name)

      podfile.plugins.keys.each do |plugin|
        unless loaded_plugins.include? plugin
          raise Informative, "Your Podfile requires that the plugin `#{plugin}` be installed. Please install it and try installation again." unless plugin.include?('cocoapods-bytedance-')
        end
      end
    end
  end
end


Pod::HooksManager.register('cocoapods-bytedance-transform', :post_install) do |installer_context|
  cdir = File.dirname(__FILE__)
  if !Binary.empty? && !ENV['WORKSPACE']
    string = Binary.to_s
    string = string.gsub("\"","").gsub("[","").gsub("]","").gsub(","," ")
    system("#{cdir}/BDTransmit #{string}")
  end
end

Pod::HooksManager.register('cocoapods-bytedance-Slardar', :post_install) do |installer_context|
  if ENV['WORKSPACE']
    
    sandbox_root = File::dirname(installer_context.sandbox_root)
    Dir.chdir(sandbox_root)
    json = @@recorde.to_json
    aFile = File.new("pod.json", "w+")
    if aFile
      aFile.syswrite(json)
    end
    
    cmd = "
    root=`git rev-parse --show-toplevel`
    cd $root
    curl -o ParseProjectFileMap http://tosv.byted.org/obj/iosbinary/bd_pod_extentions/6.3.0/ParseProjectFileMap
    chmod 777 ParseProjectFileMap
    find ./ -type f|egrep -v \".svn|.git|.png|.plist|.strings\" > context.txt
    commit=`git rev-parse HEAD`
    git=`git remote -v |xargs -n 1|egrep 'git' |head -n 1`
    ./ParseProjectFileMap $root/context.txt #{sandbox_root}/pod.json $git $commit
    "
    system(cmd)
    
  end


end

module Pod
  class Podfile
    module DSL
      def target(name, options = nil)

        if options
          raise Informative, "Unsupported options `#{options}` for " \
            "target `#{name}`."
        end
        parent = current_target_definition
        definition = TargetDefinition.new(name, parent)
        self.current_target_definition = definition
        $CurrentDevPodsMap = Target_Dev_Pods_Map[name]
        $CurrentDevPods = Target_Dev_Pod_Container[name]
        pod_install_dev
        yield if block_given?
      ensure
        self.current_target_definition = parent
      end
    end
  end

  class Specification
    if ENV['WORKSPACE']
      def root
        record_source
        parent ? parent.root : self
      end

      def record_source
        if !@@recorde[attributes_hash['name']]

          source = attributes_hash['source']
          if source
            source = attributes_hash['source_code'] unless source.keys.include?('git')
          else
            source = attributes_hash['source_code']
          end
          @@recorde[attributes_hash['name']] = source if source
        end

      end
    end
  end

end
