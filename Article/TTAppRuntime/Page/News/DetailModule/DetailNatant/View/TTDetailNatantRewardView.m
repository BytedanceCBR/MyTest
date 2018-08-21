//
//  TTDetailNatantRewardView.m
//  Article
//
//  Created by 刘廷勇 on 16/4/29.
//
//

#import "TTDetailNatantRewardView.h"
#import "TTAlphaThemedButton.h"
#import "SSAvatarView+VerifyIcon.h"
#import "TTDiggButton.h"
//#import "UIButton+TTCache.h"

#import "ExploreItemActionManager.h"
#import "ArticleInfoManager.h"
#import "TTReportManager.h"

#import "NewsDetailLogicManager.h"

#import "TTDeviceHelper.h"
#import "TTIndicatorView.h"
#import "UIButton+TTAdditions.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <QuartzCore/QuartzCore.h>

#define ButtonWidth 112.f / 345.f * self.width
#define ButtonHeight [TTDeviceUIUtils tt_newPadding:36]

static CGFloat const avatarWidth          = 24;
static CGFloat const leftMargin           = 0;
static CGFloat const rightMargin          = 0;
static CGFloat const rewardLabelLeftInset = 9;

@interface TTDetailNatantRewardView ()

@property (nonatomic, strong) TTAlphaThemedButton *rewardButton;
@property (nonatomic, strong) TTDiggButton        *digButton;
@property (nonatomic, strong) TTAlphaThemedButton *avatarContainer;
@property (nonatomic, strong) SSThemedLabel       *rewardLabel;
@property (nonatomic, strong) TTAlphaThemedButton *reportButton;
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;

@end

@implementation TTDetailNatantRewardView

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        [self buildView];
        [self themeChanged:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layout];
    if (self.relayOutBlock) {
        self.relayOutBlock(YES);
    }
}

- (void)buildView
{
    [self addSubview:self.rewardButton];
    [self addSubview:self.digButton];
    [self addSubview:self.reportButton];
    [self addSubview:self.avatarContainer];
    [self addSubview:self.rewardLabel];
}

- (void)layout
{
    self.rewardButton.frame = CGRectMake(0, 0, ButtonWidth, ButtonHeight);
    self.digButton.frame = CGRectMake(0, 0, ButtonWidth, ButtonHeight);
    self.reportButton.frame = CGRectMake(0, 0, ButtonWidth, ButtonHeight);
    if ([self showReward]) {
        self.rewardButton.hidden = NO;
        
        if (self.viewModel.rewardUserList.count > 0) {
            self.avatarContainer.hidden = NO;
            self.avatarContainer.left = self.rewardButton.left;
            self.avatarContainer.top = self.rewardButton.bottom + 16;
            
            [self.rewardLabel sizeToFit];
            self.rewardLabel.hidden = NO;
            self.rewardLabel.centerY = self.avatarContainer.centerY;
            self.rewardLabel.left = self.avatarContainer.right + rewardLabelLeftInset;
        } else {
            self.avatarContainer.hidden = YES;
            self.rewardLabel.hidden = YES;
        }
        
        self.digButton.left = self.rewardButton.right + 4.5f;
        self.reportButton.left = self.digButton.right + 4.5f;
        
    } else {
        self.rewardButton.hidden = YES;
        self.avatarContainer.hidden = YES;
        self.rewardLabel.hidden = YES;
        
        self.digButton.left = self.width * 35.0f / 345.0f;
        self.reportButton.left = self.digButton.right + self.width * 51.0f / 345.0f;
//        self.digButton.left = self.width * 35.0f / 375.0f;
//        self.reportButton.left = self.digButton.right + self.width * 51.0f / 375.0f;
    }
    
    if (self.viewModel.rewardUserList.count > 0 && [self showReward]) {
        self.height = self.avatarContainer.bottom;
    } else {
        self.height = self.rewardButton.bottom;
    }
}

- (void)reloadData:(id)object
{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager *manager = object;
    NSDictionary *modelDict = [manager.ordered_info valueForKey:kDetailNatantLikeAndReWardsKey];
    if (modelDict) {
        TTDetailNatantRewardViewModel *rewardModel = [[TTDetailNatantRewardViewModel alloc] initWithDictionary:modelDict error:nil];
        self.detailModel = manager.detailModel;
        self.viewModel = rewardModel;
    }
}

- (void)trackEventIfNeededWithStyle:(NSString *)style {
    if (!self.hasShow) {
        Article * article = self.detailModel.article;
        NSMutableDictionary * extDict = [[NSMutableDictionary alloc] init];
        [extDict setValue:article.itemID forKey:@"item_id"];
        [extDict setValue:self.goDetailLabel forKey:@"source"];
        [extDict setValue:style forKey:@"style"];
        if ([self.detailModel.adID longLongValue] > 0) {
            [extDict setValue:self.detailModel.adID forKey:@"aid"];
        }
        wrapperTrackEventWithCustomKeys(@"detail", @"report_and_dislike_show", @(article.uniqueID).stringValue, nil, extDict);
        self.hasShow = YES;
    }
}

