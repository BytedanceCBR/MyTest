//
//  TTMessageNotificationTipsManager.m
//  Article
//
//  Created by lizhuoli on 17/3/24.
//
//

#import "TTMessageNotificationTipsManager.h"
#import "TTMessageNotificationTipsModel.h"
#import "TTMessageNotificationTipsView.h"

#import "TTRoute.h"
#import "TTMessageNotificationMacro.h"

#import "UIView+CustomTimingFunction.h"


#import <TTAccountBusiness.h>

#import "TTProfileViewController.h"
#import "TTUIResponderHelper.h"

#import <TTDialogDirector/TTDialogDirector.h>

NSString * const kTTMessageNotificationTipsChangeNotification = @"kTTMessageNotificationTipsChangeNotification";
NSString * const kTTMessageNotificationLastTipSaveKey = @"kTTMessageNotificationLastTipSaveKey";
NSString * const kTTMessageNotificationLastListMaxCursorSaveKey = @"kTTMessageNotificationLastListMaxCursorSaveKey";
NSString * const kTTMessageNotificationTipsDialogKey = @"kTTMessageNotificationTipsDialogKey";
NSString * const kTTMessageNotificationTipsDialogLocationKey = @"kTTMessageNotificationTipsDialogLocationKey";

@interface TTMessageNotificationTipsManager ()
@property (nonatomic, strong) TTMessageNotificationTipsView *tipsView;
@property (nonatomic, strong) TTMessageNotificationTipsModel *tipsModel;//保存当前正在展示的model
@property (nonatomic, assign, readwrite) BOOL isShowingTips;

//手势拖动相关
@property (nonatomic, assign) TTMessageNotificationTipsMoveDirection panDirection;    //记录初始的移动方向
@property (nonatomic, assign) BOOL panRun;               //判断当前是否正在拖动
@property (nonatomic, strong) NSTimer *timer;            //气泡自动消失的计时器
@property (nonatomic, assign) CGPoint oriCenter;         //气泡正常展示时的位置
@property (nonatomic, assign) CGFloat parentViewHeight;  //传进来的父view的高度
@property (nonatomic, assign) CGFloat parentViewWidth;   //传进来的父view的宽度

@property (nonatomic, assign) BOOL isFading; //是否正在进行消息通知Tips动画

@property (nonatomic, strong) NSDictionary *context;
@end

@implementation TTMessageNotificationTipsManager

+ (instancetype)sharedManager
{
    static TTMessageNotificationTipsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTMessageNotificationTipsManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    if(self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTipsWithModel:(TTMessageNotificationTipsModel *)model
{
    if (![model isKindOfClass:[TTMessageNotificationTipsModel class]]) {
        return;
    }
    
    self.tipsModel = model;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTMessageNotificationTipsChangeNotification object:nil];
}

- (void)clearTipsModel
{
    BOOL needNotify = (self.tipsModel != nil);
    
    self.tipsModel = nil;
    
    if(needNotify){
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTMessageNotificationTipsChangeNotification object:nil];
    }
}

