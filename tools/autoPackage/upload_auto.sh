#! /bin/bash

# version: 版本号，第三个参数为version，命名方式：1_2_2
# devDir: 目标文件存储目录，命名规则: projectName_targetName_version_rc，eg. ../dist/projectName_targetName_version_rc
# projectName: 参数 -p 指定， Gallery 或者 Essay，根据project的不同决定 srcDir 和 channelList
# targetName: target Name，参数 -t 指定
# channelListFileName: 渠道号所在目录，存储在sh脚本同文件夹下，gallery_channel_list.txt 和 essay_channel_list.txt
# srcFile: 资源文件所在目录，sh脚本所在位置和Common为同一级，即: "../Common/SSCommon.h"
# releaseDir: build目录， ../project/"build/Release-iphoneos"
# channelKey: 渠道名的在SSCommon.h中对应的宏，即："CHANNEL_NAME"

projectName=$1
targetName=$2
version=$3

if [ $# -lt 2 ]; then
	echo "tip: no project or target name"
	exit 1
fi

# 进入工程所在目录，xcodeBuild
cd ../$projectName

echo "---------- start build $projectName $targetName all packages ----------"

devDir="../autoPackage/${targetName}_${projectName}_dev"
releaseDir="build/Release-iphoneos"

# if [ $projectName == 'Gallery' ]; then
# elif [ $projectName == 'Essay' ]; then
# elif [ $projectName == 'Video' ]; then
# elif [ $projectName == 'Article' ]; then
# else 
# 	echo "tip: project name error"
# 	exit 1
# fi

if [ ! -n "$version" ]; then
	echo "use default version"
	version="1_0_0";
fi

xcodebuild clean -configuration Development

rm -rdf "$devDir"
mkdir "$devDir"

grep -e "$channelName" $srcFile
rm -rdf "$releaseDir"

echo "---------- start build $channelName $version ----------"
xcodebuild -target "$targetName" -configuration Development -sdk iphoneos build

appFile="${releaseDir}/${targetName}.app"
ipaPath=`pwd`/$devDir/${targetName}.ipa

echo "---------- start build ipa for $channelName ----------"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$appFile" -o "$ipaPath"

scp ipaPath iosapp@dev.bytedance.com:./ipa/$targetName

