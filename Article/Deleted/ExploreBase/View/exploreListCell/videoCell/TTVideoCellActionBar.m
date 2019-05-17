//
//  TTVideoCellActionBar.m
//  Article
//
//  Created by 王双华 on 16/9/8.
//
//

#import "TTVideoCellActionBar.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ArticleVideoActionButton.h"
#import "ExploreActionButton.h"
#import "ExploreArticleCellView.h"
#import "ExploreCellHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData.h"
#import "HuoShan.H"
#import "TTDeviceHelper.h"
#import "TTImageView.h"
#import "TTLayOutCellDataHelper.h"
#import "TTUISettingHelper.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "ExploreOrderedData+TTAd.h"

#define kLeftPadding        15
#define kRightPadding       15
#define kTopPadding         12
#define kGapAvatarView      8
#define kMinHeight [TTDeviceUIUtils tt_newPadding:56]   
#define B_kMinHeight [TTDeviceUIUtils tt_newPadding:50]
#define KButtonsMinHeight [TTDeviceUIUtils tt_newPadding:32] //用于保持common,share,follow,more,avatarLabel的height
#define SINGLE_LINE_WIDTH           (2.0 / [UIScreen mainScreen].scale)

extern BOOL ttvs_isVideoCellShowShareEnabled(void);


@interface TTVideoCellActionBar ()
@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, assign) BOOL shouldHiddenAvatarView;//非广告样式下头像url为空时，不展示头像
@property (nonatomic, assign) BOOL shouldHiddenTypeLabel;//非广告样式下，displaylabel为空时，隐藏类型标签

@property (nonatomic, strong) UIImageView *indicatorImageView;

@end

@implementation TTVideoCellActionBar

- (void)dealloc
{
//    [_avatarLabelButton removeObserver:self forKeyPath:@"alpha"];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//{
//    //头像添加点击态
//    if (object == _avatarLabelButton && [keyPath isEqualToString:@"alpha"]) {
//        _avatarLabel.alpha = _avatarLabelButton.alpha;
//        _avatarView.alpha = _avatarLabelButton.alpha;
//    }
//}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.schemeType = TTVideoCellActionBarLayoutSchemeDefault;
        
        // add by zjing remove 头像点击效果
//        [self.avatarLabelButton addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
//        [self.avatarButton addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

/** 头像 */
- (TTAsyncCornerImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, [self.class avatarHeight], [self.class avatarHeight]) allowCorner:YES];
        _avatarView.borderWidth = 0;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarView.cornerRadius = [self.class avatarHeight] / 2;
        _avatarView.placeholderName = @"big_defaulthead_head";
        [_avatarView setupVerifyViewForLength:[self.class avatarNormalHeight] adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        [self addSubview:_avatarView];
    }
    return _avatarView;
}

/** 头条号或者来源名称 */
- (TTIconLabel *)avatarLabel {
    if (!_avatarLabel) {
        _avatarLabel = [[TTIconLabel alloc] init];
        _avatarLabel.backgroundColor = [UIColor clearColor];
        _avatarLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _avatarLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_avatarLabel];
    }
    return _avatarLabel;
}

- (TTAlphaThemedButton *)avatarLabelButton {
    if (!_avatarLabelButton) {
        _avatarLabelButton = [[TTAlphaThemedButton alloc] init];
        [self addSubview:_avatarLabelButton];
    }
    return _avatarLabelButton;
}

- (TTAlphaThemedButton *)avatarButton {
    if (ttvs_isVideoFeedCellHeightAjust() < 2) {
        return nil;
    }
    
    if (!_avatarButton) {
        _avatarButton = [[TTAlphaThemedButton alloc] init];
        [self addSubview:_avatarButton];
    }
    return _avatarButton;
}

/** 标签 */
- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.font = [UIFont systemFontOfSize:10];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _typeLabel.layer.cornerRadius = 3;
        _typeLabel.clipsToBounds = YES;
        [self addSubview:_typeLabel];
    }
    return _typeLabel;
}

/** 直播状态在线人数 */
- (SSThemedLabel *)liveCountLabel {
    if (!_liveCountLabel) {
        _liveCountLabel = [[SSThemedLabel alloc] init];
        _liveCountLabel.backgroundColor = [UIColor clearColor];
        _liveCountLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _liveCountLabel.textAlignment = NSTextAlignmentRight;
        _liveCountLabel.textColorThemeKey = kColorText3;
        _liveCountLabel.height = kMinHeight;
        [self addSubview:_liveCountLabel];
    }
    return _liveCountLabel;
}

