> 1.0.0 初始化TTAccountLogin仓库

> 1.0.1 fix 第三方平台登录偶尔不能dismissViewController bug

> 1.0.2 修改登录页弹起动画，与评论页一致

> 1.1.0 添加打开用户隐私功能

> 1.1.1 fix UI Layout (邮箱登录，提示文案下移)

> 1.1.2 调整用H5打开用户隐私页的frame

> 1.2.0 小窗登录添加Title Type

> 1.2.1 修改大窗登录成功后，dismissViewController与发送Hide小窗通知位置

> 1.2.2 修复TTAccountLoginViewController中loginCompletion回调状态loginState不正确的BUG

> 1.2.3 修复TTAccountLoginAlert在使用第三方平台登录时不被调用问题

> 1.2.4 修复TTAccountLoginAlert回调时机不统一问题；TTAccountLoginAlert中添加属性moreButtonActionMode，内部增加点击更多打开登录大窗的能力

> 1.2.5 移除TTTracker对的tag依赖

> 1.2.6 TTUserPrivacyView添加点击checkButton回调

> 1.2.7 升级登录UI相关埋点至3.0

> 1.2.8 增加登录传入title文案的Methods

> 1.2.9 Log1.0升级到Log3.0

> 1.3.0 Inhouse Target支持配置仅手机号登录

> 1.3.1 移除podspec中写死的版本依赖

> 1.3.2 修复小设备上UI布局BUG

> 1.3.3 第三方登录支持下发和修复iOS7上CRASH

> 1.4.0 UI上支持火山和抖音登录

> 1.4.1 登录大窗支持SSO样式-不显示第三方平台登录图标

> 1.4.2 适配iPad上登录大窗

> 1.4.3 fix文件引用错误

> 1.4.4 添加通知`TTForceToDismissLoginViewControllerNotification`，dismiss TTAccountLoginViewController

> 1.4.5 移除对TTAccountSDK中不合法的引用

> 1.4.6 fix TTAccountPresentAnimation BUG

> 1.5.0 将`用户协议`与`隐私保护`分开

> 1.5.1 修复历史遗留BUG
