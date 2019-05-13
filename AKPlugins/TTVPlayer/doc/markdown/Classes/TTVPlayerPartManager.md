# TTVPlayerPartManager Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVPlayerContext.html">TTVPlayerContext</a><br />  
<a href="../Protocols/TTVReduxStateObserver.html">TTVReduxStateObserver</a>  
&nbsp;&nbsp;**Declared in** TTVPlayerPartManager.h<br />  
TTVPlayerPartManager.m  

## Overview

管理 part：解析配置文件、添加和移除 part、part 中所有 view 的add、layout
可以根据配置文件动态添加 part

## Tasks

### Other Methods

[&ndash;&nbsp;addAllPartsWithConfigData:](#//api/name/addAllPartsWithConfigData:)  

[&ndash;&nbsp;addPart:](#//api/name/addPart:)  

[&ndash;&nbsp;removePart:](#//api/name/removePart:)  

[&ndash;&nbsp;removePartForKey:](#//api/name/removePartForKey:)  

[&ndash;&nbsp;removeAllParts](#//api/name/removeAllParts)  

[&ndash;&nbsp;partForKey:](#//api/name/partForKey:)  

[&ndash;&nbsp;allParts](#//api/name/allParts)  

[&ndash;&nbsp;viewDidLoad:](#//api/name/viewDidLoad:)  

[&ndash;&nbsp;viewDidLayoutSubviews:](#//api/name/viewDidLayoutSubviews:)  

### Other Methods

[&ndash;&nbsp;stateDidChangedToNew:lastState:store:](#//api/name/stateDidChangedToNew:lastState:store:)  

[&ndash;&nbsp;subscribedStoreSuccess:](#//api/name/subscribedStoreSuccess:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/addAllPartsWithConfigData:" title="addAllPartsWithConfigData:"></a>
### addAllPartsWithConfigData:

根据配置文件，对所有parts以及 parts 上的所有 control 进行添加和配置

`- (void)addAllPartsWithConfigData:(NSDictionary *)*configDic*`

#### Parameters

*configDic*  
&nbsp;&nbsp;&nbsp;配置数据  

#### Discussion
根据配置文件，对所有parts以及 parts 上的所有 control 进行添加和配置

#### Declared In
* `TTVPlayerPartManager.h`

<a name="//api/name/addPart:" title="addPart:"></a>
### addPart:

根据配置文件，添加 part和 part 里面相关的 control
跟已有 key 相同会覆盖当前的 key 绑定的 part
TODO: 如果已经从 default 获取了，再后续动态加入，会对布局有影响

`- (void)addPart:(NSObject&lt;TTVPlayerContext,TTVPlayerPartProtocol,TTVReduxStateObserver&gt; *)*part*`

#### Parameters

*part*  
&nbsp;&nbsp;&nbsp;self  

#### Discussion
根据配置文件，添加 part和 part 里面相关的 control
跟已有 key 相同会覆盖当前的 key 绑定的 part
TODO: 如果已经从 default 获取了，再后续动态加入，会对布局有影响

#### Declared In
* `TTVPlayerPartManager.h`

<a name="//api/name/allParts" title="allParts"></a>
### allParts

获取所有的player 上已经添加的所有parts

`- (NSArray&lt;NSObject&lt;TTVPlayerContext,TTVPlayerPartProtocol,TTVReduxStateObserver&gt; *&gt; *)allParts`

#### Return Value
parts array

#### Discussion
获取所有的player 上已经添加的所有parts

#### Declared In
* `TTVPlayerPartManager.h`

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
* `TTVPlayerPartManager.h`

<a name="//api/name/removeAllParts" title="removeAllParts"></a>
### removeAllParts

移除全部的part，将所有可移除的 part 相关的功能+UI 都整体移除掉

`- (void)removeAllParts`

#### Discussion
移除全部的part，将所有可移除的 part 相关的功能+UI 都整体移除掉

#### Declared In
* `TTVPlayerPartManager.h`

<a name="//api/name/removePart:" title="removePart:"></a>
### removePart:

移除 part，会移除整体 part 对应 UI 组件以及全部功能

`- (void)removePart:(NSObject&lt;TTVPlayerContext,TTVPlayerPartProtocol,TTVReduxStateObserver&gt; *)*part*`

#### Parameters

*part*  
&nbsp;&nbsp;&nbsp;part  

#### Discussion
移除 part，会移除整体 part 对应 UI 组件以及全部功能

#### Declared In
* `TTVPlayerPartManager.h`

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
* `TTVPlayerPartManager.h`

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

<a name="//api/name/viewDidLayoutSubviews:" title="viewDidLayoutSubviews:"></a>
### viewDidLayoutSubviews:

需要在此方法layout view

`- (void)viewDidLayoutSubviews:(TTVPlayer *)*playerVC*`

#### Parameters

*playerVC*  
&nbsp;&nbsp;&nbsp;playerVC 可以获取所有的 view，以及 part  

#### Discussion
需要在此方法layout view

#### Declared In
* `TTVPlayerContext.h`

<a name="//api/name/viewDidLoad:" title="viewDidLoad:"></a>
### viewDidLoad:

需要在此方法添加 view

`- (void)viewDidLoad:(TTVPlayer *)*playerVC*`

#### Parameters

*playerVC*  
&nbsp;&nbsp;&nbsp;playerVC 可以获取所有的 view，以及 part  

#### Discussion
需要在此方法添加 view

#### Declared In
* `TTVPlayerContext.h`

