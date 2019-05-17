# TTVReduxStateObserver Protocol Reference

&nbsp;&nbsp;**Conforms to** NSObject  
&nbsp;&nbsp;**Declared in** TTVReduxStore.h  

## Tasks

### 

[&ndash;&nbsp;stateDidChangedToNew:lastState:store:](#//api/name/stateDidChangedToNew:lastState:store:)  *required method*

[&ndash;&nbsp;subscribedStoreSuccess:](#//api/name/subscribedStoreSuccess:)  

[&ndash;&nbsp;unsubcribedStoreSuccess:](#//api/name/unsubcribedStoreSuccess:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/stateDidChangedToNew:lastState:store:" title="stateDidChangedToNew:lastState:store:"></a>
### stateDidChangedToNew:lastState:store:

状态已经发生改变

`- (void)stateDidChangedToNew:(NSObject&lt;TTVReduxStateProtocol&gt; *)*newState* lastState:(NSObject&lt;TTVReduxStateProtocol&gt; *)*lastState* store:(NSObject&lt;TTVReduxStoreProtocol&gt; *)*store*`

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

`- (void)subscribedStoreSuccess:(id&lt;TTVReduxStoreProtocol&gt;)*store*`

#### Parameters

*store*  
&nbsp;&nbsp;&nbsp;订阅的 store  

#### Discussion
成功订阅通知

#### Declared In
* `TTVReduxStore.h`

<a name="//api/name/unsubcribedStoreSuccess:" title="unsubcribedStoreSuccess:"></a>
### unsubcribedStoreSuccess:

成功接触订阅通知

`- (void)unsubcribedStoreSuccess:(id&lt;TTVReduxStoreProtocol&gt;)*store*`

#### Parameters

*store*  
&nbsp;&nbsp;&nbsp;订阅的 store  

#### Discussion
成功接触订阅通知

#### Declared In
* `TTVReduxStore.h`

