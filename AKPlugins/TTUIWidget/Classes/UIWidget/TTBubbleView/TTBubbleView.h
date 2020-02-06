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


/**
 动画样式
 */
typedef NS_ENUM(NSUInteger, TTBubbleViewAnimStyle) {
    TTBubbleViewAnimStyleDefault = 0,              // 默认动画样式
    TTBubbleViewAnimStyleWithBgImage,              // Bubble有背景图时的动画样式
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
 相比前者，可以设置整个tip、箭头的背景图片而不再用纯色背景填充
 建议背景图片支持stretch

 @param anchorPoint                  锚点，箭头指向的点
 @param imageName                    传nil，就无icon，比如添加一个关闭按钮
 @param text                         提示文案，和attributedText二选一即可
 @param attributedText               提示富文本文案，和tipText二选一即可
 @param arrowDirection               指向：上、下
 @param lineHeight                   值<=0 表示用箭头，值>0 表示用线，且值为线高
 @param fontSize                     字体大小，默认14
 @param textColors                   字体颜色，默认[@"ffffff", @"cacaca"]
 @param viewType                     tip类型，可通过type属性来访问
 @param screenMargin                 当tip过长显示不下时，和屏幕之间的最小距离，默认4像素
 @param bgImage                      tip背景图，传nil则使用纯色填充
 @param arrowImage                   箭头背景图，传nil则使用纯色填充
 @param containerViewHeight          tip高度，默认36像素
 @param imageViewHeightOffset        背景imageView高度偏移量，imageView填充图片时可能会留有空白，此时会和箭头分开，因此需要此偏移量来变更imageView的高度保证和箭头交接上。
 @param paddingH                     文案和tip边界的留白，默认10像素
 */
- (id)initWithAnchorPoint:(CGPoint)anchorPoint
                imageName:(NSString *)imageName
                  tipText:(NSString *)text
           attributedText:(NSAttributedString *)attributedText
           arrowDirection:(TTBubbleViewArrowDirection)arrowDirection
               lineHeight:(CGFloat)lineHeight
                 fontSize:(CGFloat)fontSize
               textColors:(NSArray<UIColor *>*)textColors
                 viewType:(NSInteger)viewType
             screenMargin:(CGFloat)screenMargin
                  bgImage:(UIImage *)bgImage
               arrowImage:(UIImage *)arrowImage
      containerViewHeight:(CGFloat)containerViewHeight
    imageViewHeightOffset:(CGFloat)imageViewHeightOffset
                 paddingH:(CGFloat)paddingH;

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

- (void)showTipWithAnimation:(BOOL)animation
                   animStyle:(TTBubbleViewAnimStyle)animStyle
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
