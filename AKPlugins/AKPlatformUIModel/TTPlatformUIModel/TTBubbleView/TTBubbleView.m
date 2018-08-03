//
//  TTFeedUserRefreshGuideTopView.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/31.
//
//

#import "TTBubbleView.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import <TTDialogDirector/TTDialogDirector.h>

@interface TTBubbleView ()

@property(nonatomic, assign, readwrite)BOOL isShowing;
@property(nonatomic, assign, readwrite)BOOL isAnimating;

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, assign) CGPoint anchorPoint; 
@property (nonatomic, assign) TTBubbleViewArrowDirection arrowDirection;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat containerHeight;
@property (nonatomic, assign) CGFloat paddingH;
@property (nonatomic, assign) CGFloat screenMargin;
@property (nonatomic, assign, readwrite) NSInteger type;

@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedImageView *tipImageView;
@property (nonatomic, strong) SSThemedLabel *tipTextLabel;
@property (nonatomic, strong) SSThemedView *splitLine;
@property (nonatomic, strong) SSThemedView *line;
@property (nonatomic, strong) SSThemedView *dot;
@property (nonatomic, strong) SSThemedView *upArrowView;
@property (nonatomic, strong) SSThemedView *downArrowView;

@property (nonatomic, copy) NSArray<UIColor *> *containerColors;
@property (nonatomic, copy) NSArray<UIColor *> *textColors;

@property (nonatomic, copy)void(^tapHandle)(void);//点文字区域
@property (nonatomic, copy)void(^closeHandle)(void);//点关闭按钮

@end

@implementation TTBubbleView

- (id)initWithAnchorPoint:(CGPoint)anchorPoint imageName:(NSString *)imageName tipText:(NSString *)text attributedText:(NSAttributedString *)attributedText arrowDirection:(TTBubbleViewArrowDirection)arrowDirection lineHeight:(CGFloat)lineHeight viewType:(NSInteger)viewType
{
    return [self initWithAnchorPoint:anchorPoint imageName:imageName tipText:text attributedText:attributedText arrowDirection:arrowDirection lineHeight:lineHeight viewType:viewType screenMargin:4.0];
}

- (id)initWithAnchorPoint:(CGPoint)anchorPoint imageName:(NSString *)imageName tipText:(NSString *)text attributedText:(NSAttributedString *)attributedText arrowDirection:(TTBubbleViewArrowDirection)arrowDirection lineHeight:(CGFloat)lineHeight viewType:(NSInteger)viewType screenMargin:(CGFloat)screenMargin
{
    if(self = [super initWithFrame:CGRectZero]){
        self.anchorPoint = anchorPoint;
        self.imageName = imageName;
        self.text = text;
        self.attributedText = attributedText;
        self.arrowDirection = arrowDirection;
        self.lineHeight = lineHeight;
        self.type = viewType;
        self.screenMargin = screenMargin;
        [self commonInit];
    }
    return self;
}

- (id)initWithAnchorPoint:(CGPoint)anchorPoint imageName:(NSString *)imageName tipText:(NSString *)text attributedText:(NSAttributedString *)attributedText arrowDirection:(TTBubbleViewArrowDirection)arrowDirection lineHeight:(CGFloat)lineHeight viewType:(NSInteger)viewType screenMargin:(CGFloat)screenMargin backgroundColors:(NSArray<UIColor *>*)backgroundColors textColors:(NSArray<UIColor *>*)textColors; {
    if(self = [super initWithFrame:CGRectZero]){
        self.anchorPoint = anchorPoint;
        self.imageName = imageName;
        self.text = text;
        self.attributedText = attributedText;
        self.arrowDirection = arrowDirection;
        self.lineHeight = lineHeight;
        self.type = viewType;
        self.screenMargin = screenMargin;
        self.containerColors = backgroundColors;
        self.textColors = textColors;
        [self commonInit];
    }
    return self;
}

