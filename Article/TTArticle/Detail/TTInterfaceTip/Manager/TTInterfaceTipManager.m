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
#import <TTDialogDirector/TTDialogDirector.h>
#import <UIViewAdditions.h>
#import <NSDictionary+TTAdditions.h>
#import <TTUIResponderHelper.h>
#import <TTDeviceHelper.h>

#define kTTInterfaceTipViewScaleSize 0.96
#define kTTInterfaceTipViewDismissDuration 0.2f
#define kTTInterfaceTipViewHorZoomBoundary 10.f
#define kTTInterfaceTipViewHorDismissBoundary 60.f
#define kTTInterfaceTipViewVerZoomBoundary 10.f
#define kTTInterfaceTipViewVerDismissBoundary 20.f

NSString *const kTTInterfaceTipModelKey = @"kTTInterfaceTipModelKey";

@interface TTInterfaceTipBackgroundView ()

@property (nonatomic, weak)TTInterfaceTipManager *manager;

@end

@implementation TTInterfaceTipBackgroundView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.hidden || self.alpha < 0.01) {
        return nil;
    }
    if (_manager.currentTipView == nil){
        return nil;
    }
    UIView *nextView = [super hitTest:point withEvent:event];
    if (nextView != self && nextView){
        return nextView;
    }
    if ([_manager.currentTipView needBlockTouchInBlankView]){
        return self;
    }
    return nil;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([_manager.currentTipView needBlockTouchInBlankView] && touch.view == self){
        [_manager.currentTipView blankGroundViewClickCallBack];
    }
}

@end

@interface TTInterfaceTipManager () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite)TTInterfaceTipBackgroundView *backgroundView;
@property (nonatomic, weak)UIViewController <TTInterfaceTabBarControllerProtocol> *tabbarController;
//gesture相关
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign)CGPoint tipViewOrigionCenter;
@property (nonatomic, assign)TTInterfaceTipsMoveDirection gestureDirection;
@property (nonatomic, strong)NSMutableArray<TTInterfaceTipBaseModel *>          *readyShowTipModels;//当首页出现的时候，需要展示的弹窗
@property (nonatomic, strong)NSMutableArray<TTInterfaceTipBaseView *>           *curShowTipViews;//所有的弹窗数组
@property (nonatomic, strong)NSMutableArray<TTInterfaceTipBaseView *>           *dialogDirectorTipViews;//受弹窗控制管理的弹窗数组
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
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabSelectNotification:) name:kExploreTabBarClickNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTopVCChangeNotification:) name:kExploreTopVCChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackgroundWithNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTabSelectNotification:) name:@"kTTShowPostUGCEntranceNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainViewDidShowNotification:) name:@"MainList_ViewAppear" object:nil];
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

+ (void)appendNonDirectorTipWithModel:(TTInterfaceTipBaseModel *)model
{
    if (model == nil){
        return;
    }
    model.manager = [self sharedInstance_tt];
    if ([model checkShouldDisplay]) {
        [[self sharedInstance_tt] showWithModel:model withDialogDirector:NO];
    }
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
    
    [TTDialogDirector enqueueShowDialog:model
                           withPriority:model.dialogPriority
                           shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
                               return [model checkShouldDisplay];
                           } showMe:^(id  _Nonnull dialogInst) {
                               [self showWithModel:model withDialogDirector:YES];
                           } hideForcedlyMe:^(id  _Nonnull dialogInst) {
                               TTInterfaceTipBaseView *tipView = [self.dialogDirectorTipViews firstObject];
                               [tipView hideByTipWithHigherPriority];
                           }];
    
    [self.dialogDirectorTipViews enumerateObjectsUsingBlock:^(TTInterfaceTipBaseView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.model != model && obj.model.dialogPriority < model.dialogPriority) {
            [obj hideByTipWithHigherPriority];
        }
    }];
}

+ (void)showInstanceTipWithModel:(TTInterfaceTipBaseModel *)model
{
    [[TTInterfaceTipManager sharedInstance_tt] showInstanceTipWithModel:model];
}

- (void)showInstanceTipWithModel:(TTInterfaceTipBaseModel *)model
{
    model.manager = self;
    [TTDialogDirector showInstantlyDialog:model
                             shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
                                 return [model checkShouldDisplay];
                             } showMe:^(id  _Nonnull dialogInst) {
                                 [self showWithModel:model withDialogDirector:YES];
                             } hideForcedlyMe:^(id  _Nonnull dialogInst) {
                                 TTInterfaceTipBaseView *tipView = [self.dialogDirectorTipViews firstObject];
                                 [tipView hideByTipWithHigherPriority];
                             }];
}