/** 播放次数 */
- (SSThemedLabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[SSThemedLabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.textColorThemeKey = kColorText1;
        _countLabel.height = kMinHeight;
        [self addSubview:_countLabel];
    }
    return _countLabel;
}
/** 关注按钮 */
- (TTAlphaThemedButton *)followButton {
    
    if (!_followButton) {
        
        _followButton = [[TTAlphaThemedButton alloc] init];
        _followButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_followButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]]];
        [self addSubview:_followButton];
        
        // 分享按钮和关注按钮互斥
        _followButton.hidden = [[[TTSettingsManager sharedManager] settingForKey:@"video_cell_show_share" defaultValue:@NO freeze:NO] boolValue];;
        if (ttvs_isVideoFeedCellHeightAjust() == 3) {
            _followButton.hidden = NO;
        }
    }
    
    return _followButton;
}

- (TTFollowThemeButton *)redPacketFollowButton
{
    if (!_redPacketFollowButton) {
        _redPacketFollowButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType202 followedType:TTFollowedType102];
        _redPacketFollowButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _redPacketFollowButton.hidden = ttvs_isVideoCellShowShareEnabled();
        [self addSubview:_redPacketFollowButton];
    }
    return _redPacketFollowButton;
}

/** 评论按钮 */
- (ArticleVideoActionButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [[ArticleVideoActionButton alloc] init];
        _commentButton.minHeight = KButtonsMinHeight;
        _commentButton.disableRedHighlight = YES;
        _commentButton.maxWidth = 72.0f;
        _commentButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self addSubview:_commentButton];
    }
    return _commentButton;
}

- (ArticleVideoActionButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[ArticleVideoActionButton alloc] init];
        _shareButton.minHeight = KButtonsMinHeight;
        _shareButton.disableRedHighlight = YES;
        _shareButton.maxWidth = 72.0f;
        _shareButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self addSubview:_shareButton];
    }
    return _shareButton;
}

/** 更多按钮 */
- (ArticleVideoActionButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[ArticleVideoActionButton alloc] init];
        _moreButton.minHeight = KButtonsMinHeight;
        _moreButton.centerAlignImage = YES;
        _moreButton.minWidth = 44.f;
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self addSubview:_moreButton];
    }
    return _moreButton;
}

/** 广告分享 */
- (TTVideoAdCellShareController *)shareController {
    if (!_shareController) {
        _shareController = [[TTVideoAdCellShareController alloc] init];
        [self addSubview:_shareController.shareBtn];
    }
    return _shareController;
}

/** 广告查看详情按钮 */
- (ExploreActionButton *)adActionButton {
    if (!_adActionButton) {
        _adActionButton = [[ExploreActionButton alloc] init];
        _adActionButton.frame = CGRectMake(0, 0, 90, 28);
        _adActionButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _adActionButton.titleColorThemeKey = kColorText6;
        _adActionButton.backgroundColorThemeKey = nil;
        _adActionButton.backgroundColors = nil;
        _adActionButton.layer.borderWidth = 0;
        [self addSubview:_adActionButton];
    }
    return _adActionButton;
}

- (void)updateAvatarViewWithUrl:(NSString *)avatarUrl sourceText:(NSString *)sourceText
{
    if (!isEmptyString(avatarUrl)) {
        [_avatarView tt_setImageWithURLString:avatarUrl];
        self.shouldHiddenAvatarView = NO;
    }
    else {
        if (!isEmptyString(sourceText)) {
            NSString *firstName = [sourceText substringToIndex:1];
            [_avatarView tt_setImageText:firstName fontSize:[TTDeviceUIUtils tt_fontSize:12] textColorThemeKey:kColorText8 backgroundColorThemeKey:nil backgroundColors:[self randomSourceBackgroundColors]];
            self.shouldHiddenAvatarView = NO;
        }
        else{
            self.shouldHiddenAvatarView = YES;
        }
    }
}

- (void)updateAvatarLabelWithText:(NSString *)avatarText
{
    [self.avatarLabel setText:avatarText];
    [self.avatarLabel refreshIconView];
}

- (void)updateTypeLabelWithText:(NSString *)typeText
{
    self.shouldHiddenTypeLabel = YES;
    if (!isEmptyString(typeText)) {
        self.shouldHiddenTypeLabel = NO;
        [self.typeLabel setText:typeText];
        [self.typeLabel sizeToFit];
        _typeLabel.width += 3 * 2;
    }
}

- (void)updateLiveCountLabelWithText:(NSString *)liveCountText
{
    if (!isEmptyString(liveCountText)) {
        [self.liveCountLabel setText:liveCountText];
        [_liveCountLabel sizeToFit];
    }
}

- (void)updateCountLabelWithText:(NSString *)countText
{
    if (!isEmptyString(countText)) {
        [self.countLabel setText:countText];
        [_countLabel sizeToFit];
    }
}

