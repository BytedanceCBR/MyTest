//
//  ExploreMoviePlayerControlTipView.m
//  Article
//
//  Created by Chen Hong on 15/9/21.
//
//

#import "ExploreMoviePlayerControlTipView.h"
#import "ExploreMovieLoadingView.h"
#import "ExploreMoviePlayerControlView.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@interface ExploreMoviePlayerControlTipView ()
@property (nonatomic, assign) BOOL hiddenRetryBtnInTypeRetryIfNeed;
@end

@implementation ExploreMoviePlayerControlTipView

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backView];
        _backView.hidden = YES;
        
        CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 15.0 : 13.0;
        
        self.userInteractionEnabled = NO;
        self.loadingView = [[ExploreMovieLoadingView alloc] init];
        _loadingView.backgroundColor = [UIColor clearColor];
        _loadingView.hidden = YES;
        [self addSubview:_loadingView];
        
        self.liveTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _liveTipLabel.backgroundColor = [UIColor clearColor];
        _liveTipLabel.font = [UIFont systemFontOfSize:fontSize];
        _liveTipLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _liveTipLabel.textAlignment = NSTextAlignmentCenter;
        _liveTipLabel.numberOfLines = 1;
        _liveTipLabel.hidden = YES;
        [self addSubview:_liveTipLabel];
        
        self.liveImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finish_live_video"]];
        [self addSubview:self.liveImageView];
        
        self.retryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _retryLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _retryLabel.font = [UIFont systemFontOfSize:14.f];
        _retryLabel.text = @"视频加载失败";
        [_retryLabel sizeToFit];
        [_backView addSubview:_retryLabel];
        _retryLabel.hidden = YES;
        
        self.retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 28)];
        [_retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_retryButton setTitleColor:[UIColor tt_defaultColorForKey:kColorText12] forState:UIControlStateNormal];
        _retryButton.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine12].CGColor;
        _retryButton.layer.borderWidth = 1;
        _retryButton.layer.cornerRadius = 6;
        _retryButton.layer.masksToBounds = YES;
        [_backView addSubview:_retryButton];
        _retryButton.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_forbidLayout) {
        return;
    }
    [self updateFrame];
}

- (void)updateFrame {
    self.backView.frame = CGRectMake((self.width - self.movieControlView.width) / 2, (self.height - self.movieControlView.height) / 2, self.movieControlView.width, self.movieControlView.height);
    CGFloat height = _retryLabel.height + 14 + _retryButton.height;
    if (_hiddenRetryBtnInTypeRetryIfNeed) {
        _retryLabel.centerY = _backView.height / 2;
        _retryLabel.centerX = _backView.width / 2;

    }else{
        _retryLabel.top = (_backView.height - height) / 2;
        _retryLabel.centerX = _backView.width / 2;
        _retryButton.top = _retryLabel.bottom + 14;
        _retryButton.centerX = _retryLabel.centerX;

    }
    CGRect frame = self.frame;
    _loadingView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    _liveImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2 - 14);
    [_liveTipLabel sizeToFit];
    [_retryLabel sizeToFit];
    _liveTipLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2 + 14);
}

- (ExploreMoviePlayerControlViewTipType)tipType
{
    return _tipType;
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    self.loadingView.isFullScreen = isFullScreen;
    CGFloat fontSize = isFullScreen ? 17.f : 14.f;
    _retryLabel.font = [UIFont systemFontOfSize:fontSize];
    CGRect rect = isFullScreen ? CGRectMake(0, 0, 108, 42) : CGRectMake(0, 0, 72, 28);
    _retryButton.frame = rect;
    _retryButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [_retryLabel sizeToFit];
}

- (BOOL)hasTipType
{
    return _tipType != ExploreMoviePlayerControlViewTipTypeNotAssign;
}

- (void)_refreshType:(ExploreMoviePlayerControlViewTipType)type andTipString:(NSString *)tipString
{
    if (!tipString) {
        tipString = @"视频加载失败";
        _hiddenRetryBtnInTypeRetryIfNeed = NO;
    }else{
        _hiddenRetryBtnInTypeRetryIfNeed = YES;
    }
    _tipType = type;
    
    _backView.hidden = YES;
    _retryLabel.hidden = YES;
    _retryButton.hidden = YES;
    
    //加载中
    if (type == ExploreMoviePlayerControlViewTipTypeLoading) {
        
        self.userInteractionEnabled = NO;
        _loadingView.hidden = NO;
        _retryButton.hidden = YES;
        _liveTipLabel.hidden = YES;
        _liveImageView.hidden = YES;
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.24];
        _backView.hidden = NO;
    }
    //加载失败重新加载
    else if (type == ExploreMoviePlayerControlViewTipTypeRetry) {
        if (tipString) {
            _retryLabel.text = tipString;
            CGRect retryLabelFrame = _retryLabel.frame;
            CGRect rect = [tipString boundingRectWithSize:CGSizeMake(_backView.width, _retryLabel.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:_retryLabel.font}
                                                  context:nil];
            _retryLabel.frame = CGRectMake(retryLabelFrame.origin.x, retryLabelFrame.origin.y, rect.size.width, retryLabelFrame.size.height);
            [self updateFrame];
        }
        self.userInteractionEnabled = YES;
        _loadingView.hidden = YES;
        _retryButton.hidden = _hiddenRetryBtnInTypeRetryIfNeed;
        _liveTipLabel.hidden = YES;
        _liveImageView.hidden = YES;
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _retryLabel.hidden = NO;;
        _backView.hidden = NO;
    }
    //直播等待
    else if (type == ExploreMoviePlayerControlViewTipTypeLiveWaiting) {
        
        self.userInteractionEnabled = YES;
        _loadingView.hidden = YES;
        _retryButton.hidden = NO;
        _liveTipLabel.hidden = NO;
        _liveTipLabel.text = @"直播马上开始,不要走开哦";
        _liveImageView.hidden = NO;
        
    }
    //直播结束
    else if (type == ExploreMoviePlayerControlViewTipTypeLiveOver) {
        
        self.userInteractionEnabled = YES;
        _loadingView.hidden = YES;
        _retryButton.hidden = YES;
        _liveTipLabel.hidden = NO;
        _liveTipLabel.text = @"直播已结束,订阅头条号关注更多精彩内容";
        _liveImageView.hidden = NO;
    }
}

- (BOOL)hasShowTipView
{
    switch (_tipType) {
        case ExploreMoviePlayerControlViewTipTypeRetry:
            return YES;
            break;
        case ExploreMoviePlayerControlViewTipTypeLiveWaiting:
            return YES;
            break;
        case ExploreMoviePlayerControlViewTipTypeLiveOver:
            return YES;
            break;
        default:
            break;
    }
    return NO;
}

- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type
{
    [self _refreshType:type andTipString:nil];
}

- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type andTipString:(NSString *)tipString
{
    [self _refreshType:type andTipString:tipString];
    if (_tipType == ExploreMoviePlayerControlViewTipTypeLoading) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
    
    if (_tipType == ExploreMoviePlayerControlViewTipTypeLoading) {
        [_loadingView startAnimating];
    }
    else {
        [_loadingView stopAnimating];
    }
    
}
- (void)dismissTipViewAnimation
{
    [_loadingView stopAnimating];
}

@end