- (void)showTipsInView:(UIView *)view tabCenterX:(CGFloat)centerX callback:(void (^)(void))callback
{
    if (!self.context) {
        self.context = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    
    [self.context setValue:view forKey:@"view"];
    [self.context setValue:[NSNumber numberWithFloat:centerX] forKey:@"centerX"];
    [self.context setValue:callback forKey:@"callback"];
    
    if (![TTDialogDirector containsDialog:kTTMessageNotificationTipsDialogKey]) {
        [TTDialogDirector enqueueDialog:kTTMessageNotificationTipsDialogKey atLocation:kTTMessageNotificationTipsDialogLocationKey shouldShowMe:^BOOL(BOOL * _Nullable keepAlive) {
            *keepAlive = NO;
            
            return [self __shouldShowMessageTipsForContainerView:view];
        } showMe:^(id  _Nonnull dialogInst) {
            [self __showTips];
        } hideForcedlyMe:^(id  _Nonnull dialogInst) {
            [self forceRemoveTipsView];
        }];
    }
    
    if ([self __shouldShowMessageTipsForContainerView:view]) {
        [TTDialogDirector showLocationDialogForKey:kTTMessageNotificationTipsDialogLocationKey];
    }
}

- (BOOL)__shouldShowMessageTipsForContainerView:(UIView *)view
{
    TTMessageNotificationTipsModel *model = self.tipsModel;
    
    if (!view || !model.important || ![model.important isKindOfClass:[TTMessageNotificationTipsImportantModel class]]) {
        return NO;
    }
    
    if (self.tipsView) {
        //如果当前正在展示气泡，这时候来了新的重要消息，不展示
        model.important.hasShown = @(1);
        return NO;
    }
    
    // 针对的是当前这条重要的消息
    if ([model.important.hasShown boolValue]){
        return NO;
    }
    
    //不进入消息列表的气泡不做去重，服务器下发的msg_id和cursor没有意义
    if ([self isNeedRemoveDuplicatingBubble]) {
        //避免气泡重复展示，针对的收到连续两条重要的消息
        if([model.important.msgID isEqualToString:[self lastImportantMessageID]]){
            return NO;
        }
        
        // 针对如果进入消息列表以后，如果拿到还是原来的cursor应该怎么处理
        if ([model.important.cursor compare:[self lastListMaxCursor]] != NSOrderedDescending){
            return NO;
        }
    }
    
    return YES;
}

- (void)_decodeWithEncodedURLString:(NSString **)urlString
{
    if ([*urlString rangeOfString:@"%"].length == 0){
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    *urlString = (__bridge_transfer NSString *)(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)*urlString, CFSTR(""), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSMutableDictionary *)__parseParameterWithUrl:(NSString *)urlString
{
    NSRange schemeSegRange = [urlString rangeOfString:@"://"];
    NSString *outScheme = nil;
    if (schemeSegRange.location != NSNotFound) {
        outScheme = [urlString substringFromIndex:NSMaxRange(schemeSegRange)];
    }
    else {
        outScheme = urlString;
    }
    
    NSArray *substrings = [outScheme componentsSeparatedByString:@"?"];
    if ([substrings count] > 1) {
        NSString *queryString = [substrings objectAtIndex:1];
        NSArray *paramsList = [queryString componentsSeparatedByString:@"&"];
        NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
        [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
            NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
            if ([keyAndValue count] > 1) {
                NSString *paramKey = [keyAndValue objectAtIndex:0];
                NSString *paramValue = [keyAndValue objectAtIndex:1];
                //v0.2.19 去掉递归decode，外部保证传入合法encode的url
                [self _decodeWithEncodedURLString:&paramValue];
                if (paramValue && paramKey) {
                    [queryParams setValue:paramValue forKey:paramKey];
                }
            }
        }];
        return queryParams;
    }
    return nil;
}

- (void)__showTips
{
    TTMessageNotificationTipsModel *model = self.tipsModel;
    
    UIView *view = [self.context tt_objectForKey:@"view"];
    CGFloat centerX = ((NSNumber *)[self.context tt_objectForKey:@"centerX"]).floatValue;
    void (^callback)(void) = [self.context tt_objectForKey:@"callback"];
    
    model.important.hasShown = @(1);
    
    [self saveLastImportantMessageID];
    
    self.panDirection = TTMessageNotificationTipsMoveDirectionNone;
    self.panRun = NO;
    self.isShowingTips = YES;
    
    TTMessageNotificationTipsImportantModel *tipsImportantModel = model.important;
    
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
    CGRect frame = CGRectMake(padding, CGRectGetMaxY(view.bounds) - kTTMessageNotificationTipsViewHeight - kTTMessageNotificationTipsViewBottom - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom, CGRectGetWidth(view.bounds) - 2 * padding, kTTMessageNotificationTipsViewHeight);
    self.tipsView = [[TTMessageNotificationTipsView alloc] initWithFrame:frame tabCenterX:centerX];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipsViewTouched:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tipsViewMoved:)];
    [self.tipsView addGestureRecognizer:gesture];
    [self.tipsView addGestureRecognizer:pan];
    [self.tipsView configWithModel:model];
    
    [view addSubview:self.tipsView];
    
    _oriCenter = self.tipsView.center;
    _parentViewWidth = view.width;
    _parentViewHeight = view.height;
    
