### 这个脚本的作用是将linkmap和工程目录匹配，得到工程目录中各个group所占包大小

最终产物是一个包大小占用报告，大概是这样：

```
total 37.36 MB
  TTUGC 6.19 MB
    Common 1.38 MB
      TTUGCCommonLogic.m 3.15 KB
      CommonURLSetting 569 B
        FRCommonURLSetting.m 569 B
      CSSTheme 133.92 KB
        CSSParser 54.73 KB
......
```

建议输出成文件，使用Sublime打开，左侧可以看到小箭头，便于折叠/展开，提高可读性

注意⚠️：作者脚本水平十分有限，该项目仅作线下分析使用，性能和鲁棒性暂时未能保障


##### 使用方法举例

（1）命令行使用：

```
sh ./analyse_and_map.sh /Users/xushuangqing/Documents/tt_app_ios2/Article /Users/xushuangqing/Documents/tt_app_ios2/Article/Article.xcworkspace/ /Users/xushuangqing/Library/Developer/Xcode/DerivedData/Article-aosqqabgqybkjzhdwkoebzzckbrc/Build/Products/Debug-iphonesimulator/NewsInHouse-LinkMap-x86_64.txt
```
三个参数分别为：工程根目录、workspace地址、linkmap文件


（2）集成到工程中使用

在build phase中加一项run script，在其中输入：

```
sh "${SRCROOT}/link_map_shells/analyse_and_map.sh" "${SRCROOT}" "${SRCROOT}/Article.xcworkspace/" "${LD_MAP_FILE_PATH}"
```
同时将build settings中的Write Link Map File置为YES
这样每次build之后就能生成一个包大小占用报告
(⚠️建议日常关闭，仅在需要时由专人打开跑一下)

##### 前置条件

依赖于xcodeproj，安装cocoapods时会自带

##### 文件说明

- analyse_and_map.sh

调用入口，将各个步骤串联起来，输出最终报表

- linkmap.py

开源脚本，读取linkmap，输出 各个类大小 和 各个静态库大小

- get_all_groups.rb

将各个类/静态库大小匹配到工程的目录结构上


