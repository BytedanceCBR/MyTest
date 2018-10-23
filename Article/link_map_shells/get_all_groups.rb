#!/usr/bin/ruby

require 'xcodeproj'

Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

# 各个.o文件的大小
$sizes = Hash.new
# 各个.o\.a\framework的大小
$static_sizes = Hash.new

# 对size进行格式化
def beauty_size (size)
  if size >= 1024 * 1024
    return (size.to_f / 1024.0 / 1024.0).round(2).to_s + " MB"
  elsif size >= 1024
    return (size.to_f / 1024.0).round(2).to_s + " KB"
  else
    return size.to_s + " B"
  end
end

# 从最右子树到最左子树的后续遍历
def print_group_relations (root_group, depth)
  size = 0
  if root_group == nil
    return size
  end

  # 当前节点是一个文件
  if root_group.instance_of? Xcodeproj::Project::Object::PBXFileReference
    name = (root_group.path ? root_group.path : root_group.name)
    name = name.split("/").last

    # 取得文件名和扩展名
    extension = name.split(".").last
    pule_name = name.split(".").first
    
    if ['m', 'mm', 'c', 'cpp'].include? extension
      size = $sizes[pule_name].to_i
    elsif ['a', 'framework'].include? extension and (root_group.source_tree != "BUILT_PRODUCTS_DIR" ) and (File.exist?(root_group.real_path))
      size = $static_sizes[pule_name].to_i
    else
      return 0;
    end
    print '  ' * depth + (root_group.path ? root_group.path : root_group.name) + " " + (beauty_size size) + "\n"
    return size
  end

  # 当前节点是一个group，则从最右子树开始后序遍历
  root_group.children.reverse_each do |group|
    size += print_group_relations(group, depth + 1)
  end
  print '  ' * depth + (root_group.path ? root_group.path : root_group.name ? root_group.name : 'total') + " " + (beauty_size size) + "\n"
  return size
end

src_root = ARGV[0]
workspace_path = ARGV[1]
linkmap_analysis_path = ARGV[2]
linkmap_analysis_g_path = ARGV[3]

# 读取所有.o文件的大小
file = File.new(linkmap_analysis_path, "r")
while (line = file.gets)
  # 一行样例：160301 libHTSVideoPlay.a(AWEVideoDetailViewController.o)，中间“\t”分隔
  # 提取size，单位为B
  size = line.split("\t").first
  object_file_name = line.split("\t").last
  # 静态库中的.o文件名为 “libPushManager.a(websocketClient.o)” 需要提取出括号内的部分
  object_file_name = object_file_name.split("(").last
  # 去掉扩展名
  object_file_name = object_file_name.split(".").first
  $sizes[object_file_name] = size.to_i
end
file.close

# 读取各个.a和framework的大小
file = File.new(linkmap_analysis_g_path, "r")
while (line = file.gets)
  # 一行样例：5559641  libTTPlayer.a，中间“\t”分隔
  # 提取size，单位为B
  size = line.split("\t").first
  object_file_name = line.split("\t").last
  object_file_name = object_file_name.split("\n").first
  # 去掉扩展名
  object_file_name = object_file_name.split(".").first
  $static_sizes[object_file_name] = size.to_i
end
file.close

# 打开workspace
workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
# 逆序遍历workspace中的project
workspace.file_references.reverse_each do |file_reference|
  project = Xcodeproj::Project.open(file_reference.absolute_path(src_root))
  root_group = project.main_group
  # 递归打印出该project中各个group的包大小占用量
  print_group_relations root_group, 0
end