- (void)updateFollowButtonWithStatus:(BOOL)status hidden:(BOOL)hidden {
    
    if (ttvs_isVideoFeedCellHeightAjust() == 3) {
        self.followButton.hidden = NO;
    }else if (ttvs_isVideoCellShowShareEnabled()) {
        self.followButton.hidden = YES;
        self.redPacketFollowButton.hidden = YES;
        return ;
    }
    
    self.followButton.hidden = hidden;
    self.redPacketFollowButton.hidden = hidden;
    
    if (hidden) return ;
    
    self.redPacketFollowButton.followed = status;
    self.followButton.imageView.hidden = status;
    
    if (status) { // 已关注
        [self.followButton setTitle:NSLocalizedString(@"已关注", nil) forState:UIControlStateNormal];
        self.followButton.titleColorThemeKey = kColorText1Disabled;
        [self.followButton setTitleColor:[UIColor tt_themedColorForKey:self.followButton.titleColorThemeKey] forState:UIControlStateNormal];
        self.followButton.imageName = nil;
        [self.followButton setImage:nil forState:UIControlStateNormal];

    } else {
        [self.followButton setTitle:NSLocalizedString(@"关注", nil) forState:UIControlStateNormal];
        self.followButton.titleColorThemeKey = kColorText1;
        [self.followButton setTitleColor:[UIColor tt_themedColorForKey:self.followButton.titleColorThemeKey] forState:UIControlStateNormal];
        self.followButton.imageName = @"video_add";
        [self.followButton setImage:[UIImage themedImageNamed:self.followButton.imageName] forState:UIControlStateNormal];
        
        [self.followButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:4.0f];
    }
    
    [self.followButton sizeToFit];
}

- (void)updateCommentButtonWithText:(NSString *)commentText
{
    if (!isEmptyString(commentText)) {
        [self.commentButton setTitle:commentText];
    }
}

- (void)updateShareButtonWithText:(NSString *)shareText
{
    if (!isEmptyString(shareText)) {
        [self.shareButton setTitle:shareText];
        self.shareButton.centerAlignImage = NO;
    }else{
        self.shareButton.minWidth = 34.f;
        self.shareButton.centerAlignImage = YES;
        [self.shareButton setTitle:@""];
    }
}