- (void)trackEventIfNeeded{
    if (!self.hasShow) {
        Article * article = self.detailModel.article;
        NSMutableDictionary * extDict = [[NSMutableDictionary alloc] init];
        [extDict setValue:article.itemID forKey:@"item_id"];
        [extDict setValue:self.goDetailLabel forKey:@"source"];
        [extDict setValue:@"" forKey:@"style"];
        [TTTrackerWrapper event:@"detail"
                   label:@"report_and_dislike_show"
                   value:@(article.uniqueID)
                extValue:self.detailModel.adID
               extValue2:nil
                    dict:extDict];
        self.hasShow = YES;
    }
}

- (void)trackEventWithLabel:(NSString *)label{
    [NewsDetailLogicManager trackEventTag:@"detail"
                                    label:label
                                    value:@(self.detailModel.article.uniqueID)
                                 extValue:nil
                                     adID:self.detailModel.adID
                               groupModel:self.detailModel.article.groupModel];

}

- (void)filterWordIsEmpty {
    [self.reportButton setTitle:@"举报" forState:UIControlStateNormal];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [self.reportButton setImage:[UIImage imageNamed:@"details_report_icon"] forState:UIControlStateNormal];
    }
    else {
        [self.reportButton setImage:[UIImage imageNamed:@"details_report_icon_night"] forState:UIControlStateNormal];
    }
    [self.reportButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
}


#pragma mark -
#pragma mark action

- (void)clickReward:(id)sender
{
    [self trackEventWithLabel:@"rewards"];
    NSString *requestURL = self.viewModel.rewardOpenURL;
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:requestURL]];
}

- (void)showRewardList
{
    [self trackEventWithLabel:@"rewards_user_view"];
    NSString *requestURL = self.viewModel.rewardListURL;
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:requestURL]];
}

- (void)showReport
{
    if (self.clickReportBlock) {
        self.clickReportBlock();
    }
}

- (void)updateDigButton
{
    int digCnt = [self.detailModel.article.likeCount intValue];
    [self.digButton setDiggCount:digCnt];
    if ([self.detailModel.article.userLike boolValue]) {
        [self.digButton setSelected:YES];
        self.digButton.borderColorThemeKey = @"ff0031";
    } else {
        [self.digButton setSelected:NO];
        self.digButton.borderColorThemeKey = kColorLine7;
    }
//    [self.digButton sizeToFit];
}

