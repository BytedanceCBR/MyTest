# TTVPlayerEnvironmentContext Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Declared in** TTVPlayerEnvironmentContext.h<br />  
TTVPlayerEnvironmentContext.m  

## Overview

这个类存放当前播放器的一些环境变量，播放器销毁后，这个变量跟着一起销毁，播放器更新后，此数据跟着更新，比如 host等
此类Pod 外可以读取，Pod 内可以修改？？？TODO

## Tasks

### 

[+&nbsp;reset](#//api/name/reset)  

<a title="Class Methods" name="class_methods"></a>
## Class Methods

<a name="//api/name/reset" title="reset"></a>
### reset

重新设置到初始值，由于播放器切换或者重新设置，退出播放等

`+ (void)reset`

#### Discussion
重新设置到初始值，由于播放器切换或者重新设置，退出播放等

#### Declared In
* `TTVPlayerEnvironmentContext.h`

