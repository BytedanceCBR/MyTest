//
//  WDDetailNatantRewardView.m
//  Article
//
//  Created by 张延晋 on 17/11/16.
//
//

#import "WDDetailNatantRewardView.h"
#import "TTAlphaThemedButton.h"
#import "SSAvatarView+VerifyIcon.h"
#import "WDDiggButton.h"
#import "WDServiceHelper.h"
#import "TTReportManager.h"

#import "WDDetailModel.h"
#import "WDAnswerEntity.h"
#import "TTDeviceHelper.h"
#import "TTIndicatorView.h"
#import "UIButton+TTAdditions.h"
#import "WDAnswerService.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <QuartzCore/QuartzCore.h>
#import <KVOController/NSObject+FBKVOController.h>

#define ButtonWidth 112.f / 345.f * self.width
#define ButtonHeight [TTDeviceUIUtils tt_newPadding:36]

static CGFloat const avatarWidth          = 24;
static CGFloat const leftMargin           = 0;
static CGFloat const rightMargin          = 0;
static CGFloat const rewardLabelLeftInset = 9;

@interface WDDetailNatantRewardView ()

@property (nonatomic, strong) TTAlphaThemedButton *rewardButton;
@property (nonatomic, strong) WDDiggButton        *digButton;
@property (nonatomic, strong) TTAlphaThemedButton *avatarContainer;
@property (nonatomic, strong) SSThemedLabel       *rewardLabel;
@property (nonatomic, strong) TTAlphaThemedButton *reportButton;

@end

@implementation WDDetailNatantRewardView

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
    {
        self.rewardButton.hidden = YES;
        self.avatarContainer.hidden = YES;
        self.rewardLabel.hidden = YES;
        
        self.digButton.left = self.width * 35.0f / 345.0f;
        self.reportButton.left = self.digButton.right + self.width * 51.0f / 345.0f;
    }
    
    self.height = self.rewardButton.bottom;
}

- (void)reloadData:(id)object
{
    if (![object isKindOfClass:[WDDetailModel class]]) {
        return;
    }
    WDDetailModel *model = object;
    NSString *modelString = [model.ordered_info valueForKey:kWDDetailNatantLikeAndRewardsKey];
    NSData *stringData = [modelString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *modelDict = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:nil];
    if (modelDict) {
        WDDetailNatantRewardViewModel *rewardModel = [[WDDetailNatantRewardViewModel alloc] initWithDictionary:modelDict error:nil];
        self.detailModel = model;
        self.viewModel = rewardModel;
    }
}

- (void)trackEventIfNeededWithStyle:(NSString *)style {
    if (!self.hasShow) {
        WDAnswerEntity *answerEntity = self.detailModel.answerEntity;
        NSMutableDictionary * extDict = [[NSMutableDictionary alloc] initWithDictionary:self.detailModel.gdExtJsonDict];
        [extDict setValue:answerEntity.ansid forKey:@"ans_id"];
        [extDict setValue:style forKey:@"style"];
   
        self.hasShow = YES;
    }
}

- (void)trackEventIfNeeded
{
    if (!self.hasShow) {
        WDAnswerEntity *answerEntity = self.detailModel.answerEntity;
        NSMutableDictionary * extDict = [[NSMutableDictionary alloc] initWithDictionary:self.detailModel.gdExtJsonDict];
        [extDict setValue:answerEntity.ansid forKey:@"ans_id"];
        [extDict setValue:self.goDetailLabel forKey:@"source"];
        self.hasShow = YES;
    }
}

- (void)trackEventWithLabel:(NSString *)label
{

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
    int digCnt = [self.detailModel.answerEntity.diggCount intValue];
    [self.digButton setDiggCount:digCnt];
    if (self.detailModel.answerEntity.isDigg) {
        [self.digButton setSelected:YES];
        self.digButton.borderColorThemeKey = @"ff0031";
    } else {
        [self.digButton setSelected:NO];
        self.digButton.borderColorThemeKey = kColorLine7;
    }
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
            
            WDDetailNatantRewardUser *user = self.viewModel.rewardUserList[i];
            
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

            [avatar showOrHideVerifyViewWithVerifyInfo:user.userAuthInfo decoratorInfo:user.userDecoration];
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

- (void)setDetailModel:(WDDetailModel *)detailModel
{
    _detailModel = detailModel;
    

    
    [self.KVOController observe:self.detailModel.answerEntity keyPaths:@[NSStringFromSelector(@selector(diggCount)), NSStringFromSelector(@selector(isDigg))] options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        WDDetailNatantRewardView *rewardView = observer;
        [rewardView updateDigButton];
    }];
}