- (id)initWithAnchorPoint:(CGPoint)anchorPoint tipText:(NSString *)text arrowDirection:(TTBubbleViewArrowDirection)arrowDirection fontSize:(CGFloat)fontSize containerViewHeight:(CGFloat)containerHeight paddingH:(CGFloat)paddingH {
    if(self = [super initWithFrame:CGRectZero]){
        self.anchorPoint = anchorPoint;
        self.text = text;
        self.arrowDirection = arrowDirection;
        self.fontSize = fontSize;
        self.containerHeight = containerHeight;
        self.paddingH = paddingH;
        self.screenMargin = 4;
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    [self buildViews];
    self.userInteractionEnabled = NO;
}

- (void)buildViews{
    CGFloat screenMargin = 4.0;
    if (self.screenMargin > 0) {
        screenMargin = self.screenMargin;
    }
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat maxContainerWidth = screenWidth - screenMargin * 2;
    if (self.imageName) {
        [self buildContainerViewWithImage:maxContainerWidth];
    }
    else{
        [self buildContainerViewWithoutImage:maxContainerWidth];
    }
    [self addSubview:self.containerView];
    
    if(self.arrowDirection == TTBubbleViewArrowUp){
        [self buildViewForArrowUp];
    }
    else{
        [self buildViewForArrowDown];
    }
    CGFloat anchorPointX = self.anchorPoint.x;
    if (self.left < screenMargin || self.right > screenWidth - screenMargin) {//left,right限制在屏幕15pi内
        CGFloat offset = 0;
        if (anchorPointX < screenWidth - anchorPointX) {//在左半屏幕时
            offset = screenMargin - self.left;
        }
        else{//在右半屏幕
            offset = screenWidth - screenMargin - self.right;
        }
        self.centerX += offset;
        self.upArrowView.centerX -= offset;
        self.downArrowView.centerX -= offset;
        self.line.centerX -= offset;
        self.dot.centerX -= offset;
    }
}

- (void)changeAnchorPoint:(CGPoint)anchorPoint {
    if (self.isShowing) {
        
        self.centerX += anchorPoint.x - self.anchorPoint.x;
        self.bottom  += anchorPoint.y - self.anchorPoint.y;
        
        self.anchorPoint = anchorPoint;
    }
}

#pragma mark - 创建各个子view
- (SSThemedView *)containerView{
    if(!_containerView){
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        //_containerView.backgroundColorThemeKey = kColorBackground5;
        _containerView.backgroundColors = self.containerColors ?: @[@"000000", @"505050"];
        _containerView.layer.cornerRadius = [self containerViewCornerRadius];
    }
    return _containerView;
}

- (SSThemedImageView *)tipImageView{
    if(!_tipImageView){
        _tipImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _tipImageView.contentMode = UIViewContentModeScaleAspectFit;
        _tipImageView.backgroundColor = [UIColor clearColor];
    }
    return _tipImageView;
}

- (SSThemedLabel *)tipTextLabel {
    if (!_tipTextLabel) {
        _tipTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _tipTextLabel.numberOfLines = 1;
        //_tipTextLabel.textColorThemeKey = kColorText10;
        _tipTextLabel.textColors = self.textColors ?: @[@"ffffff", @"cacaca"];
        _tipTextLabel.font = [UIFont systemFontOfSize:[self textFontSize]];
        _tipTextLabel.backgroundColor = [UIColor clearColor];
        _tipTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _tipTextLabel;
}

- (SSThemedView *)splitLine{
    if(!_splitLine){
        _splitLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _splitLine.backgroundColorThemeKey = kColorLine9;
    }
    return _splitLine;
}

#pragma mark - 各种间距
- (CGFloat)leftPadding{
    if (self.paddingH > 0) {
        return self.paddingH;
    }
    return 10.f;
}

- (CGFloat)rightPadding{
    if (self.paddingH > 0) {
        return self.paddingH;
    }
    return 10.f;
}

- (CGFloat)imageWidth{
    return 31.f;
}

- (CGFloat)imageHeight{
    return 23.f;
}

- (CGFloat)imageAndTextMargin{
    return 2.f;
}

- (CGFloat)containerViewHeight{
    if (self.containerHeight > 0) {
        return self.containerHeight;
    }
    return 36.f;
}

- (CGFloat)textFontSize{
    if (self.fontSize > 0) {
        return self.fontSize;
    }
    return 14.f;
}

- (CGFloat)containerViewCornerRadius{
    return 4.f;
}

- (CGFloat)lineWidth{
    return 1.f;
}

- (CGFloat)dotSize{
    return 4.f;
}

- (CGFloat)arrowHeight {
    return 6.f;
}

- (CGFloat)arrowWidth {
    return 14.f;
}

#pragma mark - 实现动画效果
- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
                   tapHandle:(void(^)(void))tapHandle
{
    [self showTipWithAnimation:animation
                 automaticHide:automaticHide
       animationCompleteHandle:animationCompletionHandle
                autoHideHandle:nil tapHandle:tapHandle];
}

- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
              autoHideHandle:(void(^)(void))autoHideHandle
                   tapHandle:(void(^)(void))tapHandle
{
    [self showTipWithAnimation:animation
                 automaticHide:automaticHide
       animationCompleteHandle:animationCompletionHandle
                autoHideHandle:autoHideHandle
                     tapHandle:tapHandle
                   closeHandle:nil];
}

- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
              autoHideHandle:(void(^)(void))autoHideHandle
                   tapHandle:(void(^)(void))tapHandle
                 closeHandle:(void(^)(void))closeHandle
{
    [self showTipWithAnimation:animation
                 automaticHide:automaticHide
              autoHideInterval:5
       animationCompleteHandle:animationCompletionHandle
                autoHideHandle:autoHideHandle
                     tapHandle:tapHandle
                   closeHandle:closeHandle
                  shouldShowMe:nil];
}

- (void)showOnView:(UIView *)superview
     withAnimation:(BOOL)animation
     automaticHide:(BOOL)automaticHide
  autoHideInterval:(NSTimeInterval)autoHideInterval
animationCompleteHandle:(void(^)(void))animationCompletionHandle
    autoHideHandle:(void(^)(void))autoHideHandle
         tapHandle:(void(^)(void))tapHandle
       closeHandle:(void(^)(void))closeHandle {
    if (_isAnimating || _isShowing) {
        return;
    }
    [superview addSubview:self];
    self.isShowing = YES;
    self.tapHandle = tapHandle;
    self.closeHandle = closeHandle;
    
    if (animation) {
        self.isAnimating = YES;
        
        NSTimeInterval delay = 0;
        if (self.lineHeight > 0) {
            delay = 0.2;
            [UIView animateWithDuration:delay delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.dot.transform = CGAffineTransformIdentity;
                if(self.arrowDirection == TTBubbleViewArrowUp){
                    self.dot.top = 0;
                }else{
                    self.dot.top = self.height - [self dotSize];
                }
                self.line.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
        
        [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(1.13, 1.13);
            self.containerView.alpha = 0.96;
            self.upArrowView.transform = CGAffineTransformMakeScale(1.13, 1.13);
            self.upArrowView.alpha = 0.96;
            self.downArrowView.transform = CGAffineTransformMakeScale(1.13, 1.13);
            self.downArrowView.alpha = 0.96;
        } completion:nil];
        
        [UIView animateWithDuration:0.2 delay:0.2+delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            self.upArrowView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            self.downArrowView.transform = CGAffineTransformMakeScale(0.95, 0.95);
        } completion:nil];
        
        [UIView animateWithDuration:0.1 delay:0.4 + delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(1.01, 1.01);
            self.upArrowView.transform = CGAffineTransformMakeScale(1.01, 1.01);
            self.downArrowView.transform = CGAffineTransformMakeScale(1.01, 1.01);
        } completion:nil];
        
        [UIView animateWithDuration:0.1 delay:0.5 + delay options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
            self.upArrowView.transform = CGAffineTransformIdentity;
            self.downArrowView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            self.userInteractionEnabled = YES;
            if (animationCompletionHandle) {
                animationCompletionHandle();
            }
        }];
        
    }else {
        self.isAnimating = NO;
        self.userInteractionEnabled = YES;
        self.dot.transform = CGAffineTransformIdentity;
        if(self.arrowDirection == TTBubbleViewArrowUp){
            self.dot.top = 0;
        }else{
            self.dot.top = self.height - [self dotSize];
        }
        self.line.transform = CGAffineTransformIdentity;
        self.containerView.alpha = 0.96;
        self.containerView.transform = CGAffineTransformIdentity;
        self.upArrowView.alpha = 0.96;
        self.upArrowView.transform = CGAffineTransformIdentity;
        self.downArrowView.alpha = 0.96;
        self.downArrowView.transform = CGAffineTransformIdentity;
    }
    
    if (automaticHide) {
        typeof(self) __weak weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(autoHideInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf hideTipWithAnimation:animation forceHide:NO completionHandle:autoHideHandle];
        });
    }
}

