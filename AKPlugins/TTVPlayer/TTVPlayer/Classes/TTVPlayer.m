//
//  TTVPlayer.m
//  Article
//
//  Created by lisa on 2018/3/1.
//

#import "TTVPlayer.h"
#import "TTVPlayer+Engine.h"
#import "TTVPlayer+Part.h"
#import "TTVPlayer+BecomeResignActive.h"
#import "TTVAudioSessionManager.h"
#import "TTVPlayer+CacheProgress.h"
#import "TTVPlayerReducer.h"
#import "TTVPlayerAction.h"
#import "TTVideoIdleTimeService.h"
#import "TTVLoadingReducer.h"
#import "TTVSeekReducer.h"
#import "TTVNetworkMonitorReducer.h"
#import "TTVSpeedReducer.h"

static NSPointerArray *playersArray = nil;

/// config
static NSMutableDictionary<NSString *, NSDictionary *> * configDict;// 用来保存配置的

@interface TTVPlayer () <TTVPlayerGestureContainerViewDelegate>

#pragma mark - View
@property (nonatomic, strong) TTVPlayerGestureContainerView  *containerView;
#pragma mark - part
@property (nonatomic, strong) TTVReduxStore*        playerStore;
@property (nonatomic, strong) TTVPlayerAction*      playerAction;
@property (nonatomic, weak)   TTVPlayerPartManager  *basePart;  // 做一些通用 part相关功能的类
@property (nonatomic, copy)   NSString              *customConfigName;
@property (nonatomic, strong) NSBundle              *customBundle;
@property (nonatomic, assign) TTVPlayerStyle        style;

@end

@implementation TTVPlayer

@dynamic playerView;

#pragma mark - life
+ (void)initialize {
    playersArray = [NSPointerArray weakObjectsPointerArray];
    configDict = @{}.mutableCopy;
}

- (instancetype)init {
    return [self initWithOwnPlayer:NO];
}

- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer {
    self = [super init];
    if (self) {
        // core
        [self initializeEngineWithOwnPlayer:isOwnPlayer];
        
        _supportPlaybackControlAutohide = YES;
        _showPlaybackControlsOnViewFirstLoaded = YES;

        // player management
        [playersArray addPointer:(__bridge void *)(self)];

        // 创建 store
        _playerStore = [[TTVReduxStore alloc] initWithReducer:[[TTVReduxReducer alloc] init] state:[[TTVPlayerState alloc] init]];
        _playerAction = [[TTVPlayerAction alloc] initWithPlayer:self];
        
        // 配置 reducer, 是不是创建 part 的时候进行配置呢，base 提供此处的管理功能
        TTVPlayerReducer * playReducer = [[TTVPlayerReducer alloc] initWithPlayer:self];
        [_playerStore setSubReducer:playReducer forKey:@"TTVPlayerReducer"];
        [_playerStore setSubReducer:[[TTVLoadingReducer alloc] initWithPlayer:self] forKey:@"TTVLoadingReducer"];
        [_playerStore setSubReducer:[[TTVSeekReducer alloc] initWithPlayer:self] forKey:@"TTVSeekReducer"];
        [_playerStore setSubReducer:[[TTVNetworkMonitorReducer alloc] initWithPlayer:self] forKey:@"TTVNetworkMonitorReducer"];
        [_playerStore setSubReducer:[[TTVSpeedReducer alloc] initWithPlayer:self] forKey:@"TTVSpeedReducer"];
        
        // 前后台
        [self addBackgroundObserver];
        
        [self addTerminateNotification];
    }
    return self;
}

- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer configFileName:(NSString *)configFileName {
    self = [self initWithOwnPlayer:isOwnPlayer configFileName:configFileName bundle:[NSBundle mainBundle]];
    return self;
}

- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer configFileName:(NSString *)configFileName bundle:(NSBundle *)bundle {
    self = [self initWithOwnPlayer:isOwnPlayer];
    if (self) {
        if (!isEmptyString(configFileName) && bundle) {
            self.customBundle = bundle;
            self.customConfigName = configFileName;
            
            // base
            // 默认创建一个 base part 来做一些挂了你 part 的工作
            self.basePart = [self createPartManager];
            [_playerStore subscribe:_basePart];
            self.basePart.player = self;
            self.basePart.playerStore = _playerStore;
            self.basePart.playerAction = _playerAction;
        }
    }
    return self;
}

