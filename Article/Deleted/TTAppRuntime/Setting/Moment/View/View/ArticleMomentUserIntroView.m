
//
//  ArticleUserIntroView.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-24.
//
//

#import "ArticleMomentUserIntroView.h"
#import "TTRelationshipViewController.h"
#import <TTAccountBusiness.h>
#import "TTEditUserProfileViewController.h"
#import "FriendDataManager.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "SSThemed.h"
#import "TTBlockManager.h"

#import "TTThirdPartyAccountInfoBase.h"
#import "TTThirdPartyAccountsHeader.h"
#import "TTPhotoScrollViewController.h"

#import "SSIndicatorTipsManager.h"
#import "TTAuthorizeManager.h"
#import "TTUserInfoView.h"

#import "TTNavigationController.h"
#import "SSWebViewController.h"
#import <TTUserSettingsManager+FontSettings.h>
#import "TTAlphaThemedButton.h"
//#import "UIButton+TTCache.h"
#import "TTRoute.h"
#import "TTIndicatorView.h"
#import "TTReportManager.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"
#import "TTActionSheetController.h"
#import "TTRelationshipDefine.h"

#import <TTInteractExitHelper.h>
//#import "TTAddFriendViewController.h"

#define kActionButtonLeftPadding    0
#define kActionButtonTopPadding     0
#define kLeftMargin 10
#define kRightMargin 10
#define kBottomMargin 14
#define kDescLabelFontSize 12
#define kVerifyLabelFontSize 12


@interface ArticleMomentUserIntroActionButton : SSViewBase

@property(nonatomic, strong)UILabel * titleLabel;
@property(nonatomic, strong)UILabel * countLabel;
@property(nonatomic, strong)UIButton * actionButton;

//will change self frame
- (void)setTitleText:(NSString *)title countText:(NSString *)count;
@end

@implementation ArticleMomentUserIntroActionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self addSubview:_titleLabel];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_countLabel];
        
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_actionButton];
        
        [self reloadThemeUI];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"005a99" nightColorName:@"56707f"]];
    _countLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"707070"]];
}

- (void)setTitleText:(NSString *)title countText:(NSString *)count
{
    [_titleLabel setText:title];
    [_countLabel setText:count];
    
    [_countLabel sizeToFit];
    [_titleLabel sizeToFit];
    
    
    CGRect titleFrame = _titleLabel.frame;
    titleFrame.origin = CGPointMake(kActionButtonLeftPadding, kActionButtonTopPadding);
    _titleLabel.frame = titleFrame;
    
    CGRect countFrame = _countLabel.frame;
    countFrame.origin = CGPointMake(CGRectGetMaxX(titleFrame) + 5, CGRectGetMinY(titleFrame));
    _countLabel.frame = countFrame;
    
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(titleFrame) + CGRectGetWidth(countFrame) + kActionButtonLeftPadding * 2 + 5, CGRectGetHeight(titleFrame) + kActionButtonTopPadding * 2);
    self.frame = frame;
    
    _actionButton.frame = self.bounds;
}

@end

@interface ArticleMomentUserIntroView()
<
TTEditUserProfileViewControllerDelegate,
FriendDataManagerDelegate,
TTBlockManagerDelegate
> {
    BOOL _hasFetchedData;
    BOOL _willShowFirstConcernAlert;
}

@property(nonatomic, strong)ArticleAvatarView * avatarView;
@property(nonatomic, strong)UIButton * avatarButton;
@property(nonatomic, strong)TTUserInfoView * nameView;
@property(nonatomic, strong)TTAlphaThemedButton * questionLogo;
@property(nonatomic, strong)UILabel * descLabel;
@property(nonatomic, strong, readwrite)ArticleFriend * friend;
@property(nonatomic, strong)UIImageView * bgView;
@property(nonatomic, strong)UIImageView * buttonSeperatorImageView;
@property(nonatomic, strong)UIImageView * buttonSeperatorImageView2;
@property(nonatomic, strong)UIImageView * buttonSeperatorImageView3;
@property(nonatomic, strong)ArticleMomentUserIntroActionButton * followedButton;
@property(nonatomic, strong)ArticleMomentUserIntroActionButton * followingButton;
@property(nonatomic, strong)ArticleMomentUserIntroActionButton * pgcLikeButton;
@property(nonatomic, strong)ArticleMomentUserIntroActionButton * entityLikeButton;
@property(nonatomic, strong)UIButton * relationButton;
@property(nonatomic, strong)UIActivityIndicatorView * indicator;
@property(nonatomic, strong)FriendDataManager * friendManager;
@property(nonatomic, strong)UIImageView *bottomSeperatorImageView;
@property(nonatomic, strong)UILabel * verifyInfoLabel;
@property(nonatomic, strong)UILabel *verifyDescLabel;
@property(nonatomic, strong)SSThemedImageView * platformImageView;
@property(nonatomic, strong)SSThemedLabel *platformScreenNameLabel;
@property(nonatomic, strong)SSThemedLabel *recommendReasonLabel;
@property(nonatomic, strong)TTBlockManager * blockUserManager;
@property(nonatomic, copy)NSDictionary * extraTracks;
@property(nonatomic, strong)TTActionSheetController *actionSheetController;
@end

