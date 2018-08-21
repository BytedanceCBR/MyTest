//
//  FriendListCellUnit.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-19.
//
//

#import <QuartzCore/QuartzCore.h>
#import "NewFriendListCellUnit.h"
#import "ArticleFriendModel.h"

#import "TTThirdPartyAccountInfoBase.h"
#import "TTThirdPartyAccountsHeader.h"
#import "SSAvatarView+VerifyIcon.h"

#import "SSABPerson.h"
#import "ArticleAddressManager.h"
#import "SSThemed.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTFollowThemeButton.h"

#define kRelationButtonHeight         28
#define kRelationButtonRightPadding   10
#define kRelationButtonTopPadding     21
#define kRelationButtonTitleFontSize  14

#define kAvatarViewLeftPadding      15
#define kAvatarViewTopPadding       15
#define kAvatarViewWidth            36
#define kAvatarViewHeight           36

#define kTitleLabelFontSize         15
#define kTitleLabelLeftPadding      15
#define kTitleLabelTopPadding       15
#define kTitleLabelRightPadding     72

#define kDescLabelFontSize          12
#define kDescLabelLeftPadding       15
#define kDescLabelTopRPadding       3

@interface NewFriendListCellUnit(){
    ArticleFriendModel *_friendModel;
}
@property(nonatomic, strong)SSThemedLabel * titleLabel;
@property(nonatomic, strong)SSThemedLabel * subTitleLabel1;
@property(nonatomic, strong)SSThemedLabel * subTitleLabel2;
@property(nonatomic, strong, readwrite)UIButton * relationButton;
@property(nonatomic, strong)UIView * bottomLineView;
@property(nonatomic, strong)UIActivityIndicatorView * loadingIndicator;
@property(nonatomic, strong)UIImageView * platformImageView;
@property(nonatomic, strong)UILabel * tipNewLabel;
@end

@implementation NewFriendListCellUnit

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = SSGetThemedColorInArray(@[@"fafafa", @"252525"]);
        
        self.avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(kAvatarViewLeftPadding, kAvatarViewTopPadding, kAvatarViewWidth, kAvatarViewHeight)];
        _avatarView.avatarStyle = SSAvatarViewStyleRound;
        _avatarView.avatarImgPadding = 0;
//        [_avatarView.avatarButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        _avatarView.avatarButton.userInteractionEnabled = NO;
        [_avatarView setupVerifyViewForLength:kAvatarViewWidth adaptationSizeBlock:nil];
        [self addSubview:_avatarView];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColorThemeKey = kColorText2;
        _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        [self addSubview:_titleLabel];
        
        self.tipNewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_tipNewLabel setText:NSLocalizedString(@"新加入", nil)];
        _tipNewLabel.hidden = YES;
        _tipNewLabel.backgroundColor = [UIColor clearColor];
        [_tipNewLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_tipNewLabel sizeToFit];
        [self addSubview:_tipNewLabel];
        
        self.subTitleLabel1 = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel1.textColorThemeKey = kColorText2;
        _subTitleLabel1.backgroundColor = [UIColor clearColor];
        _subTitleLabel1.numberOfLines = 1;
        _subTitleLabel1.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        [self addSubview:_subTitleLabel1];
        
        self.subTitleLabel2 = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel2.backgroundColor = [UIColor clearColor];
        _subTitleLabel2.numberOfLines = 1;
        _subTitleLabel2.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        _subTitleLabel2.textColorThemeKey = kColorText3;
        [self addSubview:_subTitleLabel2];
        
        self.platformImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _platformImageView.hidden = YES;
        [self addSubview:_platformImageView];
        
        self.relationButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_relationButton.titleLabel setFont:[UIFont systemFontOfSize:kRelationButtonTitleFontSize]];
        _relationButton.layer.cornerRadius = 6.f;
        _relationButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _relationButton.hidden = YES;
        [self addSubview:_relationButton];
        
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:_loadingIndicator];
        
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomLineView];
        
        [self reloadThemeUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFriendModelChangedNotification:)
                                                     name:KFriendModelChangedNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorInArray(@[@"fafafa", @"252525"]);
    _bottomLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"363636"]];
    _tipNewLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"00a4ff" nightColorName:@"57607f"]];
}

