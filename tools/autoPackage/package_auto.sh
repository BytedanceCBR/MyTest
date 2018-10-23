#! /bin/bash

# version: 版本号，第三个参数为version，命名方式：1_2_2
# distDir: 目标文件存储目录，命名规则: projectName_targetName_version_rc，eg. ../dist/projectName_targetName_version_rc
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
cd ../../$projectName

echo "---------- start build $projectName $targetName all packages ----------"

distDir="../tools/autoPackage/${targetName}_${projectName}"
srcFile="../$projectName/$targetName/$targetName-Info.plist"
releaseDir="build/Release-iphoneos"

if [ $projectName == 'Gallery' ]; then
	channelListFileName="../tools/autoPackage/gallery_channel_list.txt"
elif [ $projectName == 'Essay' ]; then
	channelListFileName="../tools/autoPackage/essay_channel_list.txt"
elif [ $projectName == 'Video' ]; then
	channelListFileName="../tools/autoPackage/video_channel_list.txt"
elif [ $projectName == 'Article' ]; then
	channelListFileName="../tools/autoPackage/article_channel_list.txt"
else 
	echo "tip: project name error"
	exit 1
fi

channelKey="CHANNEL_NAME"

if [ ! -n "$version" ]; then
	echo "use default version"
	version="1_0_0";
fi

xcodebuild clean -configuration Distribution

rm -rdf "$distDir"
mkdir "$distDir"

cp $srcFile $srcFile.bak

for line in $(cat $channelListFileName)
do
	channelName=$line

	echo "channel name: $channelName"

	# 需要在 src file 中更改 channel name
	# eg. 
	# <key>CHANNEL_NAME</key>
	# <string>App Store</string>

	echo "src file:$srcFile channel key:$channelKey"
	grep -e "$channelKey" $srcFile
	if [ $? -ne 0 ]; then
		echo "tip: channel key not found"
		break
	fi

	sed '/<key>'$channelKey'<\/key>/{N;s/\(<string>\).*\(<\/string>\)/\1'$channelName'\2/;}' $srcFile > $srcFile.tmp
	# test: sed "s/App Store/91zhushou/" Criticism-Info.plist > test.plist
	# sed '/<key>CHANNEL_NAME<\/key>/{N;s/\(<string>\).*\(<\/string>\)/\1test\2/;}' Criticism-Info.plist > test.plist

	cat $srcFile.tmp > $srcFile
	rm -f $srcFile.tmp

	grep -e "$channelName" $srcFile

	rm -rdf "$releaseDir"

	echo "---------- start build $channelName $version ----------"
	xcodebuild -target "$targetName" -configuration Distribution  -sdk iphoneos build

	#cp -rdf "$releaseDir" "/$distDir/$targetName_$version_$channelName/"
	#echo "dYSM file dir: /${distDir}/${targetName}_${version}_${channelName}/"

	appFile="${releaseDir}/${targetName}.app"
	ipaPath=`pwd`/$distDir/${targetName}_${projectName}_${channelName}_${version}.ipa

	echo "---------- start build ipa for $channelName ----------"
	/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$appFile" -o "$ipaPath"

done

mv $srcFile.bak $srcFile


