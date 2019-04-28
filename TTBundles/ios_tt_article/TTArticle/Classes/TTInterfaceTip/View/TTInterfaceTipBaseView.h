//
//  TTInterfaceTipBaseView.h
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import <SSThemed.h>
#import "TTInterfaceTipHeader.h"
#import "TTInterfaceTipManager.h"

#define kTTInterfaceTipViewSpringDuration 0.8f
#define kTTInterfaceTipViewSpringDampingRatio 0.6f
#define kTTInterfaceTipViewSpringVelocity 0.f

typedef NS_ENUM(NSInteger, TTInterfaceTipViewType){
    TTInterfaceTipViewTypeSheet = 0,
    TTInterfaceTipViewTypeAlert = 1,
    TTInterfaceTipViewTypeNone = 2,
};

@class TTInterfaceTipBaseModel;
@interface TTInterfaceTipBaseView : SSThemedView
//手势是否正在拖动
@property (nonatomic, assign)BOOL panGestureRun;
@property (nonatomic, strong, readonly)NSTimer *timer;
@property (nonatomic, strong, readonly)TTInterfaceTipBaseModel *model;
@property (nonatomic, weak, readonly)TTInterfaceTipManager *manager;

/**
 当一个tipView被展示前会调用这个方法

 @param model
 */
- (void)setupViewWithModel:(TTInterfaceTipBaseModel *)model;


/**
 
 通过show方法将tipView展示出来
 默认动画根据panGestureDirection决定是从下还是从上出现
 
 */
- (void)show;


/**
 4个方法指定一些UI，主要是在动画的时候以及最终展现用

 @return 宽高默认值是屏幕宽高
         间距默认值是0
 */
- (CGFloat)widthForView;
- (CGFloat)heightForView;
- (CGFloat)topPadding;
- (CGFloat)bottomPadding;


/**
 目前主要影响出现的动画

 @return 默认值是TTInterfaceTipViewTypeSheet
 */
- (TTInterfaceTipViewType)viewType;


/**
 当将要被展示的时候，将调用这个方法进行询问

 @param model 数据
 @return YES 则立刻展示出来
         NO 放弃展示
        默认是YES
 */
+ (BOOL)shouldDisplayWithModel:(TTInterfaceTipBaseModel *)model;


/**
 支持的手势拖动退出的方位，影响show的默认动画

 @return TTInterfaceTipsMoveDirectionUp or TTInterfaceTipsMoveDirectionDown
 */
- (TTInterfaceTipsMoveDirection)panGestureDirection;


/**
 是否需要一个黑色透明度为50%的背景蒙层

 @return 默认值是NO
 */
- (BOOL)needDimBackground;


/**
 是否需要阻断空白区域的事件点击

 @return 默认是NO，如果返回YES，则会回调blankGroundViewClickCallBack方法
 */
- (BOOL)needBlockTouchInBlankView;

/**
 是否需要手势拖动退出

 @return 默认值是YES
 */
- (BOOL)needPanGesture;


/**
 当通过手势被移除的时候，会调用这个方法
 默认不做任何操作
 */
- (void)removeFromSuperviewByGesture;

/**
 通过定时器移除的时候，会调用这个方法
  默认不做任何操作
 */
- (void)removeFromSuperViewByTimer;

/**
 当有一个优先级更强的弹窗出现的时候，会调用这个方法
 默认实现是移除自己
 */
- (void)hideByTipWithHigherPriority;

/**
 是否需要定时退出，定时器的时间从timerDuration方法获取

 @return 默认值是YES
 */
- (BOOL)needTimer;


/**
 重启定时器，定时器的时间会从restartTimerDuration获取
 */
- (void)restartTimer;


/**
 清理定时器，不会调用Action
 */
- (void)clearTimer;

/**
 定时器的时间

 @return 默认值是6
 */
- (CGFloat)timerDuration;


/**
 重启定时器的时间

 @return 默认值也是6
 */
- (CGFloat)restartTimerDuration;

/**
 当tab发生点击的时候会调用
 
 @param current 当前选中的tab
 @param last 上一个选中的tab
 @param isPostEntrance 是否是点击了UGC的发布入口，此时current和last都等于0
 */
- (void)selectedTabChangeWithCurrentIndex:(NSUInteger)current lastIndex:(NSUInteger)last isUGCPostEntrance:(BOOL)isPostEntrance;

/**
 当push出一个新页面的时候将被调用
 */
- (void)topVCChange;


/**
 进入后台的时候被调用
 */
- (void)enterBackground;

/**
 当needBlockTouchInBlankView返回YES时，点击空白区域则会回调该方法
 */
- (void)blankGroundViewClickCallBack;

/**
 退出，根据是否需要动画
 @param animate YES or NO
 */
- (void)dismissSelfWithAnimation:(NSNumber *)animate;
@end