- (void)refreshVerifyImage
{
    NSString *userAuthInfo = _friendModel.userAuthInfo;
    [_avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
}

- (void)refreshRelationButton
{
    BOOL needStartIndicator = NO;
    
    if (_relationButtonType == FriendListCellUnitRelationButtonHide || _relationButtonType == FriendListCellUnitRelationButtonLoading) {
        _relationButton.hidden = YES;
        
        if (_relationButtonType == FriendListCellUnitRelationButtonLoading) {
            needStartIndicator = YES;
        }
    }
    else {
        _relationButton.hidden = NO;
        
        NSString * rButtonColorString = nil;
        NSString * titleStr = nil;
        NSString * borderColorString = nil;
        switch (_relationButtonType) {
            case FriendListCellUnitRelationButtonFollow:
            {
                rButtonColorString = kColorText6;
                titleStr = NSLocalizedString(@"关注", nil);
                borderColorString = kColorLine5;
            }
                break;
            case FriendListCellUnitRelationButtonFollowingFollowed:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"互相关注", nil);
                borderColorString = kColorLine7 ;
            }
                break;
            case FriendListCellUnitRelationButtonCancelFollow:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"取消关注", nil);
                borderColorString = kColorLine7;
            }
                break;
            case FriendListCellUnitRelationButtonInviteFriend:
            {
                rButtonColorString = kColorText6;
                titleStr = NSLocalizedString(@"告诉TA", nil);
                borderColorString = kColorLine5;
            }
                break;
            case FriendListCellUnitRelationButtonInvitedFriend:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"已发送", nil);
                borderColorString = kColorLine7;
            }
                break;
            case FriendListCellUnitRelationButtonCancelBlock:
            {
                rButtonColorString = kColorText6;
                titleStr = NSLocalizedString(@"解除", nil);
                borderColorString = kColorLine5;
            }
                break;
            case FriendListCellUnitRelationButtonBlock:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"已解除", nil);
                borderColorString = kColorLine7;
            }
                break;
            default:
                break;
        }
        
        if ([SSCommonLogic followButtonDefaultColorStyleRed]) {
            if ([rButtonColorString isEqualToString:kColorText6]) {
                rButtonColorString = kColorText4;
            }
            if ([borderColorString isEqualToString:kColorLine5]) {
                borderColorString = kColorLine4;
            }
        }
        
        if (!isEmptyString(borderColorString)) {
            _relationButton.layer.borderColor = [SSGetThemedColorWithKey(borderColorString) CGColor];
        }
        if (!isEmptyString(rButtonColorString)) {
            [_relationButton setTitleColor:SSGetThemedColorWithKey(rButtonColorString) forState:UIControlStateNormal];
        }
        if (!isEmptyString(titleStr)) {
            [_relationButton setTitle:titleStr forState:UIControlStateNormal];
            [_relationButton sizeToFit];
            _relationButton.width = _relationButton.frame.size.width + 16;
            [_relationButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        }
        
    }
    
    if (needStartIndicator) {
        [_loadingIndicator startAnimating];
        _loadingIndicator.hidden = NO;
    }
    else {
        [_loadingIndicator stopAnimating];
        _loadingIndicator.hidden = YES;
    }
    _relationButton.origin = CGPointMake(CGRectGetWidth(self.frame) - kTitleLabelRightPadding + (kTitleLabelRightPadding - kRelationButtonRightPadding - _relationButton.frame.size.width) / 2.f,
                       (CGRectGetHeight(self.frame) - kRelationButtonHeight) / 2.f);
    _loadingIndicator.center = _relationButton.center;
}

- (void)refreshPlatform
{
    NSString * platformNameStr = _friendModel.platformString;
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
    // 如果image为空或者没有姓名，则不展示这个图标了
    _platformImageView.hidden = (imageName == nil || (isEmptyString(_friendModel.platformScreenName) && ![_friendModel.recommendReason isEqualToString:NSLocalizedString(@"通讯录好友", nil)]));
    _platformImageView.image = [UIImage themedImageNamed:imageName];
    [_platformImageView sizeToFit];
    _platformImageView.origin = CGPointMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame) + kDescLabelTopRPadding + 2);
}

