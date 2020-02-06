//
//  TTFMAudioDialogView.m
//  News
//
//  Created by Jesse He on 2018/5/25.
//

#import "TTDialogViewBase.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"

#define kTTconfirmButtonHeight  44
#define screenWidth [TTUIResponderHelper screenSize].width
#define screenHeight [TTUIResponderHelper screenSize].height

#define kTTDialogViewBaseAlphaAnimationDuration 0.1f
#define kTTDialogViewBaseScaleAnimationDuration 0.45f

@interface TTDialogViewBase ()

@property (nonatomic, assign) NSInteger dialogHeight;
@property (nonatomic, assign) NSInteger dialogWidth;
@property (nonatomic, copy) NSString *confirmTitle;

@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedButton *closeButton; // 关闭按钮
@property (nonatomic, strong) SSThemedButton *confirmButton; // 购买按钮
@property (nonatomic, strong) UIView *contentView; //记录外部传进来的内容视图
///签到成功回调
@property (nonatomic, copy) TTDialogViewBaseConfirmHandler confirmHandler;
///失败回调
@property (nonatomic, copy) TTDialogViewBaseCancelHandler cancelHandler;
///失败回调
@property (nonatomic, copy) TTDialogViewBaseCancelHandlerWithExitArea cancelHandlerWithExitArea;

//当前视图正在显示
@property(nonatomic, assign) BOOL isShowing;

/**
 选择某个 action 的回调
 */
@property (nonatomic, copy) TTDialogViewBaseActionHandler actionHandler;

/**
 action 的名字数组
 */
@property (nonatomic, copy) NSArray<NSString *> *actions;

/**
 action 对应的具体数据，例如 action 按钮的文字、样式、响应跳转的地址
 */
@property (nonatomic, copy) NSDictionary<NSString *,NSDictionary *> *actionsDetail;

@end

@implementation TTDialogViewBase

const NSInteger kTTDialogContentOffsetY = 28;

+ (NSBundle *)resourceBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle bundleForClass:self.class].resourcePath stringByAppendingPathComponent:@"TTDialogViewResource.bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

