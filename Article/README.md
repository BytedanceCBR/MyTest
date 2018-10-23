

##### 更新Pods
cd Article  
pod install  

# 注意：
1. 项目中全部使用group（而不是folder），创建文件夹时，请手动维护finder中的实际目录结构与group结构一致。
2. 文件夹和group名称不包括空格、下划线，使用驼峰式命名，首字母大写。
3. 新写的组件名称以TT开头。
4. 大多数情况下，请确保目录中要么全是文件夹，要么全是文件，不要混在一起。
5. 资源文件请以xcassets 引入，引入前请确定是否已经有可直接用的历史资源。

6. 7月6日目录整理，去掉了原来的TTRefactor和TTCommon，目录结构以业务形态划分。
7. 各自代码找到对应的业务文件夹里，尽量别往source文件夹里放。
8. 凡是写公共组件一定要去掉依赖，仅仅某个业务使用到的伪公共组件，不算做公共组件，不放TTService。
9. 被放到TTService的ServiceNotUse的服务，尽量别用，如果没有替换方案可以先用着，然后给平台化小组提需求即可。
10. 有的业务用到组件在其他业务文件夹里，以解耦为目标就最好自己提炼为公共组件服务放到TTService，酌情。
11. 涉及公共服务组件的升级更新，同步给平台化小组，避免旧文件被放入pod，新更新内容没有。

## 目录结构：
TTAppRuntime : 
站在的角度是整个应用级别的业务，包括整体的设置、跳转、初次的全局提示、以及不能被业务所归纳的框架结构等等类似性质的业务，比如TTPadRootViewController

TTAppRuntime/TTStartUp  ：启动项相关的业务设置。

TTService : 
公共组件和服务的角色，平台化也在此开展。分为：1、不再使用将来会被删除的公共组件服务 2、新增的或原本需要公共化却还有依赖的文件 3、已经没有依赖未来要沉pod的文件

TTPrivateMessage ：私信业务。
TTHTSVideo       ：第四个tab，火山抖音业务。
TTSearch         ：搜索相关业务。
TTGallery        ：图集业务。
TTArticle        ：文章详情页业务。
TTAD             ：商业化。
TTWenda          ：问答业务。
TTFeedTab        ：首页tab各个频道。
TTUserProfile    ：个人主页相关业务。
TTVideo          ：西瓜视频业务。
TTUGC            ：UGC微头条。
TTLiveRoom       ：嘉宾聊天室、直播活动。
Source           ：历史文件夹，尽量别放新文件。
Targets-Config   ：工程配置。
Extensions       ：extension。
Resource         ：业务资源，各业务最好有自己的资源文件夹，参考问答Resource。

# 部分pod库说明
TTShare               ：包含基础分享类型的数据
TTShareService        ：包含常见个例的分享UI
TTNewsAccountBusiness : 新头条账号业务库
TTRexxar              ：包含基础JSBridge和webview
TTImage               ：包含图片下载SD封装，无上传
TTUserSettings        ：设置页面的字号、网络、通知、阅读模式
TTBatchItemAction     ：点赞分享顶踩不感兴趣

## 安装ReactNative
brew install node  
brew install watchman  
cd Article/ReactNative
npm install

