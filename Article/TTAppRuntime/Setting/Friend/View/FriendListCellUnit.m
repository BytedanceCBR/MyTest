//
//  FriendListCellUnit.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-19.
//
//

#import <QuartzCore/QuartzCore.h>
#import "FriendListCellUnit.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "TTIconLabel+VerifyIcon.h"

#define kRelationButtonWidth          51
#define kRelationButtonHeight         24
#define kRelationButtonRightPadding   15
#define kRelationButtonTopPadding     21
#define kRelationButtonTitleFontSize  11

#define kAvatarViewLeftPadding      15
#define kAvatarViewTopPadding       15
#define kAvatarViewWidth            36
#define kAvatarViewHeight           36

#define kTitleLabelFontSize         15
#define kTitleLabelLeftPadding      15
#define kTitleLabelTopPadding       15
#define kTitleLabelRightPadding     (kRelationButtonRightPadding + kRelationButtonWidth)

#define kDescLabelFontSize          12
#define kDescLabelLeftPadding       15
#define kDescLabelTopRPadding       3

@interface FriendListCellUnit()
@property(nonatomic, retain)TTIconLabel * titleLabel;
@property(nonatomic, retain)UILabel * descLabel;
@property(nonatomic, retain)SSAvatarView * avatarView;
@property(nonatomic, retain, readwrite)UIButton * relationButton;
@property(nonatomic, retain)UIView * bottomLineView;
@property(nonatomic, retain)UIActivityIndicatorView * loadingIndicator;
@property(nonatomic, retain)UIImageView * platformImageView;
@property(nonatomic, assign)FriendListCellUnitPlatformType platformType;
@property(nonatomic, retain)UILabel * tipNewLabel;
@end

@implementation FriendListCellUnit

- (void)dealloc
{
    self.tipNewLabel = nil;
    self.platformImageView = nil;
    self.loadingIndicator = nil;
    self.bottomLineView = nil;
    self.relationButton = nil;
    self.titleLabel= nil;
    self.descLabel = nil;
    self.avatarView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _platformType = FriendListCellUnitPlatformTypeHide;
        self.avatarView = [[SSAvatarView alloc] initWithFrame:CGRectMake(kAvatarViewLeftPadding, kAvatarViewTopPadding, kAvatarViewWidth, kAvatarViewHeight)];
        _avatarView.avatarStyle = SSAvatarViewStyleRectangle;
        _avatarView.rectangleAvatarImgRadius = 2.f;
        _avatarView.avatarImgPadding = 0;
        [self addSubview:_avatarView];
        
        self.titleLabel = [[TTIconLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        [self addSubview:_titleLabel];
        
        self.tipNewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_tipNewLabel setText:NSLocalizedString(@"新加入", nil)];
        _tipNewLabel.hidden = YES;
        _tipNewLabel.backgroundColor = [UIColor clearColor];
        [_tipNewLabel setFont:[UIFont systemFontOfSize:12.f]];
        [_tipNewLabel sizeToFit];
        [self addSubview:_tipNewLabel];
        
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        [self addSubview:_descLabel];
        
        self.platformImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _platformImageView.hidden = YES;
        [self addSubview:_platformImageView];
        
        self.relationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _relationButton.frame = CGRectMake(0, 0, kRelationButtonWidth, kRelationButtonHeight);
        [_relationButton.titleLabel setFont:[UIFont systemFontOfSize:kRelationButtonTitleFontSize]];
        _relationButton.layer.cornerRadius = 2.f;
        _relationButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _relationButton.hidden = YES;
        [self addSubview:_relationButton];
        
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:_loadingIndicator];
        
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomLineView];
        
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _bottomLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"363636"]];
    _titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"303030" nightColorName:@"707070"]];
    _descLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"707070" nightColorName:@"505050"]];
    _tipNewLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"00a4ff" nightColorName:@"57607f"]];
}

- (CGRect)frameForRelationButton
{
    CGRect rect = CGRectMake(self.frame.size.width - kRelationButtonRightPadding - kRelationButtonWidth, kRelationButtonTopPadding, kRelationButtonWidth, kRelationButtonHeight);
    return rect;
}