- (void)setViewModel:(WDDetailNatantRewardViewModel *)viewModel
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
        _rewardButton.layer.borderWidth = 0.5f;
        _rewardButton.borderColorThemeKey = kColorLine7;
    }
    return _rewardButton;
}

- (WDDiggButton *)digButton
{
    if (!_digButton) {
        _digButton = [WDDiggButton diggButton];
        _digButton.imageName = @"details_like_icon";
        _digButton.selectedImageName = @"details_like_icon_press";
        _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -10);
        _digButton.titleColorThemeKey = kColorText1;
        _digButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _digButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        _digButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _digButton.layer.cornerRadius = ButtonHeight/2;
        _digButton.layer.borderWidth = 0.5f;

        WeakSelf;
        [_digButton setShouldClickBlock:^BOOL{
            StrongSelf;
            if ([self.detailModel.answerEntity isBuryed]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经反对过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                return NO;
            }
            return YES;
        }];
        [_digButton setClickedBlock:^(WDDiggButtonClickType type) {
            StrongSelf;
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
            WDAnswerEntity *answerEntity = self.detailModel.answerEntity;
            [dict setValue:answerEntity.ansid forKey:@"group_id"];
            [dict setValue:answerEntity.user.userID forKey:@"user_id"];
            [dict setValue:@(10) forKey:@"group_source"];
            [dict setValue:@"detail_mid" forKey:@"position"];
     
            if (type == WDDiggButtonClickTypeDigg) {
                [TTTracker eventV3:@"rt_like" params:[dict copy]];

                self.detailModel.answerEntity.diggCount = @([self.detailModel.answerEntity.diggCount longLongValue] + 1);
                self.detailModel.answerEntity.isDigg = YES;
                [WDAnswerService digWithAnswerID:self.detailModel.answerEntity.ansid
                                        diggType:WDDiggTypeDigg
                                       enterFrom:kWDDetailViewControllerUMEventName
                                        apiParam:self.detailModel.apiParam
                                     finishBlock:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TTAppStoreStarManagerShowNotice" object:nil userInfo:@{@"trigger":@"like"}];
            } else {
                [TTTracker eventV3:@"rt_unlike" params:[dict copy]];

                self.digButton.selected = NO;
                self.detailModel.answerEntity.diggCount = (self.detailModel.answerEntity.diggCount.longLongValue >= 1) ? @(self.detailModel.answerEntity.diggCount.longLongValue - 1) : @0;
                self.detailModel.answerEntity.isDigg = NO;
                [WDAnswerService digWithAnswerID:self.detailModel.answerEntity.ansid
                                        diggType:WDDiggTypeUnDigg
                                       enterFrom:kWDDetailViewControllerUMEventName
                                        apiParam:self.detailModel.apiParam
                                     finishBlock:nil];
            }
            
            [self updateDigButton];
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
        [_reportButton setTitle:@"举报" forState:UIControlStateNormal];
        _reportButton.imageName = @"details_report_icon";
//        [_reportButton setImage:[UIImage imageNamed:@"dislike_details_press"] forState:UIControlStateHighlighted];
        [_reportButton addTarget:self action:@selector(showReport) forControlEvents:UIControlEventTouchUpInside];
        
//        _reportButton.layer.cornerRadius = 20.f / 375.0f * [[UIScreen mainScreen] bounds].size.width;
        _reportButton.layer.cornerRadius = ButtonHeight/2;
        _reportButton.layer.borderWidth = 0.5f;
        _reportButton.borderColorThemeKey = kColorLine7;
        
    }
    return _reportButton;
}

@end
