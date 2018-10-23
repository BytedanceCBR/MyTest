打包脚本修改说明：

修改原因：
	1. 旧版本打包脚本耗时过长
	2. 旧版本打包脚本没有保存dsym，无法追查越狱渠道crash log
	3. 旧版本打包渠道需要xcode和代码才可以打包。

新版本优势：
	1.大幅度减少打包时间
	2.只需要有一个release 包，即可打其他渠道的包，不需要源代码，不需要安装XCode。

打包脚本使用说明：

需要MAX OS 10.9 或更高

使用方法， bash pack.bash xx.ipa xxx.txt xxxx

xx.ipa : 源ipa， 需要通过修改该ipa 才打其他包，该ipa包必须为可发布状态， 建议使用提交到app store 的ipa
xxx.txt: 需要打包的渠道号的文件，（每行一个渠道号，头尾不要有空格，行间不要有空行，最后不要有没用的回车）
xxxx:     需要附带的信息，如news_1_2_3 可以表示普通版本 1.2.3

eg:
	bash pack.bash News.ipa channel.txt News_4_1


打包过程中，会出现如下提示：
------------------------------------------
------------------------------------------
-----开始打包 tongbu 渠道----
----- tongbu 开始修改 info.plist ----
  "CHANNEL_NAME" => "tongbu"
----- tongbu 开始修改extenstion info.plist ----
  "CHANNEL_NAME" => "tongbu"
----- tongbu 渠道打包完成----
------------------------------------------
------------------------------------------

请注意如下行
"CHANNEL_NAME" => “tongbu"
是否正确

如果有app 扩展的应用，脚本会检测，并修改app 扩展的Info.plist中相关渠道。

打包完成后， 请使用itools类软件随即安装一个市场的包， 然后用Charles 监测下 ， 渠道是否成功。


附件中 
pack.bash 为打包脚本
channel.txt 为渠道示例



<channel.txt>
<pack.bash>




wiki 链接 ： https://wiki.bytedance.com/pages/viewpage.action?pageId=16450217
后续修改说明， 请参见如上地址