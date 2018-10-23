## TTUIWidget

主要包括一些业务层可复用的UI组件及扩展实现

## 快速集成

```ruby
pod "TTUIWidget"
```

## 组件列表

* `SSViewControllerBase` : 头条vc基类，遵从`TTRoute`初始化协议，支持日夜间模式
* `TTNavigationController` : 头条定制`navigationController`，支持右滑返回
* `TTIndicatorView` : 通用黑色背景的`toast`提示
* `TTPanelController` : 头条定制分享面板
* `TTThemedAlertController` : 头条定制`alertView`&`actionSheet`，支持日夜间模式
* `TTRefresh` : 下拉刷新&加载更多 控件，及`UIScrollView`的相关集成
* `UIViewController+ErrorHandler` : 全屏异常页面组件，及`UIView`和`UIViewController`的相关集成
* `SSAlertViewBase` : 屏幕底部弹出浮层通用控件，带黑色背景遮罩，点击可取消。`SaveImageAlertView`即为使用场景之一，保存图片弹窗
* `TTUserInfoView` : ugc信息控件，文字+icon后缀形式
* `TTAlphaThemedButton` : 自定义`UIButton`，`highlight`状态`tintCollor`变为50%透明度，同时支持日夜间模式
* `UILabel+Tapping` : `UILabel`增加文字链接
* `TTTagView` : 标签组件，主要用于各业务详情页浮层
* `TTBadgeNumberView` : 头条通用标新组件
* `TTHorizontalScrollView` : 带复用机制的水平滚动控件，封装了`UIScrollView`
* `TTPageController` : `header`和`content`两部分均为`UIScrollView`的嵌套组件
* `UIViewController+CustomTimingFunction` ：一些`UIView`的`CoreAnimation`自定义动画
* `TTViewWrapper` : 适配头条`iPad`页面容器，带水平`margin`
* `VVeboImage` : 封装的展示`gif`图三方控件，做了少量定制
* `ALAssetsLibrary+TTAddiction` : 系统相册扩展，封装保存图片及获取相册图片等接口

## 依赖

