//
//  TTVControlManager.m
//  Article
//
//  Created by panxiang on 2018/8/29.
//

#import "TTVControlManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <objc/runtime.h>
#import "TTVPlayerState.h"
#import "TTVPlayer.h"
#import "TTVPlayerControlView.h"
#import "TTVPlayerStateControlPrivate.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "TTVPlayerStateFullScreen.h"

@interface TTVControlManager ()//<TTVPlayerControlViewDelegate>

@property (nonatomic, assign) BOOL monitorGuideAttention;
@property (nonatomic, weak) UIView <TTVPlayerControlViewProtocol> *controlView;
@property (nonatomic, assign) BOOL showWhenReadyToplay;
@end

@implementation TTVControlManager

@synthesize store = _store;

- (instancetype)initWithControlView:(UIView<TTVPlayerControlViewProtocol> *)controlView {
    self = [super init];
    if (self) {
        self.controlView = controlView;
    }
    return self;
}

- (void)controlViewHidden:(BOOL)hidden
{
    self.controlView.backgroundColor = hidden ? [UIColor clearColor] : [UIColor colorWithWhite:0.0 alpha:0.12f];
    self.controlView.containerView.hidden = hidden;
    self.controlView.controlsOverlayView.hidden = hidden;
    self.controlView.controlsUnderlayView.hidden = hidden;
}

- (void)showControlView:(BOOL)show
{
    self.showWhenReadyToplay = show;
    [self controlViewHidden:!show];
    self.store.state.control.isShowing = show;
}

- (void)registerPartWithStore:(TTVPlayerStore *)store
{
    if (store == self.store) {
        if (!self.controlView) {
            TTVPlayerControlView *controlView = [[TTVPlayerControlView alloc] init];
//            controlView.delegate = self;
            self.controlView = controlView;
            [self showControlView:NO];
            [self.store.player setValue:self.controlView forKey:@"controlView"];
        }
        
        @weakify(self);
        [self.store subscribe:^(id<TTVRActionProtocol> action, id<TTVRStateProtocol> state) {
            @strongify(self);
            if ([action.type isEqualToString:TTVPlayerActionTypeVideoEngineDidFinish] ||
                [action.type isEqualToString:TTVPlayerActionTypeVideoEngineUserStopped]) {
                    self.store.state.control.isShowing = NO;
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeDoubleTapClick]) {
                [self doubleTapClick];
            }else if ([action.type isEqualToString:TTVGestureManagerActionTypeSingleTapClick]) {
                [self singleTapClick];
                void(^controlShowingBySingleTap)(void) = (void(^)(void))[action.info valueForKey:@"controlShowingBySingleTap"];
                controlShowingBySingleTap();
            }else if ([action.type isEqualToString:TTVPlayerActionTypeClickResolutionButton]) {
                NSDictionary *dic = action.info;
                if (dic[TTVPlayerActionTypeClickResolutionButtonKeyIsShowing]) {
                    self.store.state.control.isShowing = [dic[TTVPlayerActionTypeClickResolutionButtonKeyIsShowing] boolValue];
                }
            }else if ([action.type isEqualToString:TTVPlayerActionTypeChangeResolution]) {
                self.store.state.control.isShowing = NO;
            }
            

        }];
        [self ttv_bindsObserve];
    }
}

- (void)ttv_bindsObserve {
    if (self.showWhenReadyToplay) {
        RAC(self.store.state.control, isShowing) = RACObserve(self.store.player, readyForRender);
    }
    RAC(self.store.state.control, isShowing) = [[RACObserve(self.store.state.error, isShowing) skip:1] map:^id _Nullable(id  _Nullable value) {
        return @(!self.store.state.error.isShowing);
    }];
    
    //当 isShowing, !showPlayButton, 清晰度!showing，!isDragging 时，才启动 hide
    NSArray *combinedObservers = @[RACObserve(self.store.state.control, isShowing),
                                   RACObserve(self.store.state.play, showPlayButton),
                                   RACObserve(self.store.state.resolution, isShowing),
                                   RACObserve(self.store.state.control, isDragging)];
    @weakify(self);
    [[RACSignal combineLatest:combinedObservers reduce:^{
        @strongify(self);
        TTVPlayerStateControl *control = self.store.state.control;
        BOOL result = control.isShowing && !self.store.state.play.showPlayButton && !self.store.state.resolution.isShowing && !control.isDragging;
        return @(result);
    }] subscribeNext:^(NSNumber *hidden) {
        [self ttv_autoHidden:[hidden boolValue]];
    }];
    
    [RACObserve(self.store.state.control, isShowing) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self controlViewHidden:![x boolValue]];
    }];
//    [RACObserve(self.store.state.fullScreen, isFullScreen) subscribeNext:^(id  _Nullable x) {
//        @strongify(self);
//        [self.controlView performSelector:@selector(setIsFullScreen) withObject:@(self.store.state.fullScreen.isFullScreen)];
////        [self.controlView setIsFullScreen:self.store.state.fullScreen.isFullScreen];
//    }];
}

- (void)layoutSubviews
{
    CGFloat leftMargin = 0.0f;
    BOOL isIPhoneXDevice = [TTDeviceHelper isIPhoneXSeries];
    CGFloat statusBarHeight = 44.0f; // iPhoneX刘海高度

    if (isIPhoneXDevice && self.store.state.fullScreen.isFullScreen && !self.store.state.fullScreen.supportsPortaitFullScreen) {
        leftMargin += statusBarHeight; // 播放控件左边需要留出刘海空间
    }
    self.controlView.width = self.controlView.superview.bounds.size.width - 2 * leftMargin;
    self.controlView.left = leftMargin;
    
    self.store.player.controlView.controlsUnderlayView.width = self.controlView.width;
    self.store.player.controlView.controlsUnderlayView.left = leftMargin;
    
    self.store.player.controlView.controlsOverlayView.width = self.controlView.width;
    self.store.player.controlView.controlsOverlayView.left = leftMargin;
}

- (void)ttv_autoHidden:(BOOL)hidden {
    if (hidden) {
        //3s后自动消失
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttv_setShowing:) object:nil];
        [self performSelector:@selector(ttv_setShowing:) withObject:@(NO) afterDelay:3];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttv_setShowing:) object:@(NO)];
    }
}

- (void)ttv_setShowing:(NSNumber *)show
{
    self.store.state.control.isShowing = [show boolValue];
}

- (void)singleTapClick
{
    self.store.state.control.isShowing = !self.store.state.control.isShowing;
}

- (void)doubleTapClick
{
    
}


- (BOOL)isFullScreen
{
    return self.store.state.fullScreen.isFullScreen;
}

- (CGFloat)duration
{
    return self.store.player.duration;
}

- (TTVPlayerSource)source
{
    return self.store.state.model.source;
}

- (NSDictionary *)logPb
{
    return self.store.state.model.logPb;
}

- (NSString *)categoryID
{
    return self.store.state.model.categoryID;
}

- (BOOL)isInDetail
{
    return self.store.state.model.source == TTVPlayerSourceDetail;
}

@end