@implementation ArticleMomentUserIntroView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame extraTracks:nil];
}

- (instancetype)initWithFrame:(CGRect)frame extraTracks:(NSDictionary *)extraTracks
{
    self = [super initWithFrame:CGRectMake(0, 0, 0, kArticleMomentUserIntroViewMinHeight)];
    if (self) {
        _fromWidget = NO;
        _hasFetchedData = NO;
        _extraTracks = [extraTracks copy];
        
        self.friendManager = [[FriendDataManager alloc] init];
        _friendManager.delegate = self;
        
        self.blockUserManager = [[TTBlockManager alloc] init];
        _blockUserManager.delegate = self;
        self.bgView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"bg_profile.jpg"]];
        self.bgView.frame = [self _bgViewFrame];
        [self.contentView addSubview:_bgView];
        
        self.avatarView = [[ArticleAvatarView alloc] initWithFrame:[self frameForAvatarView]];
        _avatarView.avatarStyle = SSAvatarViewStyleRectangle;
        _avatarView.avatarImgPadding = [TTDeviceHelper ssOnePixel];
        _avatarView.rectangleAvatarImgRadius = 4.f;
        _avatarView.userInteractionEnabled = NO;
        [_avatarView setupVerifyViewForLength:57.f adaptationSizeBlock:nil];
        [self.contentView addSubview:_avatarView];
        
        self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarButton.frame = _avatarView.frame;
        _avatarButton.backgroundColor = [UIColor clearColor];
        [_avatarButton addTarget:self action:@selector(avatarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_avatarButton];
        
        
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        _descLabel.numberOfLines = 0;
        _descLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_descLabel];
        
        
        self.verifyDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _verifyDescLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        _verifyDescLabel.numberOfLines = 0;
        _verifyDescLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_verifyDescLabel];
        
        self.platformImageView = [[SSThemedImageView alloc] init];
        _platformImageView.hidden = YES;
        [self.contentView addSubview:_platformImageView];
        
        self.platformScreenNameLabel = [[SSThemedLabel alloc] init];
        _platformScreenNameLabel.numberOfLines = 2;
        _platformScreenNameLabel.font = [UIFont systemFontOfSize:12];
        _platformScreenNameLabel.textColorThemeKey = kColorText2;
        [self.contentView addSubview:_platformScreenNameLabel];
        
        
        self.recommendReasonLabel = [[SSThemedLabel alloc] init];
        _recommendReasonLabel.numberOfLines = 2;
        _recommendReasonLabel.font = [UIFont systemFontOfSize:12];
        _recommendReasonLabel.textColorThemeKey = kColorText2;
        [self.contentView addSubview:_recommendReasonLabel];
        
        self.followingButton = [[ArticleMomentUserIntroActionButton alloc] initWithFrame:CGRectZero];
        [_followingButton.actionButton addTarget:self action:@selector(countButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_followingButton];
        
        self.buttonSeperatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_buttonSeperatorImageView];
        
        self.buttonSeperatorImageView2 = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_buttonSeperatorImageView2];
        
        self.buttonSeperatorImageView3 = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_buttonSeperatorImageView3];
        
        self.pgcLikeButton = [[ArticleMomentUserIntroActionButton alloc] initWithFrame:CGRectZero];
        [_pgcLikeButton.actionButton addTarget:self action:@selector(countButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_pgcLikeButton];
        
        
        self.followedButton = [[ArticleMomentUserIntroActionButton alloc] initWithFrame:CGRectZero];
        [_followedButton.actionButton addTarget:self action:@selector(countButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_followedButton];
        
        self.entityLikeButton = [[ArticleMomentUserIntroActionButton alloc] initWithFrame:CGRectZero];
        [_entityLikeButton.actionButton addTarget:self action:@selector(countButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_entityLikeButton];
        
        self.relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_relationButton setTitle:@"---" forState:UIControlStateNormal];
        [_relationButton addTarget:self action:@selector(relationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _relationButton.backgroundColor = [UIColor clearColor];
        _relationButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [self.contentView addSubview:_relationButton];
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidden = YES;
        [self.contentView addSubview:_indicator];
        
        self.bottomSeperatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_bottomSeperatorImageView];
        
        self.verifyInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _verifyInfoLabel.font = [UIFont systemFontOfSize:kVerifyLabelFontSize];
        _verifyInfoLabel.backgroundColor = [UIColor clearColor];
        _verifyInfoLabel.numberOfLines = 0;
        [self.contentView addSubview:_verifyInfoLabel];
        [self reloadThemeUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnblockUserHandler:) name:kHasBlockedUnblockedUserNotification object:nil];
        
    }
    return self;
}

- (CGRect)_bgViewFrame
{
    return CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 239);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgView.frame = [self _bgViewFrame];
    _relationButton.frame = CGRectMake(self.contentView.frame.size.width - 10 - CGRectGetWidth(_relationButton.frame), CGRectGetMaxY(_bgView.frame) + 5, CGRectGetWidth(_relationButton.frame), CGRectGetHeight(_relationButton.frame));
}

