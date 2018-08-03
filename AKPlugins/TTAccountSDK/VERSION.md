> 0.0.1 初始化账号pod lib

> 0.0.2 添加NSBundle+Resources

> 0.0.3 添加TTAccountIndicatorView

> 0.0.4 在TTAccount中提供快速方法返回用户UserId

> 1.0.0 升级TTAccountSDK，移除通知，仅支持TTAccountMulticast；支持人人和腾讯微博绑定登录

> 2.0.0 添加修改用户Extra信息接口，添加TTAccountServiceFirstResponder对外发送消息

> 2.1.0 合并wd_master和tt_master到master

> 2.1.1 fix绑定手机号没有同步用户信息BUG

> 2.1.2 内存警告时，仅仅持久化，不清空账号内容

> 2.1.3 Fix iOS7上Crash

> 2.1.4 支持subspec引入第三方SDK

> 2.1.5 修复线上TTAWapNavigationBar使用通知，而没有移除导致的crash

> 2.2.5 添加监控Delegate和完善注释

> 2.3.0 用户信息添加shareToRepost字段

> 2.3.1 TTAccountMulticast添加多线程支持

> 2.4.0 支持火山和抖音登录

> 2.4.1 对外添加platformAppId和loginWithSSOCallback接口

> 2.4.2 添加头条、西瓜视频、悟空问答等登录方式支持

> 2.4.3 添加`connect_exist`错误类型处理

> 3.0.0 第三方账号配置信息发生改变（示例见README或AppDelegate.m文件末尾注释）

> 3.0.1 更换账号登录相关接口

> 3.0.2 修复服务端返回手机号和输入手机号进行校验方式（使用NSRegularExpression进行）

> 3.0.3 fix绑定过程中302BUG

> 3.0.4 `TTAccountConfiguration`添加开关`showAlertWhenLoginFail`，控制当第三方平台登录失败时是否显示alert提示弹窗

> 3.0.6 userinfo接口添加`userPrivacyExtend`字段


