# TTVReduxStoreProtocol Protocol Reference

&nbsp;&nbsp;**Conforms to** NSObject  
&nbsp;&nbsp;**Declared in** TTVReduxProtocol.h  

## Tasks

### 

[&nbsp;&nbsp;state](#//api/name/state) *property* *required method*

[&nbsp;&nbsp;reducer](#//api/name/reducer) *property* *required method*

[&ndash;&nbsp;subscribe:](#//api/name/subscribe:)  *required method*

[&ndash;&nbsp;unSubscribe:](#//api/name/unSubscribe:)  *required method*

[&ndash;&nbsp;dispatch:](#//api/name/dispatch:)  *required method*

[&ndash;&nbsp;setSubReducer:forKey:](#//api/name/setSubReducer:forKey:)  

[&ndash;&nbsp;subReducerForKey:](#//api/name/subReducerForKey:)  

[&ndash;&nbsp;setSubState:forKey:](#//api/name/setSubState:forKey:)  

[&ndash;&nbsp;subStateForKey:](#//api/name/subStateForKey:)  

## Properties

<a name="//api/name/reducer" title="reducer"></a>
### reducer

用来拿到当前的根 reducer, 通过根 reducer，可以传入 key，拿到 subReducer，进行状态判断

`@property (nonatomic, strong, readonly) NSObject&lt;TTVReduxReducerProtocol&gt; *reducer`

#### Discussion
用来拿到当前的根 reducer, 通过根 reducer，可以传入 key，拿到 subReducer，进行状态判断

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/state" title="state"></a>
### state

用来拿到当前的根 state, 通过根 state，可以传入 key，拿到 subState，进行状态判断, 可不修改

`@property (nonatomic, copy, readonly) NSObject&lt;TTVReduxStateProtocol&gt; *state`

#### Discussion
用来拿到当前的根 state, 通过根 state，可以传入 key，拿到 subState，进行状态判断, 可不修改

#### Declared In
* `TTVReduxProtocol.h`

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
* `TTVReduxProtocol.h`

<a name="//api/name/setSubReducer:forKey:" title="setSubReducer:forKey:"></a>
### setSubReducer:forKey:

添加 subReducer

`- (void)setSubReducer:(NSObject&lt;TTVReduxReducerProtocol&gt; *)*subReducer* forKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*subReducer*  
&nbsp;&nbsp;&nbsp;子 <a href="#//api/name/reducer">reducer</a>  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 subReducer

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/setSubState:forKey:" title="setSubState:forKey:"></a>
### setSubState:forKey:

添加 sub<a href="#//api/name/state">state</a>

`- (void)setSubState:(NSObject&lt;TTVReduxStateProtocol&gt; *)*subState* forKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*subState*  
&nbsp;&nbsp;&nbsp;子 <a href="#//api/name/state">state</a>  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 sub<a href="#//api/name/state">state</a>

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/subReducerForKey:" title="subReducerForKey:"></a>
### subReducerForKey:

获取子 reducer，self 为 root <a href="#//api/name/reducer">reducer</a>

`- (NSObject&lt;TTVReduxReducerProtocol&gt; *)subReducerForKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 reducer，self 为 root <a href="#//api/name/reducer">reducer</a>

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/subStateForKey:" title="subStateForKey:"></a>
### subStateForKey:

获取子 state，self 为 root <a href="#//api/name/state">state</a>

`- (NSObject&lt;TTVReduxStateProtocol&gt; *)subStateForKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 state，self 为 root <a href="#//api/name/state">state</a>

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/subscribe:" title="subscribe:"></a>
### subscribe:

订阅 <a href="#//api/name/state">state</a> 的变化

`- (void)subscribe:(id)*observer*`

#### Parameters

*observer*  
&nbsp;&nbsp;&nbsp;观察者，会收到- (void)newState:(NSObject<a href="../Protocols/TTVReduxStateProtocol.html">TTVReduxStateProtocol</a> *)<a href="#//api/name/state">state</a>;回调  

#### Discussion
订阅 <a href="#//api/name/state">state</a> 的变化

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/unSubscribe:" title="unSubscribe:"></a>
### unSubscribe:

移除订阅的变化

`- (void)unSubscribe:(id)*observer*`

#### Parameters

*observer*  
&nbsp;&nbsp;&nbsp;observer 观察者，订阅后会收到- (void)newState:(NSObject<a href="../Protocols/TTVReduxStateProtocol.html">TTVReduxStateProtocol</a> *)<a href="#//api/name/state">state</a>;回调  

#### Discussion
移除订阅的变化

#### Declared In
* `TTVReduxProtocol.h`