//    //百万英雄
//    if ([self.tipsModel.important.openUrl rangeOfString:@"fantasy"].location != NSNotFound) {
//        NSMutableDictionary *params = [self __parseParameterWithUrl:self.tipsModel.important.openUrl];
//        [TTTrackerWrapper eventV3:@"show_million_pound" params:params];
//    }


    wrapperTrackEventWithCustomKeys(@"bubble", @"show", self.tipsView.msgID,nil,kTTMessageNotificationTrackExtra(self.tipsView.actionType));
    
    self.tipsView.top = _parentViewHeight;
    
    [UIView animateWithDuration:kTTMessageNotificationTipsViewSpringDuration delay:kTTMessageNotificationTipsViewSpringDelay usingSpringWithDamping:kTTMessageNotificationTipsViewSpringDampingRatio initialSpringVelocity:kTTMessageNotificationTipsViewSpringVelocity options:0 animations:^{
        self.tipsView.center = _oriCenter;
    } completion:^(BOOL finished) {
        NSTimeInterval displayTime = tipsImportantModel.displayTime.doubleValue;
        if (!displayTime || displayTime <= 0) {
            displayTime = kTTMessageNotificationTipsViewDefaultDisplayTime;
        }
        if(_timer){
            [_timer invalidate];
            _timer = nil;
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:displayTime target:self selector:@selector(autoRemoveTipsView) userInfo:nil repeats:NO];
        
        if (callback) {
            callback();
        }
    }];
}

- (void)setMessageHasShown{
    self.tipsModel.important.hasShown = @(1);
}

- (void)autoRemoveTipsView{
    if(self.panRun){
        return;
    }
    
    if (!self.tipsView || self.isFading) {
        self.isShowingTips = NO;
        return;
    }
    
    wrapperTrackEventWithCustomKeys(@"bubble", @"fade", self.tipsView.msgID, nil,kTTMessageNotificationTrackExtra(self.tipsView.actionType));
    [self removeTipsView];
}

//别的方式隐藏气泡，如进入详情页，切换tab
- (void)forceRemoveTipsView{
    if (!self.tipsView || self.isFading) {
        self.isShowingTips = NO;
        return;
    }
    [self clearTipView];
}

- (void)tipsViewTouched:(UITapGestureRecognizer *)gesture
{
    wrapperTrackEventWithCustomKeys(@"bubble", @"click", self.tipsView.msgID, nil, kTTMessageNotificationTrackExtra(self.tipsView.actionType));
    //服务器会下发不可跳转的气泡
    NSURL *openURL = [NSURL URLWithString:self.tipsModel.important.openUrl];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
    }
    [self removeTipsView];
}

