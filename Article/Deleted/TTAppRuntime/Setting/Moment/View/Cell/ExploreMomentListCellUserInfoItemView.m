//
//  ExploreMomentListCellUserInfoItemView.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "ExploreMomentListCellUserInfoItemView.h"
#import "SSUserModel.h"
#import "ArticleAvatarView.h"
#import <TTAccountBusiness.h>
#import "ArticleMomentHelper.h"
#import "TTImageView.h"
#import "SSCommentModel.h"
#import "TTUserInfoView.h"
#import "TTLabelTextHelper.h"
#import "TTDiggButton.h"
#import "UIButton+TTAdditions.h"
#import "TTDeviceUIUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTUserInfoView.h"
#import "TTTabBarProvider.h"

#define kAvatarViewNormalWidth              36
#define kAvatarViewHeight                   [TTDeviceUIUtils tt_paddingForMoment:36]
#define kAvatarViewWidth                    [TTDeviceUIUtils tt_paddingForMoment:36]
#define kAvatarViewLeftPadding              [TTDeviceUIUtils tt_paddingForMoment:15]
#define kAvatarViewTopPadding               [TTDeviceUIUtils tt_paddingForMoment:20]

#define kUserViewTopPadding                 [TTDeviceUIUtils tt_paddingForMoment:24]
#define kUserViewVerticalGap                [TTDeviceUIUtils tt_paddingForMoment:2]
#define kNameLabelRightPadding              80
#define kAvatarViewBottomPadding            [TTDeviceUIUtils tt_paddingForMoment:8]

#define kDiggButtonRightPadding             [TTDeviceUIUtils tt_paddingForMoment:15]

@interface ExploreMomentListCellUserInfoItemView()
@property(nonatomic, strong)ArticleAvatarView * avatarView;
@property(nonatomic, strong)TTUserInfoView * userView;
@property(nonatomic, strong)UILabel * reasonLabel;
@property(nonatomic, strong)UILabel * timeLabel;
//@property(nonatomic, strong)SSThemedButton * reportButton;
@end

@implementation ExploreMomentListCellUserInfoItemView

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    self = [super initWithWidth:cellWidth userInfo:uInfo];
    if (self) {
        self.avatarView = [[ArticleAvatarView alloc] initWithFrame:CGRectMake(kAvatarViewLeftPadding, kAvatarViewTopPadding, kAvatarViewWidth, kAvatarViewHeight)];
        [self.avatarView setupVerifyViewForLength:kAvatarViewNormalWidth adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_sizeForMoment:standardSize];
        }];
        _avatarView.avatarStyle = SSAvatarViewStyleRound;
        _avatarView.avatarImgPadding = 0;
        _avatarView.userInteractionEnabled = YES;
        [_avatarView.avatarButton addTarget:self action:@selector(avatarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_avatarView];
        
        self.reasonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reasonLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        _reasonLabel.numberOfLines = 1;
        _reasonLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_reasonLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        _timeLabel.numberOfLines = 1;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
//        _reportButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
//        _reportButton.titleLabel.font = _timeLabel.font;
//        [_reportButton setTitle:@" · 举报" forState:UIControlStateNormal];
//        [_reportButton sizeToFit];
//        _reportButton.hitTestEdgeInsets = UIEdgeInsetsMake(-6, -8, -8, -8);
//        [_reportButton addTarget:self action:@selector(reportButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_reportButton];
        
        self.arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowButton.frame = CGRectMake(0, 0, 40, 30);
        [self addSubview:_arrowButton];
        
        self.diggButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeBigNumber];
        [self.diggButton setImageEdgeInsets:UIEdgeInsetsMake(0, -[TTDeviceUIUtils tt_newPadding:3.f], 0, 0)];
        [self.diggButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
        [self addSubview:_diggButton];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    _timeLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
//    [_reportButton setTitleColor:_timeLabel.textColor forState:UIControlStateNormal];
    _reasonLabel.textColor = [UIColor tt_themedColorForKey:kColorText4];
    
    [_arrowButton setImage:[UIImage themedImageNamed:@"morebutton_dynamic.png"] forState:UIControlStateNormal];
    [_arrowButton setImage:[UIImage themedImageNamed:@"morebutton_dynamic_press.png"] forState:UIControlStateHighlighted];
}

- (void)setShowTimeLabel:(BOOL)showTimeLabel
{
    _showTimeLabel = showTimeLabel;
    _timeLabel.hidden = !showTimeLabel;
}

