# TTVPlayPart Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVPlayerContext.html">TTVPlayerContext</a><br />  
<a href="../Protocols/TTVPlayerPartProtocol.html">TTVPlayerPartProtocol</a><br />  
<a href="../Protocols/TTVReduxStateObserver.html">TTVReduxStateObserver</a>  
&nbsp;&nbsp;**Declared in** TTVPlayPart.h<br />  
TTVPlayPart.m  

## Tasks

### Other Methods

[&nbsp;&nbsp;centerPlayButton](#//api/name/centerPlayButton) *property* 

[&ndash;&nbsp;setCustomControlForKey:imageOnNormal:imageOnFull:forState:](#//api/name/setCustomControlForKey:imageOnNormal:imageOnFull:forState:)  

### Other Methods

[&ndash;&nbsp;stateDidChangedToNew:lastState:store:](#//api/name/stateDidChangedToNew:lastState:store:)  

[&ndash;&nbsp;subscribedStoreSuccess:](#//api/name/subscribedStoreSuccess:)  

[&ndash;&nbsp;customPartControlForKey:withConfig:](#//api/name/customPartControlForKey:withConfig:)  

## Properties

<a name="//api/name/centerPlayButton" title="centerPlayButton"></a>
### centerPlayButton

UI

`@property (nonatomic, strong) UIButton *centerPlayButton`

#### Discussion
UI

#### Declared In
* `TTVPlayPart.h`

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

<a name="//api/name/setCustomControlForKey:imageOnNormal:imageOnFull:forState:" title="setCustomControlForKey:imageOnNormal:imageOnFull:forState:"></a>
### setCustomControlForKey:imageOnNormal:imageOnFull:forState:

设置自定义 UI, 时机：需要在注册到store之前进行设置

`- (void)setCustomControlForKey:(TTVPlayerPartControlKey)*key* imageOnNormal:(NSString *_Nullable)*imageOnNormal* imageOnFull:(NSString *_Nullable)*imageOnFull* forState:(TTVPlayPartControlState)*state*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;<a href="#//api/name/key">key</a> 绑定的view  

*imageOnNormal*  
&nbsp;&nbsp;&nbsp;在小屏展示的 image name  

*imageOnFull*  
&nbsp;&nbsp;&nbsp;在全屏展示的 image name  

*state*  
&nbsp;&nbsp;&nbsp;play control的状态  

#### Discussion
设置自定义 UI, 时机：需要在注册到store之前进行设置

#### Declared In
* `TTVPlayPart.h`

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

////////////////////////////////////////////  中间位置展示互斥关系 ////////////////////////////////////

`- (void)subscribedStoreSuccess:(TTVReduxStore *)*store*`

#### Discussion
////////////////////////////////////////////  中间位置展示互斥关系 ////////////////////////////////////

#### Declared In
* `TTVPlayPart.m`

