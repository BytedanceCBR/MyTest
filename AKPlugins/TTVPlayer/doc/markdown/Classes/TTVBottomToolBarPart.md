# TTVBottomToolBarPart Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVPlayerContext.html">TTVPlayerContext</a><br />  
<a href="../Protocols/TTVPlayerPartProtocol.html">TTVPlayerPartProtocol</a><br />  
<a href="../Protocols/TTVReduxStateObserver.html">TTVReduxStateObserver</a>  
&nbsp;&nbsp;**Declared in** TTVBottomToolBarPart.h<br />  
TTVBottomToolBarPart.m  

## Tasks

### 

[&ndash;&nbsp;customPartControlForKey:withConfig:](#//api/name/customPartControlForKey:withConfig:)  

[&ndash;&nbsp;stateDidChangedToNew:lastState:store:](#//api/name/stateDidChangedToNew:lastState:store:)  

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