- (void)avatarButtonClicked
{
    if (isEmptyString(_friend.avatarURLString)) {
        return;
    }
    TTPhotoScrollViewController * showImageViewController = [[TTPhotoScrollViewController alloc] init];
    showImageViewController.targetView = self;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    if (_friend.avatarLargeURLString) {
        showImageViewController.imageURLs = @[_friend.avatarLargeURLString];
    }
    else {
        
        NSMutableString * largeAvatarStr = [_friend.avatarURLString mutableCopy];
        [largeAvatarStr replaceOccurrencesOfString:@"medium" withString:@"large" options:NSLiteralSearch range:NSMakeRange(0, _friend.avatarURLString.length)];
        showImageViewController.imageURLs = @[largeAvatarStr];
    }
    [showImageViewController setStartWithIndex:0];
    
    CGRect frame = [self.viewController.view convertRect:self.avatarButton.frame fromView:self];
    showImageViewController.placeholderSourceViewFrames = @[[NSValue valueWithCGRect:frame]];
    [showImageViewController presentPhotoScrollView];
}

- (void)refreshPlatformImage
{
    NSString * platformNameStr = _friend.platform;
    NSString *imageName = nil;
    
//    if([platformNameStr isEqualToString:[SinaUserAccount platformName]])
//    {
//        imageName = @"noticeable_approve_sina.png";
//    }
//    else if([platformNameStr isEqualToString:[QZoneUserAccount platformName]])
//    {
//        imageName = @"noticeable_approve_qzone.png";
//    }
//    else if([platformNameStr isEqualToString:[TencentWBUserAccount platformName]])
//    {
//        imageName = @"noticeable_approve_qqweibo.png";
//    }
//    else if([platformNameStr isEqualToString:[RenrenUserAccount platformName]])
//    {
//        imageName = @"noticeable_approve_renren.png";
//    }
//    else if([platformNameStr isEqualToString:[KaixinUserAccount platformName]])
//    {
//        imageName = @"noticeable_approve_kaixin.png";
//    }
    if([platformNameStr isEqualToString:@"mobile"])
    {
        imageName = @"noticeable_approve_cellphone.png";
    }
    
    _platformImageView.hidden = imageName == nil;
    _platformImageView.image = [UIImage themedImageNamed:imageName];
    [_platformImageView sizeToFit];
}

- (void)setLikeCount:(long long)likeCount followedCount:(long long)followedCount followingCount:(long long)followingCount entityLikeCount:(long long)entityLikeCount
{
    
    NSString * followedCountStr = nil;
    if (followedCount >= 0) {
        followedCountStr = [NSString stringWithFormat:@"%ld", (long)followedCount];
    }
    else {
        followedCountStr = @"---";
    }
    [_followedButton setTitleText:NSLocalizedString(@"粉丝", nil) countText:followedCountStr];
    
    NSString * followingCountStr = nil;
    if (followingCount >= 0) {
        followingCountStr = [NSString stringWithFormat:@"%lld", followingCount];
    }
    else {
        followingCountStr = @"---";
    }
    [_followingButton setTitleText:NSLocalizedString(@"关注", nil) countText:followingCountStr];
    
    NSString * likeCountStr = nil;
    if (likeCount >= 0) {
        likeCountStr = [NSString stringWithFormat:@"%lld", likeCount];
    }
    else {
        likeCountStr = @"---";
    }
    [_pgcLikeButton setTitleText:NSLocalizedString(@"订阅", nil) countText:likeCountStr];
    
    NSString * entityLikeCountStr = nil;
    if (entityLikeCount >= 0) {
        entityLikeCountStr = [NSString stringWithFormat:@"%lld", entityLikeCount];
    }
    else {
        entityLikeCountStr = @"---";
    }
    [_entityLikeButton setTitleText:NSLocalizedString(@"关心", nil) countText:entityLikeCountStr];
    
    
    _followingButton.origin = CGPointMake(10, CGRectGetMaxY(self.avatarView.frame) + 20);
    
    _buttonSeperatorImageView.origin = CGPointMake(CGRectGetMaxX(self.followingButton.frame) + 10 , CGRectGetMinY(self.followingButton.frame) + 2);
    _buttonSeperatorImageView.size = CGSizeMake([TTDeviceHelper ssOnePixel], CGRectGetHeight(self.followingButton.frame) - 4);
    
    _followedButton.origin = CGPointMake(CGRectGetMinX(self.buttonSeperatorImageView.frame) + 10, CGRectGetMinY(_followingButton.frame));
    
    _buttonSeperatorImageView2.frame = _buttonSeperatorImageView.frame;
    _buttonSeperatorImageView2.left = CGRectGetMaxX(_followedButton.frame) + 10;
    
    _pgcLikeButton.origin = CGPointMake(CGRectGetMaxX(_buttonSeperatorImageView2.frame) + 10, CGRectGetMinY(_followingButton.frame));
    
    _buttonSeperatorImageView3.frame = _buttonSeperatorImageView.frame;
    _buttonSeperatorImageView3.left = CGRectGetMaxX(_pgcLikeButton.frame) + 10;
    
    _entityLikeButton.origin = CGPointMake(CGRectGetMaxX(_buttonSeperatorImageView3.frame) + 10, CGRectGetMinY(_followingButton.frame));
    
    if (entityLikeCount <= 0) {
        _entityLikeButton.hidden = YES;
        _buttonSeperatorImageView3.hidden = YES;
    } else {
        _entityLikeButton.hidden = NO;
        _buttonSeperatorImageView3.hidden = NO;
    }
}

