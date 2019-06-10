# TTVPlayerGestureContainerView Class Reference

&nbsp;&nbsp;**Inherits from** UIView  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVPlayerContext.html">TTVPlayerContext</a><br />  
<a href="../Protocols/TTVReduxStateObserver.html">TTVReduxStateObserver</a>  
&nbsp;&nbsp;**Declared in** TTVPlayerGestureContainerView.h<br />  
TTVPlayerGestureContainerView.m  

## Overview

除了视频播放view之外，看到的所有 view 都加在这个 view 上；这个 view 可以响应单击、双击、滑动等手势以及处理相关冲突
整体分为两层view，参见下面成员注释，其中最重要的是 controlView：part 中控制功能的控件会加到这个 view 上, 他控制着整体控件的消失和出现

## Tasks

### Other Methods

[&ndash;&nbsp;showControlView:](#//api/name/showControlView:)  

### Other Methods

[&ndash;&nbsp;stateDidChangedToNew:lastState:store:](#//api/name/stateDidChangedToNew:lastState:store:)  

[&ndash;&nbsp;subscribedStoreSuccess:](#//api/name/subscribedStoreSuccess:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/showControlView:" title="showControlView:"></a>
### showControlView:

手动控制控件展示；多用于第一次展示

`- (void)showControlView:(BOOL)*show*`

#### Parameters

*show*  
&nbsp;&nbsp;&nbsp;是否需要展示 controlView  

#### Discussion
手动控制控件展示；多用于第一次展示

#### Declared In
* `TTVPlayerGestureContainerView.h`

<a name="//api/name/stateDidChangedToNew:lastState:store:" title="stateDidChangedToNew:lastState:store:"></a>
### stateDidChangedToNew:lastState:store:

状态已经发生改变

`- (void)stateDidChangedToNew:(TTVPlayerState *)*newState* lastState:(TTVPlayerState *)*lastState* store:(NSObject&lt;TTVReduxStoreProtocol&gt; *)*store*`

#### Parameters

*newState*  
&nbsp;&nbsp;&nbsp;改变后的状态  

*lastState*  
&nbsp;&nbsp;&nbsp;改变前的状态,上一个状态  

*store*  
&nbsp;&nbsp;&nbsp;持有state 的仓库  

#### Discussion
状态已经发生改变

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/subscribedStoreSuccess:" title="subscribedStoreSuccess:"></a>
### subscribedStoreSuccess:

成功订阅通知

`- (void)subscribedStoreSuccess:(TTVReduxStore *)*store*`

#### Parameters

*store*  
&nbsp;&nbsp;&nbsp;订阅的 store  

#### Discussion
成功订阅通知

#### Declared In
* `TTVReduxStore.h`