- (void)refreshVerifyImage
{
    [self.titleLabel removeAllIcons];
    if (_verifyType != FriendListCellUnitVerifyTypeHide) {
        [self.titleLabel addIconWithVerifyInfo:nil];
    }
    [self.titleLabel refreshIconView];
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
                rButtonColorString = kColorText4;
                titleStr = NSLocalizedString(@"+ 关注", nil);
                borderColorString = kColorText4;
            }
                break;
            case FriendListCellUnitRelationButtonFollowingFollowed:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"互相关注", nil);
                borderColorString = kColorText3;
            }
                break;
            case FriendListCellUnitRelationButtonCancelFollow:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"取消关注", nil);
                borderColorString = kColorText3;
            }
                break;
            case FriendListCellUnitRelationButtonInviteFriend:
            {
                rButtonColorString = kColorText4;
                titleStr = NSLocalizedString(@"告诉TA", nil);
                borderColorString = kColorText4;
            }
                break;
            case FriendListCellUnitRelationButtonInvitedFriend:
            {
                rButtonColorString = kColorText3;
                titleStr = NSLocalizedString(@"已发送", nil);
                borderColorString = kColorText3;
            }
                break;
            default:
                break;
        }
        
        if (!isEmptyString(borderColorString)) {
            _relationButton.layer.borderColor = [UIColor tt_themedColorForKey:borderColorString].CGColor;
        }
        if (!isEmptyString(rButtonColorString)) {
            [_relationButton setTitleColor:[UIColor tt_themedColorForKey:rButtonColorString] forState:UIControlStateNormal];
        }
        if (!isEmptyString(titleStr)) {
            [_relationButton setTitle:titleStr forState:UIControlStateNormal];
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
    
    _relationButton.origin = CGPointMake(CGRectGetWidth(self.frame) - kRelationButtonWidth - kRelationButtonRightPadding,
                       (CGRectGetHeight(self.frame) - kRelationButtonHeight) / 2.f);
    _loadingIndicator.center = _relationButton.center;
}

- (void)refreshPlatform
{
    NSString * platformNameStr = nil;

    switch (_platformType) {
        case FriendListCellUnitPlatformTypeSinaWeibo:
        {
            platformNameStr = @"noticeable_approve_sina.png";
        }
            break;
        case FriendListCellUnitPlatformTypeQQZone:
        {
            platformNameStr = @"noticeable_approve_qzone.png";
        }
            break;
        case FriendListCellUnitPlatformTypeTencentWeibo:
        {
            platformNameStr = @"noticeable_approve_qqweibo.png";
        }
            break;
        case FriendListCellUnitPlatformTypeRenRen:
        {
            platformNameStr = @"noticeable_approve_renren.png";
        }
            break;
        case FriendListCellUnitPlatformTypeKaixin:
        {
            platformNameStr = @"noticeable_approve_kaixin.png";
        }
            break;
        default:
        {
        }
            break;
    }
    
    _platformImageView.hidden = platformNameStr == nil;
    _platformImageView.image = [UIImage themedImageNamed:platformNameStr];
    [_platformImageView sizeToFit];
    _platformImageView.origin = CGPointMake(CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame) + kDescLabelTopRPadding);
}

#pragma mark -- public

- (void)setPlatformType:(FriendListCellUnitPlatformType)platformType
{
    _platformType = platformType;
    [self refreshPlatform];
}

- (void)showTipNew:(BOOL)show
{
    _tipNewLabel.hidden = !show;
}

- (void)setTitleText:(NSString *)title
{
    [_titleLabel setText:title];
}

- (void)setAvatarURLString:(NSString *)avatarURLString
{
    [_avatarView showAvatarByURL:avatarURLString];
}

- (void)setDesc:(NSString *)desc
{
    [_descLabel setText:desc];
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
    
    [self refreshPlatform];
    CGFloat descLabelOriginX = _platformImageView.hidden ? CGRectGetMinX(_titleLabel.frame) : (CGRectGetMaxX(_platformImageView.frame) + 5);
    CGFloat delta = descLabelOriginX - CGRectGetMinX(_titleLabel.frame);
    [_descLabel sizeToFit];
    CGFloat descLength = MIN(CGRectGetWidth(_descLabel.frame), (titleMaxLength - delta));
    _descLabel.frame = CGRectMake(descLabelOriginX, CGRectGetMaxY(_titleLabel.frame) + kDescLabelTopRPadding,
                                  descLength, CGRectGetHeight(_descLabel.frame));
    
    [self refreshVerifyImage];
    [self refreshRelationButton];
    
    _bottomLineView.frame = CGRectMake(kAvatarViewLeftPadding, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) - kAvatarViewLeftPadding * 2, [TTDeviceHelper ssOnePixel]);
}

#pragma mark -- setter

- (void)setRelationButtonType:(FriendListCellUnitRelationButtonType)relationButtonType
{
    _relationButtonType = relationButtonType;
    
    [self refreshRelationButton];
}



@end
