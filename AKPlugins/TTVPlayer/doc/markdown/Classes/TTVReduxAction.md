# TTVReduxAction Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Conforms to** TTVReduxActionProtocol  
&nbsp;&nbsp;**Declared in** TTVReduxAction.h<br />  
TTVReduxAction.m  

## Tasks

### 

[&ndash;&nbsp;initWithTarget:selector:params:actionType:](#//api/name/initWithTarget:selector:params:actionType:)  

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/initWithTarget:selector:params:actionType:" title="initWithTarget:selector:params:actionType:"></a>
### initWithTarget:selector:params:actionType:

可执行 action 的初始化方法

`- (instancetype)initWithTarget:(id)*target* selector:(SEL)*selector* params:(NSArray *)*params* actionType:(NSString *)*type*`

#### Parameters

*target*  
&nbsp;&nbsp;&nbsp;实际执行的对象  

*selector*  
&nbsp;&nbsp;&nbsp;<a href="#//api/name/target">target</a> 的方法  

*params*  
&nbsp;&nbsp;&nbsp;<a href="#//api/name/selector">selector</a> 的参数  

*type*  
&nbsp;&nbsp;&nbsp;action 的类型，由于额外信息不常用，经常是 nil，所以不在此处加入  

#### Return Value
self

#### Discussion
可执行 action 的初始化方法

#### Declared In
* `TTVReduxAction.h`

