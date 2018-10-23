//
//  TTBubbleView.h
//  Article
//
//  Created by 邱鑫玥 on 16/8/31.
//
//

#import <UIKit/UIKit.h>
#import <TTDialogDirector/TTDialogDirectorDefine.h>

typedef NS_ENUM(NSUInteger,TTBubbleViewArrowDirection){
    TTBubbleViewArrowUp = 0,
    TTBubbleViewArrowDown,
};

@interface TTBubbleView : UIView

@property(nonatomic, assign) BOOL willShow;//因为这个bubble会延时展示，所以标记下状态
@property(nonatomic, assign, readonly)BOOL isShowing;
@property(nonatomic, assign, readonly)BOOL isAnimating;
@property(nonatomic, assign, readonly)NSInteger type;
/**
 *  初始化方法
 *
 *  @param anchorPoint               锚点，箭头指向的点
 *  @param imageName                 传nil，就无icon
 *  @param tipText                   提示文案，和attributedText选择一种即可
 *  @param attributedText            提示富文本文案
 *  @param arrowDirection            指向：上、下
 *  @param lineHeight                值<=0 表示用箭头，值>0 表示用线，且值为线高
 *  @param viewType                  tip类型
 */
- (id)initWithAnchorPoint:(CGPoint)anchorPoint imageName:(NSString *)imageName tipText:(NSString *)text attributedText:(NSAttributedString *)attributedText arrowDirection:(TTBubbleViewArrowDirection)arrowDirection lineHeight:(CGFloat)lineHeight viewType:(NSInteger)viewType;

- (id)initWithAnchorPoint:(CGPoint)anchorPoint imageName:(NSString *)imageName tipText:(NSString *)text attributedText:(NSAttributedString *)attributedText arrowDirection:(TTBubbleViewArrowDirection)arrowDirection lineHeight:(CGFloat)lineHeight viewType:(NSInteger)viewType screenMargin:(CGFloat)screenMargin;

- (id)initWithAnchorPoint:(CGPoint)anchorPoint tipText:(NSString *)text arrowDirection:(TTBubbleViewArrowDirection)arrowDirection fontSize:(CGFloat)fontSize containerViewHeight:(CGFloat)containerViewHeight paddingH:(CGFloat)paddingH;

- (id)initWithAnchorPoint:(CGPoint)anchorPoint imageName:(NSString *)imageName tipText:(NSString *)text attributedText:(NSAttributedString *)attributedText arrowDirection:(TTBubbleViewArrowDirection)arrowDirection lineHeight:(CGFloat)lineHeight viewType:(NSInteger)viewType screenMargin:(CGFloat)screenMargin backgroundColors:(NSArray<UIColor *>*)backgroundColors textColors:(NSArray<UIColor *>*)textColors;


/**
 *  展示tip（NOTE：如果tip正在动画过程中，调用此方法无效）
 *
 *  @param animation                 是否需要动画
 *  @param automaticHide             是否自动隐藏（NOTE:如果YES，5s后自动调用hideTipWithAnimation隐藏tip）
 *  @param animationCompletionHandle 如果animation为YES，动画完成后会调用此block
 *  @param tapHandle                 用户点击后会调用此block
 */
- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
                   tapHandle:(void(^)(void))tapHandle;

/**
 *  展示tip（NOTE：如果tip正在动画过程中，调用此方法无效）
 *
 *  @param animation                 是否需要动画
 *  @param automaticHide             是否自动隐藏（NOTE:如果YES，5s后自动调用hideTipWithAnimation隐藏tip）
 *  @param animationCompletionHandle 如果animation为YES，动画完成后会调用此block
 *  @param autoHideHandle            自动隐藏后会调用此block
 *  @param tapHandle                 用户点击后会调用此block
 *  @param shouldShowMe 显示弹窗回调前判断是否满足显示条件；若满足条件则显示
 */
- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
              autoHideHandle:(void(^)(void))autoHideHandle
                   tapHandle:(void(^)(void))tapHandle;


- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
              autoHideHandle:(void(^)(void))autoHideHandle
                   tapHandle:(void(^)(void))tapHandle
                 closeHandle:(void(^)(void))closeHandle;

- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
            autoHideInterval:(NSTimeInterval)autoHideInterval
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
              autoHideHandle:(void(^)(void))autoHideHandle
                   tapHandle:(void(^)(void))tapHandle
                 closeHandle:(void(^)(void))closeHandle
                shouldShowMe:(TTDoAskForShowDialogBlock _Nullable)shouldShowMeHandler;

/**
 将tips展示在特定view上
 */
- (void)showOnView:(UIView *)superview
     withAnimation:(BOOL)animation
     automaticHide:(BOOL)automaticHide
  autoHideInterval:(NSTimeInterval)autoHideInterval
animationCompleteHandle:(void(^)(void))animationCompletionHandle
    autoHideHandle:(void(^)(void))autoHideHandle
         tapHandle:(void(^)(void))tapHandle
       closeHandle:(void(^)(void))closeHandle;

//动态改动显示的tips位置
- (void)changeAnchorPoint:(CGPoint)anchorPoint;

/**
 *  隐藏tip（NOTE：假如forceHide是YES，即使tip正在动画过程中也强制隐藏，并且隐藏过程没有动画；如果是NO，在tip动画过程中时候，调用此方法无效）
 *
 *  @param animation 是否需要动画
 *  @param forceHide 是否强制隐藏tip
 */
- (void)hideTipWithAnimation:(BOOL)animation forceHide:(BOOL)forceHide;

/**
 *  隐藏tip（NOTE：假如forceHide是YES，即使tip正在动画过程中也强制隐藏，并且隐藏过程没有动画；如果是NO，在tip动画过程中时候，调用此方法无效）
 *
 *  @param animation 是否需要动画
 *  @param forceHide 是否强制隐藏tip
 *  @param completionHandle 隐藏完成后会调用此block
 */
- (void)hideTipWithAnimation:(BOOL)animation forceHide:(BOOL)forceHide completionHandle:(void(^)(void))completionHandle;

@end