- (BOOL)needShowLikeButton
{
    return YES;
}

- (void)refreshRelationButtonUI
{
    if ([_friend isAccountUser]) {
        [_relationButton setImage:[UIImage themedImageNamed:@"set_title_profile.png"] forState:UIControlStateNormal];
    }
    else if (([_friend.isFollowed boolValue] && [_friend.isFollowing boolValue])) {
        [_relationButton setImage:[UIImage themedImageNamed:@"followed_title_profile.png"] forState:UIControlStateNormal];
    }
    else if ([_friend.isFollowing boolValue]) {
        [_relationButton setImage:[UIImage themedImageNamed:@"following_title_profile.png"] forState:UIControlStateNormal];
    }
    else if ([_friend.isBlocking boolValue]) {
        [_relationButton setImage:[UIImage themedImageNamed:@"profile_ic_remove.png"] forState:UIControlStateNormal];
    }
    else {
        [_relationButton setImage:[UIImage themedImageNamed:@"follow_title_profile.png"] forState:UIControlStateNormal];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    _buttonSeperatorImageView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"808080" nightColorName:@"505050"]];
    _buttonSeperatorImageView2.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"808080" nightColorName:@"505050"]];
    _buttonSeperatorImageView3.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"808080" nightColorName:@"505050"]];
    _bgView.image = [UIImage themedImageNamed:@"bg_profile.jpg"];
    [_relationButton setBackgroundImage:[[UIImage themedImageNamed:@"message_title_profile.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:15] forState:UIControlStateNormal];
    [_relationButton setBackgroundImage:[[UIImage themedImageNamed:@"message_title_profile_press.png"] stretchableImageWithLeftCapWidth:23 topCapHeight:15] forState:UIControlStateHighlighted];
    [_relationButton setTitleColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"808080" nightColorName:@"505050"]] forState:UIControlStateNormal];
    [self refreshRelationButtonUI];
    _avatarView.borderColorName = kColorBackground400;
    _descLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"707070"]];
    
    _bottomSeperatorImageView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"464646"]];
    
    
    [self refreshVerifyLabel];
}


- (CGRect)frameForAvatarView
{
    CGRect rect = CGRectMake(10, 213, 57.f, 57.f);
    return rect;
}



- (void)startIndicatorAnimation
{
    _relationButton.hidden = YES;
    _indicator.hidden = NO;
    [_indicator startAnimating];
}

- (void)stopIndicatorAnimation
{
    _relationButton.hidden = NO;
    _indicator.hidden = YES;
    [_indicator stopAnimating];
}

- (void)refreshRelationButton
{
    CGFloat buttonWidth = 80.f;
    if (_friend.isFollowing == nil && _friend.isFollowed == nil) {
        [_relationButton setTitle:@"---" forState:UIControlStateNormal];
    }
    else if ([_friend isAccountUser]) {
        [_relationButton setTitle:NSLocalizedString(@" 设置", nil) forState:UIControlStateNormal];
    }
    else if (([_friend.isFollowed boolValue] && [_friend.isFollowing boolValue])) {
        [_relationButton setTitle:NSLocalizedString(@"互相关注", nil) forState:UIControlStateNormal];
    }
    else if ([_friend.isFollowing boolValue]) {
        [_relationButton setTitle:NSLocalizedString(@"已关注", nil) forState:UIControlStateNormal];
    }
    else if ([_friend.isBlocking boolValue]) {
        [_relationButton setTitle:NSLocalizedString(@"解除黑名单", nil) forState:UIControlStateNormal];
        buttonWidth = 100.f;
    }
    else {
        [_relationButton setTitle:NSLocalizedString(@"关注", nil) forState:UIControlStateNormal];
    }
    
    [self refreshRelationButtonUI];
    [_relationButton sizeToFit];
    _relationButton.width = buttonWidth;
    _relationButton.origin = CGPointMake(self.contentView.frame.size.width - 10 - (_relationButton.width), CGRectGetMaxY(_bgView.frame) + 5);
}

- (void)refreshCountButtons
{
    [self setLikeCount:[_friend.pgcLikeCount longLongValue] followedCount:[_friend.followerCount longLongValue] followingCount:[_friend.followingCount longLongValue] entityLikeCount:[_friend.entityLikeCount longLongValue]];
}

- (void)fetchCompleteUserInfo
{
    if (isEmptyString(_friend.userID)) {
        return;
    }
    [_friendManager startGetFriendProfileByUserID:_friend.userID extraTrack:self.extraTracks];
    _hasFetchedData = YES;
}

#pragma mark -- public

- (void)presentReportView{
    self.actionSheetController = [[TTActionSheetController alloc] init];
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        StrongSelf;
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = self.friend.userID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceUser).stringValue userModel:model animated:YES];
        }
    }];
    
}