- (void)showTipWithAnimation:(BOOL)animation
               automaticHide:(BOOL)automaticHide
            autoHideInterval:(NSTimeInterval)autoHideInterval
     animationCompleteHandle:(void(^)(void))animationCompletionHandle
              autoHideHandle:(void(^)(void))autoHideHandle
                   tapHandle:(void(^)(void))tapHandle
                 closeHandle:(void(^)(void))closeHandle
                shouldShowMe:(TTDoAskForShowDialogBlock _Nullable)shouldShowMeHandler
{
    if (_isAnimating || _isShowing) {
        return;
    }
    WeakSelf;
    [TTDialogDirector enqueueShowDialog:self withPriority:TTDialogPriorityTip shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
        if (shouldShowMeHandler) {
            return shouldShowMeHandler(keepAlive);
        } else {
            return YES;
        }
    } showMe:^(id  _Nonnull dialogInst) {
        StrongSelf;
        self.isShowing = YES;
        self.tapHandle = tapHandle;
        self.closeHandle = closeHandle;
        
        if (animation) {
            self.isAnimating = YES;
            
            NSTimeInterval delay = 0;
            if (self.lineHeight > 0) {
                delay = 0.2;
                [UIView animateWithDuration:delay delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.dot.transform = CGAffineTransformIdentity;
                    if(self.arrowDirection == TTBubbleViewArrowUp){
                        self.dot.top = 0;
                    }else{
                        self.dot.top = self.height - [self dotSize];
                    }
                    self.line.transform = CGAffineTransformIdentity;
                } completion:nil];
            }
            
            [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(1.13, 1.13);
                self.containerView.alpha = 0.96;
                self.upArrowView.transform = CGAffineTransformMakeScale(1.13, 1.13);
                self.upArrowView.alpha = 0.96;
                self.downArrowView.transform = CGAffineTransformMakeScale(1.13, 1.13);
                self.downArrowView.alpha = 0.96;
            } completion:nil];
            
            [UIView animateWithDuration:0.2 delay:0.2+delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(0.95, 0.95);
                self.upArrowView.transform = CGAffineTransformMakeScale(0.95, 0.95);
                self.downArrowView.transform = CGAffineTransformMakeScale(0.95, 0.95);
            } completion:nil];
            
            [UIView animateWithDuration:0.1 delay:0.4 + delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.containerView.transform = CGAffineTransformMakeScale(1.01, 1.01);
                self.upArrowView.transform = CGAffineTransformMakeScale(1.01, 1.01);
                self.downArrowView.transform = CGAffineTransformMakeScale(1.01, 1.01);
            } completion:nil];
            
            [UIView animateWithDuration:0.1 delay:0.5 + delay options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.containerView.transform = CGAffineTransformIdentity;
                self.upArrowView.transform = CGAffineTransformIdentity;
                self.downArrowView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.isAnimating = NO;
                self.userInteractionEnabled = YES;
                if (animationCompletionHandle) {
                    animationCompletionHandle();
                }
            }];
            
        }else {
            self.isAnimating = NO;
            self.userInteractionEnabled = YES;
            self.dot.transform = CGAffineTransformIdentity;
            if(self.arrowDirection == TTBubbleViewArrowUp){
                self.dot.top = 0;
            }else{
                self.dot.top = self.height - [self dotSize];
            }
            self.line.transform = CGAffineTransformIdentity;
            self.containerView.alpha = 0.96;
            self.containerView.transform = CGAffineTransformIdentity;
            self.upArrowView.alpha = 0.96;
            self.upArrowView.transform = CGAffineTransformIdentity;
            self.downArrowView.alpha = 0.96;
            self.downArrowView.transform = CGAffineTransformIdentity;
        }
        
        if (automaticHide) {
            typeof(self) __weak weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(autoHideInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideTipWithAnimation:animation forceHide:NO completionHandle:autoHideHandle];
            });
        }
    } hideForcedlyMe:^(id  _Nonnull dialogInst) {
        StrongSelf;
        [self hideTipWithAnimation:NO forceHide:YES completionHandle:nil];
    }];
}