- (void)dismissViewWithDefaultAnimation:(NSNumber *)animate withView:(TTInterfaceTipBaseView *)baseView
{
    if (animate.boolValue){
        [self animateForPanOutWithDirection:[baseView panGestureDirection] byGesture:NO withTipView:baseView];
    }else{
        TTInterfaceTipBaseView *curTipView = baseView;
        [self.curShowTipViews removeObject:curTipView];
        [self addPanGestureIfNeedWithTipView:curTipView];
        [curTipView clearTimer];
        [curTipView removeFromSuperview];
        if (self.curShowTipViews.count == 0) {
            [_backgroundView removeFromSuperview];
            _backgroundView = nil;
        }
        if ([self.dialogDirectorTipViews indexOfObject:curTipView] != NSNotFound) {
            [self.dialogDirectorTipViews removeObject:curTipView];
            [TTDialogDirector dequeueDialog:baseView.model];
        }
    }
}

+ (void)setupShowAfterMainListDidShowWithTipModel:(TTInterfaceTipBaseModel *)tipModel
{
    [[TTInterfaceTipManager sharedInstance_tt] setupShowAfterMainListDidShowWithTipModel:tipModel];
}

- (void)setupShowAfterMainListDidShowWithTipModel:(TTInterfaceTipBaseModel *)tipModel
{
    __block NSUInteger index = self.readyShowTipModels.count; // 默认插队尾
    [self.readyShowTipModels enumerateObjectsUsingBlock:^(TTInterfaceTipBaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 按优先级降序排列，发现比 tipModel 低后，即停止比较并记录该位置
        if (obj.dialogPriority < tipModel.dialogPriority) {
            *stop = YES;
            index = idx;
        }
    }];
    [self.readyShowTipModels insertObject:tipModel atIndex:index];
}

+ (void)hideTipView
{
    [[self sharedInstance_tt] currentTipView].hidden = YES;
    [[self sharedInstance_tt] backgroundView].hidden = YES;
}