- (void)refreshWithData:(id)data {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if ([orderedData managedObjectContext]) {
        self.orderedData = orderedData;
        self.shareController.orderedData = orderedData;
    } else {
        self.orderedData = nil;
        return;
    }
    
    [self hiddenAllViews];
    
    NSString *avatarUrl = nil;
    NSString *sourceText = nil;
    NSString *typeText = nil;
    NSString *countText = nil;
    NSString *commentText = nil;
    NSString *liveCountText = nil;
    NSString *shareText = nil;
    BOOL followed = NO;
    BOOL hiddenFollowedBtn = YES;
    
    _avatarLabel.textColorThemeKey = kColorText1;
    
    switch (_schemeType) {
        case TTVideoCellActionBarLayoutSchemeDefault:
        {
            if ([[orderedData article] managedObjectContext]) {
                Article *article = orderedData.article;

                if ([article isVideoSourceUGCVideoOrHuoShan]) {
                    avatarUrl = [article.userInfo stringValueForKey:@"avatar_url" defaultValue:nil];
                    sourceText = [article.userInfo stringValueForKey:@"name" defaultValue:nil];
                }
                else{
                    avatarUrl = article.sourceAvatar;
                    if (isEmptyString(avatarUrl)) {
                        avatarUrl = [article.mediaInfo stringValueForKey:@"avatar_url" defaultValue:nil];
                    }
                    sourceText = article.source;
                    if (isEmptyString(sourceText)) {
                        sourceText = [article.mediaInfo stringValueForKey:@"name" defaultValue:nil];
                    }
                    // 视频列表和详情页，user_auth_info只从userInfo中取，不取mediaInfo
                    NSString *userAuthInfo = [article.userInfo tt_stringValueForKey:@"user_auth_info"];
                    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
                }

                if (isEmptyString(sourceText)) {
                    sourceText = [article.mediaInfo stringValueForKey:@"name" defaultValue:nil];
                    _avatarLabel.textColorThemeKey = kColorText3;
                    self.avatarLabelButton.userInteractionEnabled = NO;
                }
                long count = [article.videoDetailInfo longValueForKey:VideoWatchCountKey defaultValue:0];
                countText = [[TTBusinessManager formatPlayCount:count] stringByAppendingString:@"次播放"];
                if (orderedData.isFakePlayCount) {
                    countText = [[TTBusinessManager formatPlayCount:article.readCount] stringByAppendingString:@"次阅读"];
                }
                
                long long cmtCnt = article.commentCount;
                commentText = cmtCnt > 0 ? [TTBusinessManager formatCommentCount:article.commentCount] : NSLocalizedString(@"评论", nil);
                long long shareCnt = [article.share_count longLongValue];
                shareText = shareCnt > 0 ? [TTBusinessManager formatCommentCount:shareCnt] : @"分享";
                if (!isEmptyString(orderedData.displayLabel)) {
                    typeText = orderedData.displayLabel;
                    [ExploreCellHelper colorTypeLabel:_typeLabel orderedData:self.orderedData];
                }
                if (!isEmptyString(orderedData.ad_id)) {
                    self.avatarLabelButton.userInteractionEnabled = NO;
                    self.avatarButton.userInteractionEnabled = NO;
                    //typeText = @"广告";
                }
                
                followed = [article isFollowed];
                hiddenFollowedBtn = (followed && !orderedData.showFeedFollowedBtn);
            }
        }
            break;
        case TTVideoCellActionBarLayoutSchemeAD:
        {
            Article *article = nil;
            id<TTAdFeedModel> adModel = [orderedData adModel];
            if ([[orderedData article] managedObjectContext]) {
                article = orderedData.article;
                
                if (isEmptyString(avatarUrl) && !isEmptyString(article.sourceAvatar)) {
                    avatarUrl = article.sourceAvatar;
                }
                if (isEmptyString(avatarUrl)) {
                    avatarUrl = [article.mediaInfo stringValueForKey:@"avatar_url" defaultValue:nil];
                }

                if (!isEmptyString(orderedData.displayLabel)) {
                    typeText = orderedData.displayLabel;
                    [ExploreCellHelper colorTypeLabel:_typeLabel orderedData:self.orderedData];
                }
                sourceText = [TTLayOutCellDataHelper getADSourceStringWithOrderedDada:orderedData];
                if (isEmptyString(sourceText)){
                    //来源为空时，用pgc名称
                    NSString *avatarName = [article.mediaInfo stringValueForKey:@"name" defaultValue:nil];
                    sourceText = avatarName;
                }
                if (isEmptyString(sourceText)) {
                    sourceText = @"佚名";
                }
            }
            if (self.orderedData) {
                self.adActionButton.actionModel = self.orderedData;
                if (![adModel isCreativeAd]) {
                    [_adActionButton setTitle:@"查看详情" forState:UIControlStateNormal];
                    [_adActionButton setUserInteractionEnabled:NO];
                    [_adActionButton setIconImageNamed:@"view detail_ad_feed"];
                }
                else{
                    [_adActionButton setTitle:[adModel actionButtonTitle] forState:UIControlStateNormal];
                    [_adActionButton setUserInteractionEnabled:YES];
                    [_adActionButton refreshForceCreativeIcon];
                }
            }
        }
            break;
        case TTVideoCellActionBarLayoutSchemeLive:
        {
            if ([[orderedData article] managedObjectContext]) {
                Article *article = orderedData.article;
                avatarUrl = [article.mediaInfo stringValueForKey:@"avatar_url" defaultValue:nil];
                sourceText = [article.mediaInfo stringValueForKey:@"name" defaultValue:nil];
                if (isEmptyString(sourceText)) {
                    sourceText = article.source;
                    self.avatarLabelButton.userInteractionEnabled = NO;
                    _avatarLabel.textColorThemeKey = kColorText3;
                }
                long count = [article.videoDetailInfo longValueForKey:VideoWatchCountKey defaultValue:0];
                countText = [[TTBusinessManager formatPlayCount:count] stringByAppendingString:@"次播放"];
           
                if (orderedData.isFakePlayCount) {
                    countText = [[TTBusinessManager formatPlayCount:article.readCount] stringByAppendingString:@"次阅读"];
                }
                
                liveCountText = [NSString stringWithFormat:@"累计%@人观看",[TTBusinessManager formatPlayCount:count]];
                
                long long cmtCnt = article.commentCount;
                commentText = cmtCnt > 0 ? [TTBusinessManager formatCommentCount:article.commentCount] : NSLocalizedString(@"评论", nil);
                // 视频列表和详情页，user_auth_info只从userInfo中取，不取mediaInfo
                NSString *userAuthInfo = [article.userInfo tt_stringValueForKey:@"user_auth_info"];
                [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
            }
            else if ([[orderedData huoShan] managedObjectContext]){
                HuoShan *huoShan = orderedData.huoShan;
                avatarUrl = [huoShan.userInfo stringValueForKey:@"avatar_url" defaultValue:nil];
                sourceText = [huoShan.userInfo stringValueForKey:@"screen_name" defaultValue:nil];
                liveCountText = [[TTBusinessManager formatPlayCount:[huoShan.viewCount longLongValue]] stringByAppendingString:@"人正在看"];
            }

        }
        default:
            break;
    }

    [self updateAvatarViewWithUrl:avatarUrl sourceText:sourceText];
    [self updateAvatarLabelWithText:sourceText];
    [self updateTypeLabelWithText:typeText];
    [self updateLiveCountLabelWithText:liveCountText];
    [self updateCountLabelWithText:countText];
    [self updateCommentButtonWithText:commentText];
    if (ttvs_isVideoFeedCellHeightAjust() == 3){
        hiddenFollowedBtn = NO;
        [self updateShareButtonWithText:nil];
    }else{
        [self updateShareButtonWithText:shareText];
    }
    [self updateFollowButtonWithStatus:followed hidden:hiddenFollowedBtn];
    
    [self themeChanged:nil];
    [self layoutSubviewsIfNeeded];
}

- (void)hiddenAllViews
{
    self.avatarView.hidden = YES;
    self.avatarLabel.hidden = YES;
    [self.avatarLabel removeAllIcons];
    self.typeLabel.hidden = YES;
    self.liveCountLabel.hidden = YES;
    self.adActionButton.hidden = YES;
    self.countLabel.hidden = YES;
    self.commentButton.hidden = YES;
    self.shareButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.shareController.shareBtn.hidden = YES;
    self.avatarLabelButton.hidden = YES;
    self.avatarButton.hidden = YES;
    self.shouldHiddenTypeLabel = YES;
    self.shouldHiddenAvatarView = YES;
    self.avatarLabelButton.userInteractionEnabled = NO;
    self.avatarButton.userInteractionEnabled = NO;
    self.followButton.hidden = YES;
    self.redPacketFollowButton.hidden = YES;
    [self.avatarView hideVerifyView];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    
    [self.commentButton setImage:[UIImage themedImageNamed:@"comment"] forState:UIControlStateNormal];
    [self.commentButton setImage:[UIImage themedImageNamed:@"comment"] forState:UIControlStateHighlighted];
    [self.commentButton updateThemes];
    [self.commentButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateHighlighted];
    
    [self.shareButton setImage:[UIImage themedImageNamed:@"tab_share"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage themedImageNamed:@"tab_share"] forState:UIControlStateHighlighted];
    [self.shareButton updateThemes];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1] forState:UIControlStateHighlighted];
    
    [self.moreButton setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateHighlighted];
    [self.moreButton updateThemes];
    [self.shareController refreshUI];
    
    UIColor *textClr =  [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"2a90d7" nightColorName:@"67778b"]];
    self.typeLabel.textColor = textClr;
    self.typeLabel.layer.borderColor = textClr.CGColor;
}