- (void)refreshForMomentModel:(ArticleMomentModel *)model
{
    [super refreshForMomentModel:model];
    if (model.digged) {
        [self.diggButton setSelected:YES];
    }
    
    [self.diggButton setDiggCount:model.diggsCount];
    [self.diggButton sizeToFit];
    
    NSString * avatarUrl = model.user.avatarURLString;
    if ([model.user.ID isEqualToString:[TTAccountManager userID]]) {
        avatarUrl = [TTAccountManager avatarURLString];
    }
    [_avatarView showAvatarByURL:avatarUrl];
    [_avatarView showOrHideVerifyViewWithVerifyInfo:model.user.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

    
    CGFloat nameLabelOriginX = kMomentCellItemViewLeftPadding;
    BOOL needShowReason = NO;
    if (!isEmptyString(model.reason)) {
        needShowReason = YES;
    }
    _reasonLabel.hidden = !needShowReason;
    if (needShowReason) {
        [_reasonLabel setText:model.reason];
        [_reasonLabel sizeToFit];
        CGFloat reasonLabelWidth = MIN((_reasonLabel.width), self.width / 2) ;
        _reasonLabel.frame = CGRectMake(nameLabelOriginX, kUserViewTopPadding - kUserViewVerticalGap - (_reasonLabel.height),reasonLabelWidth, (_reasonLabel.height));
    }
    
    NSString * showName = @"";
    if (!isEmptyString(model.user.name)) {
        showName = model.user.name;
    }
    if (!isEmptyString(showName) && !isEmptyString(model.actionDescription)) {
        showName = [NSString stringWithFormat:@"%@  %@", model.user.name, model.actionDescription];
    }
    if ([model.user.ID isEqualToString:[TTAccountManager userID]]) {
        showName = [TTAccountManager userName];
    }
    
    if (!_userView) {
        _userView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(nameLabelOriginX, kUserViewTopPadding) maxWidth:self.width - nameLabelOriginX - kNameLabelRightPadding limitHeight:21.f title:showName fontSize:[TTDeviceUIUtils tt_fontSizeForMoment:16.f] verifiedInfo:model.user.verifiedReason verified:NO owner:NO appendLogoInfoArray:model.user.authorBadgeList];
        _userView.textColorThemedKey = kColorText5;
        [self addSubview:_userView];
    }
    else {
        [_userView refreshWithTitle:showName relation:nil verifiedInfo:model.user.verifiedReason verified:NO owner:NO maxWidth:self.width - nameLabelOriginX - kNameLabelRightPadding appendLogoInfoArray:model.user.authorBadgeList];
    }
    
    __weak typeof(self) wSelf = self;
    [_userView clickTitleWithAction:^(NSString *title) {
        [wSelf nameButtonClicked];
    }];
    
    SSCommentModel *commentModel;
    UIResponder *needResponder = [self _needResponder];
    if (needResponder) {
        if ([needResponder respondsToSelector:NSSelectorFromString(@"commentModel")]) {
            commentModel = [needResponder valueForKey:@"commentModel"];
        }
    }
    
    NSString * timeLabelStr = [TTBusinessManager customtimeStringSince1970:model.createTime];
    if (!isEmptyString(model.deviceModelString)) {
        timeLabelStr = [NSString stringWithFormat:@"%@  %@", timeLabelStr, model.deviceModelString];
    }
    [_timeLabel setText:timeLabelStr];
    [_timeLabel sizeToFit];
    _timeLabel.origin = CGPointMake(nameLabelOriginX, kUserViewTopPadding + (_userView.height) + kUserViewVerticalGap);
    
//    self.reportButton.hidden = !self.shouldAddReportEntrance;
//    self.reportButton.left = _timeLabel.right;
//    self.reportButton.centerY = _timeLabel.centerY;
    
    if (self.sourceType == ArticleMomentSourceTypeMoment || self.sourceType == ArticleMomentSourceTypeProfile) {
        _arrowButton.origin = CGPointMake(self.width - (_arrowButton.width), 10);
        _diggButton.hidden = YES;
    }
    else{
        _diggButton.left = self.width - (_diggButton.width) - kDiggButtonRightPadding;
        _diggButton.centerY = _userView.centerY - 2;
        _arrowButton.hidden = YES;
    }
}

- (UIResponder *)_needResponder
{
    if ([self respondsToSelector:@selector(nextResponder)]) {
        UIResponder *responder = [self performSelector:@selector(nextResponder) withObject:nil];
        while (responder) {
            if ([responder isKindOfClass:NSClassFromString(@"ArticleMomentDetailViewController")]) {
                return responder;
            }
            responder = [responder nextResponder];
        }
    }
    return nil;
}

- (void)avatarButtonClicked
{
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"avatar" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
    }
    wrapperTrackEvent(@"update_detail",@"click_avatar");
    [self goToUserProfileView];
}

- (void)nameButtonClicked
{
    if (self.sourceType == ArticleMomentSourceTypeMoment) {
        if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.momentModel.ID forKey:@"item_id"];
            [extra setValue:self.momentModel.group.ID forKey:@"value"];
            [TTTrackerWrapper event:@"micronews_tab" label:@"avatar" value:nil extValue:nil extValue2:nil dict:[extra copy]];
        }
    }
    wrapperTrackEvent(@"update_detail", @"click_name");
    [self goToUserProfileView];
}

//- (void)reportButtonClicked
//{
//    if (self.trigReportActionBlock) {
//        self.trigReportActionBlock();
//    }
//}

- (void)goToUserProfileView
{
    [ArticleMomentHelper openMomentProfileView:self.momentModel.user navigationController:[TTUIResponderHelper topNavigationControllerFor: self] from:kFromFeedItem];
}

- (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth
{
    return [ExploreMomentListCellUserInfoItemView heightForMomentModel:model cellWidth:cellWidth userInfo:self.userInfo];
}

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model cellWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo
{
    if (![self needShowForModel:model userInfo:uInfo]) {
        return 0;
    }
    
    return kAvatarViewTopPadding + kAvatarViewHeight + kAvatarViewBottomPadding;
}

+ (BOOL)needShowForModel:(ArticleMomentModel *)model userInfo:(NSDictionary *)uInfo
{
    return YES;
}
@end
