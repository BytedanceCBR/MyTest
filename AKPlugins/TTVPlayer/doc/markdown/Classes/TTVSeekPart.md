# TTVSeekPart Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVPlayerContext.html">TTVPlayerContext</a><br />  
<a href="../Protocols/TTVPlayerPartProtocol.html">TTVPlayerPartProtocol</a><br />  
<a href="../Protocols/TTVReduxStateObserver.html">TTVReduxStateObserver</a>  
&nbsp;&nbsp;**Declared in** TTVSeekPart.h<br />  
TTVSeekPart.m  

## Tasks

### Other Methods

[&nbsp;&nbsp;timeTextColorString](#//api/name/timeTextColorString) *property* 

[&ndash;&nbsp;setImageForSliderIndicatorView:](#//api/name/setImageForSliderIndicatorView:)  

[&ndash;&nbsp;setImageForSliderIndicatorBackgroundView:](#//api/name/setImageForSliderIndicatorBackgroundView:)  

[&ndash;&nbsp;setSliderBarColor:](#//api/name/setSliderBarColor:)  

[&ndash;&nbsp;setCachedProgressColor:](#//api/name/setCachedProgressColor:)  

[&ndash;&nbsp;setWatchedProgressColor:](#//api/name/setWatchedProgressColor:)  

### Other Methods

[&ndash;&nbsp;stateDidChangedToNew:lastState:store:](#//api/name/stateDidChangedToNew:lastState:store:)  

[&ndash;&nbsp;subscribedStoreSuccess:](#//api/name/subscribedStoreSuccess:)  

[&ndash;&nbsp;customPartControlForKey:withConfig:](#//api/name/customPartControlForKey:withConfig:)  

## Properties

<a name="//api/name/timeTextColorString" title="timeTextColorString"></a>
### timeTextColorString

所有的Time 的 UI 都是一致的，所以设置一个地方的就可以了

`@property (nonatomic, copy) NSString *timeTextColorString`

#### Discussion
所有的Time 的 UI 都是一致的，所以设置一个地方的就可以了

#### Declared In
* `TTVSeekPart.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/customPartControlForKey:withConfig:" title="customPartControlForKey:withConfig:"></a>
### customPartControlForKey:withConfig:

通过配置文件来，自定义 part 的 UI；每个 part 都有不一样的 dict 规则

`- (void)customPartControlForKey:(TTVPlayerPartControlKey)*key* withConfig:(NSDictionary *)*dict*`

#### Parameters

*dict*  
&nbsp;&nbsp;&nbsp;custom 的协议  

#### Discussion
通过配置文件来，自定义 part 的 UI；每个 part 都有不一样的 dict 规则

#### Declared In
* `TTVPlayerPartProtocol.h`

<a name="//api/name/setCachedProgressColor:" title="setCachedProgressColor:"></a>
### setCachedProgressColor:

设置已经成功 cache 的颜色

`- (void)setCachedProgressColor:(NSString *)*colorString*`

#### Parameters

*colorString*  
&nbsp;&nbsp;&nbsp;默认颜色是灰色，不设置就使用默认的  

#### Discussion
设置已经成功 cache 的颜色

#### Declared In
* `TTVSeekPart.h`

<a name="//api/name/setImageForSliderIndicatorBackgroundView:" title="setImageForSliderIndicatorBackgroundView:"></a>
### setImageForSliderIndicatorBackgroundView:

给进度条的进度点的背景，设置自定义 view; 设置了最上面的 ThumbView 会重置 background

`- (void)setImageForSliderIndicatorBackgroundView:(NSString *)*imageName*`

#### Parameters

*imageName*  
&nbsp;&nbsp;&nbsp;name  

#### Discussion
给进度条的进度点的背景，设置自定义 view; 设置了最上面的 ThumbView 会重置 background

#### Declared In
* `TTVSeekPart.h`

<a name="//api/name/setImageForSliderIndicatorView:" title="setImageForSliderIndicatorView:"></a>
### setImageForSliderIndicatorView:

给进度条的进度点，设置自定义 view

`- (void)setImageForSliderIndicatorView:(NSString *)*imageName*`

#### Parameters

*imageName*  
&nbsp;&nbsp;&nbsp;name  

#### Discussion
给进度条的进度点，设置自定义 view

#### Declared In
* `TTVSeekPart.h`

<a name="//api/name/setSliderBarColor:" title="setSliderBarColor:"></a>
### setSliderBarColor:

设置 slider bar 的颜色

`- (void)setSliderBarColor:(NSString *)*colorString*`

#### Parameters

*colorString*  
&nbsp;&nbsp;&nbsp;默认颜色是灰色，不设置就使用默认的  

#### Discussion
设置 slider bar 的颜色

#### Declared In
* `TTVSeekPart.h`

<a name="//api/name/setWatchedProgressColor:" title="setWatchedProgressColor:"></a>
### setWatchedProgressColor:

设置进度点左边的已经 pass 的颜色

`- (void)setWatchedProgressColor:(NSString *)*colorString*`

#### Parameters

*colorString*  
&nbsp;&nbsp;&nbsp;默认颜色是红色，不设置就使用默认的  

#### Discussion
设置进度点左边的已经 pass 的颜色

#### Declared In
* `TTVSeekPart.h`

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

/ 如果是 swipe

`- (void)subscribedStoreSuccess:(TTVReduxStore *)*store*`

#### Discussion
/ 如果是 swipe

#### Declared In
* `TTVSeekPart.m`