- (void)layoutSubviewsIfNeeded {
    switch (self.schemeType) {
        case TTVideoCellActionBarLayoutSchemeDefault:
        {
            [self layoutSubviewsSchemeDefaultIfNeeded];
        }
            break;
        case TTVideoCellActionBarLayoutSchemeAD:
        {
            [self layoutSubviewsSchemeADIfNeeded];
            
        }
            break;
        case TTVideoCellActionBarLayoutSchemeLive:
        {
            [self layoutSubviewsSchemeLiveIfNeeded];
        }
            break;
        default:
            break;
    }
    [self bringSubviewToFront:_avatarLabelButton];
    [self bringSubviewToFront:_avatarButton];
    [self themeChanged:nil];
}

- (void)layoutSubviewsSchemeDefaultIfNeeded
{
    self.shareButton.hidden = NO;
    self.moreButton.hidden = NO;
    self.commentButton.hidden = NO;
    self.avatarView.hidden = self.shouldHiddenAvatarView;
    self.avatarLabel.hidden = NO;
    self.typeLabel.hidden = self.shouldHiddenTypeLabel;
    self.avatarLabelButton.hidden = NO;
    self.avatarButton.hidden = NO;
    if (_avatarLabel.countOfIcons > 0) { // 显示认证图标时候隐藏推广
        _typeLabel.hidden = YES;
    }
    self.countLabel.hidden = [TTDeviceHelper isPadDevice];
    BOOL showShareBtn = ttvs_isVideoCellShowShareEnabled();
    if (ttvs_isVideoFeedCellHeightAjust() == 3) {
        showShareBtn = YES;
    }
    self.countLabel.hidden = YES;
    self.shareButton.hidden = !showShareBtn;
    
    CGFloat rightMargin = [TTDeviceHelper isPadDevice] ? self.width * 0.25 : 16;
    rightMargin = ceil(rightMargin) ;
    
    //更多按钮
    [_moreButton updateFrames];
    CGFloat imageWidth = _moreButton.imageView.image.size.width;
    if ([TTDeviceHelper isPadDevice]){
        _moreButton.right = self.width - 3;
        _moreButton.centerY = self.height / 2;
    }else{
        _moreButton.right = self.width - rightMargin + [_moreButton contentEdgeInset].right;
        if (ttvs_isVideoFeedCellHeightAjust() > 1){
            _moreButton.top = 6;
        }else{
            _moreButton.centerY = self.height / 2;
        }
    }
    

    //分享按钮
    [_shareButton updateFrames];
    _shareButton.centerY = _moreButton.centerY;
    if ([TTDeviceHelper isPadDevice]) {
        _shareButton.left = self.width - rightMargin - imageWidth;
    } else {
        
        CGFloat shareBtnRight = _moreButton.left - rightMargin + [_moreButton contentEdgeInset].left + [_shareButton contentEdgeInset].right;
        if ([TTDeviceHelper is736Screen]) {
            shareBtnRight -= 4;
        }
        _shareButton.right = shareBtnRight;
        if (ttvs_isVideoFeedCellHeightAjust() ==3 ) {
            _shareButton.right = _moreButton.left - 4;
        }
    }
    imageWidth = _shareButton.imageView.image.size.width;
    
    //评论按钮
    [_commentButton updateFrames];
    _commentButton.centerY = _moreButton.centerY;
    CGFloat comBtnRight;
    if ([TTDeviceHelper isPadDevice]) {
        _commentButton.left = (showShareBtn ? _shareButton.left : self.width) - rightMargin - imageWidth;
    } else {
        if (showShareBtn) {
            comBtnRight = _shareButton.left - rightMargin + [_shareButton contentEdgeInset].left + [_commentButton contentEdgeInset].right;
        } else {
            comBtnRight = _moreButton.left - rightMargin + [_moreButton contentEdgeInset].left + [_commentButton contentEdgeInset].right;
        }
        if ([TTDeviceHelper is736Screen]) {
            comBtnRight -= 8;
        }
        _commentButton.right = comBtnRight;
    }


    //播放次数
    _countLabel.right = _commentButton.left - rightMargin + [_commentButton contentEdgeInset].left;
    _countLabel.centerY = _commentButton.centerY;
    
    //关注
    CGFloat followBtnRight = _commentButton.left - rightMargin + [_commentButton contentEdgeInset].left;
    if ([TTDeviceHelper is736Screen]) {
        followBtnRight -= 8;
    }
    self.followButton.right = followBtnRight - 2; //add:625
    self.followButton.centerY = _commentButton.centerY;
    if (ttvs_isVideoFeedCellHeightAjust() == 3){
        self.followButton.right = _commentButton.left - rightMargin - 2;
    }
    self.redPacketFollowButton.right = self.followButton.right;
    self.redPacketFollowButton.centerY = self.followButton.centerY;

    //头像
    CGFloat left = kLeftPadding;
    if (ttvs_isVideoFeedCellHeightAjust() > 1){
        self.avatarView.frame = CGRectMake(left, 8 - [self.class avatarHeight], [self.class avatarHeight], [self.class avatarHeight]);
        _avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];
        _avatarView.borderWidth = SINGLE_LINE_WIDTH;
        self.avatarView.alpha = 1;
    }else{
        self.avatarView.frame = CGRectMake(left, (self.height - KButtonsMinHeight) / 2, KButtonsMinHeight, KButtonsMinHeight);
        _avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];;
        _avatarView.borderWidth = 0.f;
        self.avatarView.alpha = 1;
        left += (!_avatarView.hidden? KButtonsMinHeight + kGapAvatarView : 0);
    }

    
    //名称
    
    CGFloat avatarLabelWidth = _followButton.left - left - (ttvs_isVideoFeedCellHeightAjust() > 1 ? 25 : 20);
    
    if (!_shareButton.hidden && ttvs_isVideoFeedCellHeightAjust() < 2) {
        avatarLabelWidth = _commentButton.left - left - 20;
    }
    
    if (!_typeLabel.hidden) {
        avatarLabelWidth -= (_typeLabel.width + kGapAvatarView);
    }
    avatarLabelWidth = avatarLabelWidth < _avatarLabel.width ? avatarLabelWidth :_avatarLabel.width;
    _avatarLabel.width = avatarLabelWidth;
    _avatarLabel.height = KButtonsMinHeight - 4;

    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        _avatarLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[TTDeviceUIUtils tt_fontSize:14]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _avatarLabel.frame = CGRectMake(kLeftPadding, 9, _avatarLabel.width, 28.f);
    }else{
        _avatarLabel.left = left;
        _avatarLabel.centerY = _avatarView.centerY;
    }
    
    left += avatarLabelWidth + kGapAvatarView;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        if (avatarLabelWidth < [self.class avatarHeight]){
            _avatarLabel.centerX = _avatarView.centerX;
            left = self.avatarLabel.right + kGapAvatarView;
        }
    }

    //类型标签
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        _typeLabel.left = kLeftPadding + avatarLabelWidth + 3.5;
    }else{
        _typeLabel.left = left;
    }
    _typeLabel.height = 14;
    _typeLabel.centerY = _avatarLabel.centerY;

    //控制头像以及名称透明度按钮
    if(ttvs_isVideoFeedCellHeightAjust() == 1){
        self.avatarLabelButton.frame = CGRectMake(_avatarView.left, 0, _avatarLabel.right - _avatarView.left, B_kMinHeight);
        self.avatarButton.height = 0;

    }else if (ttvs_isVideoFeedCellHeightAjust() > 1){
        self.avatarLabelButton.frame = self.avatarLabel.frame;
        self.avatarButton.frame = _avatarView.frame;
    }else{
        self.avatarLabelButton.frame = CGRectMake(_avatarView.left, 0, _avatarLabel.right - _avatarView.left, kMinHeight);
    }

}