#pragma mark -- public


- (void)setFriendModel:(ArticleFriendModel*)model {
    _friendModel = model;
    [self updateTitleText];
    [self updateSubTitle1Text];
    [self updateSubTitle2Text];
    [self refreshAvatarView];
    [self refreshPlatform];
    [self refreshVerifyImage];
    [self showTipNew:model.isNew];
}

- (void)refreshAvatarView
{
    [_avatarView showAvatarByURL:_friendModel.avatarURLString];
}

- (void)updateTitleText
{
    _titleLabel.text = _friendModel.name;
}

- (void)updateSubTitle1Text
{
    // 晓东需求，如果是通讯录/微博好友，则展示名字，如果名字为空，则展示推荐理由，如果没有推荐理由，则不展示（不展示的逻辑在其他地方有做
    NSString *subtitle = _friendModel.platformScreenName;
    if (isEmptyString(subtitle)) {
        subtitle = _friendModel.recommendReason;
    }
    _subTitleLabel1.text = subtitle;
}

- (void)updateSubTitle2Text
{
    if(!isEmptyString(_friendModel.verifiedContent))
    {
        _subTitleLabel2.text = _friendModel.verifiedContent;
    }
    else if(!isEmptyString(_friendModel.userDescription))
    {
        _subTitleLabel2.text = _friendModel.userDescription;
    }
    else
    {
        _subTitleLabel2.text = @"";
    }
}


- (void)showTipNew:(BOOL)show
{
    _tipNewLabel.hidden = !show;
}

- (CGFloat)calculateHeight
{
    if (isEmptyString(_titleLabel.text)) return 0;
    
    CGFloat offsetY = kTitleLabelTopPadding;
    CGRect titleRect = [_titleLabel textRectForBounds:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX) limitedToNumberOfLines:1];
    offsetY = offsetY + titleRect.size.height + kDescLabelTopRPadding;
    CGRect subtitle1Rect =  [_subTitleLabel1 textRectForBounds:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX) limitedToNumberOfLines:1];
    if((subtitle1Rect.size.height) > 0)
    {
        offsetY = offsetY + subtitle1Rect.size.height + kDescLabelTopRPadding;
    }
    CGRect subTitle2Rect = [_subTitleLabel2 textRectForBounds:CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX) limitedToNumberOfLines:1];
    if((subTitle2Rect.size.height) > 0)
    {
        offsetY = offsetY + subTitle2Rect.size.height + kDescLabelTopRPadding;
    }
    offsetY = offsetY + 12 + [TTDeviceHelper ssOnePixel];
    
    return ceilf(offsetY);
}