- (BOOL)showReward
{
    if ([[self.detailModel.article.h5Extra valueForKeyPath:@"media.can_be_praised"] boolValue]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark reload

- (void)update
{
    [self updateDigButton];
    
    NSString *num = [self.viewModel.rewardNum stringValue];
    self.rewardLabel.text = [num stringByAppendingString:@"人赞赏"];
    [self.rewardLabel sizeToFit];
    
    CGFloat avatarGap = 4;
    CGFloat avatarLeft = 0;
    
    CGFloat rewardLabelWidth = self.rewardLabel.width;
    CGFloat maxContainerWidth = self.width - (leftMargin + rightMargin) - (rewardLabelWidth + rewardLabelLeftInset);
    NSInteger maxContainerCount = floor(maxContainerWidth / (avatarGap + avatarWidth));
    
    [self.avatarContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.viewModel.rewardUserList.count > 0) {
        
        for (NSInteger i = 0; i < self.viewModel.rewardUserList.count && i < maxContainerCount; i++) {
            
            TTDetailNatantRewardUser *user = self.viewModel.rewardUserList[i];
            
            SSAvatarView *avatar = [[SSAvatarView alloc] init];
            avatar.avatarImgPadding = 0.f;
            avatar.avatarStyle = SSAvatarViewStyleRound;
            avatar.size = CGSizeMake(avatarWidth, avatarWidth);
            avatar.userInteractionEnabled = NO;
            [avatar setupVerifyViewForLength:avatarWidth adaptationSizeBlock:nil];
            
            UIImage *placeholderImage = [UIImage imageWithSize:CGSizeMake(avatarWidth, avatarWidth) backgroundColor:[UIColor tt_themedColorForKey:kColorBackground2]];
            avatar.defaultHeadImg = placeholderImage;
            
            [avatar showAvatarByURL:user.avatarURL];
            
            [self.avatarContainer addSubview:avatar];
            
            avatarLeft = (avatarWidth + avatarGap) * i;
            
            avatar.left = avatarLeft;
            [avatar showOrHideVerifyViewWithVerifyInfo:user.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
        }
        
        CGFloat containerWidth = avatarLeft + avatarWidth;
        self.avatarContainer.width = containerWidth;
        self.avatarContainer.height = avatarWidth + 1.f;//避免加V后v的边框显示不全
    } else {
        self.avatarContainer.height = 0;
    }
    [self layoutIfNeeded];
}

- (void)themeChanged:(NSNotification *)notification {
    if ([self.reportButton.titleLabel.text isEqualToString:@"举报"]) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            [_reportButton setImage:[UIImage imageNamed:@"details_report_icon"] forState:UIControlStateNormal];
        }
        else {
            [_reportButton setImage:[UIImage imageNamed:@"details_report_icon_night"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark -
#pragma mark getter and setter

- (void)setViewModel:(TTDetailNatantRewardViewModel *)viewModel
{
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        [self update];
    }
}

- (TTAlphaThemedButton *)rewardButton
{
    if (!_rewardButton) {
        _rewardButton = [[TTAlphaThemedButton alloc] init];
        _rewardButton.titleColorThemeKey = kColorText1;
        _rewardButton.imageName = @"details_admire_icon";
        _rewardButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _rewardButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _rewardButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        [_rewardButton addTarget:self action:@selector(clickReward:) forControlEvents:UIControlEventTouchUpInside];
        [_rewardButton setTitle:@"赞赏" forState:UIControlStateNormal];
        
        _rewardButton.layer.cornerRadius = ButtonHeight/2;
//        _rewardButton.layer.cornerRadius = 20.0f / 375.0f * self.width;
        _rewardButton.layer.borderWidth = 0.5f;
        _rewardButton.borderColorThemeKey = kColorLine7;
    }
    return _rewardButton;
}

- (TTDiggButton *)digButton
{
    if (!_digButton) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeBoth];
        _digButton.imageName = @"details_like_icon";
        _digButton.selectedImageName = @"details_like_icon_press";
        _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -10);
        _digButton.titleColorThemeKey = kColorText1;
        _digButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _digButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _digButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _digButton.layer.cornerRadius = ButtonHeight/2;
//        _digButton.layer.cornerRadius = 20.0f / 375.0f * self.width;
        _digButton.layer.borderWidth = 0.5f;

        __weak typeof(self) wself = self;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            __strong typeof(wself) self = wself;
            self.detailModel.article.userLike = [NSNumber numberWithBool:!self.detailModel.article.userLike.boolValue];
            self.detailModel.article.likeCount = [NSNumber numberWithInt:self.detailModel.article.userLike.boolValue? ([self.detailModel.article.likeCount intValue] + 1): MAX(0, ([self.detailModel.article.likeCount intValue] - 1))];
            [self.detailModel.article save];
            [self updateDigButton];
            [self.itemActionManager sendActionForOriginalData:self.detailModel.article adID:nil actionType:self.detailModel.article.userLike.boolValue? DetailActionTypeLike: DetailActionTypeUnlike finishBlock:nil];
            if (self.detailModel.article.userLike.boolValue) {
                [self trackEventWithLabel:@"like"];
            } else {
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                [params setValue:self.detailModel.article.groupModel.groupID forKey:@"group_id"];
                [params setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
                [params setValue:[self.detailModel.article.mediaInfo tt_stringValueForKey:@"media_id"] forKey:@"user_id"];
                [params setValue:@"detail" forKey:@"position"];
                [params setValue:self.detailModel.orderedData.logPb forKey:@"log_pb"];
                [params setValue:self.detailModel.categoryID forKey:@"category_name"];
                [params setValue:self.detailModel.clickLabel forKey:@"enter_from"];
                [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_id"] forKey:@"card_id"];
                [params setValue:[self.detailModel.statParams tt_stringValueForKey:@"card_position"] forKey:@"card_position"];
                [params setValue:self.detailModel.orderedData.groupSource forKey:@"group_source"];
                
                if (self.detailModel.orderedData.listLocation != 0) {
                    [params setValue:@"main_tab" forKey:@"list_entrance"];
                }
                
                [TTTrackerWrapper eventV3:@"rt_unlike" params:params];
            }
            
            
        }];
    }
    return _digButton;
}

- (TTAlphaThemedButton *)avatarContainer
{
    if (!_avatarContainer) {
        _avatarContainer = [[TTAlphaThemedButton alloc] init];
        [_avatarContainer addTarget:self action:@selector(showRewardList) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarContainer;
}

- (SSThemedLabel *)rewardLabel
{
    if (!_rewardLabel) {
        _rewardLabel = [[SSThemedLabel alloc] init];
        _rewardLabel.font = [UIFont systemFontOfSize:12];
        _rewardLabel.textColorThemeKey = kColorText1;
    }
    return _rewardLabel;
}

- (TTAlphaThemedButton *)reportButton
{
    if (!_reportButton) {
        _reportButton = [[TTAlphaThemedButton alloc] init];
        _reportButton.titleColorThemeKey = kColorText1;
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_reportButton setTitle:@"不喜欢" forState:UIControlStateNormal];
        _reportButton.imageName = @"dislike_details";
//        [_reportButton setImage:[UIImage imageNamed:@"dislike_details_press"] forState:UIControlStateHighlighted];
        [_reportButton addTarget:self action:@selector(showReport) forControlEvents:UIControlEventTouchUpInside];
        
//        _reportButton.layer.cornerRadius = 20.f / 375.0f * [[UIScreen mainScreen] bounds].size.width;
        _reportButton.layer.cornerRadius = ButtonHeight/2;
        _reportButton.layer.borderWidth = 0.5f;
        _reportButton.borderColorThemeKey = kColorLine7;
        
    }
    return _reportButton;
}

- (ExploreItemActionManager *)itemActionManager
{
    if (!_itemActionManager) {
        _itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    return _itemActionManager;
}

@end
