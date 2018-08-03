
#import "TTVideoFloatContentView.h"
#import "TTVideoFloatProtocol.h"
#import "SSThemed.h"
#import "TTImageView.h"
#import "TTIconLabel.h"
#import "TTImageView.h"
#import "TTImageView+TrafficSave.h"
#import "TTIconLabel.h"
#import "ExploreMovieView.h"
#import "ExploreCellHelper.h"
#import "SSMotionRender.h"
#import "TTVideoFloatFollowButton.h"
#import "TTStatusButton.h"
#import "TTVideoFloatActionButton.h"
#import "TTVideoFloatActionButton.h"
#import "TTVideoFloatAvatar.h"
#import "NSDictionary+TTGeneratedContent.h"
#import <TTAccountBusiness.h>

#define kImmerseAlpha 0.94

@interface TTVideoFloatContentView()
{
    TTIconLabel *_userName;
    TTVideoFloatAvatar *_userIcon;
    TTVideoFloatFollowButton *_followButton;
    TTImageView *_videoIcon;
    UIView *_videoIconBg;
    SSThemedLabel *_titleLabel;
    SSThemedLabel *_watchCountLabel;
    ExploreMovieView *_movieView;//视频播放器
    UIView *_movieContainer;
    SSThemedView *_line;
    TTImageInfosModel * _imageInfosModel;
    TTVideoFloatActionButton *_digg;
    TTVideoFloatActionButton *_burry;
    TTVideoFloatActionButton *_comment;
    TTVideoFloatActionButton *_share;
    UIView *_immerseMaskViewTop;
    UIView *_immerseMaskViewBottom;
    UIButton *_playButton;
}
@property (nonatomic, strong, nullable) UIImageView      *subscribeIndicator;
@property (nonatomic, assign) BOOL                       isImmersed;
@property (nonatomic, strong, nullable) ExploreMovieView *movieView;
@end

#define kCommentCountKeyPath @"cellEntity.article.commentCount"
#define kDiggCountKeyPath @"cellEntity.article.diggCount"
#define kBuryCountKeyPath @"cellEntity.article.buryCount"
#define kStartActivityKeyPath @"cellEntity.startActivity"
#define kIsUserBuryKeyPath @"cellEntity.article.userBury"
#define kIsUserDiggKeyPath @"cellEntity.article.userDigg"
#define kIsSubcribedKeyPath @"cellEntity.article.mediaInfo.subcribed"
#define kUserInfoKeyPath @"cellEntity.article.userInfo"
#define kMediaInfoKeyPath @"cellEntity.article.mediaInfo"

#define kArticleKeyPath @"cellEntity.article"

@implementation TTVideoFloatContentView
@dynamic cellEntity;

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kCommentCountKeyPath];
    [self removeObserver:self forKeyPath:kDiggCountKeyPath];
    [self removeObserver:self forKeyPath:kBuryCountKeyPath];
    [self removeObserver:self forKeyPath:kStartActivityKeyPath];
    [self removeObserver:self forKeyPath:kIsUserBuryKeyPath];
    [self removeObserver:self forKeyPath:kIsUserDiggKeyPath];
    [self removeObserver:self forKeyPath:kIsSubcribedKeyPath];
    [self removeObserver:self forKeyPath:kArticleKeyPath];
    [self removeObserver:self forKeyPath:kUserInfoKeyPath];
    [self removeObserver:self forKeyPath:kMediaInfoKeyPath];
}

