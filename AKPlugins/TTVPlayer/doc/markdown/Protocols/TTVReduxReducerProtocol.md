# TTVReduxReducerProtocol Protocol Reference

&nbsp;&nbsp;**Conforms to** NSObject  
&nbsp;&nbsp;**Declared in** TTVReduxProtocol.h  

## Tasks

### 

[&ndash;&nbsp;executeWithAction:state:](#//api/name/executeWithAction:state:)  *required method*

[&ndash;&nbsp;setSubReducer:forKey:](#//api/name/setSubReducer:forKey:)  

[&ndash;&nbsp;subReducerForKey:](#//api/name/subReducerForKey:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/executeWithAction:state:" title="executeWithAction:state:"></a>
### executeWithAction:state:

reducer 计算方法，处理一个 action 和当前 store 的 state，返回一个新的 state

`- (NSObject&lt;TTVReduxStateProtocol&gt; *)executeWithAction:(NSObject&lt;TTVReduxActionProtocol&gt; *)*action* state:(NSObject&lt;TTVReduxStateProtocol&gt; *)*state*`

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

`- (void)setSubReducer:(NSObject&lt;TTVReduxReducerProtocol&gt; *)*subReducer* forKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*subReducer*  
&nbsp;&nbsp;&nbsp;子 reducer  

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
添加 subReducer

#### Declared In
* `TTVReduxProtocol.h`

<a name="//api/name/subReducerForKey:" title="subReducerForKey:"></a>
### subReducerForKey:

获取子 reducer，self 为 root reducer

`- (NSObject&lt;TTVReduxReducerProtocol&gt; *)subReducerForKey:(NSObject&lt;NSCopying&gt; *)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;key  

#### Discussion
获取子 reducer，self 为 root reducer

#### Declared In
* `TTVReduxProtocol.h`

