#用法： bash pack.bash News.ipa channel.txt News_4_1

# IPA:IPA包的名字
# channel_list_file_name:渠道名随在的文件名
# app_info:应用信息 如： news_1_1_1

IPA=$1
channel_list_file_name=$2
app_info=$3
echo "-----打包开始----"
cp $IPA test.zip
unzip -q test.zip
rm test.zip
for line in $(cat $channel_list_file_name)
do
channel_value=$line
echo "------------------------------------------"
echo "------------------------------------------"
echo "-----开始打包 $channel_value 渠道----"
cd PayLoad/*.app
echo "----- $channel_value 开始修改 info.plist ----"
plutil -replace CHANNEL_NAME -string $channel_value Info.plist
plutil -p Info.plist | grep CHANNEL_NAME
if [ ! -d "PlugIns/*.appex" ]; then
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
done
rm -r Payload
echo "-----打包结束----"


