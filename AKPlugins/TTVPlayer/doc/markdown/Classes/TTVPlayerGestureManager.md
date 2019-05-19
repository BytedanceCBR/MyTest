# TTVPlayerGestureManager Class Reference

&nbsp;&nbsp;**Inherits from** NSObject  
&nbsp;&nbsp;**Declared in** TTVPlayerGestureManager.h<br />  
TTVPlayerGestureManager.m  

## Tasks

### 

[&nbsp;&nbsp;pan](#//api/name/pan) *property* 

## Properties

<a name="//api/name/pan" title="pan"></a>
### pan

panning 手势, 最后可识别为 dragging 或者是 swipping
手势对外的 对外回调, 外界拿到方向，位移，状态，左右，来进行判断

`@property (nonatomic, copy) void ( ^ ) ( UIPanGestureRecognizer *gestureRecogizer , UIView *viewAddedPanGesture , TTVPlayerPanGestureDirection direction , BOOL isSwiped ) pan`

#### Discussion
panning 手势, 最后可识别为 dragging 或者是 swipping
手势对外的 对外回调, 外界拿到方向，位移，状态，左右，来进行判断

#### Declared In
* `TTVPlayerGestureManager.h`