* [TTBaseLib](https://code.byted.org/TTIOS/tt_pods_base)
* [TTThemed](https://code.byted.org/TTIOS/tt_pods_theme)
* [TTImage](https://code.byted.org/TTIOS/tt_pods_image)
* [TTRoute](https://code.byted.org/TTIOS/tt_pods_route)
* [TTVerifyKit](https://code.byted.org/TTIOS/tt_pods_TTVerifyKit)
* [KVOController](https://github.com/facebook/KVOController)
* [Masonry](https://github.com/SnapKit/Masonry)

## 更新记录
 版本号 | 升级日志
 ------ | -----------------
 v0.4.0 | [SSAppPageManager] : 增加registerPageClass:forSchema:方法，用于新的viewController动态注册schema。同时，解析时如果出现同名，动态添加的schema会覆盖配置文件中的schema
 v0.4.1 | [SSAppPageManager] : 增加canOpenURL的动态判断，联调火山直播schema跳转
 v0.4.2 | [SSAppPageManager] : fix
 v0.4.3 | 增加VVeboImage及VVeboImageView类，包含主端修改，不影响第三方原有功能
 v0.4.4 | Fix bug, TTOriginalLogo中通过CoreText计算UILabel的每行文字时，忽略了UILabel中存在attributedString的情况，导致计算错误。
 v0.4.5 | [SSAppPageManager] : 增加返回按钮/关闭页面判断逻辑
 v0.4.6 | [SSAppPageManager] : 新增连续present呈现页面的方式;[SSAlertViewBase]&[TTSaveImageAlertView] : 当present的时候图集长按保存的视图正常显示
 v0.4.7 | [SSAppPageManager] : 增加 transitioningDelegate 自定义present动画
 v0.4.8 | [TTUserInfoView]   : 增加大Vlogo
 v0.4.9 | [TTFoldableLayout] : 增加 lockHeaderAutoFolded 属性，控制 header 是否需要跟随手指的滑动而展开或收起，且可代码改变 header 的展开或收起状态。
 v0.5.0 | [TTTabbarTipView] : 更改tipview展示时间为5s
 v0.5.1 | [TTUserInfoView]  : fix
 v0.5.2 | [TTUserInfoView]  : fix
 v0.5.3 | [SSAppPageManager] : 增加钩子，支持自定义打开VC
 v0.5.4 | [TTUserInfoView]  : 夜间模式图片效果不好...更换图片;[TTSwipePageViewControllerDelegate] : 改为@optional
 v0.5.6 | [TTTabBarController]  : 整个文件夹删除，代码挪到主工程中;[TTNumberView] : 小红点大小12px->16px
 v0.5.7 | podspec依赖写死版本
 v0.5.8 | [TTUserInfoView]  : Logo间距调整
 v0.5.9 | [TTNavigationController] : 修复iPad下详情页字体设置弹出后swip手势优先响应的bug
 v0.6.0 | [TTThemedAlertController] : 修复4s未登录状态下发表评论提示登录弹窗被键盘遮挡的bug
 v0.6.1 | [UIView+Refresh_ErrorHandler] : 增加ttDisableNotifyBar参数控制蓝条是否展示
 v0.6.2 | [TTLoadMoreView] : 点击加载更多button背景颜色改为透明，即颜色和列表背景颜色相同;[UINavigationController+NavigationBarConfig] : 改变日夜间模式的时候状态栏变化有动画
 v0.6.3&v0.6.4 | [UIView+Refresh_ErrorHandler] : 修复getter方法死循环调用问题
 v0.7.2 | [TTFullScreenErrorView] : 修改错误视图中关注列表和兴趣列表的文案
 v0.7.3 | [TTNavigationController] : 重构TTNavigationController解决之前pop时可能日夜间状态不同步的问题
 v0.7.4 | [TTNavigationController] : 解决新导航栏是否启用接口可能和本地配置不一致的问题
 v0.7.5~v0.7.6 | [TTUIWidget.podspec] : 修复查找不到UIWidget pod中资源文件的问题
 v0.7.7 | [TTNavigationController] : 修复从京东商城首页pop到上一级导航栏隐藏的问题
 v0.7.8 | [TTNavigationController] : 修复调用NavigationController setViewControllers方法之后当前VC自定义navigationBar没有显示的问题
 v0.7.9 | [TTFullScreenErrorView] : 添加错误视图中TA的关注列表和兴趣列表的文案
 v0.7.10 | [TTNavigationController] : 添加保护防止手势返回的时候数组越界
 v0.7.11 | [TTNavigationController] : 解决iOS10TabBar截图透明的问题
 v0.7.12 | [TTNavigationController] : 修复iOS7横屏iPad push动画漂移的问题
 v0.7.13 | [TTThemedAlertController] : 修复alertView在iPad上的显示问题
 v0.7.14 | 迁移到gitlab
 v0.7.15 | [TTNavigationController] : 修复iPad转屏的时候导航栏下面分割线宽度不对的问题
 v0.7.16 | [TTNavigationController] : pan中添加设置顶层vc.view.userInteractionEnabled = NO，解决RCTRootView需要主动调用cancelTouches的问题
 v0.7.17 | [TTNavigationController] : 修复有presentingViewController的情况,返回截图不对问题
 v0.7.18 | [TTUserInfoView] : 增加楼主标签和好友关系
 v0.7.19 | [TTLoadingView] : CABasicAnimation的delegate是strong的，会引起详情页加载更多动画的内存泄露，此处没用到delegate，直接注释掉
 v0.7.20 | [TTNavigationController] : 修复vc.view中可能出现的内存泄漏问题&删除关于禁止手势返回的冗余代码
 v0.7.21 | [SSAppPageManager] : 修复openURL时遇到登陆界面导致详情页被push到登陆界面的问题
 v0.7.22 | [TTNavigationController] : 只有对用了自定义navigationBar的VC.view才需要观察是否有子视图动态的被添加，来调整其inset
 v0.7.23 | [TTUserInfoView] : 有认证信息时logo大小不能超过认证信息label高度
 v0.7.24 | [TTNavigationController] : 修复选择图片页面左滑返回当前顶层视图被下面视图遮挡的问题
 v0.7.25 | [SSAppPageManager] : 统一处理，将encode后的跳转URL里的"+"替换为"%20"
 v0.7.26 | [TTPanelController] : 修复TTPanelController中的item在iPad无法完全的UI bug
 v0.7.27 | [UIView+Refresh_ErrorHandler] : 修复iOS7系统由OBJC_ASSOCIATION_ASSIGN引起的野指针访问时crash的问题
 v0.7.28 | [TTPageController/TTFoldableLayout] :  修复 iOS 8.1 及以下版本，嘉聊视频直播室自动收起时底部会留白的问题。
 v0.7.29 | [TTGradientView/UIView+Refresh_ErrorHandler] :  替换"好多房"加载态为"你关心的才是头条"
 v0.7.30 | [TTNavigationController] : TTNavigationController对tabbar截图大小调整，能截取到超出tabbar bounds的view
 v0.7.31 | [TTNavigationController] : 修复TTNavigationController对tabbar截图bug
 v0.7.32 | [TTGradientView] : 加载态扫描动画修改动画时间，加入停顿时间&防止动画视图被多次添加
 v0.7.33 | [TTTagView] : collectionView cellForItem方法做保护;[TTNavigationController]: 修复新导航栏夜间模式下进入图片选择器时导航栏颜色不对的问题
 v0.7.34 | [TTNavigationController] : 修复刚Push之后就pop到上一级页面可能出现黑屏的问题
 v0.7.35 | [TTNavigationController] : 添加保护防止刚pop又push或者刚push又pop导致页面错乱
 v0.7.36 | [TTAsyncLabel/TTAsyncCornerImageView] : 增加两个异步渲染的控件，用于优化详情页评论列表
 v0.7.37 | [TTThemedAlertController] : 修复alertView出现的同时，正好触发视频转屏，导致alertView位置不对的问题
 v0.7.38 | [TTUserInfoView] : 修改TTUserInfoView因为高度问题无法显示的问题
 v0.7.39 | [TTRefreshView.xib] : 修改label对齐属性为居中
 v0.7.40 | [TTPanelController] : 分享item干掉autoResizing，防止每行最后一个item热区过大
 v0.7.41 | [TTThemedAlertController] : alertView考虑键盘弹出时的场景
 v0.7.42 | [TTAlphaThemedButton] : setHighlighted未调用super导致backgroundColor未设置;[TTAsyncCornerImageView] : removeObserver
 v0.7.43 | [TTAsyncLabel] : 增加保护，防止渲染时发生crash
 v0.7.44 | [SSAppPageManager] : 修改函数registerPageClass参数名称[class]为[aClass]，[class]在C++中是关键字，混编会报错
 v0.7.45~v0.7.46 | [SSAppPageManager] : 增加一个数组，记录访问过的UIViewController，用户反馈的时候会读取;[UIViewController+Track] : viewwillAppear和viewillDisAppear里将访问的类名记录一下，最多记录最近的40个类
 v0.7.47 | [TTPanelController] : 分享面板色值调整
 v0.7.48 | [TTAlphaThemedButton] : TTAlphaThemedButton setHighlighted方法在backgroundColorThemeKey不为空时再重置backgroundColor
 v0.7.49 | [TTAlphaThemedButton] : TTAlphaThemedButton setThemeColorKey时不再通过highlighted方式设置
 v0.7.50 | [TTUserInfoView] : 修改了在TTNewCommentCellLite情况下认证信息错位问题
 v0.7.51 | [TTAsyncLabel/TTAsyncCornerImageView] : TTAsyncLabel增加truncationToken点击响应,TTAsyncCornerImageView修正闪动bug
 v0.7.52 | [TTAsynclabel/TTAsyncCornerImageView] : TTAsyncLabel修改绘制的position/TTAsyncCornerImageView加入串行队列
 v0.7.53 | [TTAsynclabel/TTAsyncCornerImageView] : TTAsyncLabel修改异步线程cancel时机/TTAsyncCornerImageView占位图绘制加入串行队列
 v0.8.0 | [SSNavigationBar] : 修复UIBarButtonItem传入UIButton导致响应热区过大的问题;[TTSwipePageViewController] : 修复单独使用TTSwipePageViewController控件时导航栏被隐藏的问题
 v0.8.1  | [TTPanelController] : 分享面板设置调整
 v0.8.2  | 添加原TTCommonManager的TTRichEditor
 v0.8.3  | [TTAlphaThemedButton] : 在初始化方法里默认开启点击态，透明度变成0.3
 v0.8.4  | [TTRichEditorView] : 修改bundle的load方式，先加载outerBundle，再取TTEditor Bundle
 v0.8.5  | 合并0.7.53代码
 v0.8.6  | [TTASyncLabel]注释ASyncLabel中的方法
 v0.8.7  | [TTNavigationController]增加Navigation的push动画样式
 v0.8.8  | [TTNavigationController]Navigation的新样式不再由useCustomTransition控制
 v0.8.9  | [TTAsyncCornerImageView] : 修改设置文字背景色的方式/修改渲染文字背景色的线程加入同步队列中
 v0.8.9.0 | [TTAsyncCornerImageView] : 修改TTAsyncCornerImageView方法名不一致
 v0.8.9.1 | [TTSwipePageViewController] : 修复TTSwipePageViewController组件慢速滑动切换时停止滑动回调没有被触发的问题
 v0.8.9.2 | [TTUserInfoView]: 在6plus下nameLabel下移2pt;[TTNavigationController]:1.增加Fade动画 2.自定义动画的时候不再添加Tab切图
 v0.8.9.3 | [TTUserInfoView]: 1.iPad下titleLable高度+2  2. 为了与titleLabel对齐, 除titleLabel外,其他view整体上移2pt
 v0.8.9.4 | [TTPanelControllerItem] : 添加TTPanelControllerItemTypeAvatarNoBorder类型
 v0.8.9.5 | [TTAsyncCornerImageView] : 修改头像遮罩
 v0.8.9.8 | [TTUserInfoView] : 修改window问题;[TTIndicatorView] : window闲置时hidden掉，防止被设为keyWindow出现异常情况；不能取parentView，直接取backWindow；针对连续弹出indicator的情况做兼容
 v0.8.9.9.3 | 路由判断topVC时改为while判断，并增加上限保护
 v0.8.9.9.4 | [TTNavigationController] : 增加一种动画方式，支持ab测
 v0.8.9.9.5 | [TTAsyncLabel] : 增加保护，防止CT对象为nil的crash
 v0.8.9.9.6 | 优化pushAnimation转场动画
 v0.8.9.9.7 | 修复asyncLabel的crash和indicatorWindow的UI问题
 v0.8.9.9.8 | 修复新push动画交互问题
 v0.8.9.9.9 | 修复字体设置浮层手势冲突的问题
 v0.8.9.9.10 | 删除富文本编辑器
 v0.8.9.9.11 | 修改pop动画时，蒙层被navigationbar遮住的UI问题
 v0.8.9.9.12 | 修改pop动画时，把rootViewController移除导致黑屏的问题
 v0.8.9.9.13 | 修复TTAsyncLabel在转发评论中有高亮用户名，且换行出现“全文”时造成数组越界的crash，增加保护
 v0.8.9.9.14 | TTRefreshView增加下拉刷新广告相关逻辑
 v0.8.9.9.15 | 合入612 && 火山接入头条 增加badgeView展示...的功能 navigationController的pop动画处理黑屏问题
 v0.8.9.9.16 | SSAppPageManager的canOpenURL方法增加scheme判断
 v0.8.9.9.17 | TTNavigationController处理手势冲突
 v0.8.10.2 | merge news_6.0.8 ~ news_6.1.4分支代码，包含最新逻辑
 v0.8.11 | 升级到三位版本号
 v0.8.12 | 接入1.0+版本baselib
 v0.8.13 | 修复下拉刷新pad适配问题
 v0.8.14 | 修复refreshView布局bug
 v0.8.15 | 修复UINavigationController+NavigationBarConfig偶尔崩溃的问题
 v0.8.16 | TTHorizontalCategoryBar增加渐变动画开关参数
 v0.8.17 | 适配sd4.0
 v0.8.18 | 引入TTRoute，SSViewControllerBase实现TTRouteInitializeProtocol协议，去掉原有initWithBaseCondition初始化方法
 v0.8.19 | [SSViewControllerBase] 删除viewDidLoad里对navigationItem.title的操作
 v0.8.22 | TTNavigationController手势增加RN页面判断，临时方案，TODO
 v0.8.23 | 平台化三期，下沉几个库+引入TTVerifyKit
 v0.8.24 | TTRefreshView添加delegate方法 -(void)refreshViewDidMessageBarResetContentInset，蓝条收起动画结束时调用
 v0.8.25 | TTBadgeNumberView修改边框绘制方式，解决发虚问题
 v0.8.26 | fix OBJC_ASSOCIATION_ASSIGN可能带来的野指针问题
 v0.8.27 | TTWaitingView去掉willMoveToWindow方法实现，改为willMoveToSuperView实现
 v0.8.28 | 完善readme文档，删除SSPageFlowView组件
 v0.8.29 | 修复警告和尝试修复UINavigationBar的CRASH
 v0.8.30 | 修复在viewController动画时，由于viewDidLoad调用时机问题导致的ttNavigationiBar初始化出来却没有被SSViewControllerBase的ttHideNavigationBar=NO属性所隐藏的问题
 v0.8.31 | 修复 TTAsyncLabel 中可能出现的内存泄漏问题
 v0.8.32 | 修复UILabel+Tapping在检测点击区域时，如果用户采用点击后拖拽不放到文本下方区域（y为正值），则仍保持了点击态的问题
 v0.8.33 | 修复UILabel+Tapping使用TextKit在计算含有NSParagraphStyle且linebreakMode不为wordWrapping或者charWrapping的情况下，得到文本矩形高度错误（只有一行高度），导致点击区域识别出错的问题
 v0.8.34 | 修复下拉刷新无法弹起问题
 v0.8.35 | TTIconLabel的认证图标使用SD4.1替代YYImage
 v0.8.36 | 修复TTThemedAlertController展示alert时底部白线的问题,适配iOS 11
v0.8.37|对评论cell的人名部分做“楼主展示与否”的区分逻辑
 V0.8.38 | 适配iPhoneX
 V0.8.39 | Transitioning转场需要提前调下tovc的viewdidload、干掉老版动画、接口名字修改
 v0.8.40 | 在初始化navBar的时候，设置barPosition
 v0.8.42 | 不根据安全区来设置导航栏的顶部
 v0.8.43 | TTIndicatorView拆分成独立子库 for video
 v0.8.44 | TTModalContainerController沉库
 v0.8.45 | 修复TTModalContainerController手势问题
 v0.8.46 | TTModalContainerController适配iPhone X
 v0.8.47 | Fix TTNavigationController Memory Leaks
 v0.8.48 | 删除冗余的安全区适配代码
 v0.8.50 | indicator增加行数可配
 v0.8.53 | TTFullScreenErrorView增加空页面文案图片自定义和自定义视图（使用自定义的视图覆盖）
 v0.8.55 | TTNavigationController Pan 与 ChildViewController Canvas 手势冲突
 
## Author

fengjingjun, fengjingjun@bytedance.com

## License

TTUIWidget is available under the MIT license. See the LICENSE file for more info.


