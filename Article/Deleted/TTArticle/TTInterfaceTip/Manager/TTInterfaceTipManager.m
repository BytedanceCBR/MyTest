//
//  TTInterfaceTipManager.m
//  Article
//
//  Created by chenjiesheng on 2017/6/23.
//
//

#import "TTInterfaceTipManager.h"
#import "TTInterfaceTipBaseView.h"
#import "TTInterfaceTipBaseModel.h"
#import <UIView+CustomTimingFunction.h>

#define kTTInterfaceTipViewScaleSize 0.96
#define kTTInterfaceTipViewDismissDuration 0.2f
#define kTTInterfaceTipViewHorZoomBoundary 10.f
#define kTTInterfaceTipViewHorDismissBoundary 60.f
#define kTTInterfaceTipViewVerZoomBoundary 10.f
#define kTTInterfaceTipViewVerDismissBoundary 20.f

NSString *const kTTInterfaceTipModelKey = @"kTTInterfaceTipModelKey";

@interface TTInterfaceTipBackgroundView : UIView
@end
@implementation TTInterfaceTipBackgroundView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIView *subView in self.subviews){
        UIView *nextView = [subView hitTest:[self convertPoint:point toView:subView] withEvent:event];
        if (nextView != nil){
            return nextView;
        }
    }
    return nil;
}

@end

@interface TTInterfaceTipManager () <UIGestureRecognizerDelegate>

@property (nonatomic, weak)TTInterfaceTipBaseView *currentTipView;
@property (nonatomic, weak)TTInterfaceTipBaseModel *currentTipModel;
@property (nonatomic, strong)TTInterfaceTipBackgroundView *backgroundView;
@property (nonatomic, weak)UIViewController <TTInterfaceTabBarControllerProtocol> *tabbarController;
//gesture相关
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign)CGPoint tipViewOrigionCenter;
@property (nonatomic, assign)TTInterfaceTipsMoveDirection gestureDirection;
@end

@implementation TTInterfaceTipManager

static TTInterfaceTipManager *sharedInstance_tt = nil;
+ (TTInterfaceTipManager *)sharedInstance_tt
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_tt = [[TTInterfaceTipManager alloc] init];
    });
    return sharedInstance_tt;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabSelectNotification:) name:kExploreTabBarClickNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTopVCChangeNotification:) name:kExploreTopVCChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackgroundWithNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabSelectNotification:) name:@"kTTShowPostUGCEntranceNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)appendTipWithModel:(TTInterfaceTipBaseModel *)model
{
    if (model == nil){
        return;
    }
    [[self sharedInstance_tt] appendTipWithModel:model];
}

+ (void)appendTipWithTipViewIdentifier:(NSString *)identifier
{
    TTInterfaceTipBaseModel *model = [[TTInterfaceTipBaseModel alloc] init];
    model.interfaceTipViewIdentifier = identifier;
    [[TTInterfaceTipManager sharedInstance_tt] appendTipWithModel:model];
}

- (void)appendTipWithModel:(TTInterfaceTipBaseModel *)model
{
    model.manager = self;
    [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:model withContext:model.context];
}

