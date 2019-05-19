# TTVPlayerPartProtocol Protocol Reference

&nbsp;&nbsp;**Conforms to** NSObject  
&nbsp;&nbsp;**Declared in** TTVPlayerPartProtocol.h  

## Overview

所有的 part，需要遵循 part 协议来完成功能 ？？？？？

## Tasks

### 

[&ndash;&nbsp;customPartControlForKey:withConfig:](#//api/name/customPartControlForKey:withConfig:)  *required method*

<a title="Instance Methods" name="instance_methods"></a>
## Instance Methods

<a name="//api/name/customPartControlForKey:withConfig:" title="customPartControlForKey:withConfig:"></a>
### customPartControlForKey:withConfig:

通过配置文件来，自定义 part 的 UI；每个 part 都有不一样的 dict 规则

`- (void)customPartControlForKey:(TTVPlayerPartControlKey)*key* withConfig:(NSDictionary *)*dict*`

#### Parameters

*dict*  
&nbsp;&nbsp;&nbsp;custom 的协议  

#### Discussion
通过配置文件来，自定义 part 的 UI；每个 part 都有不一样的 dict 规则

#### Declared In
* `TTVPlayerPartProtocol.h`