- (void)refreshByUserID:(NSString *)userID
{
    if (![self.friend.userID isEqualToString:userID]) {
        ArticleFriend * friend = [[ArticleFriend alloc] init];
        friend.userID = userID;
        [self refreshFriendData:friend];
    } else if (!_hasFetchedData) {
        [self fetchCompleteUserInfo];
    }
}

- (void)willAppear
{
    // 强制刷新
    _hasFetchedData = NO;
}

- (void)refreshFriendData:(ArticleFriend *)model
{
    self.friend = model;
    [self refreshUI];
    [self fetchCompleteUserInfo];
}

- (void)refreshUser:(SSUserModel *)userModel
{
    [self refreshByUserID:userModel.ID];
}

#pragma mark -- action

- (void)countButtonClicked:(id)sender
{
    if (sender == _entityLikeButton.actionButton) {
        NSString * urlString = @"http://ic.snssdk.com/api/2/wap/entity_like_list/";
        
        BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
        NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
        urlString = [urlString stringByAppendingFormat:@"?uid=%@#tt_daymode=%d&tt_font=%@", _friend.userID, isDayModel, fontSizeType];;
        UINavigationController * nv = [TTUIResponderHelper topNavigationControllerFor: self];
        if (nv) {
            [SSWebViewController openWebViewForNSURL:[NSURL URLWithString:urlString] title:@"关心" navigationController:nv supportRotate:NO];
        }
        return;
    }
    
    RelationViewAppearType appearType = RelationViewAppearFollowing;
    
    if (sender == _followedButton.actionButton) {
        appearType = RelationViewAppearTypeFollower;
        wrapperTrackEvent(@"profile", @"followers_button");
    }
    else if (sender == _followingButton.actionButton) {
        appearType = RelationViewAppearFollowing;
        wrapperTrackEvent(@"profile", @"followings_button");
    }
    else {
        appearType = RelationViewAppearTypePGCLikeUser;
        wrapperTrackEvent(@"profile", @"subscribers_button");
    }
    
    TTRelationshipViewController *controller = [[TTRelationshipViewController alloc] initWithAppearType:appearType currentUser:_friend];
    UINavigationController *topNav = [TTUIResponderHelper topNavigationControllerFor: self];
    [topNav pushViewController:controller animated:YES];
    
}

- (void)refreshVerifyLabel
{
    _verifyInfoLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"505050" nightColorName:@"505050"]];
    if (!isEmptyString(_friend.verfiedAgency) && !isEmptyString(_friend.verfiedContent)) {
        NSString * str = [NSString stringWithFormat:@"%@:%@", _friend.verfiedAgency, _friend.verfiedContent];
        if ([_verifyInfoLabel respondsToSelector:@selector(attributedText)]) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
            NSInteger agencyStr = [_friend.verfiedAgency length];
            [attributeString setAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"FF6000" nightColorName:@"956900"]] forKey:NSForegroundColorAttributeName] range:NSMakeRange(0, agencyStr)];
            _verifyInfoLabel.attributedText = attributeString;
        }
        else {
            _verifyInfoLabel.text = str;
        }
        CGFloat height = [TTLabelTextHelper heightOfText:str fontSize:kVerifyLabelFontSize forWidth:self.contentView.frame.size.width - kLeftMargin - kRightMargin];
        CGFloat originY = isEmptyString(_friend.userDescription) ? CGRectGetMaxY(_followedButton.frame) + 5 : CGRectGetMaxY(_descLabel.frame) + 5;
        _verifyInfoLabel.frame = CGRectMake(kLeftMargin, originY, self.contentView.frame.size.width - kLeftMargin - kRightMargin, height);
        
    }
    else {
        if ([_verifyInfoLabel respondsToSelector:@selector(attributedText)]) {
            _verifyInfoLabel.attributedText = nil;
        }
        else {
            _verifyInfoLabel.text = nil;
        }
        _verifyInfoLabel.frame = CGRectZero;
    }
    
    if(!isEmptyString(_friend.verifyDesc) || !isEmptyString(_friend.verifySource))
    {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:_verifyDescLabel.attributedText];
        UIColor *sourceColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"FF6000" nightColorName:@"956900"]];
        UIColor *descColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"505050" nightColorName:@"505050"]];
        
        if(!isEmptyString(_friend.verifySource))
        {
            [attrStr addAttribute:NSForegroundColorAttributeName value:sourceColor range:NSMakeRange(0, _friend.verifySource.length + 1)];
            [attrStr addAttribute:NSForegroundColorAttributeName value:descColor range:NSMakeRange(_friend.verifySource.length + 1, _friend.verifyDesc.length)];
        }
        else
        {
            [attrStr addAttribute:NSForegroundColorAttributeName value:descColor range:NSMakeRange(0, attrStr.length)];
        }
        
        _verifyDescLabel.attributedText = attrStr;
    }
    
}

