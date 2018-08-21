//
//  TTVFeedListAdBottomContainerView.m
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListAdBottomContainerView.h"

#import "ExploreCellHelper.h"
#import "ExploreMovieView.h"
#import "JSONAdditions.h"
#import "SSADEventTracker.h"
#import "TTVFeedItem+Extension.h"
#import "UIControl+BlocksKit.h"
#import <TTVideoService/Common.pbobjc.h>
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <libextobjc/extobjc.h>
#import "TTTrackerProxy.h"
#import "TTADEventTrackerEntity.h"

#define kLeftPadding        15
#define kRightPadding       15
#define kTopPadding         12
#define kGapAvatarView      8
#define kMinHeight [TTDeviceUIUtils tt_newPadding:56]

extern CGFloat adBottomContainerViewHeight(void);

@implementation TTVFeedListAdBottomContainerView

- (void)setAdActionButton:(TTVAdActionButton *)adActionButton
{
    [_adActionButton removeFromSuperview];
    _adActionButton = adActionButton;
    
    adActionButton.frame = CGRectMake(0, 0, 72, 28);
    [self addSubview:adActionButton];
}

/** 广告查看详情按钮 */

- (void)setCellEntity:(TTVFeedListItem *)cellEntity
{
    super.cellEntity = cellEntity;
    
    [self configureUI];
}

- (void)configureUI {
    NSAssert(self.adActionButton != nil, @"adActionButton must be set");
    @weakify(self);
    self.adActionButton.ttv_command.feedItem = self.cellEntity.originData;
    [self.adActionButton setTitle:[self p_getActionButtonText] forState:UIControlStateNormal];
    [self.adActionButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [ExploreMovieView stopAllExploreMovieView];
        TTADEventTrackerEntity *trackerEntity = [TTADEventTrackerEntity entityWithData:self.cellEntity.originData item:self.cellEntity];
        NSMutableDictionary *dict = [@{} mutableCopy];
        if ([sender isKindOfClass:[TTVAdActionTypeAppButton class]]) {
            [[self class] trackRealTime:self.cellEntity];
            [dict setValue:@"1" forKey:@"has_v3"];
        }
        [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click" eventName:@"embeded_ad" extra:dict duration:0];
        [self.adActionButton.ttv_command executeAction];
    } forControlEvents:UIControlEventTouchUpInside];
    
    NSString *avatarUrl = nil;
    NSString *sourceText = nil;
    NSString *typeText = nil;

    TTVVideoArticle *article = [self.cellEntity article];
    TTVUserInfo *userInfo = [self.cellEntity.originData videoUserInfo];   /* TOASKPY: 怎么没有media_info */

    if (!isEmptyString(article.label)) {
        typeText = article.label;
    }
    
    avatarUrl = userInfo.avatarURL;
    sourceText = article.source;
    
    if (self.cellEntity.originData.hasAdCell) {
        TTVADCell *adCell = self.cellEntity.originData.adCell;
        if (adCell.hasApp) {
            sourceText = adCell.app.appName;
        }
        if (isEmptyString(sourceText)) {
            sourceText = article.source;
        }
    }
    if (isEmptyString(sourceText)) {
        sourceText = @"佚名";
    }
    if (isEmptyString(typeText)) {
        typeText = @"广告";
    }
    
    [self updateAvatarViewWithUrl:avatarUrl sourceText:sourceText];
    [self updateAvatarLabelWithText:sourceText];
    [self updateTypeLabelWithText:typeText];
    
    [self themeChanged:nil];
    [self setNeedsLayout];
    
    self.avatarLabelButton.enabled = NO;
    self.avatarViewButton.enabled = YES;
    
    
    BOOL isCanvas = NO;
    if (!isEmptyString(self.cellEntity.originData.article.rawAdDataString)) {
        NSDictionary *rawAdInfo = [self.cellEntity.originData.article.rawAdDataString tt_JSONValue];
        isCanvas = [rawAdInfo[@"style"] isEqualToString:@"canvas"];
    }
    
    if (TTVVideoBusinessType_Adnormal == self.cellEntity.originData.videoBusinessType ||
        TTVVideoBusinessType_PicAdweb == self.cellEntity.originData.videoBusinessType ||
        (isCanvas && TTVVideoBusinessType_VideoAdweb == self.cellEntity.originData.videoBusinessType)) {
        // 普通广告 统一由cell点击事件处理
        self.adActionButton.userInteractionEnabled = NO;
    } else {
        self.adActionButton.userInteractionEnabled = YES;
    }
}