- (void)tipsViewMoved:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:pan.view.superview];
    
    // 判断初始移动方向
    [self changePandirectionWithPoint:point];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.panRun = YES;
            break;
        case UIGestureRecognizerStateChanged: {
            // 根据初始移动方向决定 当前继续移动方向
            if(self.panDirection == TTMessageNotificationTipsMoveDirectionLeft || self.panDirection == TTMessageNotificationTipsMoveDirectionRight){
                if(fabs(point.x) <= kTTMessageNotificationTipsViewHorZoomBoundary){
                    CGFloat offset = fabs(point.x);
                    CGFloat zoomRatio = (kTTMessageNotificationTipsViewScaleSize - 1) / kTTMessageNotificationTipsViewHorZoomBoundary * offset + 1;
                    [self.tipsView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                }
                else{
                    [self.tipsView setTransform:CGAffineTransformMakeScale(kTTMessageNotificationTipsViewScaleSize,kTTMessageNotificationTipsViewScaleSize)];
                }
                self.tipsView.centerX = _oriCenter.x + point.x;
            }
            else if(self.panDirection == TTMessageNotificationTipsMoveDirectionDown){
                if(point.y >=0){
                    if(point.y <= kTTMessageNotificationTipsViewVerZoomBoundary){
                        CGFloat offset = point.y;
                        CGFloat zoomRatio = (kTTMessageNotificationTipsViewScaleSize - 1) / kTTMessageNotificationTipsViewVerZoomBoundary * offset + 1;
                        [self.tipsView setTransform:CGAffineTransformMakeScale(zoomRatio, zoomRatio)];
                    }
                    else{
                        [self.tipsView setTransform:CGAffineTransformMakeScale(kTTMessageNotificationTipsViewScaleSize,kTTMessageNotificationTipsViewScaleSize)];
                    }
                    self.tipsView.centerY = _oriCenter.y + point.y;
                }
                else{
                    self.tipsView.center = _oriCenter;
                    [self.tipsView setTransform:CGAffineTransformIdentity];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if(self.panDirection == TTMessageNotificationTipsMoveDirectionLeft || self.panDirection == TTMessageNotificationTipsMoveDirectionRight){
                // 根据手势松开时的方向决定消失气泡时的方向
                if(fabs(point.x) > kTTMessageNotificationTipsViewHorDismissBoundary){
                    if(point.x > 0){
                        [self animateForPanOutWithDirection:TTMessageNotificationTipsMoveDirectionRight];
                    }
                    else{
                        [self animateForPanOutWithDirection:TTMessageNotificationTipsMoveDirectionLeft];
                    }
                }
                else{
                    [self animateWithPanFailed];
                }
            }
            else if (self.panDirection == TTMessageNotificationTipsMoveDirectionDown){
                // 要求松手时一定是向下的
                if(point.y > 0 && point.y > kTTMessageNotificationTipsViewVerDismissBoundary){
                    [self animateForPanOutWithDirection:TTMessageNotificationTipsMoveDirectionDown];
                }
                else{
                    [self animateWithPanFailed];
                }
            }
            self.panDirection = TTMessageNotificationTipsMoveDirectionNone;
            self.panRun = NO;
        }
            break;
        default:
            break;
    }
}

- (void)changePandirectionWithPoint:(CGPoint) point{
    if(self.panDirection != TTMessageNotificationTipsMoveDirectionNone)
        return ;
    
    if(point.x < 0){
        self.panDirection = TTMessageNotificationTipsMoveDirectionLeft;
    }
    else if(point.x > 0){
        self.panDirection = TTMessageNotificationTipsMoveDirectionRight;
    }
    else if(point.y > 0){
        self.panDirection = TTMessageNotificationTipsMoveDirectionDown;
    }
}

- (void)animateWithPanFailed{
    // 手势失败时，先回原处，然后再判断定时器是否到时
    [UIView animateWithDuration:kTTMessageNotificationTipsViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        [self.tipsView setTransform:CGAffineTransformIdentity];
        self.tipsView.center = _oriCenter;
    } completion:^(BOOL finished) {
        if(![_timer isValid]){
            [self autoRemoveTipsView];
        }
    }];
}