- (instancetype)initDialogViewWithTitle:(NSString *)title
                         confirmHandler:(TTDialogViewBaseConfirmHandler)confirmHandler
                          cancelHandler:(TTDialogViewBaseCancelHandler)cancelHandler
{
    if (self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)]) {
        _confirmTitle = [title copy];
        _confirmHandler = [confirmHandler copy];
        _cancelHandler = [cancelHandler copy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initDialogViewWithTitle:(NSString *)title
                         confirmHandler:(TTDialogViewBaseConfirmHandler)confirmHandler
                          cancelHandlerWithExitArea:(TTDialogViewBaseCancelHandlerWithExitArea)cancelHandlerWithExitArea
{
    if (self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)]) {
        _confirmTitle = [title copy];
        _confirmHandler = [confirmHandler copy];
        _cancelHandlerWithExitArea = [cancelHandlerWithExitArea copy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initDialogViewWithActions:(NSArray<NSString *> *)actions
                            actionsDetail:(NSDictionary<NSString *,NSDictionary *> *)actionsDetail
                            actionHandler:(TTDialogViewBaseActionHandler)actionHandler
                            cancelHandler:(TTDialogViewBaseCancelHandler)cancelHandler
{
    self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    if (self) {
        _actions = [actions copy];
        _actionsDetail = [actionsDetail copy];
        _actionHandler = [actionHandler copy];
        _cancelHandler = [cancelHandler copy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (instancetype)initDialogViewWithActions:(NSArray<NSString *> *)actions
                            actionsDetail:(NSDictionary<NSString *, NSDictionary *> *)actionsDetail
                            actionHandler:(TTDialogViewBaseActionHandler)actionHandler
                cancelHandlerWithExitArea:(TTDialogViewBaseCancelHandlerWithExitArea)cancelHandlerWithExitArea
{
    self = [super initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    if (self) {
        _actions = [actions copy];
        _actionsDetail = [actionsDetail copy];
        _actionHandler = [actionHandler copy];
        _cancelHandlerWithExitArea = [cancelHandlerWithExitArea copy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)addDialogContentView:(UIView *)view
{
    self.contentView = view;
    _dialogWidth = self.contentView.frame.size.width;
    _dialogHeight = kTTDialogContentOffsetY + self.contentView.frame.size.height + kTTconfirmButtonHeight;
    [self.containerView addSubview:self.contentView];
    self.contentView.top = kTTDialogContentOffsetY;
    [self setUpView];
}

- (void)addDialogContentView:(UIView *)view atTop:(BOOL)top
{
    if (!top) {
        [self addDialogContentView:view];
    } else {
        self.contentView = view;
        _dialogWidth = self.contentView.frame.size.width;
        _dialogHeight = self.contentView.frame.size.height + kTTconfirmButtonHeight;
        [self.containerView addSubview:self.contentView];
        self.contentView.top = 0;
        [self setUpView];
        UIImage *closeIcon = [UIImage themedImageNamed:@"token_dialog_close_white" inBundle:TTDialogViewBase.resourceBundle];
        [self.closeButton setImage:closeIcon forState:UIControlStateNormal];
    }
}

- (void)orientationChange:(NSNotification *)notification
{
    if (self.isShowing) {
        [self hide];
    }
}

- (void)setUpView
{
    // 添加关闭手势
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction:)]];
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];
    // 关闭
    [self.containerView addSubview:self.closeButton];
    if (self.confirmTitle) {
        // confirmTitle 有值，说明是只有一个按钮（无 actions）样式，故只需要添加确认按钮
        [self.containerView addSubview:self.confirmButton];
    } else {
        // 多个按钮的样式
        // 单个 action 按钮的宽度
        CGFloat actionButtonWidth = _containerView.width / self.actions.count;
        __weak __typeof(self) weakSelf = self;
        [self.actions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            SSThemedButton *actionButton = [strongSelf buildActionButtonWithActionDetial:strongSelf.actionsDetail[obj] index:idx actionButtonWidth:actionButtonWidth];
            [strongSelf.containerView addSubview:actionButton];
        }];
    }
}

- (SSThemedButton *)buildActionButtonWithActionDetial:(NSDictionary *)actionDetail index:(NSInteger)index actionButtonWidth:(CGFloat)actionButtonWidth {
    SSThemedButton *actionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    actionButton.frame = CGRectMake(actionButtonWidth * index, _containerView.height - kTTconfirmButtonHeight, actionButtonWidth, kTTconfirmButtonHeight);
    NSNumber *style = (NSNumber *)actionDetail[@"style"];
    BOOL isDefaultMode = (style && [style isKindOfClass:[NSNumber class]]) ? (style.integerValue == 0) : YES;
    actionButton.backgroundColorThemeKey = isDefaultMode ? kColorBackground4 : kColorBackground7;
    actionButton.titleColorThemeKey = isDefaultMode ? kColorText1 : kColorText12;
    if (isDefaultMode) {
        // 默认模式需要在按钮上添加一条线 否则按钮会和背景成为一体
        SSThemedView *lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, actionButtonWidth, 1.f / [UIScreen mainScreen].scale)];
        lineView.backgroundColorThemeKey = kColorLine7;
        [actionButton addSubview:lineView];
    }
    actionButton.clipsToBounds = YES;
    [actionButton setTitle:actionDetail[@"text"] forState:UIControlStateNormal];
    actionButton.titleLabel.font = [UIFont systemFontOfSize:16];
    actionButton.tag = index;
    [actionButton addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [actionButton addTarget:self action:@selector(preventHightEffect:) forControlEvents:UIControlEventAllTouchEvents];
    return actionButton;
}

-(SSThemedView *)containerView
{
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, _dialogWidth, _dialogHeight)];
        _containerView.center = self.center;
        _containerView.layer.cornerRadius = 6.0;
        _containerView.clipsToBounds = YES;
        _containerView.backgroundColorThemeKey = kColorBackground4;
    }
    return _containerView;
}

