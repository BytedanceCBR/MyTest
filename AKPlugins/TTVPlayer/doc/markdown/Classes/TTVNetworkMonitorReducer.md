# TTVNetworkMonitorReducer Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** <a href="../Protocols/TTVReduxReducerProtocol.html">TTVReduxReducerProtocol</a>  
&nbsp;&nbsp;**Declared in** TTVNetworkMonitorReducer.h<br />  
TTVNetworkMonitorReducer.m  

## Tasks

### 

[&ndash;&nbsp;executeWithAction:state:](#//api/name/executeWithAction:state:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/executeWithAction:state:" title="executeWithAction:state:"></a>
### executeWithAction:state:

reducer 计算方法，处理一个 action 和当前 store 的 state，返回一个新的 state

`- (TTVPlayerState *)executeWithAction:(TTVReduxAction *)*action* state:(TTVPlayerState *)*state*`

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

