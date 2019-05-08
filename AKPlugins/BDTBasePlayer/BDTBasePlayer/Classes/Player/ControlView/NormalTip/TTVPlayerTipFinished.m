//
//  TTVPlayerTipFinished.m
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import "TTVPlayerTipFinished.h"
#import "TTVPlayerStateStore.h"
#import "TTVPlayerSettingUtility.h"

NSString * const TTVPlayerFinishActionTypeNone = @"TTVPlayerFinishActionTypeNone";
NSString * const TTVPlayerFinishActionTypeShare = @"TTVPlayerFinishActionTypeShare";
NSString * const TTVPlayerFinishActionTypeReplay = @"TTVPlayerFinishActionTypeReplay";
NSString * const TTVPlayerFinishActionTypeMoreShare = @"TTVPlayerFinishActionTypeMoreShare";

NSString * const TTVPlayerFinishActionTypeDirectShare = @"TTVPlayerFinishActionTypeDirectShare";
NSString * const TTVPlayerFinishActionTypeDirectShareQQ  = @"TTVPlayerFinishActionTypeDirectShareQQ";
NSString * const TTVPlayerFinishActionTypeDirectSharePYQ = @"TTVPlayerFinishActionTypeDirectSharePYQ";
NSString * const TTVPlayerFinishActionTypeDirectShareWeixin = @"TTVPlayerFinishActionTypeDirectShareWeixin";
NSString * const TTVPlayerFinishActionTypeDirectShareQQZone = @"TTVPlayerFinishActionTypeDirectShareQQZone";

static const CGFloat kBtnW = 44;
static const CGFloat KMoreButtonCenterY = 22;

@interface TTVPlayerTipFinished ()

@property (nonatomic, strong) SSThemedButton *replayButton;
@property (nonatomic, strong) SSThemedButton *shareButton;
@property (nonatomic, strong) SSThemedLabel *replayLabel;
@property (nonatomic, strong) SSThemedLabel *shareLabel;
@property (nonatomic, strong) SSThemedButton *moreButton; //播放结束后，在详情页时展示

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat bannerHeight; // 兼容banner出现的情况

@end

@implementation TTVPlayerTipFinished

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
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
        [self addSubview:_backView];

        _containerView = [[UIView alloc] initWithFrame:_backView.bounds];
        [_backView addSubview:_containerView];

        //分享按钮
        _shareButton = [[SSThemedButton alloc] init];
        _shareButton.frame = CGRectMake(0, 0, kBtnW, kBtnW);
        _shareButton.imageName = @"Share";
        [_containerView addSubview:_shareButton];

        _shareLabel = [[SSThemedLabel alloc] init];
        _shareLabel.text = NSLocalizedString(@"分享", nil);
        _shareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _shareLabel.textColor = SSGetThemedColorWithKey(kColorText12);
        [_shareLabel sizeToFit];
        [_containerView addSubview:_shareLabel];

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
        
        //更多按钮
        [self ttv_addMoreButton];
        
        //播放结束相关
        [_shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_replayButton addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    CGFloat sepW = 22;
    _shareButton.center = CGPointMake(frame.size.width/2+sepW+CGRectGetWidth(_shareButton.frame)/2, CGRectGetHeight(frame)/2);
    _shareLabel.center = CGPointMake(_shareButton.center.x, CGRectGetMaxY(_shareButton.frame)+5+_shareLabel.frame.size.height);
    _replayButton.center = CGPointMake(frame.size.width/2-sepW-CGRectGetWidth(_replayButton.frame)/2, CGRectGetHeight(frame)/2);
    _replayLabel.center = CGPointMake(_replayButton.center.x, _shareLabel.center.y);

    _moreButton.center = CGPointMake(self.width - 24, KMoreButtonCenterY);
    if (self.playerStateStore.state.isInDetail) {
        _moreButton.hidden = NO;
    }else{
        _moreButton.hidden = YES;
    }
    [super layoutSubviews];
}

- (void)shareButtonClicked:(UIButton *)sender
{
    if (self.finishAction) {
        self.finishAction(TTVPlayerFinishActionTypeShare);
    }
    [self disableInterface:sender];
}

- (void)replayButtonClicked:(UIButton *)sender
{
    if (self.finishAction) {
        self.finishAction(TTVPlayerFinishActionTypeReplay);
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
    if ([TTVPlayerSettingUtility ttvs_isVideoShowOptimizeShare] > 0) {
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