- (SSThemedButton *)closeButton {
    if (!_closeButton) {
        UIImage *closeIcon = [UIImage imageNamed:@"token_dialog_close" inBundle:TTDialogViewBase.resourceBundle compatibleWithTraitCollection:nil];
        _closeButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(_containerView.width - closeIcon.size.width - 8, 8, closeIcon.size.width, closeIcon.size.height)];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -8, -8, 0);
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:closeIcon forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (SSThemedButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(0, _containerView.height - kTTconfirmButtonHeight, _containerView.width, kTTconfirmButtonHeight);
        _confirmButton.backgroundColorThemeKey = kColorBackground7;
        _confirmButton.clipsToBounds = YES;
        _confirmButton.titleColorThemeKey = kColorText12;
        _confirmButton.highlightedTitleColors = @[[[UIColor colorWithHexString:@"FFFFFF"] colorWithAlphaComponent:0.5],
                                                  [[UIColor colorWithHexString:@"CACACA"] colorWithAlphaComponent:0.5]];
        _confirmButton.highlightedBackgroundColors = @[[UIColor colorWithHexString:@"DE4F4F"],
                                                       [[UIColor colorWithHexString:@"935656"] colorWithAlphaComponent:0.5]];
        [_confirmButton setTitle:_confirmTitle forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton addTarget:self action:@selector(preventHightEffect:) forControlEvents:UIControlEventAllTouchEvents];
    }
    return _confirmButton;
}

#pragma mark - actions

- (void)closeAction:(id)sender {
    BOOL isClickedByGesture = [sender isKindOfClass:[UIGestureRecognizer class]];
    if (isClickedByGesture) {
        CGPoint touchPoint = [(UIGestureRecognizer *)sender locationInView:self];
        if (CGRectContainsPoint(self.containerView.frame, touchPoint)) {
            return;
        }
    }
    if (self.cancelHandlerWithExitArea) {
        self.cancelHandlerWithExitArea(self, isClickedByGesture ? TTDialogViewBaseExitAreaBlank : TTDialogViewBaseExitAreaCloseButton);
    } else if (self.cancelHandler) {
        self.cancelHandler(self);
    }
}

- (void)confirmAction:(UIButton *)sender {
    if (self.confirmHandler) {
        self.confirmHandler(self);
    }
}

- (void)actionButtonClicked:(UIButton *)sender {
    if (self.actionHandler) {
        self.actionHandler(self, sender.tag);
    }
}

- (void)preventHightEffect:(UIButton *)sender 
{
    sender.highlighted = NO;
}


#pragma mark - showing helper

- (UIView *)findSuperViewInVisibleWindow
{
    return [UIApplication sharedApplication].delegate.window ? : [TTUIResponderHelper topmostView];
}

#pragma mark - show/hide

- (void)show
{
    if (self.superview) return;
    UIView * superView = [self findSuperViewInVisibleWindow];
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
                if ([TTDeviceHelper OSVersionNumber] >= 9.0) {
                    transform = CGAffineTransformMakeRotation(-M_PI_2);
                }
                break;
            case UIInterfaceOrientationLandscapeRight:
                if([TTDeviceHelper OSVersionNumber] >= 9.0){
                    transform = CGAffineTransformMakeRotation(M_PI_2);
                }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationUnknown:
                break;
        }
        self.transform = transform;
        [self setCenter:superView.center];
    }
    [superView addSubview:self];
    [self setIsShowing:YES];
    
    self.userInteractionEnabled = NO;
    self.containerView.transform = CGAffineTransformMakeScale(.00001f, .00001f);
    self.alpha = 0.f;
    
    [UIView animateWithDuration:kTTDialogViewBaseAlphaAnimationDuration animations:^{
        self.alpha = 1.f;
    }];
    
    [UIView animateWithDuration:kTTDialogViewBaseScaleAnimationDuration
                          delay:0.f
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.containerView.transform = CGAffineTransformIdentity;
                         self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
                     } completion:^(BOOL finished) {
                         self.userInteractionEnabled = YES;
                     }];
}

- (void)hide
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setIsShowing:NO];
    self.userInteractionEnabled = NO;
    self.alpha = 1.f;
    
    [UIView animateWithDuration:kTTDialogViewBaseAlphaAnimationDuration animations:^{
        self.alpha = 0.f;
    } completion:nil];
    
    [UIView animateWithDuration:kTTDialogViewBaseScaleAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:0.78
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.containerView.transform = CGAffineTransformMakeScale(.00001f, .00001f);
                     } completion:^(BOOL finished) {
                         if (!finished) {
                             return;
                         }
                         [self removeFromSuperview];
                     }];
}

@end