- (void)hideTipWithAnimation:(BOOL)animation forceHide:(BOOL)forceHide{
    [self hideTipWithAnimation:animation forceHide:forceHide completionHandle:nil];
}

- (void)hideTipWithAnimation:(BOOL)animation forceHide:(BOOL)forceHide completionHandle:(void(^)(void))completionHandle{
    if (!_isShowing) {
        return;
    }
    [TTDialogDirector dequeueDialog:self];
    if (_isAnimating && forceHide == NO) {
        return;
    }else if (_isAnimating && forceHide == YES){
        self.isShowing = NO;
        [self.containerView removeFromSuperview];
        [self.line removeFromSuperview];
        [self.dot removeFromSuperview];
        [self.upArrowView removeFromSuperview];
        [self.downArrowView removeFromSuperview];
        
        self.tipTextLabel = nil;
        self.tipImageView = nil;
        self.containerView = nil;
        self.splitLine = nil;
        self.line = nil;
        self.dot = nil;
        self.upArrowView = nil;
        self.downArrowView = nil;
        
        [self buildViews];
        [self removeFromSuperview];
        
        if(completionHandle){
            completionHandle();
        }
        self.userInteractionEnabled = NO;
        return;
    }
    
    self.isShowing = NO;
    
    if (animation) {
        self.isAnimating = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.containerView.alpha = 0;
            self.line.alpha = 0;
            self.dot.alpha = 0;
            self.upArrowView.alpha = 0;
            self.downArrowView.alpha = 0;
        } completion:^(BOOL finished) {
            [self initAnimateState];
            self.isAnimating = NO;
            [self removeFromSuperview];
            if(completionHandle){
                completionHandle();
            }
        }];
    }else {
        [self initAnimateState];
        self.isAnimating = NO;
        [self removeFromSuperview];
        if(completionHandle){
            completionHandle();
        }
    }
    self.userInteractionEnabled = NO;
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint point = [tapGestureRecognizer locationInView:self];
    
    CGRect tapRect = CGRectMake(self.tipTextLabel.right, 0, self.containerView.width - self.tipTextLabel.right, self.containerView.height);
    if(!CGRectContainsPoint(tapRect, point)){
        if (_isShowing && _tapHandle) {
            _tapHandle();
        }
        return;
    } else {
        if (_isShowing && _closeHandle) {
            _closeHandle();
        }
        return;
    }
}

