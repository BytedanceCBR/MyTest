#!/usr/bin/ruby

require 'xcodeproj'
require 'plist'

def clear_capabilities(target, entitlements_path = './Article/NewsInHouse/NewsInHouse.entitlements')
	system "cp #{entitlements_path} #{entitlements_path + '.backup'}"
	puts "\e[32mbackup at ./Article/NewsInHouse/NewsInHouse.entitlements.backup\e[0m"
	
	#clean capabilities in NewsInHouse.entitlements
	entitlements = Plist::parse_xml(entitlements_path)
	entitlements.clear
	entitlements.save_plist(entitlements_path)
	
	#clean capabilities in NewsInHouse Target
	capabilities = target.project.root_object.attributes['TargetAttributes'][target.uuid]['SystemCapabilities']
	['com.apple.ApplicationGroups.iOS', 'com.apple.InAppPurchase', 'com.apple.Keychain', 'com.apple.Push', 'com.apple.SafariKeychain', 'com.apple.Siri', 'com.apple.iCloud'].each do |key|
		capabilities[key]['enabled'] = 0
	end
	
	#delete StoreKit.framework
	target.frameworks_build_phases.files.each do |file|
		if file.display_name != 'StoreKit.framework' then next end
		file.remove_from_project
		puts 'StoreKit.framework  --delete success'
		break
	end
end

def clear_NewsInHouse(project_path = './Article/Article.xcodeproj')
	
	project = Xcodeproj::Project.open(project_path)
	raise '找不到工程文件, 请把脚本放到仓库根目录下执行' unless project
	
	project.targets.each do |target|
		if target.name != 'NewsInHouse' then next end
			
		target.dependencies.find_all { |dependency|
			dependency.display_name.include?('InHouse')
		}.each do |dependency|
			dependency.remove_from_project
			puts dependency.display_name + '  --delete success'
		end
		
		#delete 'Embed App Extensions' & 'Embed Watch Content in build phases
		target.copy_files_build_phases.find_all { |copy_phase| 
			['Embed App Extensions', 'Embed Watch Content'].include?(copy_phase.display_name)
		}.each do |copy_phase|
			copy_phase.remove_from_project
			puts copy_phase.display_name + '  --delete success'
		end
		
		system "cp -r #{project_path} #{project_path + '.backup'}"
		puts "\e[32mbackup at ./Article/Article.xcodeproj.backup\e[0m"
		
		clear_capabilities(target)
		puts "\e[32m-----清理完成------\e[0m"
		puts "还有两部需要手动操作"
		puts "1.手动修改xcode证书和bundleID"
		puts "2.NewsBaseDelegate中 注释掉-(void)registerSiriAuthorization"
		puts "\e[31m注意不要提交到gitlab上\e[0m"
	end
	project.save
end

clear_NewsInHouse