- (void)dismissViewWithDefaultAnimation:(NSNumber *)animate
{
    if (animate.boolValue){
        [self animateForPanOutWithDirection:[_currentTipView panGestureDirection] byGesture:NO];
    }else{
        [_currentTipView clearTimer];
        [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:_currentTipModel];
        [_currentTipView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        _currentTipView = nil;
    }
}

#pragma mark -- private 
#pragma mark - Gesture

- (void)addPanGestureIfNeedWithTipView:(TTInterfaceTipBaseView *)tipView{
    if (tipView.needPanGesture == NO){
        return ;
    }
    if (self.panGesture.view){
        [_panGesture.view removeGestureRecognizer:_panGesture];
    }
    [tipView addGestureRecognizer:self.panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:pan.view.superview];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _currentTipView.panGestureRun = YES;
            [self changePandirectionWithPoint:[pan velocityInView:pan.view]];
            break;
        case UIGestureRecognizerStateChanged: {
            // 根据初始移动方向决定 当前继续移动方向
            if(_gestureDirection == TTInterfaceTipsMoveDirectionLeft || _gestureDirection == TTInterfaceTipsMoveDirectionRight){
                if(fabs(point.x) <= kTTInterfaceTipViewHorZoomBoundary){
                    CGFloat offset = fabs(point.x);
                    CGFloat zoomRatio = (kTTInterfaceTipViewScaleSize - 1) / kTTInterfaceTipViewHorZoomBoundary * offset + 1;
                    [_currentTipView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                }
                else{
                    [_currentTipView setTransform:CGAffineTransformMakeScale(kTTInterfaceTipViewScaleSize,kTTInterfaceTipViewScaleSize)];
                }
                _currentTipView.centerX = _tipViewOrigionCenter.x + point.x;
            }
            else if(_gestureDirection == TTInterfaceTipsMoveDirectionDown){
                if(point.y >= 0){
                    if(point.y <= kTTInterfaceTipViewVerZoomBoundary){
                        CGFloat offset = point.y;
                        CGFloat zoomRatio = (kTTInterfaceTipViewScaleSize - 1) / kTTInterfaceTipViewVerZoomBoundary * offset + 1;
                        [_currentTipView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                    }
                    else{
                        [_currentTipView setTransform:CGAffineTransformMakeScale(kTTInterfaceTipViewScaleSize,kTTInterfaceTipViewScaleSize)];
                    }
                    _currentTipView.centerY = _tipViewOrigionCenter.y + point.y;
                }else{
                    _currentTipView.center = _tipViewOrigionCenter;
                    [_currentTipView setTransform:CGAffineTransformIdentity];
                }
            }
            else if (_gestureDirection == TTInterfaceTipsMoveDirectionUp){
                if(point.y <= 0){
                    if(fabs(point.y) <= kTTInterfaceTipViewVerZoomBoundary){
                        CGFloat offset = fabs(point.y);
                        CGFloat zoomRatio = (kTTInterfaceTipViewScaleSize - 1) / kTTInterfaceTipViewVerZoomBoundary * offset + 1;
                        [_currentTipView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                    }
                    else{
                        [_currentTipView setTransform:CGAffineTransformMakeScale(kTTInterfaceTipViewScaleSize,kTTInterfaceTipViewScaleSize)];
                    }
                    _currentTipView.centerY = _tipViewOrigionCenter.y + point.y;
                }else{
                    _currentTipView.center = _tipViewOrigionCenter;
                    [_currentTipView setTransform:CGAffineTransformIdentity];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            BOOL gestureFailed = NO;
            if(_gestureDirection == TTInterfaceTipsMoveDirectionLeft || _gestureDirection == TTInterfaceTipsMoveDirectionRight){
                // 根据手势松开时的方向决定消失气泡时的方向
                if(fabs(_currentTipView.centerX - _tipViewOrigionCenter.x) > kTTInterfaceTipViewHorDismissBoundary){
                    [self animateForPanOutWithDirection:_gestureDirection byGesture:YES];
                }else{
                    [self animateWithPanFailed];
                    gestureFailed = YES;
                }
            }
            else if (_gestureDirection == TTInterfaceTipsMoveDirectionDown){
                // 要求松手时一定是向下的
                if(_currentTipView.centerY - _tipViewOrigionCenter.y > kTTInterfaceTipViewVerDismissBoundary){
                    [self animateForPanOutWithDirection:_gestureDirection byGesture:YES];
                }else{
                    [self animateWithPanFailed];
                     gestureFailed = YES;
                }
            }
            else if (_gestureDirection == TTInterfaceTipsMoveDirectionUp){
                if(_tipViewOrigionCenter.y - _currentTipView.centerY > kTTInterfaceTipViewVerDismissBoundary){
                    [self animateForPanOutWithDirection:_gestureDirection byGesture:YES];
                }else{
                    [self animateWithPanFailed];
                     gestureFailed = YES;
                }
            }
            if (gestureFailed){
                _gestureDirection = TTInterfaceTipsMoveDirectionNone;
                _currentTipView.panGestureRun = NO;
            }
        }
            break;
        default:
            break;
    }
}

- (void)changePandirectionWithPoint:(CGPoint) point{
    if (self.gestureDirection != TTInterfaceTipsMoveDirectionNone){
        return;
    }
    if (fabs(point.x) > fabs(point.y)){
        if (point.x > 0){
            self.gestureDirection = TTInterfaceTipsMoveDirectionRight;
        }else{
            self.gestureDirection = TTInterfaceTipsMoveDirectionLeft;
        }
    }else{
        if (point.y > 0){
            self.gestureDirection = TTInterfaceTipsMoveDirectionDown;
        }else{
            self.gestureDirection = TTInterfaceTipsMoveDirectionUp;
        }
    }
}

- (void)animateForPanOutWithDirection:(TTInterfaceTipsMoveDirection)dir byGesture:(BOOL)isGesture{
    CGPoint finalPosition = _currentTipView.frame.origin;
    switch (dir) {
        case TTInterfaceTipsMoveDirectionLeft:
            finalPosition.x = -_currentTipView.superview.width;
            break;
        case TTInterfaceTipsMoveDirectionRight:
            finalPosition.x = _currentTipView.superview.width;
            break;
        case TTInterfaceTipsMoveDirectionUp:
            finalPosition.y = -_currentTipView.height;
            break;
        case TTInterfaceTipsMoveDirectionDown:
            finalPosition.y = _currentTipView.superview.height;
        default:
            break;
    }
    [UIView animateWithDuration:kTTInterfaceTipViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        _currentTipView.origin = finalPosition;
    } completion:^(BOOL finished) {
        if (isGesture){
            [_currentTipView removeFromSuperviewByGesture];
        }
        [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:_currentTipModel];
        [_currentTipView removeFromSuperview];
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        _currentTipView = nil;
    }];
}

- (void)animateWithPanFailed
{
    [UIView animateWithDuration:kTTInterfaceTipViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        [_currentTipView setTransform:CGAffineTransformIdentity];
        _currentTipView.center = _tipViewOrigionCenter;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - notification

- (void)handleTabSelectNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo){
        _currentTabBarIndex = [userInfo tt_integerValueForKey:@"currentIndex"];
    }
    [_currentTipView selectedTabChangeWithCurrentIndex:[userInfo tt_integerValueForKey:@"currentIndex"] lastIndex:[userInfo tt_integerValueForKey:@"lastIndex"] isUGCPostEntrance:userInfo == nil];
}

- (void)handleTopVCChangeNotification:(NSNotification *)notification
{
    [_currentTipView topVCChange];
}

- (void)handleEnterBackgroundWithNotification:(NSNotification *)notification
{
    [_currentTipView enterBackground];
}

#pragma mark -- Getter & Setter

- (TTInterfaceTipBackgroundView *)backgroundView{
    if (_backgroundView == nil){
        _backgroundView = [[TTInterfaceTipBackgroundView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self.tabbarController.view addSubview:_backgroundView];
        _backgroundView.frame = self.tabbarController.view.bounds;
    }
    return _backgroundView;
}

- (UIViewController <TTInterfaceTabBarControllerProtocol> *)tabbarController{
    if ([TTDeviceHelper isPadDevice]){
        return nil;
    }
    if (_tabbarController == nil){
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        if (window == nil){
            window = [UIApplication sharedApplication].keyWindow;
        }
        UIViewController *rootViewController = window.rootViewController;
        if ([rootViewController conformsToProtocol:@protocol(TTInterfaceTabBarControllerProtocol)]){
            _tabbarController = (UIViewController<TTInterfaceTabBarControllerProtocol> *) rootViewController;
        }
    }
    return _tabbarController;
}

- (UIPanGestureRecognizer *)panGesture{
    if (_panGesture == nil){
        _panGesture = [[UIPanGestureRecognizer alloc] init];
        _panGesture.delegate = self;
        [_panGesture addTarget:self action:@selector(handlePanGesture:)];
    }
    return _panGesture;
}

#pragma mark - gestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == _panGesture){
        _tipViewOrigionCenter = _currentTipView.center;
        CGPoint velocity = [_panGesture velocityInView:_currentTipView];
        [self changePandirectionWithPoint:velocity];
        TTInterfaceTipsMoveDirection dir = self.gestureDirection;
        self.gestureDirection = TTInterfaceTipsMoveDirectionNone;
        switch (_currentTipView.panGestureDirection) {
            case TTInterfaceTipsMoveDirectionDown:
                return dir != TTInterfaceTipsMoveDirectionUp;
                break;
            case TTInterfaceTipsMoveDirectionUp:
                return dir != TTInterfaceTipsMoveDirectionDown;
                break;
            default:
                return NO;
                break;
        }
    }
    return YES;
}

#pragma mark -- TTGuideProtocol

- (void)showWithModel:(TTInterfaceTipBaseModel *)model{
    NSMutableDictionary *contextDict = [NSMutableDictionary dictionary];
    UIViewController<TTInterfaceBackViewControllerProtocol> *currentSelectedViewController;
    CGFloat bottomHeight = 0;
    if ([self.tabbarController respondsToSelector:@selector(currentSelectedViewController)]){
        [contextDict setValue:self.tabbarController.currentSelectedViewController forKey: kTTInterfaceContextCurrentSelectedViewControllerKey];
        currentSelectedViewController = self.tabbarController.currentSelectedViewController;
    }
    if ([self.tabbarController respondsToSelector:@selector(tabbarHeight)]){
        [contextDict setValue:@(self.tabbarController.tabbarHeight) forKey:kTTInterfaceContextTabbarHeightKey];
        bottomHeight += self.tabbarController.tabbarHeight;
    }
    if ([self.tabbarController respondsToSelector:@selector(mineIconView)]){
        [contextDict setValue:self.tabbarController.mineIconView forKey:kTTInterfaceContextMineIconViewKey];
    }
    if ([currentSelectedViewController respondsToSelector:@selector(topHeight)]){
        [contextDict setValue:@(currentSelectedViewController.topHeight) forKey:kTTInterfaceContextTopHeightKey];
    }
    if ([currentSelectedViewController respondsToSelector:@selector(bottomHeight)]){
        bottomHeight += currentSelectedViewController.bottomHeight;
    }
    [contextDict setValue:@(bottomHeight) forKey:kTTInterfaceContextBottomHeightKey];
    
    [model setupContextWithDict:contextDict];
    
    Class class = NSClassFromString(model.interfaceTipViewIdentifier);
    TTInterfaceTipBaseView *tipView = [[class alloc] init];
    [tipView setupViewWithModel:model];
    [self addPanGestureIfNeedWithTipView:tipView];
    [self.backgroundView addSubview: tipView];
    _currentTipView = tipView;
    _currentTipModel = model;
    [_currentTipView show];
}

+ (void)appendNightShiftTipViewIfNeed{
    TTInterfaceTipBaseModel *model = [[TTInterfaceTipBaseModel alloc] init];
    model.interfaceTipViewIdentifier = @"TTInterfaceTipNightShiftView";
    [self appendTipWithModel:model];
}
@end
