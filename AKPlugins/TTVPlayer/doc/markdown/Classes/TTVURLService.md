# TTVURLService Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Declared in** TTVURLService.h<br />  
TTVURLService.m  

## Tasks

### 

[+&nbsp;signFromVideoID:ts:](#//api/name/signFromVideoID:ts:)  

<a title="Class Methods" name="class_methods"></a>
## Class Methods

<a name="//api/name/signFromVideoID:ts:" title="signFromVideoID:ts:"></a>
### signFromVideoID:ts:

sign⽣生成规则可以分为4个步骤:
1.把其它所有参数按key升序排序。
2.把key和它对应的value拼接成⼀一个字符串。按步骤1中顺序,把所有键值对字符串拼接成⼀一个字符串。
3.把分配给的secretkey拼接在第2步骤得到的字符串后⾯面。
4.计算第3步骤字符串的md5值,使⽤用md5值的16进制字符串作为sign的值。

`+ (NSString *)signFromVideoID:(NSString *)*videoID* ts:(long long)*ts*`

#### Discussion
sign⽣生成规则可以分为4个步骤:
1.把其它所有参数按key升序排序。
2.把key和它对应的value拼接成⼀一个字符串。按步骤1中顺序,把所有键值对字符串拼接成⼀一个字符串。
3.把分配给的secretkey拼接在第2步骤得到的字符串后⾯面。
4.计算第3步骤字符串的md5值,使⽤用md5值的16进制字符串作为sign的值。

#### Declared In
* `TTVURLService.m`