- (void)refreshUI
{
    [_avatarView showAvatarByURL:_friend.avatarURLString];
    //    //test
    //    NSArray *logoInfo = @[@{@"url":@"http://p1.pstatp.com/large/5000353d9e001b4b7.png", @"width":@(142), @"height":@(51), @"url_list":@[@{@"url":@"http://p1.pstatp.com/large/5000353d9e001b4b7.png"}, @{@"url":@"http://p1.pstatp.com/large/5000353d9e001b4b7.png"}, @{@"url":@"http://p1.pstatp.com/large/5000353d9e001b4b7.png"}], @"open_url":@"sslocal://detail?groupid=123456", @"uri":@"large/11554/1878294955"}];
    //    //end test
    if (!_nameView && !isEmptyString(_friend.screenName)) {
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(_avatarView.right + 10, 0) maxWidth:self.contentView.width - _avatarView.right - 30 limitHeight:17.f title:_friend.screenName fontSize:18.f verifiedInfo:nil verified:NO owner:NO appendLogoInfoArray:_friend.authorBadgeList];
        _nameView.textColorThemedKey = kColorText10;
        _nameView.top = _avatarView.top;
        [self.contentView addSubview:_nameView];
        
        if (self.friend.showSpringFestivalIcon && !_questionLogo) {
            _questionLogo = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
            UIImage *festivalImage = [UIImage imageNamed:@"question_button_profile"];
            
            [_questionLogo setImage:festivalImage forState:UIControlStateNormal];
            _questionLogo.frame = CGRectMake((_nameView.right) + 8.f, ((_nameView.bottom) + (_nameView.top) - festivalImage.size.height) / 2, festivalImage.size.width, festivalImage.size.height);
            [_questionLogo addTarget:self action:@selector(festivalAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_questionLogo];
        }
    }
    [_descLabel setText:_friend.userDescription];
    _platformScreenNameLabel.text = _friend.platformScreenName;
    _recommendReasonLabel.text = _friend.recommendReason;
    
    
    [self refreshPlatformImage];
    
    float offsetX = (_nameView.left);
    if(!_platformImageView.hidden)
    {
        _platformImageView.origin = CGPointMake((_nameView.left), (_nameView.bottom) + 17);
        offsetX = (_platformImageView.right) + 5;
    }
    
    [self refreshRelationButton];
    
    
    float platformScreenNameWidth = _relationButton.hidden ? ((self.contentView.width) - offsetX) : ((_relationButton.left) - offsetX);
    CGRect platformScreenNameRect = [_platformScreenNameLabel textRectForBounds:CGRectMake(0, 0, platformScreenNameWidth, 999) limitedToNumberOfLines:2];
    _platformScreenNameLabel.frame = CGRectMake(offsetX, (_nameView.bottom) + 15, platformScreenNameWidth, platformScreenNameRect.size.height);
    NSMutableString *verifyDescString = [NSMutableString string];
    if(!isEmptyString(_friend.verifySource) || !isEmptyString(_friend.verifyDesc))
    {
        if(!isEmptyString(_friend.verifySource))
        {
            [verifyDescString appendFormat:@"%@:", _friend.verifySource];
        }
        
        if(!isEmptyString(_friend.verifyDesc))
        {
            [verifyDescString appendString:_friend.verifyDesc];
        }
        
        _verifyDescLabel.text = nil;
        _verifyDescLabel.attributedText = [[NSAttributedString alloc] initWithString:verifyDescString];
    }
    
    
    float offsetY = (_followingButton.bottom);
    
    if (isEmptyString(_friend.userDescription)) {
        _descLabel.frame = CGRectZero;
    }
    else {
        CGFloat descLabelHeight = [TTLabelTextHelper heightOfText:_friend.userDescription fontSize:kDescLabelFontSize forWidth:self.contentView.frame.size.width - kLeftMargin - kRightMargin];
        //        CGFloat descLabelHeight =  heightOfContent(_friend.userDescription, self.contentView.frame.size.width - kLeftMargin - kRightMargin, kDescLabelFontSize);
        _descLabel.frame = CGRectMake(kLeftMargin, offsetY + 5, self.contentView.frame.size.width - kLeftMargin - kRightMargin, descLabelHeight);
        offsetY = (_descLabel.bottom);
        
    }
    if(!isEmptyString(_friend.verifySource) || !isEmptyString(_friend.verifyDesc)){
        if(!isEmptyString(_friend.verifySource))
        {
            [verifyDescString appendFormat:@"%@:", _friend.verifySource];
        }
        
        if(!isEmptyString(_friend.verifyDesc))
        {
            [verifyDescString appendString:_friend.verifyDesc];
        }
        CGFloat verifyDescLabelHeight = [TTLabelTextHelper heightOfText:verifyDescString fontSize:kVerifyLabelFontSize forWidth:self.contentView.frame.size.width - kLeftMargin - kRightMargin];
        //        CGFloat verifyDescLabelHeight = heightOfContent(verifyDescString, self.contentView.frame.size.width - kLeftMargin - kRightMargin, kVerifyLabelFontSize);
        _verifyDescLabel.frame = CGRectMake(kLeftMargin, offsetY + 5, self.contentView.frame.size.width - kLeftMargin - kRightMargin, verifyDescLabelHeight);
        offsetY = (_verifyDescLabel.bottom);
    }
    NSString *userAuthInfo = _friend.userAuthInfo;
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
    [self refreshCountButtons];
    [self refreshVerifyLabel];
    
    
    offsetY = MAX(offsetY, MAX((_verifyInfoLabel.bottom), (_verifyDescLabel.bottom)));
    
    if(!isEmptyString(_recommendReasonLabel.text))
    {
        CGRect _recommendReasonRect = [_recommendReasonLabel textRectForBounds:CGRectMake(0, 0, self.contentView.frame.size.width - kLeftMargin - kRightMargin, 999) limitedToNumberOfLines:2];
        _recommendReasonLabel.frame = CGRectMake((_followingButton.left), offsetY + 5, _recommendReasonRect.size.width, _recommendReasonRect.size.height);
        //        offsetY = SSMaxY(_recommendReasonLabel);
    }
    else
    {
        _recommendReasonLabel.frame = CGRectZero;
    }
    
    _indicator.center = _relationButton.center;
    
    CGRect frame = self.frame;
    
    if(_recommendReasonLabel.frame.size.height > 0)
    {
        frame.size.height = (_recommendReasonLabel.bottom) + kBottomMargin;
    }
    else if (_verifyInfoLabel.frame.size.height > 0) {
        frame.size.height = CGRectGetMaxY(_verifyInfoLabel.frame) + kBottomMargin;
    }
    else if((_verifyDescLabel.bottom) > 0)
    {
        frame.size.height = (_verifyDescLabel.bottom) + kBottomMargin;
    }
    else if (_descLabel.frame.size.height > 0) {
        frame.size.height = CGRectGetMaxY(_descLabel.frame) + kBottomMargin;
    }
    
    else {
        frame.size.height = CGRectGetMaxY(_followedButton.frame) + kBottomMargin;
    }
    self.frame = frame;
    self.contentView.frame = self.bounds;
    
    _bottomSeperatorImageView.frame = CGRectMake(0, self.contentView.frame.size.height - [TTDeviceHelper ssOnePixel], self.contentView.frame.size.width, [TTDeviceHelper ssOnePixel]);
}