- (void)renderView
{
    {
        _userIcon = [[TTVideoFloatAvatar alloc] init];
        [_userIcon addTarget:self action:@selector(getUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_userIcon];
    }
    
    {
        _followButton = [[TTVideoFloatFollowButton alloc] init];
        [_followButton addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
        
        _subscribeIndicator = [[UIImageView alloc] init];
        _subscribeIndicator.image = [UIImage imageNamed:@"loading_add_video.png"];
        _subscribeIndicator.backgroundColor = [UIColor clearColor];
        _subscribeIndicator.userInteractionEnabled = YES;
        _subscribeIndicator.alpha = 0;
        [_subscribeIndicator sizeToFit];
        [self addSubview:_followButton];
        [self addSubview:self.subscribeIndicator];
        [self.subscribeIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_followButton);
        }];
    }
    
    {
        _userName = [[TTIconLabel alloc] init];
        _userName.textColorThemeKey = kColorText3;
        _userName.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        [self addSubview:_userName];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getUserInfo)];
        [_userName addGestureRecognizer:tapGesture];
    }
    
    {
        _videoIconBg = [[UIView alloc] init];
        _videoIconBg.backgroundColor = [UIColor clearColor];
        _videoIconBg.clipsToBounds = YES;
        [self addSubview:_videoIconBg];
        
        _videoIcon = [[TTImageView alloc] initWithFrame:CGRectZero];
        _videoIcon.userInteractionEnabled = YES;
        _videoIcon.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _videoIcon.backgroundColor = [UIColor tt_defaultColorForKey:@"Background21"];
        [_videoIconBg addSubview:_videoIcon];
    }
    
    {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText3];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.lineBreakMode = NSLineBreakByClipping;
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
    }
    
    {
        _watchCountLabel = [[SSThemedLabel alloc] init];
        _watchCountLabel.textColor = [UIColor colorWithHexString:@"0x707070"];
        _watchCountLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_watchCountLabel];
    }
    
    //bottom action
    {
        //good
        _digg = [[TTVideoFloatActionButton alloc] initWithImageName:@"good_immersion_video" highlightedImageName:@"good_immersion_video_press"];
        [_digg addTarget:self action:@selector(digg) forControlEvents:UIControlEventTouchUpInside];
        _digg.seletedImageName = @"good_immersion_video_select";
        _digg.seletedImageNameHighlighted = @"good_immersion_video_select_press";
        _digg.seleted = NO;
        [self addSubview:_digg];
        
        _burry = [[TTVideoFloatActionButton alloc] initWithImageName:@"bad_immersion_video" highlightedImageName:@"bad_immersion_video_press"];
        _burry.seletedImageName = @"bad_immersion_video_select";
        _burry.seletedImageNameHighlighted = @"bad_immersion_video_select_press";
        [_burry addTarget:self action:@selector(bury) forControlEvents:UIControlEventTouchUpInside];
        _burry.seleted = NO;
        [self addSubview:_burry];
        
        _comment = [[TTVideoFloatActionButton alloc] initWithImageName:@"review_immersion_video" highlightedImageName:@"review_immersion_video_press"];
        [_comment addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_comment];
        
        _share = [[TTVideoFloatActionButton alloc] initWithImageName:@"share_immersion_video" highlightedImageName:@"share_immersion_video_press"];
        [_share addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_share];
        
    }
    
    {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        NSString *imgName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
        [_playButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [_playButton sizeToFit];
        [_videoIconBg addSubview:_playButton];
    }
    
    _line = [[SSThemedView alloc] init];
    _line.backgroundColor = [UIColor colorWithHexString:@"0x252525"];
    [self addSubview:_line];
    self.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
    _immerseMaskViewTop = [[UIView alloc] init];
    _immerseMaskViewTop.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
    _immerseMaskViewTop.alpha = kImmerseAlpha;
    _immerseMaskViewTop.userInteractionEnabled = YES;
    
    _immerseMaskViewBottom = [[UIView alloc] init];
    _immerseMaskViewBottom.backgroundColor = [UIColor colorWithHexString:kFloatVideoCellBackgroundColor];
    _immerseMaskViewBottom.alpha = kImmerseAlpha;
    _immerseMaskViewBottom.hidden = YES;
    _immerseMaskViewBottom.userInteractionEnabled = YES;
    [self addSubview:_immerseMaskViewBottom];
    [self addSubview:_immerseMaskViewTop];
    
    [self addObserver:self forKeyPath:kCommentCountKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kDiggCountKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kBuryCountKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kStartActivityKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kIsUserBuryKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kIsUserDiggKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kIsSubcribedKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kArticleKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kUserInfoKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:kMediaInfoKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)startIndicatorAnimating
{
    _followButton.alpha = 0;
    self.subscribeIndicator.alpha = 1;
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.toValue = @(M_PI * 2);
    rotate.duration = 0.5;
    rotate.repeatCount = MAXFLOAT;
    
    [self.subscribeIndicator.layer addAnimation:rotate forKey:@"rotation"];
}

- (void)stopIndicatorAnimating
{
    self.subscribeIndicator.alpha = 0;
    [self.subscribeIndicator.layer removeAnimationForKey:@"rotation"];
    [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
        _followButton.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kCommentCountKeyPath])
    {
        _comment.title = [NSString stringWithFormat:@"%@",[change valueForKey:NSKeyValueChangeNewKey]];
    }
    else if ([keyPath isEqualToString:kDiggCountKeyPath])
    {
        _digg.title = [NSString stringWithFormat:@"%@",[change valueForKey:NSKeyValueChangeNewKey]];
    }
    else if ([keyPath isEqualToString:kBuryCountKeyPath])
    {
        _burry.title = [NSString stringWithFormat:@"%@",[change valueForKey:NSKeyValueChangeNewKey]];
    }
    else if ([keyPath isEqualToString:kStartActivityKeyPath])
    {
        if ([[change valueForKey:NSKeyValueChangeNewKey] boolValue]) {
            [self startIndicatorAnimating];
        }
        else
        {
            [self stopIndicatorAnimating];
        }
    }
    else if ([keyPath isEqualToString:kIsUserDiggKeyPath])
    {
        _digg.seleted = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
    }
    else if ([keyPath isEqualToString:kIsUserBuryKeyPath])
    {
        _burry.seleted = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
    }
    else if ([keyPath isEqualToString:kArticleKeyPath] || [keyPath isEqualToString:kUserInfoKeyPath]
             || [keyPath isEqualToString:kMediaInfoKeyPath] || [keyPath isEqualToString:kIsSubcribedKeyPath])
    {
        _followButton.isSubscribed = [self.contentInfo ttgc_isSubCribed];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)play
{
    [self tt_cellAction:TTVideoFloatCellAction_Play object:self.cellEntity callbackBlock:^(BOOL success, id object) {
        
    }];
}

- (void)comment
{
    [self tt_cellAction:TTVideoFloatCellAction_Comment object:self.cellEntity callbackBlock:^(BOOL success, id object) {
        
    }];
}

- (void)digg
{
    WeakSelf;
    [self tt_cellAction:TTVideoFloatCellAction_Digg object:self.cellEntity callbackBlock:^(BOOL success, id object) {
        StrongSelf;
        if (success) {
            [self transformAnimationOnView:_digg];
        }
        
    }];
}

- (void)getUserInfo
{
    [self tt_cellAction:TTVideoFloatCellAction_UserInfo object:self.cellEntity callbackBlock:^(BOOL success, id object) {
        
    }];
}

- (void)bury
{
    WeakSelf;
    [self tt_cellAction:TTVideoFloatCellAction_Bury object:self.cellEntity callbackBlock:^(BOOL success, id object) {
        StrongSelf;
        if (success) {
            [self transformAnimationOnView:_burry];
        }
    }];
}

- (void)share
{
    [self tt_cellAction:TTVideoFloatCellAction_Share object:self.cellEntity callbackBlock:^(BOOL success, id object) {
        
    }];
}

- (void)subscribe
{
    TTVideoFloatCellAction action = _followButton.isSubscribed ? TTVideoFloatCellAction_unSubscribe : TTVideoFloatCellAction_Subscribe;
    [self tt_cellAction:action object:self.cellEntity callbackBlock:^(BOOL success, NSNumber *object) {
        if (success) {
            if ([object isKindOfClass:[NSNumber class]]) {
                _followButton.isSubscribed = [object boolValue];
            }
        }
    }];
}

- (void)transformAnimationOnView:(TTVideoFloatActionButton *)button
{
    UIImageView *imageView = [button iconImageView];
    [SSMotionRender motionInView:imageView byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic"] offsetPoint:CGPointMake(-2, -9)];
    imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    imageView.contentMode = UIViewContentModeCenter;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self updateActionButtonsWithArticle:self.cellEntity.article];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.f,1.f);
            imageView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)updateActionButtonsWithArticle:(Article *)article
{
    int digCnt = article.diggCount;
    NSString * diggTitle = digCnt > 0 ? [TTBusinessManager formatCommentCount:digCnt] : NSLocalizedString(@"顶", nil);
    _digg.title = diggTitle;
    
    int buryCnt = article.buryCount;
    NSString * buryTitle = buryCnt > 0 ? [TTBusinessManager formatCommentCount:article.buryCount] : NSLocalizedString(@"踩", nil);
    _burry.title = buryTitle;
    
    if (article.userDigg) {
        _digg.enable = YES;
        _digg.seleted = YES;
        _burry.enable = YES;
        _burry.seleted = !_digg.seleted;
    }
    else if (article.userBury) {
        _digg.enable = YES;
        _digg.seleted = NO;
        _burry.enable = YES;
        _burry.seleted = YES;
    }
    else {
        _digg.enable = YES;
        _digg.seleted = NO;
        _burry.enable = YES;
        _burry.seleted = NO;
    }
}