//dir:手指松开时的移动方向
- (void)animateForPanOutWithDirection:(TTMessageNotificationTipsMoveDirection) dir{
    wrapperTrackEventWithCustomKeys(@"bubble", @"fade_flip", self.tipsView.msgID, nil,kTTMessageNotificationTrackExtra(self.tipsView.actionType));
    self.isFading = YES;
    if (dir == TTMessageNotificationTipsMoveDirectionLeft){
        [UIView animateWithDuration:kTTMessageNotificationTipsViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
            self.tipsView.right = 0;
        } completion:^(BOOL finished) {
            [self clearTipView];
        }];
    }
    else if (dir == TTMessageNotificationTipsMoveDirectionRight){
        [UIView animateWithDuration:kTTMessageNotificationTipsViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
            self.tipsView.left = _parentViewWidth;
        } completion:^(BOOL finished) {
            [self clearTipView];
        }] ;
    }
    else if(dir == TTMessageNotificationTipsMoveDirectionDown){
        [UIView animateWithDuration:kTTMessageNotificationTipsViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
            self.tipsView.top = _parentViewHeight;
        } completion:^(BOOL finished) {
            [self clearTipView];
        }];
    }
    else{
        self.isFading = NO;
    }
    
}

- (void)removeTipsView
{
    self.isFading = YES;
    
    [UIView animateWithDuration:kTTMessageNotificationTipsViewDismissDuration customTimingFunction:CustomTimingFunctionQuadraticEasyOut animation:^{
        self.tipsView.top = _parentViewHeight;
    } completion:^(BOOL finished) {
        [self clearTipView];
    }];
}


- (void)clearTipView{
    [_timer invalidate];
    _timer = nil;
    
    [self.tipsView removeFromSuperview];
    self.tipsView = nil;
    self.isShowingTips = NO;
    self.isFading = NO;
    
    [TTDialogDirector dequeueDialog:kTTMessageNotificationTipsDialogKey];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self clearTipView];
}

- (NSString *)lastImportantMessageID{
    NSString *lastMsgID= [[NSUserDefaults standardUserDefaults] objectForKey:kTTMessageNotificationLastTipSaveKey];
    return lastMsgID;
}

- (void)saveLastImportantMessageID{
    //不需要去重的，不用保存
    if (![self isNeedRemoveDuplicatingBubble]) {
        return;
    }
    if(isEmptyString([self msgID])){
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[self msgID] forKey:kTTMessageNotificationLastTipSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)lastListMaxCursor{
    id cursor = [[NSUserDefaults standardUserDefaults] objectForKey:kTTMessageNotificationLastListMaxCursorSaveKey];
    if([cursor isKindOfClass:[NSNumber class]]){
        return (NSNumber *)cursor;
    }
    return @(0);
}

- (void)saveLastListMaxCursor:(NSNumber *)cursor{
    //不需要去重的，不用保存
    if (![self isNeedRemoveDuplicatingBubble]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:cursor forKey:kTTMessageNotificationLastListMaxCursorSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 对外提供访问数据
- (NSUInteger)unreadNumber{
    return [self.tipsModel.total unsignedIntegerValue];
}

- (NSString *)tips{
    return self.tipsModel.tips;
}

- (NSString *)actionType{
    return self.tipsModel.actionType;
}

- (NSString *)userName{
    return self.tipsModel.important.userName;
}

- (NSString *)action{
    return self.tipsModel.important.action;
}

- (NSString *)thumbUrl{
    return self.tipsModel.important.thumbUrl;
}

- (NSString *)userAuthInfo{
    return self.tipsModel.important.userAuthInfo;
}

- (NSString *)msgID{
    return self.tipsModel.important.msgID;
}

- (BOOL)isImportantMessage{
    if(self.tipsModel.important){
        return YES;
    }
    return NO;
}

- (NSString *)lastImageUrl {
    return self.tipsModel.lastImageUrl;
}

- (NSString *)followChannelTips{
    return  self.tipsModel.followChannelTips;
}

- (BOOL)isNeedRemoveDuplicatingBubble{
    //不进消息列表的气泡，由服务端进行去重，该种气泡服务端保证只下发一次。此种气泡客户端不去重，避免出现下发两个相同进入消息列表的气泡中间下发不进列表的气泡，导致进入列表的气泡重复弹出。
    if (self.tipsModel.important.onlyBubble.intValue == 1) {
        return NO;
    }
    return YES;
}
@end
