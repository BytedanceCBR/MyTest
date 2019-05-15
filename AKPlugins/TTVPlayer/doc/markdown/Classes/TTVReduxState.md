# TTVReduxState Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** NSCopying<br />  
<a href="../Protocols/TTVReduxStateProtocol.html">TTVReduxStateProtocol</a>  
&nbsp;&nbsp;**Declared in** TTVReduxState.h<br />  
TTVReduxState.m  

## Overview

实现一个根的state, 外界想使用 来初始化 store，可以继承此类进行调用, 也可以直接使用这个类

## Tasks

### 

[&ndash;&nbsp;setSubState:forKey:](#//api/name/setSubState:forKey:)  

[&ndash;&nbsp;subStateForKey:](#//api/name/subStateForKey:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/setSubState:forKey:" title="setSubState:forKey:"></a>
### setSubState:forKey:

添加 substate

`- (void)setSubState:(NSObject&lt;TTVReduxStateProtocol&gt; *)*subState* forKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*subState*  
&nbsp;&nbsp;&nbsp;子 state  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 substate

#### Declared In
* `TTVReduxState.h`

<a name="//api/name/subStateForKey:" title="subStateForKey:"></a>
### subStateForKey:

获取子 state，self 为 root state

`- (NSObject&lt;TTVReduxStateProtocol&gt; *)subStateForKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 state，self 为 root state

#### Declared In
* `TTVReduxState.h`