- (void)layoutSubviewsSchemeADIfNeeded
{
    self.avatarView.hidden = self.shouldHiddenAvatarView;
    self.avatarLabel.hidden = NO;
    self.typeLabel.hidden = self.shouldHiddenTypeLabel;
    self.adActionButton.hidden = NO;
    self.shareController.shareBtn.hidden = NO;
    self.followButton.hidden = YES;
    self.redPacketFollowButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.shareButton.hidden = YES;
    self.followButton.hidden = YES;
    CGFloat rightMargin = [TTDeviceHelper isPadDevice] ? self.width * 0.25 : 16;
    rightMargin = ceil(rightMargin);
    
    [self.shareController.shareBtn updateFrames];
    if (ttvs_isVideoFeedCellHeightAjust() > 1){
        self.shareController.shareBtn.top = 8.f;
    }else{
        self.shareController.shareBtn.centerY = self.height / 2;
    }
    self.shareController.shareBtn.right = [TTDeviceHelper isPadDevice] ? (self.width - 3) : (self.width - rightMargin + [self.shareController.shareBtn contentEdgeInset].right);
    
    CGFloat left = kLeftPadding;
    //头像
    if (ttvs_isVideoFeedCellHeightAjust() > 1){
        left += 0;
        self.avatarView.frame = CGRectMake(left, 8 - [self.class avatarHeight], [self.class avatarHeight], [self.class avatarHeight]);
        _avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];
        _avatarView.borderWidth = SINGLE_LINE_WIDTH;
        _avatarView.alpha = 1;
    }else{
        self.avatarView.frame = CGRectMake(left, (self.height - [self.class avatarHeight]) / 2, [self.class avatarHeight], [self.class avatarHeight]);
        left += (!_avatarView.hidden? KButtonsMinHeight + kGapAvatarView : 0);
        _avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];;
        _avatarView.borderWidth = 0.f;
    }
    //名称
    _avatarLabel.height = KButtonsMinHeight - 4;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        _avatarLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[TTDeviceUIUtils tt_fontSize:14]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _avatarLabel.frame = CGRectMake(kLeftPadding, 9, _avatarLabel.width, 28.f);
    }else{
        _avatarLabel.left = left;
        _avatarLabel.centerY = _avatarView.centerY;
    }
    //“查看详情”等按钮
    self.adActionButton.centerY = self.shareController.shareBtn.centerY;
    self.adActionButton.right = self.shareController.shareBtn.left;
    if ([TTDeviceHelper is736Screen]){
        self.adActionButton.right = self.shareController.shareBtn.left - 8;
    }
    
    CGFloat avatarLabelWidth = _adActionButton.left - _avatarLabel.left - (ttvs_isVideoFeedCellHeightAjust() > 1 ? 25 : 20) - (!_typeLabel.hidden ? _typeLabel.width + kGapAvatarView : 0);
    avatarLabelWidth = avatarLabelWidth < _avatarLabel.width ? avatarLabelWidth :_avatarLabel.width;
    _avatarLabel.width = avatarLabelWidth;
    left += avatarLabelWidth + kGapAvatarView;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        if (avatarLabelWidth < [self.class avatarHeight]){
            _avatarLabel.centerX = _avatarView.centerX;
            left = self.avatarLabel.right + kGapAvatarView;
        }
    }
    //类型标签
    _typeLabel.left = left;
    _typeLabel.height = 14;
    _typeLabel.centerY = _avatarLabel.centerY;
    
    //控制头像以及名称透明度按钮
    //self.avatarLabelButton.frame = CGRectMake(_avatarView.left, 0, _avatarLabel.right - _avatarView.left, kMinHeight);
}

