# TTVReduxMainStore Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Declared in** TTVReduxMainStore.h<br />  
TTVReduxMainStore.m  

## Overview

单例类，相当于根 store ，可以拿到所有的 store，默认有一个 default store，其他的都是创建而来

## Tasks

### 

[&nbsp;&nbsp;defaultStore](#//api/name/defaultStore) *property* 

[&ndash;&nbsp;storeForKey:](#//api/name/storeForKey:)  

[&ndash;&nbsp;setStore:forKey:](#//api/name/setStore:forKey:)  

[&ndash;&nbsp;removeStoreForKey:](#//api/name/removeStoreForKey:)  

## Properties

<a name="//api/name/defaultStore" title="defaultStore"></a>
### defaultStore

其他没有明确归属创建的节点，可以默认到这里

`@property (nonatomic, strong, readonly) id&lt;TTVReduxStoreProtocol&gt; defaultStore`

#### Return Value
self

#### Discussion
其他没有明确归属创建的节点，可以默认到这里

#### Declared In
* `TTVReduxMainStore.h`

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/removeStoreForKey:" title="removeStoreForKey:"></a>
### removeStoreForKey:

从 mainstore 移除

`- (void)removeStoreForKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;对应的 key  

#### Discussion
从 mainstore 移除

#### Declared In
* `TTVReduxMainStore.h`

<a name="//api/name/setStore:forKey:" title="setStore:forKey:"></a>
### setStore:forKey:

设置节点到 mainStore

`- (void)setStore:(id&lt;TTVReduxStoreProtocol&gt;)*store* forKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*store*  
&nbsp;&nbsp;&nbsp;子 store  

*key*  
&nbsp;&nbsp;&nbsp;对应的 key  

#### Discussion
设置节点到 mainStore

#### Declared In
* `TTVReduxMainStore.h`

<a name="//api/name/storeForKey:" title="storeForKey:"></a>
### storeForKey:

获取某个节点

`- (id&lt;TTVReduxStoreProtocol&gt;)storeForKey:(id&lt;NSCopying&gt;)*key*`

#### Parameters

*key*  
&nbsp;&nbsp;&nbsp;节点对应的 key  

#### Return Value
对应节点

#### Discussion
获取某个节点

#### Declared In
* `TTVReduxMainStore.h`

