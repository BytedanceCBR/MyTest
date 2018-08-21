//
//  SSADSplashControllerView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-26.
//
//

#import "SSADSplashControllerView.h"
#import "SSADSplashView.h"
#import "SSADManager.h"
#import "SSADModel.h"
#import <QuartzCore/QuartzCore.h>

NSString *const kChangeMainControlerNotification = @"kChangeMainControlerNotification";

@interface SSADSplashControllerView()<SSADSplashViewDelegate>

@property (nonatomic, strong) SSADSplashView *splashView;
@property (nonatomic, assign) BOOL fullScreenShowFlag;
@property (nonatomic, strong) SSADModel *model;
@property (nonatomic, strong) UIImageView *bgImgaeView;
@property (nonatomic, strong) UIView      *topCover;  //遮住phoneX耳朵
@property (nonatomic, assign) UIEdgeInsets safeEdgeInsets;

@end

@implementation SSADSplashControllerView

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_splashView invalidPerform];
    self.splashView.delegate = nil;
    self.delegate = nil;
    self.splashView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame model:(SSADModel *)model
{
    self = [super initWithFrame:frame];
    if (self) {
        self.model = model;
        [self loadView];
        if (![SSCommonLogic shouldUseOptimisedLaunch]) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        [_splashView refreshModel:self.model];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [_splashView willAppear];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_splashView.window) {
        [_splashView refreshModel:self.model];
        [_splashView didAppear];
    }
}

- (void)loadView
{
    if (@available(iOS 11.0, *)) {
        self.safeEdgeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    } else {
        self.safeEdgeInsets = UIEdgeInsetsZero;
    }
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.backgroundColor = [UIColor blackColor];
    }
    else{
        self.backgroundColor = [UIColor clearColor];
    }
    [self loadBgImageView];
    self.splashView = [[SSADSplashView alloc] initWithFrame:CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, self.width - self.safeEdgeInsets.left - self.safeEdgeInsets.right, self.height - self.safeEdgeInsets.top)];
    _splashView.backgroundColor = [UIColor clearColor];
    _splashView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _splashView.delegate = self;
    [self addSubview:_splashView];
}

- (void)loadBgImageView
{
    _bgImgaeView = [SSADManager adSplashBgImageViewWithFrame:self.bounds];
    if ([TTDeviceHelper isPadDevice]) {
        _bgImgaeView.image = [UIImage imageNamed:@"LaunchImage-700-Portrait~ipad.png"];
        _bgImgaeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    _bgImgaeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_bgImgaeView];
    
    _topCover = [[UIView alloc] init];
    _topCover.backgroundColor = [UIColor blackColor];
    [self addSubview:_topCover];
    _topCover.hidden = YES;
}


- (SSADModel *)openActionModel
{
    if ([_splashView haveClickAction]) {
        return _splashView.model;
    }
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bgImgaeView.frame = self.bounds;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _topCover.hidden = NO;
        _topCover.frame = CGRectMake(0, 0, self.width, self.safeEdgeInsets.top);
    }
}

- (void)didDisappear
{
    [super didDisappear];
    [_splashView didDisappear];
}

#pragma mark -- SSADSplashViewDelegate

- (void)splashViewWithAction {
    if (_delegate && [_delegate respondsToSelector:@selector(splashControllerViewWithAction:)]) {
        [_delegate performSelector:@selector(splashControllerViewWithAction:) withObject:self.model];
    }
}

- (void)splashViewClickBackgroundAction {
    if (_delegate && [_delegate respondsToSelector:@selector(splashControllerViewClickBackgroundAction:)]) {
        [_delegate performSelector:@selector(splashControllerViewClickBackgroundAction:) withObject:self.model];
    }
}

- (void)splashViewShowFinished:(SSADSplashView *)splashView
{
    [_splashView willDisappear];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeMainControlerNotification object:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(splashControllerViewShowFinished:animation:)]) {
        [_delegate performSelector:@selector(splashControllerViewShowFinished:animation:) withObject:self withObject:nil];
    } else {
        NSLog(@"%@ delegate not implement", NSStringFromSelector(_cmd));
    }
    //此处不能再添加代码,保证delegate 是该方法内部最后执行的代码
}

@end
