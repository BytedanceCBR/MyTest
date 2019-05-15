# TTVIndicatorView Class Reference

&nbsp;&nbsp;**Inherits from** UIView  
&nbsp;&nbsp;**Declared in** TTVIndicatorView.h<br />  
TTVIndicatorView.m  

## Tasks

### 

[+&nbsp;showIndicatorAudoHideWithText:image:](#//api/name/showIndicatorAudoHideWithText:image:)  

[+&nbsp;showIndicatorAddedToView:text:image:](#//api/name/showIndicatorAddedToView:text:image:)  

[+&nbsp;hideForView:animated:](#//api/name/hideForView:animated:)  

[+&nbsp;indicatorForView:](#//api/name/indicatorForView:)  

[&nbsp;&nbsp;hideCompletionBlock](#//api/name/hideCompletionBlock) *property* 

[&nbsp;&nbsp;stayDuration](#//api/name/stayDuration) *property* 

## Properties

<a name="//api/name/hideCompletionBlock" title="hideCompletionBlock"></a>
### hideCompletionBlock

隐藏提示框，可以传入此回调，因为多数弹框只是提示出来，不需要回调处理，所以把他从方法参数中移除，作为成员变量。

`@property (nonatomic, copy) void ( ^ ) ( void ) hideCompletionBlock`

#### Discussion
隐藏提示框，可以传入此回调，因为多数弹框只是提示出来，不需要回调处理，所以把他从方法参数中移除，作为成员变量。

#### Declared In
* `TTVIndicatorView.h`

<a name="//api/name/stayDuration" title="stayDuration"></a>
### stayDuration

设置提示框展示的时间，单位：秒 s, 一般不会设置这个变量，所以也放下来了。

`@property (nonatomic, assign) NSTimeInterval stayDuration`

#### Discussion
设置提示框展示的时间，单位：秒 s, 一般不会设置这个变量，所以也放下来了。

#### Declared In
* `TTVIndicatorView.h`

<a title="Class Methods" name="class_methods"></a>
## Class Methods

<a name="//api/name/hideForView:animated:" title="hideForView:animated:"></a>
### hideForView:animated:

基础方法，隐藏弹框, 立即消失

`+ (void)hideForView:(UIView *_Nonnull)*view* animated:(BOOL)*animated*`

#### Parameters

*view*  
&nbsp;&nbsp;&nbsp;添加到的 view 上，整体居中布局  

*animated*  
&nbsp;&nbsp;&nbsp;是否有动画，当页面切换 dealloc 时，不应该再做动画，应该整体消失  

#### Discussion
基础方法，隐藏弹框, 立即消失

#### Declared In
* `TTVIndicatorView.h`

<a name="//api/name/indicatorForView:" title="indicatorForView:"></a>
### indicatorForView:

拿到view 上的 indicator

`+ (TTVIndicatorView *_Nullable)indicatorForView:(UIView *_Nonnull)*view*`

#### Parameters

*view*  
&nbsp;&nbsp;&nbsp;添加到的 view 上，整体居中布局  

#### Return Value
添加到 view 上的 indicator

#### Discussion
拿到view 上的 indicator

#### Declared In
* `TTVIndicatorView.h`

<a name="//api/name/showIndicatorAddedToView:text:image:" title="showIndicatorAddedToView:text:image:"></a>
### showIndicatorAddedToView:text:image:

基础方法，不能自动消失，需要调用 hide 进行消失操作

`+ (instancetype)showIndicatorAddedToView:(UIView *_Nonnull)*view* text:(NSString *_Nonnull)*text* image:(UIImage *_Nullable)*image*`

#### Parameters

*view*  
&nbsp;&nbsp;&nbsp;添加到的 view 上，整体居中布局  

*text*  
&nbsp;&nbsp;&nbsp;文字  

*image*  
&nbsp;&nbsp;&nbsp;图片在文字的上面，分两行布局  

#### Discussion
基础方法，不能自动消失，需要调用 hide 进行消失操作

#### Declared In
* `TTVIndicatorView.h`

<a name="//api/name/showIndicatorAudoHideWithText:image:" title="showIndicatorAudoHideWithText:image:"></a>
### showIndicatorAudoHideWithText:image:

对外方法，由基础方法完成功能
显示默认3s消失的弹框
展示在 keywindow 上, 整体居中布局

`+ (instancetype)showIndicatorAudoHideWithText:(NSString *_Nonnull)*text* image:(UIImage *_Nullable)*image*`

#### Parameters

*text*  
&nbsp;&nbsp;&nbsp;文字  

*image*  
&nbsp;&nbsp;&nbsp;图片，图片在文字的上面，分两行布局  

#### Discussion
对外方法，由基础方法完成功能
显示默认3s消失的弹框
展示在 keywindow 上, 整体居中布局

#### Declared In
* `TTVIndicatorView.h`