- (void)layoutSubviewsSchemeLiveIfNeeded
{
    self.liveCountLabel.hidden = NO;
    self.moreButton.hidden = NO;
    self.avatarView.hidden = self.shouldHiddenAvatarView;
    self.avatarLabel.hidden = NO;
    self.avatarLabelButton.hidden = NO;
    self.followButton.hidden = YES;
    self.redPacketFollowButton.hidden = YES;
    
    CGFloat rightMargin = [TTDeviceHelper isPadDevice] ? self.width * 0.25 : 16;
    rightMargin = ceil(rightMargin);
    
    //more按钮
    [_moreButton updateFrames];
    _moreButton.centerY = self.height / 2;
    _moreButton.right = [TTDeviceHelper isPadDevice] ? (self.width - 3) : (self.width - rightMargin + [_moreButton contentEdgeInset].right);
    
    //直播在线人数
    _liveCountLabel.height = KButtonsMinHeight;
    _liveCountLabel.centerY = _moreButton.centerY;
    _liveCountLabel.right = _moreButton.left - rightMargin + [_moreButton contentEdgeInset].left;
    
    //头像
    CGFloat left = kLeftPadding;
    if (ttvs_isVideoFeedCellHeightAjust() > 1){
        left += 0;
        self.avatarView.frame = CGRectMake(left, 8 - [self.class avatarHeight], [self.class avatarHeight], [self.class avatarHeight]);
        _avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];
        _avatarView.borderWidth = SINGLE_LINE_WIDTH;
        _avatarView.alpha = 1;
    }else{
        self.avatarView.frame = CGRectMake(left, (self.height - [self.class avatarHeight]) / 2, [self.class avatarHeight], [self.class avatarHeight]);
        left += (!_avatarView.hidden? [self.class avatarHeight] + kGapAvatarView : 0);
        _avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];;
        _avatarView.borderWidth = 0.f;
    }
    _avatarView.userInteractionEnabled = NO;

    //名称
    _avatarLabel.height = KButtonsMinHeight;
    CGFloat avatarLabelWidth = _liveCountLabel.left - _avatarLabel.left - kGapAvatarView;
    avatarLabelWidth = avatarLabelWidth < _avatarLabel.width ? avatarLabelWidth :_avatarLabel.width;
    _avatarLabel.width = avatarLabelWidth;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        _avatarLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[TTDeviceUIUtils tt_fontSize:14]] ? : [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _avatarLabel.frame = CGRectMake(kLeftPadding, 9, _avatarLabel.width, 28.f);
        if (avatarLabelWidth < [self.class avatarHeight]) {
            _avatarLabel.centerX = _avatarView.centerX;
        }
    }else{
        _avatarLabel.left = left;
        _avatarLabel.centerY = _avatarView.centerY;
    }

    //控制头像以及名称透明度按钮
    self.avatarLabelButton.frame = CGRectMake(_avatarView.left, 0, _avatarLabel.right - _avatarView.left, kMinHeight);
}