#pragma mark - 尝试用手动布局
- (void)buildViewForArrowUp{
    self.width = self.containerView.width;
    self.centerX = self.anchorPoint.x;
    self.containerView.left = 0;
    if (self.lineHeight <= 0) {
        self.height = [self arrowHeight] + self.containerView.height;
        self.containerView.bottom = self.height;
        
        self.upArrowView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [self arrowWidth], [self arrowHeight])];
        //self.upArrowView.backgroundColorThemeKey = kColorBackground5;
        self.upArrowView.backgroundColors = _containerView.backgroundColors;
        self.upArrowView.layer.anchorPoint = CGPointMake(0.5, ([self arrowHeight] + self.containerView.height/2)/[self arrowHeight]);
        UIBezierPath * arrowPath = [UIBezierPath bezierPath];
        [arrowPath moveToPoint:CGPointMake(0, self.upArrowView.height)];
        [arrowPath addLineToPoint:CGPointMake(self.upArrowView.width/2, 0)];
        [arrowPath addLineToPoint:CGPointMake(self.upArrowView.width, self.upArrowView.height)];
        [arrowPath addLineToPoint:CGPointMake(0, self.upArrowView.height)];
        [arrowPath closePath];
        CAShapeLayer * arrowShapeLayer = [[CAShapeLayer alloc] init];
        arrowShapeLayer.path = arrowPath.CGPath;
        self.upArrowView.layer.mask = arrowShapeLayer;
        [self addSubview:self.upArrowView];
        self.upArrowView.bottom = self.containerView.top;
        self.upArrowView.centerX = self.containerView.centerX;
    }else {
        self.height = [self dotSize] + self.lineHeight + self.containerView.height;
        self.containerView.bottom = self.height;
        
        self.line = [[SSThemedView alloc] initWithFrame:CGRectZero];
        self.line.backgroundColors = self.containerColors;
        self.line.backgroundColorThemeKey = kColorBackground5;
        [self addSubview:self.line];
        self.line.width = [self lineWidth];
        self.line.height = self.lineHeight + [self dotSize];
        self.line.layer.anchorPoint  = CGPointMake(0.5, 0);
        self.line.bottom = self.containerView.top;
        self.line.centerX = self.containerView.centerX;
        
        self.dot = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [self dotSize], [self dotSize])];
        self.dot.backgroundColorThemeKey = kColorBackground5;
        self.dot.backgroundColors = self.containerColors;
        self.dot.layer.cornerRadius = [self dotSize] / 2.f;
        [self addSubview:self.dot];
        self.dot.width = [self dotSize];
        self.dot.height = [self dotSize];
        self.dot.top = 0;
        self.dot.centerX = self.line.centerX;
    }
    self.top = self.anchorPoint.y;
    [self initAnimateState];
}

