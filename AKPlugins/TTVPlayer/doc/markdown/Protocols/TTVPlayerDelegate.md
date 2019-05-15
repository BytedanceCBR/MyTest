# TTVPlayerDelegate Protocol Reference

&nbsp;&nbsp;**Conforms to** NSObject  
&nbsp;&nbsp;**Declared in** TTVPlayer.h<br />  
TTVPlayerDelegate.h  

## Tasks

### Other Methods

[&ndash;&nbsp;viewDidLoad:state:](#//api/name/viewDidLoad:state:)  

[&ndash;&nbsp;viewDidLayoutSubviews:state:](#//api/name/viewDidLayoutSubviews:state:)  

[&ndash;&nbsp;containerViewDidLayout:player:state:](#//api/name/containerViewDidLayout:player:state:)  

[&ndash;&nbsp;player:playbackTimeChanged:](#//api/name/player:playbackTimeChanged:)  

[&ndash;&nbsp;playerCloseAysncFinish:](#//api/name/playerCloseAysncFinish:)  

[&ndash;&nbsp;player:didFinishedWithStatus:](#//api/name/player:didFinishedWithStatus:)  

### Other Methods

[&ndash;&nbsp;controlViewDidLayout:player:state:](#//api/name/controlViewDidLayout:player:state:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/containerViewDidLayout:player:state:" title="containerViewDidLayout:player:state:"></a>
### containerViewDidLayout:player:state:

当 controlView 调用 layoutSubview 的时候，回调此函数

`- (void)containerViewDidLayout:(TTVPlayerGestureContainerView *)*containerView* player:(TTVPlayer *)*player* state:(TTVPlayerState *)*state*`

#### Parameters

*player*  
&nbsp;&nbsp;&nbsp;可以获取所有的 view，以及 part 和 state  

*state*  
&nbsp;&nbsp;&nbsp;播放器内核+UI 的状态  

#### Discussion
当 controlView 调用 layoutSubview 的时候，回调此函数

@param controlView

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/controlViewDidLayout:player:state:" title="controlViewDidLayout:player:state:"></a>
### controlViewDidLayout:player:state:

当 controlView 调用 layoutSubview 的时候，回调此函数

`- (void)controlViewDidLayout:(UIView *)*controlView* player:(TTVPlayer *)*player* state:(TTVRPlayerState *)*state*`

#### Parameters

*player*  
&nbsp;&nbsp;&nbsp;可以获取所有的 view，以及 part 和 state  

*state*  
&nbsp;&nbsp;&nbsp;播放器内核+UI 的状态  

#### Discussion
当 controlView 调用 layoutSubview 的时候，回调此函数

@param controlView

#### Declared In
* `TTVPlayerDelegate.h`

<a name="//api/name/player:didFinishedWithStatus:" title="player:didFinishedWithStatus:"></a>
### player:didFinishedWithStatus:

播放结束的回调：包含手动调用 stop 和自动播放结束；手动和自动在 status 中有体现

`- (void)player:(TTVPlayer *)*player* didFinishedWithStatus:(TTVPlayFinishStatus *)*finishStatus*`

#### Parameters

*player*  
&nbsp;&nbsp;&nbsp;player  

*finishStatus*  
&nbsp;&nbsp;&nbsp;status  

#### Discussion
播放结束的回调：包含手动调用 stop 和自动播放结束；手动和自动在 status 中有体现

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/player:playbackTimeChanged:" title="player:playbackTimeChanged:"></a>
### player:playbackTimeChanged:

内部 timer，默认500ms 获取回调一次，如果需要修改 回调时间间隔请调用，依旧会得到此回调通知
请调用 - (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block;

`- (void)player:(TTVPlayer *)*player* playbackTimeChanged:(TTVPlaybackTime *)*playbackTime*`

#### Parameters

*player*  
&nbsp;&nbsp;&nbsp;player  

*playbackTime*  
&nbsp;&nbsp;&nbsp;播放相关的时间  

#### Discussion
内部 timer，默认500ms 获取回调一次，如果需要修改 回调时间间隔请调用，依旧会得到此回调通知
请调用 - (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval queue:(dispatch_queue_t)queue usingBlock:(dispatch_block_t)block;

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/playerCloseAysncFinish:" title="playerCloseAysncFinish:"></a>
### playerCloseAysncFinish:

当调用 closeAysn,会收到此回调

`- (void)playerCloseAysncFinish:(TTVPlayer *)*player*`

#### Discussion
当调用 closeAysn,会收到此回调

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/viewDidLayoutSubviews:state:" title="viewDidLayoutSubviews:state:"></a>
### viewDidLayoutSubviews:state:

viewcontroller回调 viewDidLayoutSubviews时回调

`- (void)viewDidLayoutSubviews:(TTVPlayer *)*player* state:(TTVPlayerState *)*state*`

#### Parameters

*player*  
&nbsp;&nbsp;&nbsp;playerVC 可以获取所有的 view，以及 part  

*state*  
&nbsp;&nbsp;&nbsp;播放器内核+UI 的状态  

#### Discussion
viewcontroller回调 viewDidLayoutSubviews时回调

#### Declared In
* `TTVPlayer.h`

<a name="//api/name/viewDidLoad:state:" title="viewDidLoad:state:"></a>
### viewDidLoad:state:

viewcontroller 回调 viewDidLoad 回调

`- (void)viewDidLoad:(TTVPlayer *)*player* state:(TTVPlayerState *)*state*`

#### Parameters

*player*  
&nbsp;&nbsp;&nbsp;可以获取所有的 view，以及 part 和 state  

*state*  
&nbsp;&nbsp;&nbsp;播放器内核+UI 的状态  

#### Discussion
viewcontroller 回调 viewDidLoad 回调

#### Declared In
* `TTVPlayer.h`