- (instancetype)initWithOwnPlayer:(BOOL)isOwnPlayer style:(TTVPlayerStyle)style {
    NSString * configFileName;
    switch (style) {
        case TTVPlayerStyle_Simple_NoRotate:
            configFileName = @"TTVPlayerStyle-SimpleNoRotate.plist";
            break;
        case TTVPlayerStyle_Simple_CanRotate:
            configFileName = @"TTVPlayerStyle-SimpleCanRotate.plist";
            break;
        case TTVPlayerStyle_XiGua:
            configFileName = @"TTVPlayerStyle-XiGua.plist";
            break;
        case TTVPlayerStyle_None:
            break;
    }

    self = [self initWithOwnPlayer:isOwnPlayer configFileName:configFileName bundle:[NSBundle bundleWithPath:TTVPlayerBundlePath]];
    if (self) {
        _style = style;
    }
    return self;
}

- (void)dealloc {
#if DEBUG
    Debug_NSLog(@"TTVPlayer dealloc  ***************** GOOD  ***************");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self deallocEngine];
    if ([[self class] allActivePlayers].count < 1) {
        [[TTVideoIdleTimeService sharedService] lockScreen:YES later:YES];
        [[TTVAudioSessionManager sharedInstance] setActive:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // factory
    [TTVPlayerControlViewFactory sharedInstance].customViewDelegate = self.customViewDelegate;
    
    if (!configDict[self.customConfigName] && self.customBundle) {
        configDict[self.customConfigName] = [NSDictionary dictionaryWithContentsOfFile:[self.customBundle pathForResource:self.customConfigName ofType:nil]];
    }
    self.basePart.customBundle = self.customBundle;
    [self.basePart setPlayerConfigData:configDict[self.customConfigName]];
    
    self.view.tag = TTVPlayerView_Tag;
    self.view.backgroundColor = [UIColor clearColor]; // 默认设置成白色，不透出底部
    
    // 有问题，会盖住
    [self.view addSubview:self.playerView];
    self.playerView.backgroundColor = [UIColor blackColor]; // playerView的背景应该是黑色
    self.view.clipsToBounds = YES;
    self.playerView.frame = self.view.bounds;

    // 设置音频
    if (self.enableAudioSession) {
        [[TTVAudioSessionManager sharedInstance] setCategory:AVAudioSessionCategoryPlayback];
        [[TTVAudioSessionManager sharedInstance] setActive:YES];
    }

    // 创建 container view
    self.containerView = [[TTVPlayerGestureContainerView alloc] initWithFrame:self.view.bounds];
    self.containerView.delegate = self;
    [self.view addSubview:self.containerView];
    self.containerView.playerStore = self.playerStore;
    self.containerView.player = self;
    self.containerView.customBundle = self.customBundle;
    [self.playerStore subscribe:self.containerView];
    
    // 加载 view
    [self.basePart viewDidLoad:self];
    self.basePart.viewDidLoaded = YES;

    // 代理
    if ([self.delegate respondsToSelector:@selector(viewDidLoad:state:)]) {
        [self.delegate viewDidLoad:self state:(TTVPlayerState *)self.playerStore.state];
    }
    
    // 是否要出现 control
    if (self.showPlaybackControlsOnViewFirstLoaded) {
        [self.containerView showControl:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"center"]) {
        NSLog(@"%@",self.containerView.frame);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // 默认不设置 playerView 的 frame
    self.containerView.frame = self.view.bounds;
    self.playerView.frame = self.view.bounds;
    
    // 调用布局
    switch (self.style) {
        case TTVPlayerStyle_Simple_NoRotate:
            [self layoutForSimpleRotateStyle];
            break;
        case TTVPlayerStyle_Simple_CanRotate:
            [self layoutForSimpleRotateStyle];
            break;
        case TTVPlayerStyle_XiGua:
            [self layoutForXiGuaStyle];
            break;
        case TTVPlayerStyle_None:
            break;
    }
    
    // 外界可以布局
    if ([self.delegate respondsToSelector:@selector(playerViewDidLayoutSubviews:state:)]) {
        [self.delegate playerViewDidLayoutSubviews:self state:(TTVPlayerState *)self.playerStore.state];
    }
}

- (void)layoutForSimpleNoRotateStyle {
    
    UIView *navigationBar = [self partControlForKey:TTVPlayerPartControlKey_TopBar];
    navigationBar.width = self.controlView.width;
    navigationBar.height = 130;
    navigationBar.top = 0;
    navigationBar.left = 0;
    
    UIView * lock = [self partControlForKey:TTVPlayerPartControlKey_LockToggledButton];
    [lock sizeToFit];
    
    UIView *backButton = [self partControlForKey:TTVPlayerPartControlKey_BackButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@16);
        make.width.height.equalTo(@24);
    }];
    
    UIView *titleLabel = [self partControlForKey:TTVPlayerPartControlKey_TitleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backButton.mas_right).offset(10);
        make.centerY.equalTo(backButton);
    }];
    
    // bottom toolbar
    UIView *toolbar = [self partControlForKey:TTVPlayerPartControlKey_BottomBar];
    if (!toolbar) {
        return;
    }
    
    toolbar.width = self.controlView.width;
    toolbar.height = 130;
    toolbar.top = self.controlView.height - toolbar.height;
    toolbar.left = 0;
    
    UIView * lockButton = [self partControlForKey:TTVPlayerPartControlKey_LockToggledButton];
    lockButton.center = self.view.center;
    lockButton.left = 50;
    
    UIView * bottomPlayButton = [self partControlForKey:TTVPlayerPartControlKey_PlayBottomToggledButton];
    if (bottomPlayButton) {
        [bottomPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(toolbar).offset(20);
            make.bottom.equalTo(toolbar).offset(-20);
            make.width.height.equalTo(@24);
        }];
        [bottomPlayButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        UIView *currentTimeLabel = [self partControlForKey:TTVPlayerPartControlKey_TimeCurrentLabel];
        [currentTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bottomPlayButton.mas_right).offset(20);
            make.centerY.equalTo(bottomPlayButton);
        }];
        
        UIView *slider = [self partControlForKey:TTVPlayerPartControlKey_Slider];
        [slider setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(currentTimeLabel.mas_right).offset(12);
            make.centerY.equalTo(bottomPlayButton);
            make.height.equalTo(@(24));// TODO, 会影响默认高度
        }];
        
        UIView *totalTimeLabel = [self partControlForKey:TTVPlayerPartControlKey_TimeTotalLabel];
        [totalTimeLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(slider.mas_right).offset(12);
            make.centerY.equalTo(bottomPlayButton);
            make.right.equalTo(toolbar).offset(-20);
        }];
    }
}