+ (TTImageInfosModel *)imageInfoModelWithArticle:(Article *)article
{
    NSDictionary *videoDetailInfo = [article videoDetailInfo];
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:[videoDetailInfo valueForKey:VideoInfoImageDictKey]];
    return model;
}

- (void)fillContent
{
    if ([self.cellEntity isKindOfClass:[TTVideoFloatCellEntity class]]) {
        //给subViews传递数据
        NSDictionary *contentInfo = [self contentInfo];
        Article *article = self.cellEntity.article;
        _userName.text = [contentInfo ttgc_contentName];
        [_userIcon.icon setImageWithURLString:[contentInfo ttgc_contentAvatarURL]];
        _titleLabel.text = article.title;
        _imageInfosModel = [[self class] imageInfoModelWithArticle:article];
        
        _videoIcon.frame = CGRectMake(0, 0, 0, _imageInfosModel.height);
        [_videoIcon setImageWithModelInTrafficSaveMode:_imageInfosModel placeholderImage:nil];
        
        NSNumber *watchNumber = [[article videoDetailInfo] objectForKey:VideoWatchCountKey];
        _watchCountLabel.text = [NSString stringWithFormat:@"%@次播放",[TTBusinessManager formatCommentCount:[watchNumber longLongValue]]];
        
        {
            _digg.title = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:article.diggCount]];
            _digg.seleted = article.userDigg;
            _burry.title = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:article.buryCount]];
            _burry.seleted = article.userBury;
            _comment.title = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:article.commentCount]];
            _share.title = @"分享";
        }
        
        NSString *accountUserID = [TTAccountManager userID];
        if (!isEmptyString(accountUserID) && !isEmptyString([contentInfo ttgc_contentID]) && [[contentInfo ttgc_contentID] isEqualToString:accountUserID]) {
            _followButton.hidden = YES;
        } else {
            _followButton.hidden = NO;
        }
       
        // 视频列表和详情页，user_auth_info只从userInfo中取，不取mediaInfo
        NSString *userAuthInfo = [self.cellEntity.article.userInfo tt_stringValueForKey:@"user_auth_info"];
        [_userIcon.icon showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

        [self setNeedsLayout];
    }
}