+ (void)showTipView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedInstance_tt] currentTipView].hidden = NO;
        [[self sharedInstance_tt] backgroundView].hidden = NO;
    });
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
    
    TTInterfaceTipBaseView *tipView = (TTInterfaceTipBaseView *)pan.view;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            tipView.panGestureRun = YES;
            [self changePandirectionWithPoint:[pan velocityInView:pan.view]];
            break;
        case UIGestureRecognizerStateChanged: {
            // 根据初始移动方向决定 当前继续移动方向
            if(_gestureDirection == TTInterfaceTipsMoveDirectionLeft || _gestureDirection == TTInterfaceTipsMoveDirectionRight){
                if(fabs(point.x) <= kTTInterfaceTipViewHorZoomBoundary){
                    CGFloat offset = fabs(point.x);
                    CGFloat zoomRatio = (kTTInterfaceTipViewScaleSize - 1) / kTTInterfaceTipViewHorZoomBoundary * offset + 1;
                    [tipView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                }
                else{
                    [tipView setTransform:CGAffineTransformMakeScale(kTTInterfaceTipViewScaleSize,kTTInterfaceTipViewScaleSize)];
                }
                tipView.centerX = _tipViewOrigionCenter.x + point.x;
            }
            else if(_gestureDirection == TTInterfaceTipsMoveDirectionDown){
                if(point.y >= 0){
                    if(point.y <= kTTInterfaceTipViewVerZoomBoundary){
                        CGFloat offset = point.y;
                        CGFloat zoomRatio = (kTTInterfaceTipViewScaleSize - 1) / kTTInterfaceTipViewVerZoomBoundary * offset + 1;
                        [tipView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                    }
                    else{
                        [tipView setTransform:CGAffineTransformMakeScale(kTTInterfaceTipViewScaleSize,kTTInterfaceTipViewScaleSize)];
                    }
                    tipView.centerY = _tipViewOrigionCenter.y + point.y;
                }else{
                    tipView.center = _tipViewOrigionCenter;
                    [tipView setTransform:CGAffineTransformIdentity];
                }
            }
            else if (_gestureDirection == TTInterfaceTipsMoveDirectionUp){
                if(point.y <= 0){
                    if(fabs(point.y) <= kTTInterfaceTipViewVerZoomBoundary){
                        CGFloat offset = fabs(point.y);
                        CGFloat zoomRatio = (kTTInterfaceTipViewScaleSize - 1) / kTTInterfaceTipViewVerZoomBoundary * offset + 1;
                        [tipView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                    }
                    else{
                        [tipView setTransform:CGAffineTransformMakeScale(kTTInterfaceTipViewScaleSize,kTTInterfaceTipViewScaleSize)];
                    }
                    tipView.centerY = _tipViewOrigionCenter.y + point.y;
                }else{
                    tipView.center = _tipViewOrigionCenter;
                    [tipView setTransform:CGAffineTransformIdentity];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            BOOL gestureFailed = NO;
            if(_gestureDirection == TTInterfaceTipsMoveDirectionLeft || _gestureDirection == TTInterfaceTipsMoveDirectionRight){
                // 根据手势松开时的方向决定消失气泡时的方向
                if(fabs(tipView.centerX - _tipViewOrigionCenter.x) > kTTInterfaceTipViewHorDismissBoundary){
                    [self animateForPanOutWithDirection:_gestureDirection byGesture:YES withTipView:tipView];
                }else{
                    [self animateWithPanFailed];
                    gestureFailed = YES;
                }
            }
            else if (_gestureDirection == TTInterfaceTipsMoveDirectionDown){
                // 要求松手时一定是向下的
                if(tipView.centerY - _tipViewOrigionCenter.y > kTTInterfaceTipViewVerDismissBoundary){
                    [self animateForPanOutWithDirection:_gestureDirection byGesture:YES withTipView:tipView];
                }else{
                    [self animateWithPanFailed];
                     gestureFailed = YES;
                }
            }
            else if (_gestureDirection == TTInterfaceTipsMoveDirectionUp){
                if(_tipViewOrigionCenter.y - tipView.centerY > kTTInterfaceTipViewVerDismissBoundary){
                    [self animateForPanOutWithDirection:_gestureDirection byGesture:YES withTipView:tipView];
                }else{
                    [self animateWithPanFailed];
                     gestureFailed = YES;
                }
            }
            if (gestureFailed){
                _gestureDirection = TTInterfaceTipsMoveDirectionNone;
                tipView.panGestureRun = NO;
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

- (void)animateForPanOutWithDirection:(TTInterfaceTipsMoveDirection)dir byGesture:(BOOL)isGesture withTipView:(TTInterfaceTipBaseView *)view
{
    TTInterfaceTipBaseView *tipView = view;
    CGPoint finalPosition = tipView.frame.origin;
    switch (dir) {
        case TTInterfaceTipsMoveDirectionLeft:
            finalPosition.x = -tipView.superview.width;
            break;
        case TTInterfaceTipsMoveDirectionRight:
            finalPosition.x = tipView.superview.width;
            break;
        case TTInterfaceTipsMoveDirectionUp:
            finalPosition.y = -tipView.height;
            break;
        case TTInterfaceTipsMoveDirectionDown:
            finalPosition.y = tipView.superview.height;
        default:
            break;
    }
    [UIView animateWithDuration:kTTInterfaceTipViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        tipView.origin = finalPosition;
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        
        if (isGesture){
            [tipView removeFromSuperviewByGesture];
        }
        TTInterfaceTipBaseView *curTipView = tipView;
        
        [self.curShowTipViews removeObject:curTipView];
        if ([self.dialogDirectorTipViews indexOfObject:curTipView] != NSNotFound) {
            [self.dialogDirectorTipViews removeObject:curTipView];
            [TTDialogDirector dequeueDialog:curTipView.model];
        }
        [self addPanGestureIfNeedWithTipView:self.currentTipView];
        [curTipView removeFromSuperview];
        if (self.curShowTipViews.count == 0) {
            _backgroundView = nil;
            [_backgroundView removeFromSuperview];
        }
    }];
}

- (void)animateWithPanFailed
{
    UIView *view = self.panGesture.view;
    [UIView animateWithDuration:kTTInterfaceTipViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        [view setTransform:CGAffineTransformIdentity];
        view.center = _tipViewOrigionCenter;
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
    [self.curShowTipViews enumerateObjectsUsingBlock:^(TTInterfaceTipBaseView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj selectedTabChangeWithCurrentIndex:[userInfo tt_integerValueForKey:@"currentIndex"] lastIndex:[userInfo tt_integerValueForKey:@"lastIndex"] isUGCPostEntrance:userInfo == nil];
    }];
}

- (void)handleTopVCChangeNotification:(NSNotification *)notification
{
    [self.curShowTipViews enumerateObjectsUsingBlock:^(TTInterfaceTipBaseView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj topVCChange];
    }];
}

- (void)handleEnterBackgroundWithNotification:(NSNotification *)notification
{
    [self.curShowTipViews enumerateObjectsUsingBlock:^(TTInterfaceTipBaseView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enterBackground];
    }];
}

- (void)mainViewDidShowNotification:(NSNotification *)notification
{
    // 这里先将 self.readyShowTipsModels 清空，避免在 appendTipWithModel 过程中修改 self.readyShowTipsModels 导致崩溃
    NSArray * models = [self.readyShowTipModels copy];
    [self.readyShowTipModels removeAllObjects];
    
    [models enumerateObjectsUsingBlock:^(TTInterfaceTipBaseModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [TTInterfaceTipManager appendTipWithModel:obj];
    }];
}

#pragma mark -- Getter & Setter

- (TTInterfaceTipBackgroundView *)backgroundView{
    if (_backgroundView == nil){
        _backgroundView = [[TTInterfaceTipBackgroundView alloc] initWithFrame:[TTUIResponderHelper mainWindow].bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.manager = self;
        _backgroundView.backgroundColor = [UIColor clearColor];
        [[TTUIResponderHelper mainWindow] addSubview:_backgroundView];
        if ([self.currentTipView needDimBackground]){
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        }
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

- (NSMutableArray<TTInterfaceTipBaseModel *> *)readyShowTipModels
{
    if (_readyShowTipModels == nil) {
        _readyShowTipModels = [NSMutableArray array];
    }
    return _readyShowTipModels;
}

- (NSMutableArray<TTInterfaceTipBaseView *> *)curShowTipViews
{
    if (_curShowTipViews == nil) {
        _curShowTipViews = [NSMutableArray array];
    }
    return _curShowTipViews;
}

- (NSMutableArray<TTInterfaceTipBaseView *> *)dialogDirectorTipViews
{
    if (_dialogDirectorTipViews == nil) {
        _dialogDirectorTipViews = [NSMutableArray array];
    }
    return _dialogDirectorTipViews;
}

- (TTInterfaceTipBaseView *)currentTipView
{
    return self.curShowTipViews.firstObject;
}

#pragma mark - gestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == _panGesture){
        TTInterfaceTipBaseView *tipView = (TTInterfaceTipBaseView *)gestureRecognizer.view;
        _tipViewOrigionCenter = gestureRecognizer.view.center;
        CGPoint velocity = [_panGesture velocityInView:gestureRecognizer.view];
        [self changePandirectionWithPoint:velocity];
        TTInterfaceTipsMoveDirection dir = self.gestureDirection;
        self.gestureDirection = TTInterfaceTipsMoveDirectionNone;
        switch (tipView.panGestureDirection) {
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

- (void)showWithModel:(TTInterfaceTipBaseModel *)model withDialogDirector:(BOOL)dialogDirector
{
    if (model.useCustomBackView) {
        if (model.customBackView) {
            [self showWithModel:model
             withDialogDirector:dialogDirector
             withCustomBackView:model.customBackView];
        }
        return;
    }
    
    NSMutableDictionary *contextDict = [NSMutableDictionary dictionary];
    UIViewController<TTInterfaceBackViewControllerProtocol> *currentSelectedViewController;
    CGFloat bottomHeight = 0;
    if ([self.tabbarController respondsToSelector:@selector(currentSelectedViewController)]){
        [contextDict setValue:self.tabbarController.currentSelectedViewController forKey: kTTInterfaceContextCurrentSelectedViewControllerKey];
        currentSelectedViewController = self.tabbarController.currentSelectedViewController;
    }
    if ([self.tabbarController respondsToSelector:@selector(tabbarVisibleHeight)]){
        [contextDict setValue:@(self.tabbarController.tabbarVisibleHeight) forKey:kTTInterfaceContextTabbarHeightKey];
        bottomHeight += self.tabbarController.tabbarVisibleHeight;
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
    if (tipView){
        [tipView setupViewWithModel:model];
        [self.curShowTipViews addObject:tipView];
        [self addPanGestureIfNeedWithTipView:tipView];
        [self.backgroundView addSubview:tipView];
        [tipView show];
        if (dialogDirector) {
            [self.dialogDirectorTipViews addObject:tipView];
        }
    } else {
        [self dismissViewWithDefaultAnimation:@NO withView:tipView];
    }
}

- (void)showWithModel:(TTInterfaceTipBaseModel *)model withDialogDirector:(BOOL)dialogDirector withCustomBackView:(UIView *)backView
{
    Class class = NSClassFromString(model.interfaceTipViewIdentifier);
    TTInterfaceTipBaseView *tipView = [[class alloc] init];
    if (tipView){
        [tipView setupViewWithModel:model];
        [self.curShowTipViews addObject:tipView];
        [backView addSubview:tipView];
        [tipView show];
        if (dialogDirector) {
            [self.dialogDirectorTipViews addObject:tipView];
        }
    } else {
        [self dismissViewWithDefaultAnimation:@NO withView:tipView];
    }
}

+ (void)appendNightShiftTipViewIfNeed{
    TTInterfaceTipBaseModel *model = [[TTInterfaceTipBaseModel alloc] init];
    model.interfaceTipViewIdentifier = @"TTInterfaceTipNightShiftView";
    [self appendTipWithModel:model];
}
@end
