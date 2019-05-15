# TTVReduxStateProtocol Protocol Reference

&nbsp;&nbsp;**Conforms to** NSCopying<br />  
NSObject  
&nbsp;&nbsp;**Declared in** TTVReduxProtocol.h  

## Tasks

### 

[&ndash;&nbsp;setSubState:forKey:](#//api/name/setSubState:forKey:)  

[&ndash;&nbsp;subStateForKey:](#//api/name/subStateForKey:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/setSubState:forKey:" title="setSubState:forKey:"></a>
### setSubState:forKey:

添加 substate

`- (void)setSubState:(NSObject&lt;TTVReduxStateProtocol&gt; *)*subState* forKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*subState*  
&nbsp;&nbsp;&nbsp;子 state  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 substate

#### Declared In
* `TTVReduxProtocol.h`

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
* `TTVReduxProtocol.h`

