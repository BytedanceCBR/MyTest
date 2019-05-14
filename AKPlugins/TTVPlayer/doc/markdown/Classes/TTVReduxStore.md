# TTVReduxStore Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVReduxStoreProtocol.html">TTVReduxStoreProtocol</a>  
&nbsp;&nbsp;**Declared in** TTVReduxStore.h<br />  
TTVReduxStore.m  

## Tasks

### 

[&ndash;&nbsp;initWithReducer:state:](#//api/name/initWithReducer:state:)  

[&nbsp;&nbsp;state](#//api/name/state) *property* 

[&nbsp;&nbsp;reducer](#//api/name/reducer) *property* 

[&ndash;&nbsp;subscribe:](#//api/name/subscribe:)  

[&ndash;&nbsp;unSubscribe:](#//api/name/unSubscribe:)  

[&ndash;&nbsp;dispatch:](#//api/name/dispatch:)  

[&ndash;&nbsp;setSubState:forKey:](#//api/name/setSubState:forKey:)  

[&ndash;&nbsp;subStateForKey:](#//api/name/subStateForKey:)  

[&ndash;&nbsp;setSubReducer:forKey:](#//api/name/setSubReducer:forKey:)  

[&ndash;&nbsp;subReducerForKey:](#//api/name/subReducerForKey:)  

## Properties

<a name="//api/name/reducer" title="reducer"></a>
### reducer

用来拿到当前的根 reducer, 通过根 reducer，可以传入 key，拿到 subReducer，进行状态判断

`@property (nonatomic, strong, readonly) NSObject&lt;TTVReduxReducerProtocol&gt; *reducer`

#### Return Value
拿到真正当前根 reducer 的一个 copy，只读不可修改

#### Discussion
用来拿到当前的根 reducer, 通过根 reducer，可以传入 key，拿到 subReducer，进行状态判断

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/state" title="state"></a>
### state

用来拿到当前的根 state, 通过根 state，可以传入 key，拿到 subState，进行状态判断

`@property (nonatomic, copy, readonly) NSObject&lt;TTVReduxStateProtocol&gt; *state`

#### Return Value
拿到真正当前根 state 的一个 copy，只读不可修改

#### Discussion
用来拿到当前的根 state, 通过根 state，可以传入 key，拿到 subState，进行状态判断

#### Declared In
* `TTVReduxStore.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/dispatch:" title="dispatch:"></a>
### dispatch:

action 分发功能；当有修改 <a href="#//api/name/state">state</a> 需求时，调用此方法，进行对 <a href="#//api/name/state">state</a> 的修改

`- (void)dispatch:(NSObject&lt;TTVReduxActionProtocol&gt; *)*action*`

#### Parameters

*action*  
&nbsp;&nbsp;&nbsp;引起数据变化的事件  

#### Discussion
action 分发功能；当有修改 <a href="#//api/name/state">state</a> 需求时，调用此方法，进行对 <a href="#//api/name/state">state</a> 的修改

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/initWithReducer:state:" title="initWithReducer:state:"></a>
### initWithReducer:state:

初始化方法，传入一个根 <a href="#//api/name/reducer">reducer</a> 和根的 <a href="#//api/name/state">state</a>

`- (instancetype)initWithReducer:(NSObject&lt;TTVReduxReducerProtocol&gt; *)*reducer* state:(NSObject&lt;TTVReduxStateProtocol&gt; *)*state*`

#### Parameters

*reducer*  
&nbsp;&nbsp;&nbsp;根 <a href="#//api/name/reducer">reducer</a>,里面有 多个 subReducer由 root 进行管理，可以改变 <a href="#//api/name/state">state</a>  

*state*  
&nbsp;&nbsp;&nbsp;根 state，存放数据，里面有 多个 subState 由 root 进行管理  

#### Return Value
store 节点，此节点存储数据<a href="#//api/name/state">state</a>

#### Discussion
初始化方法，传入一个根 <a href="#//api/name/reducer">reducer</a> 和根的 <a href="#//api/name/state">state</a>

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/setSubReducer:forKey:" title="setSubReducer:forKey:"></a>
### setSubReducer:forKey:

添加 subReducer

`- (void)setSubReducer:(NSObject&lt;TTVReduxReducerProtocol&gt; *)*subReducer* forKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*subReducer*  
&nbsp;&nbsp;&nbsp;子 <a href="#//api/name/reducer">reducer</a>  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 subReducer

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/setSubState:forKey:" title="setSubState:forKey:"></a>
### setSubState:forKey:

添加 sub<a href="#//api/name/state">state</a>

`- (void)setSubState:(NSObject&lt;TTVReduxStateProtocol&gt; *)*subState* forKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*subState*  
&nbsp;&nbsp;&nbsp;子 <a href="#//api/name/state">state</a>  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 sub<a href="#//api/name/state">state</a>

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/subReducerForKey:" title="subReducerForKey:"></a>
### subReducerForKey:

获取子 reducer，self 为 root <a href="#//api/name/reducer">reducer</a>

`- (NSObject&lt;TTVReduxReducerProtocol&gt; *)subReducerForKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 reducer，self 为 root <a href="#//api/name/reducer">reducer</a>

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/subStateForKey:" title="subStateForKey:"></a>
### subStateForKey:

获取子 state，self 为 root <a href="#//api/name/state">state</a>

`- (NSObject&lt;TTVReduxStateProtocol&gt; *)subStateForKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 state，self 为 root <a href="#//api/name/state">state</a>

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/subscribe:" title="subscribe:"></a>
### subscribe:

订阅 <a href="#//api/name/state">state</a> 的变化

`- (void)subscribe:(NSObject&lt;TTVReduxStateObserver&gt; *)*observer*`

#### Parameters

*observer*  
&nbsp;&nbsp;&nbsp;观察者，会收到- (void)newState:(NSObject<a href="../Protocols/TTVReduxStateProtocol.html">TTVReduxStateProtocol</a> *)<a href="#//api/name/state">state</a>;回调  

#### Discussion
订阅 <a href="#//api/name/state">state</a> 的变化

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/unSubscribe:" title="unSubscribe:"></a>
### unSubscribe:

移除订阅的变化

`- (void)unSubscribe:(NSObject&lt;TTVReduxStateObserver&gt; *)*observer*`

#### Parameters

*observer*  
&nbsp;&nbsp;&nbsp;observer 观察者，订阅后会收到- (void)newState:(NSObject<a href="../Protocols/TTVReduxStateProtocol.html">TTVReduxStateProtocol</a> *)<a href="#//api/name/state">state</a>;回调  

#### Discussion
移除订阅的变化

#### Declared In
* `TTVReduxStore.h`

