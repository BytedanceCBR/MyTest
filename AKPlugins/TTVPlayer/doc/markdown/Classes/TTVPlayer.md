# TTVPlayer Class Reference

&nbsp;&nbsp;**Inherits from** UIViewController  
&nbsp;&nbsp;**Declared in** TTVPlayer.h<br />  
TTVPlayer.m  

## Overview

TTVPlayer 提供了Engine 的视频播放等基础功能；还提供了 UI 增删改查等功能与自定义功能
把 videoEngine 包装起来，隐藏内核的一切, 用于未来切换成 TTAVPlayer 或者加入直播 TTLiveVideo, 对外都可以无感知
请大家使用 TTVPlayer，代替 TTVideoEngine

## Tasks

### Other Methods

[&ndash;&nbsp;initWithOwnPlayer:](#//api/name/initWithOwnPlayer:)  

[&ndash;&nbsp;initWithOwnPlayer:configFileName:](#//api/name/initWithOwnPlayer:configFileName:)  

[&ndash;&nbsp;initWithOwnPlayer:style:](#//api/name/initWithOwnPlayer:style:)  

[&ndash;&nbsp;addPeriodicTimeObserverForInterval:queue:usingBlock:](#//api/name/addPeriodicTimeObserverForInterval:queue:usingBlock:)  

[&ndash;&nbsp;play](#//api/name/play)  

[&ndash;&nbsp;resume](#//api/name/resume)  

[&ndash;&nbsp;pause](#//api/name/pause)  

[&ndash;&nbsp;updatePlaybackTime](#//api/name/updatePlaybackTime)  

[&ndash;&nbsp;_endObservePlayTime](#//api/name/_endObservePlayTime)  

[&ndash;&nbsp;videoEngine:fetchedVideoModel:](#//api/name/videoEngine:fetchedVideoModel:)  

[&ndash;&nbsp;addTipView:](#//api/name/addTipView:)  

[&ndash;&nbsp;addControl:](#//api/name/addControl:)  

[&ndash;&nbsp;addViewUnderPlayerControl:](#//api/name/addViewUnderPlayerControl:)  

[&ndash;&nbsp;partControlForKey:](#//api/name/partControlForKey:)  

[&ndash;&nbsp;removePlayer](#//api/name/removePlayer)  

[+&nbsp;allActivePlayers](#//api/name/allActivePlayers)  

[&ndash;&nbsp;addPartForKey:](#//api/name/addPartForKey:)  

[&ndash;&nbsp;removePartForKey:](#//api/name/removePartForKey:)  

[&ndash;&nbsp;removeAllParts](#//api/name/removeAllParts)  

[&ndash;&nbsp;partForKey:](#//api/name/partForKey:)  

[&ndash;&nbsp;allParts](#//api/name/allParts)  

[&ndash;&nbsp;setHardwareDecode:](#//api/name/setHardwareDecode:)  

[&ndash;&nbsp;videoSizeOfCurrrentResolution](#//api/name/videoSizeOfCurrrentResolution)  

[&ndash;&nbsp;setVideoID:host:commonParameters:](#//api/name/setVideoID:host:commonParameters:)  

### Other Methods

[&ndash;&nbsp;setVideoID:host:commonParameters:businessToken:](#//api/name/setVideoID:host:commonParameters:businessToken:)  

[&ndash;&nbsp;setPreloaderItem:](#//api/name/setPreloaderItem:)  

[&nbsp;&nbsp;readyForRender](#//api/name/readyForRender) *property* 

[&nbsp;&nbsp;volume](#//api/name/volume) *property* 

[&ndash;&nbsp;getOptionBykey:](#//api/name/getOptionBykey:)  

[&ndash;&nbsp;setOptions:](#//api/name/setOptions:)  

### CacheProgress Methods

[&ndash;&nbsp;cacheProgress](#//api/name/cacheProgress)  

[&ndash;&nbsp;removeProgressCacheIfNeeded](#//api/name/removeProgressCacheIfNeeded)  

## Properties

<a name="//api/name/readyForRender" title="readyForRender"></a>
### readyForRender

/ 结束状态: nil 就是没结束，如果!nil 就是结束了

`@property (nonatomic, assign, readonly) BOOL readyForRender`

#### Discussion
/ 结束状态: nil 就是没结束，如果!nil 就是结束了

#### Declared In
* `TTVPlayer.m`

<a name="//api/name/volume" title="volume"></a>
### volume

enable AudioSession  ,初始化的时候，占用音轨

`@property (nonatomic) CGFloat volume`

#### Discussion
enable AudioSession  ,初始化的时候，占用音轨

#### Declared In
* `TTVPlayer.h`

<a title="Class Methods" name="class_methods"></a>
## Class Methods

<a name="//api/name/allActivePlayers" title="allActivePlayers"></a>
### allActivePlayers

由于可以同时存在多个 player，可以通过这个方法获取全部用本类创建的 player

`+ (NSArray *)allActivePlayers`

#### Return Value
player

#### Discussion
由于可以同时存在多个 player，可以通过这个方法获取全部用本类创建的 player

#### Declared In
* `TTVPlayer.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/_endObservePlayTime" title="_endObservePlayTime"></a>
### _endObservePlayTime

playtimer

`- (void)_endObservePlayTime`

#### Discussion
playtimer

#### Declared In
* `TTVPlayer.m`

<a name="//api/name/addControl:" title="addControl:"></a>
### addControl:

在 player 的 control 区域添加view,  part 上的 control 默认都添加到这里。

`- (void)addControl:(UIView *)*view*`

#### Parameters

*view*  
&nbsp;&nbsp;&nbsp;可以控制播放器的 view; 3s 后会消失掉  

#### Discussion
在 player 的 control 区域添加view,  part 上的 control 默认都添加到这里。

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/addPartForKey:" title="addPartForKey:"></a>
### addPartForKey:

根据配置文件，添加 part和 part 里面相关的 control
跟已有 key 相同会覆盖当前的 key 绑定的 part
TODO: 如果已经从 default 获取了，再后续动态加入，会对布局有影响

`- (void)addPartForKey:(TTVPlayerPartKey)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;part 对应的 key  

#### Discussion
根据配置文件，添加 part和 part 里面相关的 control
跟已有 key 相同会覆盖当前的 key 绑定的 part
TODO: 如果已经从 default 获取了，再后续动态加入，会对布局有影响

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/addPeriodicTimeObserverForInterval:queue:usingBlock:" title="addPeriodicTimeObserverForInterval:queue:usingBlock:"></a>
### addPeriodicTimeObserverForInterval:queue:usingBlock:

设置 timer

`- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)*interval* queue:(dispatch_queue_t)*queue* usingBlock:(dispatch_block_t)*block*`

#### Parameters

*interval*  
&nbsp;&nbsp;&nbsp;timer 通知间隔  

*queue*  
&nbsp;&nbsp;&nbsp;通知队列  

*block*  
&nbsp;&nbsp;&nbsp;回调  

#### Discussion
设置 timer

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/addTipView:" title="addTipView:"></a>
### addTipView:

在 player 的 非 control 区域添加, 主要用户添加提示控件

`- (void)addTipView:(UIView *)*view*`

#### Parameters

*view*  
&nbsp;&nbsp;&nbsp;不可以控制播放器，主要是提示类型的比如 loading 等  

#### Discussion
在 player 的 非 control 区域添加, 主要用户添加提示控件

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/addViewUnderPlayerControl:" title="addViewUnderPlayerControl:"></a>
### addViewUnderPlayerControl:

在 player control 下面加入 view，加入的 view 也可以响应事件

`- (void)addViewUnderPlayerControl:(UIView *)*view*`

#### Parameters

*view*  
&nbsp;&nbsp;&nbsp;view  

#### Discussion
在 player control 下面加入 view，加入的 view 也可以响应事件

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/allParts" title="allParts"></a>
### allParts

获取所有的player 上已经添加的所有parts

`- (NSArray&lt;NSObject&lt;TTVPlayerContext,TTVPlayerPartProtocol,TTVReduxStateObserver&gt; *&gt; *)allParts`

#### Return Value
parts array

#### Discussion
获取所有的player 上已经添加的所有parts

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/cacheProgress" title="cacheProgress"></a>
### cacheProgress

Cache current player progress. Must called before player stop or <a href="#//api/name/pause">pause</a>, after videoID was set up

`- (void)cacheProgress`

#### Discussion
Cache current player progress. Must called before player stop or <a href="#//api/name/pause">pause</a>, after videoID was set up

#### Declared In
* `TTVPlayer+CacheProgress.h`

<a name="//api/name/getOptionBykey:" title="getOptionBykey:"></a>
### getOptionBykey:

Get option that you care about.
Example: get video width.
NSInteger videoWidth = [[self getOptionBykey:VEKKEY(VEKGetKeyPlayerVideoWidth_NSInteger)] integerValue];
|                                  |                    |           |
value                             Gen key               Filed      valueType

`- (id)getOptionBykey:(VEKKeyType)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;Please use VEKKEY(key) to prodect a valid key.  

#### Return Value
Value correspod the key. The key include value type.

#### Discussion
Get option that you care about.
Example: get video width.
NSInteger videoWidth = [[self getOptionBykey:VEKKEY(VEKGetKeyPlayerVideoWidth_NSInteger)] integerValue];
|                                  |                    |           |
value                             Gen key               Filed      valueType

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/initWithOwnPlayer:" title="initWithOwnPlayer:"></a>
### initWithOwnPlayer:

创建原始的 player，不带 part 任何功能，需要修改下面的 NSString * configFileName；或者 <a href="../Constants/TTVPlayerStyle.html">TTVPlayerStyle</a> <a href="#//api/name/style">style</a> 进行添加配置文件
例如：在列表中可以 inline 播放的播放器，出于性能问题，不需要立马创建出来，再确定的时机再进行加载

`- (instancetype)initWithOwnPlayer:(BOOL)*isOwnPlayer*`

#### Parameters

*isOwnPlayer*  
&nbsp;&nbsp;&nbsp;是否自研  

#### Return Value
self

#### Discussion
创建原始的 player，不带 part 任何功能，需要修改下面的 NSString * configFileName；或者 <a href="../Constants/TTVPlayerStyle.html">TTVPlayerStyle</a> <a href="#//api/name/style">style</a> 进行添加配置文件
例如：在列表中可以 inline 播放的播放器，出于性能问题，不需要立马创建出来，再确定的时机再进行加载

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/initWithOwnPlayer:configFileName:" title="initWithOwnPlayer:configFileName:"></a>
### initWithOwnPlayer:configFileName:

创建player, 需要自定义布局，对布局进行修改，默认采用第二种 <a href="#//api/name/style">style</a> 的布局

`- (instancetype)initWithOwnPlayer:(BOOL)*isOwnPlayer* configFileName:(NSString *)*configFileName*`

#### Parameters

*isOwnPlayer*  
&nbsp;&nbsp;&nbsp;是否自研  

*configFileName*  
&nbsp;&nbsp;&nbsp;配置文件的名称  

#### Return Value
self

#### Discussion
创建player, 需要自定义布局，对布局进行修改，默认采用第二种 <a href="#//api/name/style">style</a> 的布局

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/initWithOwnPlayer:style:" title="initWithOwnPlayer:style:"></a>
### initWithOwnPlayer:style:

创建 player，<a href="#//api/name/style">style</a> 对应着一个 plist 配置文件和一个布局样式, 请优先使用这个初始化函数

`- (instancetype)initWithOwnPlayer:(BOOL)*isOwnPlayer* style:(TTVPlayerStyle)*style*`

#### Parameters

*isOwnPlayer*  
&nbsp;&nbsp;&nbsp;是否自研  

*style*  
&nbsp;&nbsp;&nbsp;plist 配置文件和一个布局样式  

#### Return Value
self

#### Discussion
创建 player，<a href="#//api/name/style">style</a> 对应着一个 plist 配置文件和一个布局样式, 请优先使用这个初始化函数

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/partControlForKey:" title="partControlForKey:"></a>
### partControlForKey:

通过 control 的 key 获取到已经加入到 player 的控件

`- (UIView *)partControlForKey:(TTVPlayerPartControlKey)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;控件的 key  

#### Return Value
已经加入到 player 的 view 上的 control

#### Discussion
通过 control 的 key 获取到已经加入到 player 的控件

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/partForKey:" title="partForKey:"></a>
### partForKey:

获取 part

`- (NSObject&lt;TTVPlayerContext,TTVPlayerPartProtocol,TTVReduxStateObserver&gt; *)partForKey:(TTVPlayerPartKey)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;part 绑定的 key  

#### Return Value
part

#### Discussion
获取 part

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/pause" title="pause"></a>
### pause

视频暂停，主要用于起播后，加入了播放调用栈，用于控制前后台切换等操作错误继续等情况
同时还缓存了当前进度

`- (void)pause`

#### Discussion
视频暂停，主要用于起播后，加入了播放调用栈，用于控制前后台切换等操作错误继续等情况
同时还缓存了当前进度

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/play" title="play"></a>
### play

视频播放，尤其用于第一次起播，后面调用 <a href="#//api/name/resume">resume</a> 继续播放

`- (void)play`

#### Discussion
视频播放，尤其用于第一次起播，后面调用 <a href="#//api/name/resume">resume</a> 继续播放

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/removeAllParts" title="removeAllParts"></a>
### removeAllParts

移除全部的part，将所有可移除的 part 相关的功能+UI 都整体移除掉

`- (void)removeAllParts`

#### Discussion
移除全部的part，将所有可移除的 part 相关的功能+UI 都整体移除掉

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/removePartForKey:" title="removePartForKey:"></a>
### removePartForKey:

通过 key 来移除 part，key 和 part 是一一对应的，相关的功能+UI 都整体移除掉

`- (void)removePartForKey:(TTVPlayerPartKey)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;part 绑定的 key  

#### Discussion
通过 key 来移除 part，key 和 part 是一一对应的，相关的功能+UI 都整体移除掉

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/removePlayer" title="removePlayer"></a>
### removePlayer

移除掉 player，停止播放

`- (void)removePlayer`

#### Discussion
移除掉 player，停止播放

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/removeProgressCacheIfNeeded" title="removeProgressCacheIfNeeded"></a>
### removeProgressCacheIfNeeded

Remove the progress cached before if less 5 sec left. Called when <a href="#//api/name/play">play</a> finished, after videoID was set up

`- (void)removeProgressCacheIfNeeded`

#### Discussion
Remove the progress cached before if less 5 sec left. Called when <a href="#//api/name/play">play</a> finished, after videoID was set up

#### Declared In
* `TTVPlayer+CacheProgress.h`

<a name="//api/name/resume" title="resume"></a>
### resume

视频继续播放，主要用于起播后，加入了播放调用栈，用于控制前后台切换等无法还原现场等情况

`- (void)resume`

#### Discussion
视频继续播放，主要用于起播后，加入了播放调用栈，用于控制前后台切换等无法还原现场等情况

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/setHardwareDecode:" title="setHardwareDecode:"></a>
### setHardwareDecode:

TODO

`- (void)setHardwareDecode:(BOOL)*hardwareDecode*`

#### Discussion
TODO

#### Declared In
* `TTVPlayer.m`

<a name="//api/name/setOptions:" title="setOptions:"></a>
### setOptions:

Set options by VEKKey
Example:
[self setOptions:@{VEKKEY(VEKKeyPlayerTestSpeedMode_ENUM),@(TTVideoEngineTestSpeedModeContinue)}];
|                   |          |                          |
Generate key            Filed     valueType                   value

`- (void)setOptions:(NSDictionary&lt;VEKKeyType,id&gt; *)*options*`

#### Parameters

*options*  
&nbsp;&nbsp;&nbsp;key is one of VEKKeys, value defined id type.  

#### Discussion
Set options by VEKKey
Example:
[self setOptions:@{VEKKEY(VEKKeyPlayerTestSpeedMode_ENUM),@(TTVideoEngineTestSpeedModeContinue)}];
|                   |          |                          |
Generate key            Filed     valueType                   value

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/setPreloaderItem:" title="setPreloaderItem:"></a>
### setPreloaderItem:

从预加载 item播放视频

`- (void)setPreloaderItem:(TTAVPreloaderItem *)*preloaderItem*`

#### Parameters

*preloaderItem*  
&nbsp;&nbsp;&nbsp;预加载 item  

#### Discussion
从预加载 item播放视频

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/setVideoID:host:commonParameters:" title="setVideoID:host:commonParameters:"></a>
### setVideoID:host:commonParameters:

设置播放器播放源相关的参数，此方法 将3个参数会拼接一个 url，进行真实播放地址的获取,获取视频地址的url不加密

`- (void)setVideoID:(NSString *)*videoID* host:(NSString *)*host* commonParameters:(NSDictionary *)*commonParameters*`

#### Parameters

*videoID*  
&nbsp;&nbsp;&nbsp;vid  

*host*  
&nbsp;&nbsp;&nbsp;服务端 <a href="#//api/name/host">host</a>  

*commonParameters*  
&nbsp;&nbsp;&nbsp;url 后添加的通用参数，比如机型等  

#### Discussion
设置播放器播放源相关的参数，此方法 将3个参数会拼接一个 url，进行真实播放地址的获取,获取视频地址的url不加密

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/setVideoID:host:commonParameters:businessToken:" title="setVideoID:host:commonParameters:businessToken:"></a>
### setVideoID:host:commonParameters:businessToken:

设置播放器播放源相关的参数，此方法 将3个参数会拼接一个 url，进行真实播放地址的获取,获取视频地址的url加密

`- (void)setVideoID:(NSString *)*videoID* host:(NSString *)*host* commonParameters:(NSDictionary *)*commonParameters* businessToken:(NSString *)*businessToken*`

#### Parameters

*videoID*  
&nbsp;&nbsp;&nbsp;vid  

*host*  
&nbsp;&nbsp;&nbsp;服务端 <a href="#//api/name/host">host</a>  

*commonParameters*  
&nbsp;&nbsp;&nbsp;url 后添加的通用参数，比如机型等  

*businessToken*  
&nbsp;&nbsp;&nbsp;加密秘钥，用于对此方法形成的 url 进行加密  

#### Discussion
设置播放器播放源相关的参数，此方法 将3个参数会拼接一个 url，进行真实播放地址的获取,获取视频地址的url加密

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/updatePlaybackTime" title="updatePlaybackTime"></a>
### updatePlaybackTime

/ playbacktime

`- (void)updatePlaybackTime`

#### Discussion
/ playbacktime

#### Declared In
* `TTVPlayer.m`

<a name="//api/name/videoEngine:fetchedVideoModel:" title="videoEngine:fetchedVideoModel:"></a>
### videoEngine:fetchedVideoModel:

<strong><strong><strong><strong><strong><strong><em>*** TTVideoEngine <a href="#//api/name/delegate">delegate</a> </em></strong></strong></strong></strong></strong></strong>

`- (void)videoEngine:(TTVideoEngine *)*videoEngine* fetchedVideoModel:(TTVideoEngineModel *)*videoModel*`

#### Discussion
<strong><strong><strong><strong><strong><strong><em>*** TTVideoEngine <a href="#//api/name/delegate">delegate</a> </em></strong></strong></strong></strong></strong></strong>

#### Declared In
* `TTVPlayer.m`

<a name="//api/name/videoSizeOfCurrrentResolution" title="videoSizeOfCurrrentResolution"></a>
### videoSizeOfCurrrentResolution

获取当前清晰度下，视频的大小，可以用于流量提示

`- (CGFloat)videoSizeOfCurrrentResolution`

#### Return Value
视频大小，单位是 bit，需要自行转化为 kb 或者 M 进行显示

#### Discussion
获取当前清晰度下，视频的大小，可以用于流量提示

#### Declared In
* `TTVPlayer.h`