- (void)festivalAction:(id)sender
{
    NSURL *url = [TTStringHelper URLWithURLString:self.friend.springFestivalScheme];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
}

- (void)showEditUserView:(id)sender
{
    wrapperTrackEvent(@"profile", @"account");
    
    if([TTAccountManager isLogin])
    {
        TTEditUserProfileViewController *controller = [[TTEditUserProfileViewController alloc] init];
        controller.delegate = self;
        TTNavigationController *naviControll = [[TTNavigationController alloc] initWithRootViewController:controller];
        naviControll.ttDefaultNavBarStyle = @"White";
        
        UIViewController *rootController = [TTUIResponderHelper topViewControllerFor: self];
        [rootController presentViewController:naviControll animated:YES completion:nil];
    } else {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:@"social_other" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"social_other" completion:^(TTAccountLoginState state) {
                }];
            }
        }];
    }
}

- (void)relationButtonClicked:(id)sender
{
    self.relationButton.backgroundColor = [UIColor clearColor];
    
    if ([_friend isAccountUser]) {
        [self showEditUserView:sender];
    }
    else {
        [self startIndicatorAnimation];
        if([TTAccountManager isLogin]) {
            
            if ([_friend.isFollowing boolValue]) {
                WeakSelf;
                [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeUnfollow userID:_friend.userID platform:nil name:_friend.name from:self.from reason:nil newReason:nil newSource:nil completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                    [wself friendDataManager:wself.friendManager finishActionType:FriendActionTypeUnfollow error:error result:({
                        NSMutableDictionary *mutableResult = [result mutableCopy];
                        [mutableResult setValue:wself.friend.userID forKey:@"id"];
                        [mutableResult copy];
                    })];

                }];
                
                wrapperTrackEvent(@"profile", @"unfollow");
            }
            else if ([_friend.isBlocking boolValue]) {
                wrapperTrackEvent(@"profile", @"deblacklist_button");
                wrapperTrackEvent(@"blacklist", @"click_deblacklist");
                [_blockUserManager unblockUser:_friend.userID];
            }
            else if (![_friend.isFollowing boolValue] && [_friend.isBlocked boolValue]) {
                NSString * description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
                if (!description) {
                    description = @" 根据对方设置，您不能进行此操作";
                }
                [self stopIndicatorAnimation];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(description, nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                WeakSelf;
                [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeFollow userID:_friend.userID platform:nil name:_friend.name from:self.from reason:nil newReason:nil newSource:nil completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                    [wself friendDataManager:wself.friendManager finishActionType:FriendActionTypeFollow error:error result:({
                        NSMutableDictionary *mutableResult = [result mutableCopy];
                        [mutableResult setValue:wself.friend.userID forKey:@"id"];
                        [mutableResult copy];
                    })];
                    
                }];
                
                wrapperTrackEvent(@"profile", @"follow");
            }
            if (_fromWidget) {
                wrapperTrackEvent(@"follow_recommend_widget", @"follow_success");
            }
        }
        else {
            [self showEditUserView:sender];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"请先登录", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            [self stopIndicatorAnimation];
        }
        
    }
}

