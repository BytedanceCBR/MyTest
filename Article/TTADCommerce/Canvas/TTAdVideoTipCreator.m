//
//  TTAdVideoTipCreator.m
//  Article
//
//  Created by yin on 2017/9/26.
//

#import "TTAdVideoTipCreator.h"
#import "TTVPlayerTipFinished.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerSettingUtility.h"
#import "SSThemed.h"
#import "KVOController.h"
static const CGFloat kBtnW = 44;
static const CGFloat kPrePlayBtnBottom = 10;
static const CGFloat KMoreButtonCenterY = 22;

extern NSString * const TTVPlayerFinishActionTypeMoreShare;
extern NSString * const TTVPlayerFinishActionTypeReplay;

extern NSInteger ttvs_isVideoShowOptimizeShare(void);

@implementation TTAdVideoTipCreator

- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame
{
    return [[TTVPlayerTipLoading alloc] initWithFrame:frame];
}

- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame
{
    return [[TTVPlayerTipRetry alloc] initWithFrame:frame];
}

- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame
{
    return [[TTAdVideoTipFinished alloc] initWithFrame:frame];
}

@end

@interface TTAdVideoTipFinished()

@property (nonatomic, strong) SSThemedButton *replayButton;
@property (nonatomic, strong) SSThemedLabel *replayLabel;
@property (nonatomic, strong) SSThemedButton *moreButton; //播放结束后，在详情页时展示
@property (nonatomic, strong) SSThemedButton *prePlayBtn; // 播放上一个 按钮

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat bannerHeight; // 兼容banner出现的情况

@end

@implementation TTAdVideoTipFinished


- (void)dealloc
{
    [self.playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setPlayerStateStore:(TTVPlayerStateStore *)playerStateStore
{
    if (_playerStateStore != playerStateStore) {
        [self.KVOController unobserve:self.playerStateStore.state];
        [_playerStateStore unregisterForActionClass:[TTVPlayerStateAction class] observer:self];
        _playerStateStore = playerStateStore;
        [_playerStateStore registerForActionClass:[TTVPlayerStateAction class] observer:self];
        [self ttv_kvo];
    }
}

- (void)ttv_kvo
{
    @weakify(self);
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isFullScreen) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        [self setNeedsLayout];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,bannerHeight) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.bannerHeight = self.playerStateStore.state.bannerHeight;
        [self setNeedsLayout];
    }];
    
    [self.KVOController observe:self.playerStateStore.state keyPath:@keypath(self.playerStateStore.state,isInDetail) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        @strongify(self);
        self.moreButton.hidden = !self.playerStateStore.state.isInDetail;
    }];
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bannerHeight = 0;
        //背景view
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [self addSubview:_backView];
        
        _containerView = [[UIView alloc] initWithFrame:_backView.bounds];
        [_backView addSubview:_containerView];
        
        //重播按钮
        _replayButton = [[SSThemedButton alloc] init];
        _replayButton.frame = CGRectMake(0, 0, kBtnW, kBtnW);
        _replayButton.imageName = @"Replay";
        [_containerView addSubview:_replayButton];
        
        _replayLabel = [[SSThemedLabel alloc] init];
        _replayLabel.text = NSLocalizedString(@"重播", nil);
        _replayLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _replayLabel.textColor = SSGetThemedColorWithKey(kColorText12);
        [_replayLabel sizeToFit];
        [_containerView addSubview:_replayLabel];
        
        UIImage *img = [UIImage imageNamed:@"pre_play"];
        _prePlayBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _prePlayBtn.hidden = YES;
        _prePlayBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_prePlayBtn setImage:img forState:UIControlStateNormal];
        NSString *text = ([TTVPlayerSettingUtility tt_video_detail_playlast_showtext]) ? NSLocalizedString(@"上一个", nil): @"";
        [_prePlayBtn setTitle:text forState:UIControlStateNormal];
        [_prePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText12] forState:UIControlStateNormal];
        [_prePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText12Highlighted] forState:UIControlStateHighlighted];
        _prePlayBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [_prePlayBtn layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2.f];
        [_prePlayBtn sizeToFit];
        [_containerView addSubview:_prePlayBtn];
        
        //更多按钮
        [self ttv_addMoreButton];
        
        [_replayButton addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_prePlayBtn addTarget:self action:@selector(prePlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}


- (void)layoutSubviews
{
    _backView.frame = self.bounds;
    _containerView.frame = _backView.frame;
    _containerView.height -= _bannerHeight;
    
    CGRect frame = _containerView.frame;
    
    _replayButton.center = CGPointMake(frame.size.width/2, CGRectGetHeight(frame)/2);
    _replayLabel.center = CGPointMake(_replayButton.center.x, CGRectGetMaxY(_replayButton.frame)+5+_replayLabel.frame.size.height);
    
    _prePlayBtn.frame = CGRectMake(12, _containerView.height - kPrePlayBtnBottom - _prePlayBtn.frame.size.height, 60, _prePlayBtn.frame.size.height);
    _prePlayBtn.centerY = CGRectGetHeight(frame) - _prePlayBtn.height / 2 - kPrePlayBtnBottom;
    
    _moreButton.center = CGPointMake(self.width - 24, KMoreButtonCenterY);
    if (self.playerStateStore.state.isInDetail) {
        _moreButton.hidden = NO;
    }else{
        _moreButton.hidden = YES;
    }
    [super layoutSubviews];
}


- (void)replayButtonClicked:(UIButton *)sender
{
    if (self.finishAction) {
        self.finishAction(TTVPlayerFinishActionTypeReplay);
    }
    [self disableInterface:sender];
}

- (void)prePlayBtnClicked:(UIButton *)sender
{
    if (self.finishAction) {
//        self.finishAction(TTVPlayerFinishActionTypePrePlay);
    }
    [self disableInterface:sender];
}


- (void)moreButtonClicked:(UIButton *)sender
{
    if (self.finishAction) {
        self.finishAction(TTVPlayerFinishActionTypeMoreShare);
    }
    [self disableInterface:sender];
}
- (void)disableInterface:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
}

- (void)ttv_addMoreButton
{
    if (ttvs_isVideoShowOptimizeShare() > 0) {
        self.moreButton = [[SSThemedButton alloc] init];
        _moreButton.backgroundColor = [UIColor clearColor];
        _moreButton.width = 24.f;
        _moreButton.height = 24.f;
        [_moreButton setImage:[UIImage imageNamed:@"new_morewhite_titlebar"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"new_morewhite_titlebar"] forState:UIControlStateHighlighted];
        _moreButton.imageView.center = CGPointMake(_moreButton.frame.size.width/2, _moreButton.frame.size.height/2);
        [_moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_containerView addSubview:_moreButton];
    }else{
        self.moreButton = nil;
    }
}

@end