- (NSDictionary *)contentInfo
{
    Article *article = self.cellEntity.article;
    
    if ([article hasVideoSubjectID]) {
        if (article.detailUserInfo) {
            return article.detailUserInfo;
        } else {
            return article.detailMediaInfo;
        }
    } else {
        if (article.userInfo) {
            return article.userInfo;
        } else {
            return article.mediaInfo;
        }
    }
}

- (void)willBeginReuse
{
    _movieView = nil;//cell复用会持续持有movieView,导致其不能释放,从而导致dealloc不调用,部分observer也不调用
}

- (UIView *)animationToView
{
    return _videoIconBg;
}

- (void)layoutSubviews
{
    if (!self.cellEntity) {
        return;
    }
    NSInteger margin = [TTDeviceUIUtils tt_newPaddingSpecialElement:15];
    _userIcon.frame = CGRectMake(margin, [TTDeviceUIUtils tt_newPadding:15], [TTDeviceUIUtils tt_newPadding:36], [TTDeviceUIUtils tt_newPadding:36]);
    _userName.frame = CGRectMake(_userIcon.right + [TTDeviceUIUtils tt_newPadding:8], 0, 0, 0);
    [_userName sizeToFit];
    _userName.centerY = _userIcon.centerY;
    
    // 根据图片实际宽高设置其在cell中的高度
    float picWidth = self.width;
    float imageHeight = [ExploreCellHelper heightForVideoImageWidth:_imageInfosModel.width height:_imageInfosModel.height constraintWidth:picWidth];
    NSInteger space = 1;
    _videoIconBg.frame = CGRectMake(0, _userIcon.bottom + [TTDeviceUIUtils tt_newPadding:15], picWidth, imageHeight - space);
    _videoIcon.frame = CGRectMake(0, 0, picWidth, imageHeight);
    
    _titleLabel.frame = CGRectMake(margin, [TTDeviceUIUtils tt_newPadding:15] + _videoIconBg.bottom, self.width - margin * 2, 60);
    [_titleLabel sizeToFit];
    
    [_watchCountLabel sizeToFit];
    _watchCountLabel.frame = CGRectMake(margin, [TTDeviceUIUtils tt_newPadding:6] + _titleLabel.bottom, _watchCountLabel.width, _watchCountLabel.height);
    
    NSInteger followButtonHeight = 28;
    NSInteger followButtonWidth = 57;
    _followButton.frame = CGRectMake(self.width - [TTDeviceUIUtils tt_newPaddingSpecialElement:15] - followButtonWidth, 0, followButtonWidth, followButtonHeight);
    _followButton.centerY = _userName.centerY;
    float lineHeight = 1.0/[UIScreen mainScreen].scale;
    _line.frame = CGRectMake(0, self.height - lineHeight, self.width, lineHeight);
    
    {
        NSInteger width = ceilf(self.width/4.0);
        _digg.frame = CGRectMake(0, [TTDeviceUIUtils tt_newPadding:15] + _watchCountLabel.bottom, width, 24);
        _burry.frame = CGRectMake(_digg.right, _digg.top, width, 24);
        _comment.frame = CGRectMake(_burry.right, _digg.top, width, 24);
        _share.frame = CGRectMake(_comment.right, _digg.top, self.width - _comment.right, 24);
    }
    if (_immerseMaskViewTop.frame.size.width <= 0) {
        _immerseMaskViewTop.frame = self.bounds;
        _immerseMaskViewBottom.frame = self.bounds;
    }
    _playButton.center = CGPointMake(_videoIcon.width / 2.0, _videoIcon.height / 2);
    [super layoutSubviews];
}