#pragma mark - TTEditUserProfileViewControllerDelegate

- (BOOL)hideDescriptionCellInEditUserProfileController:(TTEditUserProfileViewController *)aController
{
    return NO;
}

- (void)editUserProfileController:(TTEditUserProfileViewController *)aController goBack:(id)sender
{
    [aController dismissViewControllerAnimated:YES completion:nil];
    
    if (![TTAccountManager isLogin]) {
        UINavigationController *nav = nil;
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
        if ([topController isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)topController;
        }
        else {
            nav = topController.navigationController;
        }
        [nav popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - FriendDataManagerDelegate

- (void)friendDataManager:(FriendDataManager *)dataManager finishFriendProfileResult:(NSDictionary *)result error:(NSError *)error
{
    if (_friendManager == dataManager) {
        [_friend updateWithDictionary:result];
        //#warning remove it
        //        _friend.verifySource = NSLocalizedString(@"新浪微博认证", nil);
        //        _friend.verifyDesc = NSLocalizedString(@"二逼认证信息", nil);
        
        [self refreshUI];
        if (_delegate && [_delegate respondsToSelector:@selector(updateFriendUser:introView:)]) {
            [_delegate updateFriendUser:_friend introView:self];
        }
    }
}

- (void)friendDataManager:(FriendDataManager *)dataManager gotFollowersCount:(long long)followerCount followingCount:(long long)followingCount newFriendCount:(long long)newFriendCount pgcLikeCount:(long long)pgcLikeCount error:(NSError *)error
{
    if (error) {
        if (!TTNetworkConnected()) {
        }
        else {
            if ([error.domain isEqualToString:kCommonErrorDomain]) {
                if (error.code == kMissingSessionKeyErrorCode || error.code == kSessionExpiredErrorCode) {
//                    [FriendDataManager clearStatistics];
                }
            }
        }
    }
    else {
        _friend.followerCount = @(followerCount);
        _friend.followingCount = @(followingCount);
        _friend.pgcLikeCount = @(pgcLikeCount);
    }
    
    [self refreshRelationButton];
    [self refreshRelationButton];
    [self stopIndicatorAnimation];
}

- (void)friendDataManager:(FriendDataManager *)dataManager finishActionType:(FriendActionType)type error:(NSError *)error result:(NSDictionary *)result
{
    if (error) {
        if ([error.domain isEqualToString:kCommonErrorDomain]) {
            if (error.code == kSessionExpiredErrorCode) {
//                [FriendDataManager clearStatistics];
                [self showEditUserView:nil];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[error.userInfo objectForKey:kErrorDisplayMessageKey] indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                NSString *notify = [error.userInfo objectForKey:kErrorDisplayMessageKey];
                if (notify) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:notify indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                }
            }
        }
    }
    else {
        switch (type) {
            case FriendActionTypeFollow:
            {
                _friend.isFollowing = @(YES);
                _friend.followerCount = @([_friend.followerCount intValue] + 1);
                
//                if (!_willShowFirstConcernAlert) {
//                    [[TTAuthorizeManager sharedManager].addressObj showAlertAtActionAddFriend:^{
//                        TTAddFriendViewController *addFriendVC = [[TTAddFriendViewController alloc] init];
//                        addFriendVC.autoSynchronizeAddressBook = YES;
//                        [[TTUIResponderHelper topNavigationControllerFor: nil] pushViewController:addFriendVC animated:YES];
//                    }];
//                }
//                else {
                    _willShowFirstConcernAlert = NO;
//                }
            }
                break;
            case FriendActionTypeUnfollow:
            {
                _friend.isFollowing = @(NO);
                _friend.followerCount = @(MAX([_friend.followerCount intValue] - 1, 0));
            }
                break;
            default:
                break;
        }
        
    }
    [self refreshRelationButton];
    [self refreshCountButtons];
    [self stopIndicatorAnimation];
    [_friend postFriendModelChangedNotification];
}

#pragma mark -- TTBlockManagerDelegate

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [self stopIndicatorAnimation];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        _friend.isBlocking = @(NO);
        if ([_friend.isFollowing boolValue]) {
            _friend.isFollowing = @(NO);
        }
        if ([_friend.isFollowed boolValue]) {
            _friend.isFollowed = @(NO);
        }
        
        [self refreshRelationButton];
        [self refreshCountButtons];
        [self stopIndicatorAnimation];
        [_friend postFriendModelChangedNotification];
    }
}

- (void)blockUnblockUserHandler:(NSNotification *)notification
{
    NSDictionary * userInfo = [notification userInfo];
    NSString * userID = [userInfo valueForKey:kBlockedUnblockedUserIDKey];
    if ([userID isEqualToString:_friend.userID]) {
        _friend.isBlocking = [userInfo valueForKey:kIsBlockingKey];
        if ([_friend.isBlocking boolValue]) {
            if ([_friend.isFollowing boolValue]) {
                _friend.isFollowing = @(NO);
            }
            if ([_friend.isFollowed boolValue]) {
                _friend.isFollowed = @(NO);
            }
        }
        
        [self refreshRelationButton];
    }
}

@end
