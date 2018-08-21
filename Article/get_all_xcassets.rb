#!/usr/bin/ruby

require 'xcodeproj'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

path = ARGV[0]
target_name = ARGV[1]
project_path = path + '/Article.xcodeproj/'
project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
	if target.name != target_name then next end
	target.resources_build_phase.files.each do |file|
		if file.file_ref.path && file.file_ref.path.end_with?("xcassets")
			puts file.file_ref.real_path 
		end
	end
end