- (void)refreshFrame
{
    [_titleLabel sizeToFit];

    CGFloat titleOriginX = (_avatarView.right) + kTitleLabelLeftPadding;
    CGFloat currentTitleLength = (_titleLabel.width);
    CGFloat titleMaxLength = self.width - titleOriginX - ((_relationButtonType == FriendListCellUnitRelationButtonHide || _relationButtonType == FriendListCellUnitRelationButtonLoading) ? kAvatarViewLeftPadding : kTitleLabelRightPadding) - 10;
    _titleLabel.frame = CGRectMake(titleOriginX, kTitleLabelTopPadding,
                                   currentTitleLength < titleMaxLength ? currentTitleLength : titleMaxLength, CGRectGetHeight(_titleLabel.frame));
    
    _tipNewLabel.origin = CGPointMake(CGRectGetMaxX(_titleLabel.frame) + 3, CGRectGetMinY(_titleLabel.frame) + 2);
    
    [_platformImageView sizeToFit];
    _platformImageView.origin = CGPointMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame) + kDescLabelTopRPadding + 2);
    
    CGFloat descLabelOriginX = _platformImageView.hidden ? CGRectGetMinX(_titleLabel.frame) : (CGRectGetMaxX(_platformImageView.frame) + 5);
    CGFloat delta = descLabelOriginX - CGRectGetMinX(_titleLabel.frame);
    
    CGFloat descLength = titleMaxLength - delta;
    
    CGRect subtitle1Rect =  [_subTitleLabel1 textRectForBounds:CGRectMake(0, 0, descLength, 999) limitedToNumberOfLines:1];
    
    CGFloat offsetY = (_titleLabel.bottom) + kDescLabelTopRPadding;
    
    _subTitleLabel1.frame = CGRectMake(descLabelOriginX, offsetY,
                                  descLength, subtitle1Rect.size.height);
    
    if((_subTitleLabel1.height) > 0)
    {
        offsetY = (_subTitleLabel1.bottom) + kDescLabelTopRPadding;
    }
    
    CGRect subTitle2Rect = [_subTitleLabel2 textRectForBounds:CGRectMake(0, 0, titleMaxLength, 999) limitedToNumberOfLines:1];
    _subTitleLabel2.frame = CGRectMake(titleOriginX, offsetY, titleMaxLength, subTitle2Rect.size.height);
    
    if((_subTitleLabel2.height) > 0)
    {
        offsetY = (_subTitleLabel2.bottom) + kDescLabelTopRPadding;
    }
    
    offsetY += 12;
    
    _bottomLineView.frame = CGRectMake(kAvatarViewLeftPadding, offsetY, CGRectGetWidth(self.frame) - kAvatarViewLeftPadding * 2, [TTDeviceHelper ssOnePixel]);
    _cellUnitHeight = ceilf(_bottomLineView.bottom);
    self.height = _cellUnitHeight;
    
    _relationButton.origin = CGPointMake(CGRectGetWidth(self.frame) - kTitleLabelRightPadding + (kTitleLabelRightPadding - kRelationButtonRightPadding - _relationButton.frame.size.width) / 2.f,
                                         (CGRectGetHeight(self.frame) - kRelationButtonHeight) / 2.f);
    _loadingIndicator.center = _relationButton.center;
}

#pragma mark -- setter

- (void)setRelationButtonType:(FriendListCellUnitRelationButtonType)relationButtonType
{
    _relationButtonType = relationButtonType;
    
    [self refreshRelationButton];
}

#pragma mark -- Notification Handler

- (void)handleFriendModelChangedNotification:(NSNotification *)notification
{
    NSDictionary * userInfo = [notification userInfo];
    NSString *userID = [userInfo valueForKey:kFriendModelUserIDKey];
    if (![_friendModel.ID isEqualToString:userID]) {
        return;
    }
    
    BOOL isFollowing = [[userInfo valueForKey:kFriendModelISFollowingKey] boolValue];
    BOOL isFollowed = [[userInfo valueForKey:kFriendModelISFollowedKey] boolValue];
    BOOL isBlocking = [[userInfo valueForKey:kFriendModelISBlockingKey] boolValue];
    
    switch (_relationButtonType) {
        case FriendListCellUnitRelationButtonFollowingFollowed:
        case FriendListCellUnitRelationButtonCancelFollow:
        case FriendListCellUnitRelationButtonFollow: // "粉丝" “关注”
            if (isFollowing && isFollowed) {
                _relationButtonType = FriendListCellUnitRelationButtonFollowingFollowed;
            } else if (isFollowing) {
                _relationButtonType = FriendListCellUnitRelationButtonCancelFollow;
            } else if (!isFollowing) {
                _relationButtonType = FriendListCellUnitRelationButtonFollow;
            }
            
            [self refreshRelationButton];
            break;
        case FriendListCellUnitRelationButtonCancelBlock:
        case FriendListCellUnitRelationButtonBlock: // "黑名单"
            if (isBlocking) {
                _relationButtonType = FriendListCellUnitRelationButtonCancelBlock;
            } else {
                _relationButtonType = FriendListCellUnitRelationButtonBlock;
            }
            
            [self refreshRelationButton];
            break;
        default:
            break;
    }
    
}

@end