- (void)immerseHalf
{
    CGRect rect = _videoIconBg.frame;
    _immerseMaskViewTop.alpha = 0;
    _immerseMaskViewTop.frame = CGRectMake(0, 0, self.width, rect.origin.y);
    _immerseMaskViewBottom.frame = CGRectMake(0, CGRectGetMaxY(rect), self.width, self.height - CGRectGetMaxY(rect));
    _immerseMaskViewBottom.alpha = 0;
    _immerseMaskViewBottom.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        _immerseMaskViewTop.alpha = kImmerseAlpha;
        _immerseMaskViewBottom.alpha = kImmerseAlpha;
    }];
    self.isImmersed = YES;
    //    LOGD(@"immerseHalf %@",self.indexPath);
}

- (void)unImmerseHalf
{
    self.isImmersed = NO;
    [self unImmerseEffect];
    //    LOGD(@"unImmerseHalf %@",self.indexPath);
}

- (void)immerseAll
{
    self.isImmersed = YES;
    _immerseMaskViewBottom.alpha = 0;
    _immerseMaskViewTop.frame = CGRectMake(0, 0, self.width, self.height);
    _immerseMaskViewBottom.hidden = YES;
    if (_immerseMaskViewTop.alpha != kImmerseAlpha) {
        _immerseMaskViewTop.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _immerseMaskViewTop.alpha = kImmerseAlpha;
        }];
    }
    //    LOGD(@"immerseAll %@",self.indexPath);
    
}