+ (void)trackRealTime:(TTVFeedListItem*)feedListItem
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:feedListItem.article.adId forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:feedListItem.article.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [params addEntriesFromDictionary:[feedListItem realTimeAdExtraData:@"embeded_ad" label:@"click" extraData:nil]];
    [TTTracker eventV3:@"realtime_click" params:params];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.avatarLabel.hidden = NO;
    self.avatarViewButton.hidden = YES;
    if (self.avatarLabel.countOfIcons > 0) { // 显示认证图标时候隐藏推广
        self.typeLabel.hidden = YES;
    }
    
    CGFloat rightMargin = [TTDeviceHelper isPadDevice] ? self.width * 0.25 : 16;
    rightMargin = ceil(rightMargin);
    
    //更多按钮
    [self.moreButton updateFrames];
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.moreButton.top = 6.f;
    }else{
        self.moreButton.centerY = self.height / 2;
    }
    self.moreButton.right = [TTDeviceHelper isPadDevice] ? (self.width - 3) : (self.width - rightMargin + [self.moreButton contentEdgeInset].right);
    
    //头像
    CGFloat left = kLeftPadding;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.avatarView.frame = CGRectMake(left, 8 - [self.class avatarHeight], [self.class avatarHeight], [self.class avatarHeight]);
        self.avatarView.borderColor = [UIColor tt_themedColorForKey:kColorText7];
        self.avatarView.borderWidth = [self.class avatarViewBorderWidth];
    }else{
        self.avatarView.frame = CGRectMake(left, (self.height - [self.class avatarHeight]) / 2, [self.class avatarHeight], [self.class avatarHeight]);
        self.avatarView.borderWidth = 0.f;
        left += (!self.avatarView.hidden? [self.class avatarHeight] + kGapAvatarView : 0);
    }
    self.avatarView.hidden = YES;
    
    //“查看详情”等按钮
    self.adActionButton.centerY = self.moreButton.centerY;
    self.adActionButton.right = self.moreButton.left;
    
    //名称
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.avatarLabel.frame = CGRectMake(left, 9, self.avatarLabel.width, 28.f);
    }else{
        self.avatarLabel.left = left;
        self.avatarLabel.height = [TTDeviceUIUtils tt_newPadding:32.0];
        self.avatarLabel.centerY = self.moreButton.centerY;
    }
    CGFloat avatarLabelWidth = self.adActionButton.left - self.avatarLabel.left - 20 - (!self.typeLabel.hidden ? self.typeLabel.width + kGapAvatarView : 0);
    avatarLabelWidth = avatarLabelWidth < self.avatarLabel.width ? avatarLabelWidth : self.avatarLabel.width;
    self.avatarLabel.width = avatarLabelWidth;
    left += avatarLabelWidth + kGapAvatarView;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        if (avatarLabelWidth < [self.class avatarHeight]) {
            self.avatarLabel.centerX = self.avatarView.centerX;
            left = self.avatarLabel.right + kGapAvatarView;
        }
    }
    
    //类型标签
    self.typeLabel.left = self.avatarLabel.right + 6;
    self.typeLabel.height = 14;
    self.typeLabel.centerY = self.avatarLabel.centerY;
        
    //控制头像以及名称透明度按钮
    self.avatarViewButton.frame = self.avatarView.frame;
    CGFloat labelButtonHeight = adBottomContainerViewHeight();
    if (ttvs_isVideoFeedCellHeightAjust() > 2) {
        labelButtonHeight += 4;
    }
    self.avatarLabelButton.frame = CGRectMake(self.avatarView.left, 0, self.avatarLabel.right - self.avatarView.left, labelButtonHeight);

}

- (NSString *)p_getActionButtonText {
    
    if (!isEmptyString([self.cellEntity.originData adInfo].buttonText)) {
        return [self.cellEntity.originData adInfo].buttonText;
    }
    
     TTVVideoBusinessType type = self.cellEntity.originData.videoBusinessType;
    
    switch (type) {
        case TTVVideoBusinessType_VideoAdcounsel:
        case TTVVideoBusinessType_PicAdcounsel:
            return NSLocalizedString(@"在线咨询", @"在线咨询");
            break;
        case TTVVideoBusinessType_VideoAdapp:
        case TTVVideoBusinessType_PicAdapp:
            return NSLocalizedString(@"立即下载", @"立即下载");
            break;
        case TTVVideoBusinessType_PicAdphone:
        case TTVVideoBusinessType_VideoAdphone:
            return NSLocalizedString(@"拨打电话", @"拨打电话");
            break;
        case TTVVideoBusinessType_VideoAdform:
        case TTVVideoBusinessType_PicAdform:
            return NSLocalizedString(@"立即预约", @"立即预约");
        case TTVVideoBusinessType_VideoAdweb:
        case TTVVideoBusinessType_PicAdweb:
            return NSLocalizedString(@"查看详情", @"查看详情");
        case TTVVideoBusinessType_Adnormal:
            return NSLocalizedString(@"查看详情", @"查看详情");
        default:
            break;
    }
    return nil;
}

@end