- (NSArray<NSString *> *)randomSourceBackgroundColors {
    int index = arc4random() % 5;
    switch (index) {
        case 0:
            return @[@"90ccff", @"48667f"];
        case 1:
            return @[@"cccccc", @"666666"];
        case 2:
            return @[@"bfa1d0", @"5f5068"];
        case 3:
            return @[@"80c184", @"406042"];
        case 4:
            return @[@"e7ad90", @"735648"];
        default:
            return @[@"ff9090", @"7f4848"];
    }
}

static CGFloat sAvatarHeigth = 0;
+ (CGFloat)avatarHeight {
//    if (sAvatarHeigth) {
//        return sAvatarHeigth;
//    }
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        sAvatarHeigth = [TTDeviceUIUtils tt_newPadding:40.0];
    }else{
        sAvatarHeigth = [TTDeviceUIUtils tt_newPadding:32.0];
    }
    return sAvatarHeigth;
}

+ (CGFloat)avatarNormalHeight {
   return 32.f;
}

- (void)startFollowButtonIndicatorAnimating:(BOOL)hasFollowed {
    
    [self stopFollowButtonIndicatorAnimating];

    self.indicatorImageView.backgroundColor = [UIColor whiteColor];
    
    [self.followButton setTitle:@"" forState:UIControlStateNormal];
    [self.followButton setImage:nil forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:@"toast_keywords_refresh_gray"];
    
    self.indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    [self.indicatorImageView setImage:img];
    self.indicatorImageView.center = CGPointMake(self.followButton.width / 2, self.followButton.height / 2);
    [self.followButton addSubview:self.indicatorImageView];
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.toValue = @(M_PI * 2);
    rotate.duration = 0.5;
    rotate.repeatCount = MAXFLOAT;
    [self.indicatorImageView.layer addAnimation:rotate forKey:@"rotation"];
    [self.redPacketFollowButton stopLoading:^{
    }];
    [self.redPacketFollowButton startLoading];
}

- (void)stopFollowButtonIndicatorAnimating {
    
    [self.indicatorImageView.layer removeAnimationForKey:@"rotation"];
    [self.indicatorImageView removeFromSuperview];
    self.indicatorImageView = nil;
    [self.redPacketFollowButton stopLoading:^{
        
    }];
}

//- (BOOL)avtarPointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (self.avatarView.hidden) {
//        return NO;
//    }
//    CGRect rect = UIEdgeInsetsInsetRect(self.avatarView.frame, self.avatarView.hitTestEdgeInsets);
//    return CGRectContainsPoint(rect, point);
//}
//
//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if ([self avtarPointInside:point withEvent:event]){
//        if (self.avatarButton.height > 0){
//            return self.avatarButton;
//        }else{
//            return self.avatarLabelButton;
//        }
//    }else {
//        return [super hitTest:point withEvent:event];
//    }
//}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self.avatarLabel) {
        if (self.schemeType != TTVideoCellActionBarLayoutSchemeAD){
            return self.avatarLabelButton;
        }
    }
    
    if (!view) {
        if (!self.avatarView.hidden) {
            CGPoint pointTouched = [self convertPoint:point toView:self.avatarView];
            view = [self.avatarButton hitTest:pointTouched withEvent:event];
        }
 
    }
    return view;
}

@end