- (void)buildViewForArrowDown{
    self.width = self.containerView.width;
    self.centerX = self.anchorPoint.x;
    self.containerView.top = 0;
    self.containerView.left = 0;
    if (self.lineHeight <= 0) {
        self.height = [self arrowHeight] + self.containerView.height;
        
        self.downArrowView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [self arrowWidth], [self arrowHeight])];
        //self.downArrowView.backgroundColorThemeKey = kColorBackground5;
        self.downArrowView.backgroundColors = self.containerView.backgroundColors;
        self.downArrowView.layer.anchorPoint = CGPointMake(0.5, -self.containerView.height/2/[self arrowHeight]);
        UIBezierPath * arrowPath = [UIBezierPath bezierPath];
        [arrowPath moveToPoint:CGPointMake(0, 0)];
        [arrowPath addLineToPoint:CGPointMake(self.downArrowView.width, 0)];
        [arrowPath addLineToPoint:CGPointMake(self.downArrowView.width/2, self.downArrowView.height)];
        [arrowPath closePath];
        CAShapeLayer * arrowShapeLayer = [[CAShapeLayer alloc] init];
        arrowShapeLayer.path = arrowPath.CGPath;
        self.downArrowView.layer.mask = arrowShapeLayer;
        [self addSubview:self.downArrowView];
        self.downArrowView.top = self.containerView.bottom;
        self.downArrowView.centerX = self.containerView.centerX;
    }else {
        self.height = [self dotSize] + self.lineHeight + self.containerView.height;
        
        self.line = [[SSThemedView alloc] initWithFrame:CGRectZero];
        self.line.backgroundColorThemeKey = kColorBackground5;
        [self addSubview:self.line];
        self.line.width = [self lineWidth];
        self.line.height = self.lineHeight + [self dotSize];
        self.line.layer.anchorPoint = CGPointMake(0.5, 1);
        self.line.top = self.containerView.bottom;
        self.line.centerX = self.containerView.centerX;
        
        self.dot = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [self dotSize], [self dotSize])];
        self.dot.backgroundColorThemeKey = kColorBackground5;
        self.dot.layer.cornerRadius = [self dotSize] / 2.f;
        [self addSubview:self.dot];
        self.dot.width = [self dotSize];
        self.dot.height = [self dotSize];
        self.dot.top = self.height - [self dotSize];
        self.dot.centerX = self.line.centerX;
    }
    self.bottom = self.anchorPoint.y;
    [self initAnimateState];
}