- (void)layoutForSimpleRotateStyle {
    BOOL fullScreen = ((TTVPlayerState *)self.playerStore.state).fullScreenState.fullScreen;
    CGRectEdge leftEdge = fullScreen ? 20 : 12;
    CGRectEdge topEdge = 12;
    
    UIView *topBar = [self partControlForKey:TTVPlayerPartControlKey_TopBar];
    topBar.width = topBar.superview.width;
    topBar.height = fullScreen ? 130 : 70;
    topBar.left = 0;
    topBar.top = 0;
    
    UIView * defaultBackButton = [self partControlForKey:TTVPlayerPartControlKey_BackButton];
    UIView * defaultTitleLable = [self partControlForKey:TTVPlayerPartControlKey_TitleLabel];
    [defaultTitleLable sizeToFit];
    
    UIView * playCenter = [self partControlForKey:TTVPlayerPartControlKey_PlayCenterToggledButton];
    [playCenter sizeToFit];
    playCenter.center = CGPointMake(self.view.width / 2.0, self.view.height / 2.0);
    
    if (fullScreen) {
        defaultBackButton.size = CGSizeMake(24, 24);
        defaultBackButton.top = 32;
        defaultBackButton.left = 12;
        defaultTitleLable.frame = CGRectMake(defaultBackButton.right, 0, self.view.width - 2 * leftEdge, defaultTitleLable.height);
        defaultTitleLable.centerY = defaultBackButton.centerY;
    }else{
        defaultTitleLable.frame = CGRectMake(leftEdge, topEdge, self.view.width - 2 * leftEdge, defaultTitleLable.height);
    }
    
    UIEdgeInsets safeInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        if (fullScreen) {
            safeInset = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets;
        }
    }
    
    UIView *toolbar = [self partControlForKey:TTVPlayerPartControlKey_BottomBar];
    toolbar.width = self.view.width;
    toolbar.height = fullScreen ? 130 : 70;
    toolbar.left = 0;
    toolbar.bottom = self.view.height;
    
    UIView *currentTimeLabel = [self partControlForKey:TTVPlayerPartControlKey_TimeCurrentLabel];
    UIView *slider = [self partControlForKey:TTVPlayerPartControlKey_Slider];
    UIView *totalTimeLabel = [self partControlForKey:TTVPlayerPartControlKey_TimeTotalLabel];
    UIView *fullScreenBtn = [self partControlForKey:TTVPlayerPartControlKey_FullToggledButton];
    //只有进度条 ，全屏功能的时候
    [currentTimeLabel sizeToFit];
    currentTimeLabel.left = leftEdge;
    currentTimeLabel.centerY = (toolbar.height - safeInset.bottom - (fullScreen ? 25.5 : 16));
    
    NSInteger right = 0;
    fullScreenBtn.hidden = fullScreen == YES;
    if (fullScreenBtn && !fullScreenBtn.hidden) {
        fullScreenBtn.width = 32;
        fullScreenBtn.height = 32;
        fullScreenBtn.right = toolbar.width - 10;
        fullScreenBtn.centerY = currentTimeLabel.centerY;
        right = fullScreenBtn.left;
    }else{
        right = self.view.width - leftEdge;
    }
    
    [totalTimeLabel sizeToFit];
    totalTimeLabel.right = right - 10;
    totalTimeLabel.centerY = currentTimeLabel.centerY;
    
    NSInteger sliderEdge = 8;
    slider.width = totalTimeLabel.left - sliderEdge * 2 - currentTimeLabel.right;
    slider.height = 12;
    slider.left = currentTimeLabel.right + sliderEdge;
    slider.centerY = currentTimeLabel.centerY;
}

