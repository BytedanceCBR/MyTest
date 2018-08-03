

fileFolder=$1
IPA=$2
channel_name=$3
app_info=$4

cd ~/Desktop
if [ ! -d $fileFolder ]; then
mkdir $fileFolder
fi
cd $fileFolder

echo "-----打包开始----"
cp $IPA test.zip
unzip -q test.zip
rm test.zip
channel_value=$channel_name
echo "------------------------------------------"
echo "------------------------------------------"
echo "-----开始打包 $channel_value 渠道----"
cd PayLoad/*.app
echo "----- $channel_value 开始修改 info.plist ----"
plutil -replace CHANNEL_NAME -string $channel_value Info.plist
plutil -p Info.plist | grep CHANNEL_NAME
if [  -d "PlugIns" ]; then
    echo "----- $channel_value 开始修改extenstion info.plist ----"
    cd PlugIns/*.appex
    plutil -replace CHANNEL_NAME -string $channel_value Info.plist
    plutil -p Info.plist | grep CHANNEL_NAME
    cd ../../
fi
cd ../../
zip -r -q ${app_info}_${channel_value}.ipa Payload
echo "----- $channel_value 渠道打包完成----"
echo "------------------------------------------"
echo "------------------------------------------"
rm -r Payload
echo "-----打包结束----"