- (void)initAnimateState{
    self.containerView.transform = CGAffineTransformMakeScale(0, 0);
    self.containerView.alpha = 0;
    
    if(self.arrowDirection == TTBubbleViewArrowUp){
        self.dot.top = - [self dotSize];
    }
    else{
        self.dot.top = self.height;
    }
    
    self.dot.transform = CGAffineTransformMakeScale(0, 0);
    self.line.transform = CGAffineTransformMakeScale(1, 0);
    
    self.line.alpha = 1;
    self.dot.alpha = 1;
    
    self.upArrowView.transform = CGAffineTransformMakeScale(0, 0);
    self.upArrowView.alpha = 0;
    self.downArrowView.transform = CGAffineTransformMakeScale(0, 0);
    self.downArrowView.alpha = 0;
}

- (void)buildContainerViewWithoutImage:(CGFloat)maxContainerWidth{
    CGFloat leftPadding = [self leftPadding];
    CGFloat rightPadding = [self rightPadding];

    self.tipTextLabel.attributedText = self.attributedText ?: [[NSAttributedString alloc] initWithString:self.text];
    [self.tipTextLabel sizeToFit];
    CGFloat labelWidth = self.tipTextLabel.width;

    CGFloat containerViewWidth = leftPadding + labelWidth + rightPadding;
    if (containerViewWidth > maxContainerWidth) {
        labelWidth = maxContainerWidth - leftPadding - rightPadding;
        self.tipTextLabel.width = floorf(labelWidth);
        containerViewWidth = maxContainerWidth;
    }
    CGFloat containerViewHeight = [self containerViewHeight];

    self.containerView.size = CGSizeMake(containerViewWidth, containerViewHeight);

    [self.containerView addSubview:self.tipTextLabel];
    self.tipTextLabel.left = leftPadding;
    self.tipTextLabel.centerY = self.containerView.centerY;
}

- (void)buildContainerViewWithImage:(CGFloat)maxContainerWidth{
    CGFloat leftPadding = 15.f;

    self.tipTextLabel.attributedText = self.attributedText ?: [[NSAttributedString alloc] initWithString:self.text];
    [self.tipTextLabel sizeToFit];
    CGFloat labelWidth = self.tipTextLabel.width;
    
    CGFloat paddingForLineLeft = 10.f;
    
    CGFloat lineWidth = [TTDeviceHelper ssOnePixel];
    
    CGFloat paddingForLineRight = 10.f;
    
    CGFloat imageWidth = 12.f;
    CGFloat imageHeight = 12.f;
    
    CGFloat rightPadding = 15.f;
    CGFloat containerViewWidth = leftPadding + labelWidth + paddingForLineLeft + lineWidth + paddingForLineRight + imageWidth + rightPadding;
    if (containerViewWidth > maxContainerWidth) {
        labelWidth = maxContainerWidth - (leftPadding + paddingForLineLeft + lineWidth + paddingForLineRight + imageWidth + rightPadding);
        self.tipTextLabel.width = floorf(labelWidth);
        containerViewWidth = maxContainerWidth;
    }
    CGFloat containerViewHeight = [self containerViewHeight];
    
    self.containerView.size = CGSizeMake(containerViewWidth, containerViewHeight);
    
    [self.containerView addSubview:self.tipTextLabel];
    self.tipTextLabel.left = leftPadding;
    self.tipTextLabel.centerY = self.containerView.centerY;
    
    [self.containerView addSubview:self.splitLine];
    self.splitLine.width = lineWidth;
    self.splitLine.height = 7.f;
    self.splitLine.centerY = self.containerView.centerY;
    self.splitLine.left = self.tipTextLabel.right + paddingForLineLeft;
    
    [self.containerView addSubview:self.tipImageView];
    self.tipImageView.imageName = self.imageName;
    self.tipImageView.width = imageWidth;
    self.tipImageView.height = imageHeight;
    self.tipImageView.left = self.splitLine.right + paddingForLineRight;
    self.tipImageView.centerY = self.containerView.centerY;
}

@end