- (void)layoutForXiGuaStyle {
    
}

- (void)containerViewLayoutSubviews:(TTVPlayerGestureContainerView *)containerView {
    // 布局
    [self.basePart viewDidLayoutSubviews:self];
    if ([self.delegate respondsToSelector:@selector(playerViewDidLayoutSubviews:state:)]) {
        [self.delegate playerViewDidLayoutSubviews:self state:(TTVPlayerState *)self.playerStore.state];
    }
}

#pragma mark - ****************** UI ********************
- (TTVPlaybackControlView *)controlView {
    return self.containerView.playbackControlView;
}
- (TTVPlaybackControlView *)controlViewLocked {
    return self.containerView.playbackControlView_Lock;
}
- (UIView *)controlOverlayView {
    return self.containerView.controlOverlayView;
}
- (UIView *)controlUnderlayView {
    return self.containerView.controlUnderlayView;
}
- (void)addViewOverlayPlaybackControls:(UIView *)view {
    [self.containerView.controlOverlayView addSubview:view];
}
- (void)addPlaybackControl:(UIView *)view addToContainer:(NSString *)containerString {
    if ([containerString isEqualToString:TTVPlayerPartControlType_TopNavBar] ) { // 添加到 bottom
        [self.controlView.topBar addSubview:view];
    }
    else if ([containerString isEqualToString:TTVPlayerPartControlType_BottomToolBar]) { // 添加到 top
        [self.controlView.bottomBar addSubview:view];
    }
    else if (isEmptyString(containerString) || [containerString isEqualToString:TTVPlayerPartControlType_Content]) {
        // 加载到 playbackControl 的 contentView 上
        [self.controlView.contentView addSubview:view];
    }
}
- (void)addPlaybackControlLocked:(UIView *)view addToContainer:(NSString *)containerString {
    if ([containerString isEqualToString:TTVPlayerPartControlType_TopNavBar] ) { // 添加到 bottom
        [self.controlViewLocked.topBar addSubview:view];
    }
    else if ([containerString isEqualToString:TTVPlayerPartControlType_BottomToolBar]) { // 添加到 top
        [self.controlViewLocked.bottomBar addSubview:view];
    }
    else if (isEmptyString(containerString) || [containerString isEqualToString:TTVPlayerPartControlType_Content]) {
        // 加载到 playbackControl 的 contentView 上
        [self.controlViewLocked.contentView addSubview:view];
    }
}
- (void)addViewUnderlayPlaybackControls:(UIView *)view {
    [self.containerView.controlUnderlayView addSubview:view];
}
- (UIView *)partControlForKey:(TTVPlayerPartControlKey)key {
    return [self.view viewWithTag:key];
}
#pragma mark - ******************* player managment *******************

- (void)removePlayer {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [self didMoveToParentViewController:nil];
}

+ (NSArray *)allActivePlayers {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (TTVPlayer *player in playersArray.allObjects) {
        if (player && ![player isKindOfClass:[NSNull class]]) {
            [resultArray addObject:player];
        }
    }
    return resultArray;
}
#pragma mark - getters && setters
- (void)setVideoTitle:(NSString *)videoTitle {
    _videoTitle = [videoTitle copy];
    TTVReduxAction *action = [[TTVReduxAction alloc] initWithType:TTVPlayerActionType_VideoTitleChanged];
    [self.playerStore dispatch:action];
}

- (void)setCustomViewDelegate:(NSObject<TTVPlayerCustomViewDelegate> *)customViewDelegate {
    [TTVPlayerControlViewFactory sharedInstance].customViewDelegate = customViewDelegate;
}
- (NSObject<TTVPlayerCustomViewDelegate> *)customViewDelegate {
    return [TTVPlayerControlViewFactory sharedInstance].customViewDelegate;
}

@end

