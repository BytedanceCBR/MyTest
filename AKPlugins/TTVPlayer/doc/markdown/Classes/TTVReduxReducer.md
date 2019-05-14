# TTVReduxReducer Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVReduxReducerProtocol.html">TTVReduxReducerProtocol</a>  
&nbsp;&nbsp;**Declared in** TTVReduxReducer.h<br />  
TTVReduxReducer.m  

## Overview

实现一个根的reducer, 外界想使用来初始化 store，可以继承此类进行调用, 也可以直接使用这个类

## Tasks

### 

[&ndash;&nbsp;setSubReducer:forKey:](#//api/name/setSubReducer:forKey:)  

[&ndash;&nbsp;subReducerForKey:](#//api/name/subReducerForKey:)  

[&ndash;&nbsp;dispatchAllSubreducerWithAction:state:finishBlock:](#//api/name/dispatchAllSubreducerWithAction:state:finishBlock:)  

[&ndash;&nbsp;executeWithAction:state:](#//api/name/executeWithAction:state:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/dispatchAllSubreducerWithAction:state:finishBlock:" title="dispatchAllSubreducerWithAction:state:finishBlock:"></a>
### dispatchAllSubreducerWithAction:state:finishBlock:

根 reducer 用来分发调用子 reducer 的 executeWithAction 方法

`- (void)dispatchAllSubreducerWithAction:(id&lt;TTVReduxActionProtocol&gt;)*action* state:(NSObject&lt;TTVReduxStateProtocol&gt; *)*state* finishBlock:(void ( ^ ) ( NSObject&lt;TTVReduxStateProtocol&gt; *))*finishBlock*`

#### Parameters

*action*  
&nbsp;&nbsp;&nbsp;action  

*state*  
&nbsp;&nbsp;&nbsp;store的根 state  

*finishBlock*  
&nbsp;&nbsp;&nbsp;分发完一个完成调用回调  

#### Discussion
根 reducer 用来分发调用子 reducer 的 executeWithAction 方法

#### Declared In
* `TTVReduxReducer.h`

<a name="//api/name/executeWithAction:state:" title="executeWithAction:state:"></a>
### executeWithAction:state:

reducer 计算方法，处理一个 action 和当前 store 的 state，返回一个新的 state

`- (NSObject&lt;TTVReduxStateProtocol&gt; *)executeWithAction:(id&lt;TTVReduxActionProtocol&gt;)*action* state:(NSObject&lt;TTVReduxStateProtocol&gt; *)*state*`

#### Parameters

*action*  
&nbsp;&nbsp;&nbsp;触发事件  

*state*  
&nbsp;&nbsp;&nbsp;store 当前的旧的根状态  

#### Return Value
新根的状态

#### Discussion
reducer 计算方法，处理一个 action 和当前 store 的 state，返回一个新的 state

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/setSubReducer:forKey:" title="setSubReducer:forKey:"></a>
### setSubReducer:forKey:

添加 subReducer

`- (void)setSubReducer:(NSObject&lt;TTVReduxReducerProtocol&gt; *)*subReducer* forKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*subReducer*  
&nbsp;&nbsp;&nbsp;子 reducer  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 subReducer

#### Declared In
* `TTVReduxReducer.h`

<a name="//api/name/subReducerForKey:" title="subReducerForKey:"></a>
### subReducerForKey:

获取子 reducer，self 为 root reducer

`- (NSObject&lt;TTVReduxReducerProtocol&gt; *)subReducerForKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 reducer，self 为 root reducer

#### Declared In
* `TTVReduxReducer.h`

