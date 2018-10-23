require 'xcodeproj'

#打开.xcodeproj文件
proj=Xcodeproj::Project.open("./Article/Article.xcodeproj")


def addModuleResource (target)
    
    
    proj=Xcodeproj::Project.open("./Article/Article.xcodeproj")
    #如果需要的话 创建一个分组，名称为ModuleResource
    moduleResourceGroup=proj.main_group.find_subpath("ModuleResource",true)
    
    #获取assets的路径并检查是否存在 如果没有就创建一个
    ref1=moduleResourceGroup.find_file_by_path("../Components/TTLive/TTLive/TTlive/TTLiveAssets.xcassets")
    if ref1
        else
        ref1=moduleResourceGroup.new_reference("../Components/TTLive/TTLive/TTlive/TTLiveAssets.xcassets")
        
    end
    
    target.add_resources([ref1])
end


#加到对应的Target里去
for target in proj.targets

    puts "#{target.name}"

    if target.name == "News"
        addModuleResource(target);
    elsif target.name == "NewsSocial"
        addModuleResource(target);
    elsif target.name == "Explore"
        addModuleResource(target);
    elsif target.name == "NewsInHouse"
        addModuleResource(target);
    end
end


#保存
proj.save