- (void)unImmerseAll
{
    self.isImmersed = NO;
    [self unImmerseEffect];
    //    LOGD(@"unImmerseAll %@",self.indexPath);
}

//沉浸效果
- (void)unImmerseEffect
{
    _immerseMaskViewBottom.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _immerseMaskViewTop.alpha = 0;
        _immerseMaskViewBottom.alpha = 0;
    }];
}

- (BOOL)isImmersed
{
    return _isImmersed;
}

- (void)removeMovieView
{
    [_movieContainer removeFromSuperview];
}

- (void)showBackgroundImage:(BOOL)show
{
    _videoIcon.hidden = !show;
}

- (void)showPlayIcon:(BOOL)show
{
    _playButton.hidden = !show;
}

- (void)addMovieView:(UIView *)movieView
{
    _movieContainer = movieView;
    movieView.frame = _videoIconBg.bounds;
    for (ExploreMovieView *aview in movieView.subviews) {
        if ([aview isKindOfClass:[ExploreMovieView class]]) {
            _movieView = aview;
            _movieView.frame = movieView.bounds;
            break;
        }
    }
    [_videoIconBg addSubview:movieView];
}

+ (CGFloat)cellHeightWithEntity:(TTVideoFloatCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath
{
    //15+_userIcon+15+_videoIcon+imageHeight+titleLabel+15+titleLabel.height+
    float picWidth = [UIScreen mainScreen].bounds.size.width;
    TTImageInfosModel *imageInfosModel = [[self class] imageInfoModelWithArticle:cellEntity.article];
    float imageHeight = [ExploreCellHelper heightForVideoImageWidth:imageInfosModel.width height:imageInfosModel.height constraintWidth:picWidth];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.numberOfLines = 2;
    titleLabel.text = cellEntity.article.title;
    NSInteger margin = [TTDeviceUIUtils tt_newPaddingSpecialElement:15];
    titleLabel.frame = CGRectMake(0, 0, picWidth - margin * 2, 60);
    [titleLabel sizeToFit];
    
    
    UILabel *watchCountLabel = [[UILabel alloc] init];
    watchCountLabel.font = [UIFont systemFontOfSize:12];
    watchCountLabel.numberOfLines = 1;
    watchCountLabel.text = @"     ";
    [watchCountLabel sizeToFit];
    
    return [TTDeviceUIUtils tt_newPadding:15] + [TTDeviceUIUtils tt_newPadding:36] + [TTDeviceUIUtils tt_newPadding:15] + imageHeight + [TTDeviceUIUtils tt_newPadding:15]+ titleLabel.height
    + [TTDeviceUIUtils tt_newPadding:6] + watchCountLabel.height + [TTDeviceUIUtils tt_newPadding:15] + 24 + [TTDeviceUIUtils tt_newPadding:20];
}
@end





