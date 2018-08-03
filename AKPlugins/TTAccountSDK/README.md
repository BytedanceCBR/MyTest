# TTAccountSDK

头条账号SDK

[![CI Status](http://img.shields.io/travis/liuzuopeng/TTAccount.svg?style=flat)](https://travis-ci.org/liuzuopeng/TTAccount)
[![Version](https://img.shields.io/cocoapods/v/TTAccount.svg?style=flat)](http://cocoapods.org/pods/TTAccount)
[![License](https://img.shields.io/cocoapods/l/TTAccount.svg?style=flat)](http://cocoapods.org/pods/TTAccount)
[![Platform](https://img.shields.io/cocoapods/p/TTAccount.svg?style=flat)](http://cocoapods.org/pods/TTAccount)


## Introduction

账号SDK主要封装头条账号服务提供的接口和第三方平台登录。

支持的功能如下：

* 手机号注册
* 手机号密码登录、手机号验证登录、邮箱登录
* 修改、找回密码
* 绑定、解绑手机号
* 退出登录
* 修改用户信息（头像、昵称、手机号、生日、用户签名等）
* 第三方平台登录、绑定或解绑（微信、腾讯QQ、腾讯微博、微博、电信天翼、人人网、火山、抖音等）
* 用户信息的更新（KVO）与缓存


这里介绍使用中会用到的术语：

* SMSCode: 短信验证码
* captcha: 图形验证码
* 会话过期: 当前登录账号因太久未使用（默认登录有效期为一个月）或其他CASE（异常CASE，遇到及时联系）导致登录状态过期
* 平台过期: 第三方平台授权是否过期（仅用在话题中）
* 绑定: 当APP已登录时，执行第三方账号登录操作，则会将该第三方账号绑定到当前账号；否则执行登录操作
* 解绑: 当APP已登录时，执行第三方账号解绑操作，则会将该第三方账号与当前账号解绑（**注意**当前账号没有绑定手机和其它三方账号时，解绑操作将会注销该帐号）
* consumerKey: appId或clientKey，在第三方平台申请APP时创建，是该APP在第三方平台的唯一标识
* consumerSecret: appSecret或clientSecret，在第三方平台申请APP时创建，后期可更改
* ssAppId: ssAppId是公司内产品的唯一标识
* platformAppId: 是头条账号体系中，每个产品对第三方平台的唯一标识（用于代替老的platformName和ssAppId，**老的产品继续使用platformName和ssAppId**） (申请联系@张煜卿)


**@attention:** `账号服务`当前没有专门对会话过期进行检测的接口，访问任意账号服务接口都可能返回登录过期信息。
1. 只要请求账号接口服务端返回过期信息，`TTAccountSDK`将广播onAccountSessionExpired消息给所有接收者
2. `TTAccountSDK`没有专门对会话过期进行检测和处理。通常是使用方在第一次打开APP或每次从后台->前台时，调用`user/info`（[TTAccount getUserInfoWithCompletion:]）接口进行检测和处理


**@attention:** 同一个第三方账号只能与一个头条账号绑定。当多次绑定时会出现异常，包括以下两种CASE:
1. connect_switch：头条账号绑定冲突，已有头条账号绑定过第三方平台账号。如微信绑定账号A，然后登录B账号绑定微信时，则出现第三方账号已绑定，请先解绑的情况
2. connect_exist：第三方授权账号绑定冲突，已有第三方授权账号绑定过头条账号。如微信A绑定头条账号A，微信B绑定头条账号B，此时用微信A绑定账号B，则出现已有微信账号绑定当前账号的情况



## Requirements

* iOS 7.0 or later
* Xcode 7.3 or later



## Lib Dependencies

* TTNetworkManager (网络库)
* TTThirdPartySDKs（第三方平台SDK）



## Installation

TTAccount is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TTAccountSDK"
```

SUBSPEC依赖

```ruby
pod 'TTAccountSDK', :git => 'git@code.byted.org:TTIOS/tt_pods_account.git', :commit => 'b5ba8bd', :subspecs => [
'Account',
'WeChatAccount',
'SinaWeiboAccount',
'TencentQQAccount',
'TencentWBAccount',
'RenRenAccount',
'TianYiAccount',
'TTAwemeAccount',
'TTHotsoonAccount'
]
```

开发分支依赖

```ruby
pod 'TTAccountSDK', git:'git@code.byted.org:TTIOS/tt_pods_account.git', :branch => 'dev'
```



## Example

To run the example project, clone the repo, `cd TTAccountDemo` and run `pod install` from the Example directory first.



## Usage

TTAccountSDK使用须知：

1. 第三方平台申请consumerKey，consumerSecret（如需第三方平台授权登录）
2. 客户端接入，有问题@柳祚鹏
3. 服务端接入，有问题@梁小锋 @常晓龙 @张煜卿
4. [Bytedancebase](https://code.byted.org/TTIOS/bytedancebase)接入，consumerKey申请联系@张煜卿


### 1. 引入账号SDK头文件

```
#import <TTAccountSDK.h>
```


### 2. 初始化账号核心配置

* [Required] networkParamsHandler 动态设置网络请求通用参数

```
 [TTAccount accountConf].networkParamsHandler = ^NSDictionary *() {
        return ***;
 };
```

* [Required] appRequiredParamsHandler 设置账号SDK所需的必要参数

```
[TTAccount accountConf].appRequiredParamsHandler = ^NSDictionary *() {
        NSMutableDictionary *requiredDict = [NSMutableDictionary dictionaryWithCapacity:4];
        [requiredDict setValue:*** forKey:TTAccountInstallIdKey];
        [requiredDict setValue:*** forKey:TTAccountDeviceIdKey];
        [requiredDict setValue:*** forKey:TTAccountSessionKeyKey];
        [requiredDict setValue:*** forKey:TTAccountssAppIdKey];
        return [requiredDict copy];
};
```

* [Optional] accountMessageFirstResponder 账号通知第一响应者

此接口非常特殊，处理时机非常早，在任何接口回调之前执行，用于更新一些老的Account信息（如NSUserDefault、Cookie等）。主要为了兼容一些老的业务代码，新的接入方可选择性使用

```
[TTAccount accountConf].accountMessageFirstResponder = ***;
```

* [Optional] loggerDelegate 埋点统计

```
[TTAccount sharedAccount].accountConf.loggerDelegate = ***;
```

* [Optional] multiThreadSafeEnabled 数据操作是否支持线程安全，默认为NO

```
[TTAccount accountConf].multiThreadSafeEnabled = YES;
```

* [Optional] byFindPasswordLoginEnabled 配置是否支持通过找回密码登录，默认为YES

```
[TTAccount sharedAccount].accountConf.byFindPasswordLoginEnabled = NO;
```

* [Optional] unbindAlertEnabled 配置登录或绑定账号出现已绑定异常CASE是否弹出解绑弹窗逻辑，默认为YES

```
[TTAccount sharedAccount].accountConf.unbindAlertEnabled = NO;
```

* [Optional] showAlertWhenLoginFail 配置登录或绑定账号失败时是否弹出异常弹窗提示，默认为YES

```
[TTAccount sharedAccount].accountConf.showAlertWhenLoginFail = NO;
```

* [Optional] domain 设置账号网络接口的域名 

```
[TTAccount sharedAccount].accountConf.domain = ***;
```

* [Optional] 动态获取APP当前ViewController接口

```
[TTAccount sharedAccount].accountConf.visibleViewControllerHandler = ^UIViewController *() {
    return nil;
};
```

其它没列出的配置选项查看`TTAccountConfiguration.h`文件。



### 3. 第三方账号接入和使用

#### 3.1 申请consumerKey

首先到第三方平台申请APP接入，获取consumerKey和consumerSecret，头条内部接入申请联系@张煜卿


#### 3.2 配置第三平台信息

**注意**

1. 第三方平台配置最好在启动时执行，并且默认第三方平台通过懒加载真正进行注册（并不会马上注册而是在第一次调用时注册）

2. 采用懒加载后，直接调用第三方SDK提供的API可能存在问题（如微信，在未调用registerApp:注册时，调用isWXAppInstalled或isWXAppSupportApi都将返回NO），需调用TTAccount+PlatformAuthLogin.h文件中的方法替代

3. 若想关闭第三方平台懒注册优化选项（即调用[TTAccount registerPlatform:]直接注册第三方SDK），可通过设置TTAccountPlatformConfiguration的bootOptimization属性来完成



```
TTAccountPlatformConfiguration *conf = [TTAccountPlatformConfiguration new];
// 第三方平台类型
[Required] conf.platformType = TTAccountAuthTypeWeChat;
// 在第三平台申请的appId
[Required] conf.consumerKey = ***;
// 第三方平台在头条账号系统定义的平台名称。有默认值
// 默认值：{weixin, qzone_sns, qq_weibo, sina_weibo, telecom, facebook, twitter, live_stream（火山）, aweme（抖音）} 
[Required] conf.platformName = ***;
// 第三方平台在头条账号系统中为该APP配置的唯一标识该平台的id（用来取代ssAppId和platformName)，老的产品继续使用ssAppId和platformName，该参数不传
[Required] conf.platformAppId = ***;

// 第三方平台本地化名称；有默认值
[Optional] conf.platformAppDisplayName = ***;
// APP在第三方平台的回调地址；<微博不能为空>
[Optional] conf.platformRedirectUrl = ***;
// 仅仅头条使用；头条使用Scheme方式登录微博时，微博回调打开头条的Scheme
[Optional] conf.authCallbackSchemeUrl = ***;
// 当未安装第三方APP时，使用第三方SDK自带WAP还是自包装的WAP进行授权登录 
[Optional] conf.useDefaultWAPLogin = YES;
// 当使用第三方SDK授权失败时，是否使用自定义的WAP重新授权登录
[Optional] conf.tryCustomLoginWhenSDKFailure = YES;
// 自定义授权登录SNSBar文案
[Optional] conf.snsBarText = ***;
// 自定义授权登录时是否隐藏SNSBar
[Optional] conf.snsBarHidden = YES;

// 公司内部使用Bytedancebase相互授权登录的配置选项；有默认值
// 默认不需要配置；当内部产品信息发生改变时，由外部手动传入，TTAccountSDK不更新
// 判断内部APP是否安装的Schemes
[Optional] conf.platformAppInstallUrl = YES;
// 判断内部APP是否安装的Schemes
[Optional] conf.platformInstalledURLSchemes = @[];
// 判断内部APP是否支持OAuth登录的Schemes
[Optional] conf.platformSupportedURLSchemes = @[];

[TTAccount registerPlatform:conf];
```

其它配置字段查看`TTAccountPlatformConfiguration.h`文件。


#### 3.3 [Optional] 配置自定义登录弹窗的样式（TTACustomWapAuthViewController.h)

```
[Optional] [TTAccount accountConf].wapLoginConf.navBarBackgroundColor = ***;
[Optional] [TTAccount accountConf].wapLoginConf.navBarTintColor = ***;
[Optional] [TTAccount accountConf].wapLoginConf.navBarTitleTextColor = ***;
[Optional] [TTAccount accountConf].wapLoginConf.navBarBottomLineColor = ***;
```


#### 3.4 [Optional，deprecated] 注册第三方平台

**@attention** 注册第三方AppId一定在主线程中执行。

**@attention** 如果不手动调用registerAppId:forPlatform:进行注册，将使用registerPlatform:中信息进行懒加载注册。

**@deprecated** `[TTAccount:registerAppId:forPlatform]` 使用 `[TTAccount registerPlatform:]` 来代替，`[TTAccount registerPlatform:]` 使用懒加载进行注册。

初始化注册第三方SDK

```
[TTAccount registerAppId:@"***"      
             forPlatform:TTAccountAuthTypeWeChat];
[TTAccount registerAppId:@"***"   
             forPlatform:TTAccountAuthTypeTencent];
[TTAccount registerAppId:@"**" 
             forPlatform:TTAccountAuthTypeSinaWeibo];
```


#### 3.5 登录|绑定、解绑第三方账号

* 登录|绑定
调用`requestLoginForPlatform:completion`或`requestLoginForPlatformName:completion:`进行登录或绑定

当未登录，调用该接口执行登录操作（当第一次调用将生成新的账号并登录，否则用老的账号进行登录）；当已登录，调用该接口执行绑定操作。

当授权完成会发送`TTAccountPlatformDidAuthorizeCompletionNotification`通知

* 解绑

调用`requestLogoutForPlatform:completion:`或`requestLogoutForPlatformName:completion:`将第三方账号从当前账号解绑


```
[TTAccount requestLoginForPlatform:TTAccountAuthTypeWeChat completion:^(BOOL success, NSError *error) {
        
}];
[TTAccount requestLogoutForPlatform:TTAccountAuthTypeWeChat completion:^(BOOL success, NSError *error) {
        
}];
```


#### 3.6 处理第三方平台授权回调

当第三方平台授权完成后，需在`application:openURL:options`或`application:sourceApplication:annotation:`进行处理

```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([TTAccount handleOpenURL:url]) {
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([TTAccount handleOpenURL:url]) {
        return YES;
    }
    return NO;
}
```


**@坑记**

> 微信登录授权会清空粘贴板而分享和支付不会，所以分享和授权放前面，登录授权放后面

通常处理流程如下：

```
BOOL canWXPayHandled = [TTWeChatPay handleOpenURL:url];
if (canWXPayHandled) return YES;

BOOL canWXShareHandled = [TTWeChatShare handleOpenURL:url];
if (canWXShareHandled) return YES;

BOOL canWXAuthHandled = [TTAccountAuthWeChat handleOpenURL:url];
if (canWXAuthHandled) return YES;
```

> 腾讯QQ分享会清空粘贴板而登录不会，所以登录授权放前面，分享放后面

通常处理流程如下：

```
BOOL canQQAuthHandled = [TTAccountAuthTencent handleOpenURL:url];
if (canQQAuthHandled) return YES:

BOOL canQQShareHandled = [TencentQQShare handleOpenURL:url];
if (canQQShareHandled) return YES;
```


第三方平台其它相关API查看`TTAccount+PlatformAuthLogin.h`文件



## 账号服务相关接口

账号服务提供的所有接口封装在`TTAccount+NetworkTasks.h`文件中。

验证码类型定义在`TTAccountSMSCodeDef.h`文件中。

错误码定义在`TTAccountStatusCodeDef.h`文件中。


**常用API如下：**

|                    接口API                |                 NOTE
|------------------------------------------|-----------------------------------------------
|registerWithPhone:SMSCode:password:captcha:completion: | 使用手机号注册账号
|loginWithPhone:password:captcha:completion:            | 使用手机号和密码登录
|loginWithEmail:password:captcha:completion:            | 使用邮箱和密码登录
|quickLoginWithPhone:SMSCode:captcha:completion:        | 使用手机号和验证码登录
|logout:                                                | 登出
|logoutPlatform:                                        | 登出第三方平台
|sendSMSCodeWithPhone:captcha:SMSCodeType:unbindExist:completion: | 发送短信验证码
|validateSMSCode:SMSCodeType:captcha:completion:                  | 验证短信验证码
|bindPhoneWithPhone:SMSCode:password:captcha:unbind:completion:   | 绑定手机号
|unbindPhoneWithCaptcha:captcha:completion:                       | 解绑手机号
|changePhoneNumber:SMSCode:captcha:completion:                    | 修改手机号
|modifyPasswordWithNewPassword:SMSCode:captcha:completion:        | 修改密码
|resetPasswordWithPhone:SMSCode:password:captcha:completion:      | 找回密码
|refreshCaptchaWithCompletion:                                    | 刷新图片验证码
|getUserInfoWithCompletion:                                       | 调用`user/info`接口
|startUploadUserPhoto:progress:completion:                        | 上传用户头条
|startUploadUserBgImage:progress:completion:                      | 上传用户背景图
|checkUsername:completion:                                        | 检查用户名是否合法
|updateUserProfileWithDict:completion:                            | 更新用户基本信息
|updateUserExtraProfileWithDict:completion:                       | 更新用户额外信息




## 账号相关通知

账号SDK中账号状态的变更没有使用NSNotification的方式发送通知。

### 注册消息接收者

注册消息接收者后，接收者仅仅被账号模块`弱持有`，因此不需要手动移除接收者对象，但需注意此对象是否会立即释放。

```
[TTAccount addMulticastDelegate:***];
```

### 移除接收者

不需手动移除，会随着接收者对象的销毁而自动释放

```
[TTAccount removeMulticastDelegate:***];
```

### 账号变更通知接口 <TTAccountMulticastProtocol>

|                    账号消息                |                 NOTE
|-------------------------------------------|-----------------------------------------------
|onAccountLogin                                         | 登录成功
|onAccountLogout                                        | 登出成功
|onAccountSessionExpired                                | 会话过期
|onAccountStatusChanged:platform:                       | 账号状态发生变更（登录、登出和会话过期）
|onAccountGetUserInfo                                   | 调用接口`2/user/info`成功
|onAccountUserProfileChanged:error                      | 用户profile变更
|onAccountAuthPlatformStatusChanged:platform:error:     | 第三方平台账号发生变更（绑定、解绑、过期）


具体含义查看`TTAccountMulticast.h`文件



## deprecated

[老的使用文档](https://ttrd.byted.org/ios/account/account.html)

此文档不再维护



## 配置DEMO

**最简功能配置**

```
    [TTAccount accountConf].networkParamsHandler = ^NSDictionary *() {
        return ***;
    };
    
    [TTAccount accountConf].appRequiredParamsHandler = ^NSDictionary *() {
        NSMutableDictionary *requiredDict = [NSMutableDictionary dictionaryWithCapacity:4];
        [requiredDict setValue:*** forKey:TTAccountInstallIdKey];
        [requiredDict setValue:*** forKey:TTAccountDeviceIdKey];
        [requiredDict setValue:nil forKey:TTAccountSessionKeyKey];
        [requiredDict setValue:*** forKey:TTAccountssAppIdKey];
        return [requiredDict copy];
    };
```

**完整配置**

```
    [TTAccount accountConf].networkParamsHandler = ^NSDictionary *() {
        return ***;
    };
    [TTAccount accountConf].appRequiredParamsHandler = ^NSDictionary *() {
        NSMutableDictionary *requiredDict = [NSMutableDictionary dictionaryWithCapacity:4];
        [requiredDict setValue:*** forKey:TTAccountInstallIdKey];
        [requiredDict setValue:*** forKey:TTAccountDeviceIdKey];
        [requiredDict setValue:nil forKey:TTAccountSessionKeyKey];
        [requiredDict setValue:*** forKey:TTAccountssAppIdKey];
        return [requiredDict copy];
    };
    [TTAccount accountConf].multiThreadSafeEnabled = arc4random()%2;
    [TTAccount accountConf].sharingKeyChainGroup = ***;
    [TTAccount accountConf].accountConf.domain = ***;
    [TTAccount accountConf].accountMessageFirstResponder = ***;
    [TTAccount accountConf].loggerDelegate = ***; 

    // TTACustomWapAuthViewController配置
    [TTAccount accountConf].wapLoginConf.navBarBackgroundColor = ***;
    [TTAccount accountConf].wapLoginConf.navBarTintColor = ***;
    [TTAccount accountConf].wapLoginConf.navBarTitleTextColor = ***;
    [TTAccount accountConf].wapLoginConf.navBarBottomLineColor = ***;

    // 注册第三方平台信息
    TTAccountPlatformConfiguration *wxConf = [TTAccountPlatformConfiguration new];
    wxConf.platformType = TTAccountAuthTypeWeChat;
    wxConf.consumerKey = WXAppID;
    wxConf.platformName = PLATFORM_WEIXIN;
    wxConf.platformAppId = @"55";
    [TTAccount registerPlatform:wxConf];
    
    TTAccountPlatformConfiguration *hotsoonConf = [TTAccountPlatformConfiguration new];
    hotsoonConf.platformType = TTAccountAuthTypeHuoshan;
    hotsoonConf.consumerKey  = hotsoonAppID;
    hotsoonConf.platformName  = PLATFORM_HUOSHAN;
    hotsoonConf.platformAppId = TTLogicString(@"hotsoonPlatformAppID", nil);
    hotsoonConf.platformAppInstallUrl = @"https://itunes.apple.com/cn/app/id1086047750";
    hotsoonConf.platformInstalledURLSchemes = @[@"snssdk1112", @"hotsoonsso"];
    hotsoonConf.platformSupportedURLSchemes = @[@"hotsoonsso"];
    [TTAccount registerPlatform:hotsoonConf];
```



## 相关WIKI链接

[手机号注册登录文档](https://wiki.bytedance.net/pages/viewpage.action?pageId=13961678#id-%E6%89%8B%E6%9C%BA%E5%8F%B7%E5%92%8C%E9%82%AE%E7%AE%B1%E6%B3%A8%E5%86%8C%E7%99%BB%E5%BD%95-%E6%B3%A8%E5%86%8C/register)

[获取用户信息文档](https://wiki.bytedance.net/pages/viewpage.action?pageId=524948#id-享评SDK-获取当前登录用户的个人信息)

[用户名校验、头像和基本信息更新文档](https://wiki.bytedance.net/pages/viewpage.action?pageId=1153405#id-%E7%94%A8%E6%88%B7API-%E6%A3%80%E6%9F%A5%E7%94%A8%E6%88%B7%E5%90%8D%E6%98%AF%E5%90%A6%E5%86%B2%E7%AA%81)

[第三方授权登录文档](https://wiki.bytedance.net/pages/viewpage.action?pageId=53809581#id-%E7%94%A8%E6%88%B7%E7%99%BB%E5%BD%95%E7%9B%B8%E5%85%B3API-%E7%AC%AC%E4%B8%89%E6%96%B9%E5%9B%9E%E8%B0%83/login_success)

[账号合并后的用户和关系API](https://wiki.bytedance.net/pages/viewpage.action?pageId=62424459)



## Q&A

> 能否直接用头条账号共享登录？

* 从单纯客户端角度来看：
Apple设备上对信息共享控制非常严格，原理上仅仅对于同一个开发者账号上的多个APP可以实现信息共享（1. keychain 2. 共享粘贴板）。

* 从客户端与服务端的角度来看：
可以通过某个方式来实现多个APP之间通过后端这个桥梁打通，但是这样的信息共享不是实时的，可能出现不及时或错误的CASE。**目前并没有实现这样的打通方案。**


> 为什么用户登录的状态没有在web页同步？

从`TTAccountSDK`的层面来讲，并不解决Native与Web之间信息的同步问题，两者之间信息同步需要接入方APP自己解决。通常解决方案有两种：

1. Web自己提供获取用户信息与状态的Bridge

2. 监听账号通知，将用户信息写入Cookie，通过cookie来实现信息同步


> 什么是sessionid（sessionKey)？

sessionid是头条账号系统维护用户登录状态变化的唯一标识。

当用户登录后，服务端会将当前session置为登录状态并在COOKIE中写入sessionid、sid_tt、sid_guard（默认过期时间是一个月，可能会变化，具体数值可以抓包查看），以后每个HTTP请求会将这些COOKIE字段捎带过去，服务端用于校验登录状态。（服务端session检查顺序为：sessionid->sid_tt）

当用户退出登录后，服务端会将上次登录的session字段置为无效，然后生成新的session字段，将该字段标记为有效且未登录，并在COOKIE中写入sessionid、sid_tt（服务端来维护session是否为登录状态）。当下次登录时，若服务端检测到上次登出写入有效且未登录的session时则将其置为登录状态，否则重新生成新的session置为登录状态并写入COOKIE中。

（为了解决跨域问题，
iOS处理方式是：每次登录后会将sessionid写到多个域（.snssdk.com、.toutiao.com、.wukong.com）的COOKIE中，登出或过期时会将这些域中的sessionid置为nil）


> 如何解决`cookie`丢失，导致用户被踢的问题

在老的方案中，登录状态信息都是服务端直接写在cookie中，这样登录标记的可靠性完全依赖HTTP的`cookie`。当`cookie`丢失或者客户端不正确写入`cookie`都将带来严重的问题，若`cookie`的中`sessionid`丢失将导致用户被踢；若`sessionid`被覆盖，将导致用户串号。

过度方案，仅仅为了解决`cookie`中`sessionid`丢失问题。
由于`sessionid`信息的不仅被服务端写入`cookie`，并且client本地会存储一份，为了防止`sessionid`丢失导致用户被踢的问题，client将在所有http请求头中写入新的字段`sessionid-x`，用来表示用户登录状态标识。服务端首先会从cookie中取sessioid信息，若取不到，则尝试从http请求头中获取`sessionid-x`字段。

新的session改造方案，doing ......


> 如何测试会话过期逻辑？

* 若要严格测试，需要服务端同学帮助，向@张煜卿请教。

* 若不是那么严格，客户端可用Charles Mock数据进行测试。请求账号相关任何接口，返回如下数据将触发

```
{
"data": {
"name": "session_expired",
"description": "会话过期，请重新登录"
},
"message": "error"
}
```

Copy上面数据保存为***.json，然后用Charles的Map Local 。。。。。。


> 为何时而需要输入图片验证码，时而不需要？

这个是账号服务对恶意攻击的防护策略，会根据后端监控数据进行调整。调整策略可能是对同一个IP一天之内仅能进行登录相关操作N次，否则需要输入图像验证码。

相关问题和具体策略，请咨询@常晓龙。



## Author

liuzuopeng, liuzuopeng@bytedance.com



## License

TTAccount is available under the MIT license. See the LICENSE file for more info.


