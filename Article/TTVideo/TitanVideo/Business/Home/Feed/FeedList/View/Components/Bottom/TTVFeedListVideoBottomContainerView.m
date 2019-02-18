//
//  TTVFeedListVideoBottomContainerView.m
//  Article
//
//  Created by pei yun on 2017/3/30.
//
//

#import "TTVFeedListVideoBottomContainerView.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "TTVerifyIconHelper.h"
#import "TTIconLabel+VerifyIcon.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedCellMoreActionManager.h"
#import <KVOController/KVOController.h>
#import "TTFollowThemeButton.h"
//#import "TTRedPacketManager.h"
#import "FRApiModel.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTIndicatorView.h"
#import "TTFollowNotifyServer.h"
#import "TTVideoUserInfoService.h"
#import "TTVFeedItem+Extension.h"
#import "FriendDataManager.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTActivityShareSequenceManager.h"
//#import "TTWeitoutiaoRepostIconDownloadManager.h"
#import "UIView+CustomTimingFunction.h"
#import "TTWeChatShare.h"
#import "TTQQShare.h"
//#import "TTDingTalkShare.h"
#import <TTKitchen/TTKitchen.h>
#import "AKUILayout.h"
#import "TTVDiggAction.h"
#define kLeftPadding        20
#define kRightPadding       20
#define kTopPadding         12
#define kGapAvatarView      8
#define KShareTitleWidth    36
#define KShareButtonWidth   40
#define kShareButtonOffset  16
#define kShareImageWidth    28
extern CGFloat adBottomContainerViewHeight(void);
extern BOOL ttvs_isVideoFeedshowDirectShare(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);
extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;

@interface TTVFeedListVideoBottomContainerView ()<TTActivityShareSequenceChangedMessage>

@property (nonatomic, strong) TTVFeedCellMoreActionManager *moreActionMananger;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, assign) BOOL hasRedPacket;
@property (nonatomic, strong) NSMutableDictionary *activityDic;
@property (nonatomic, strong) TTVDiggAction       *diggAction;
@end

@implementation TTVFeedListVideoBottomContainerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    UNREGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        REGISTER_MESSAGE(TTActivityShareSequenceChangedMessage, self);
        _commentButton = [[ArticleVideoActionButton alloc] init];
        _commentButton.minHeight = [TTDeviceUIUtils tt_newPadding:32.0];
        _commentButton.disableRedHighlight = YES;
        _commentButton.maxWidth = 72.0f;
        [self addSubview:_commentButton];
        
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeBoth];
        _digButton.selectedTintColorThemeKey = nil;
        _digButton.tintColorThemeKey = nil;
        _digButton.imageName = @"tab_video_like_un_selected";
        _digButton.selectedImageName = @"tab_video_like_selected";
        _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -10);
        _digButton.highlightedTitleColorThemeKey = nil;
        _digButton.selectedTitleColorThemeKey = nil;
        [_digButton setTitleColor:[UIColor colorWithHexString:@"ff5b4c"] forState:UIControlStateSelected];
        [_digButton setTitleColor:[UIColor colorWithHexString:@"8a9299"] forState:UIControlStateNormal];
        _digButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
        _digButton.manuallySetSelectedEnabled = YES;
        [_digButton addTarget:self action:@selector(diggButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_digButton];
        
        _shareButton = [[ArticleVideoActionButton alloc] init];
        _shareButton.minHeight = [TTDeviceUIUtils tt_newPadding:32.0];
        _shareButton.disableRedHighlight = YES;
        _shareButton.maxWidth = 72.0f;
        [_shareButton setTitle:@"分享"];
        [_shareButton addTarget:self action:@selector(bottomViewShareAction)];
        [self addSubview:_shareButton];
        
        [self themeChanged:nil];
    }
    return self;
}

#pragma mark - cell direct share buttons
- (void)addDirectShareButtons
{
    [self configureShareView];
    if (ttvs_isVideoFeedCellHeightAjust() == 2 && ttvs_isVideoFeedshowDirectShare())
    {
        NSArray *activitySequenceArr;
        if (!ttvs_isShareIndividuatioEnable()) {
            if ([[TTWeChatShare sharedWeChatShare] isAvailable]){
                activitySequenceArr = @[@(TTActivityTypeWeixinMoment), @(TTActivityTypeWeixinShare)];
            }else if ([[TTQQShare sharedQQShare] isAvailable]){
                activitySequenceArr = @[@(TTActivityTypeQQShare), @(TTActivityTypeQQZone)];
            }
//            else if ([[TTDingTalkShare sharedDingTalkShare] isAvailable]){
//                activitySequenceArr = @[@(TTActivityTypeDingTalk)];
//            }
            else{
                return;
            }
        }else{
            NSArray *activityArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:activityArray];
            [activityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *objType = obj;
                    //微信好友
                    if ([objType isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
                        if (![[TTWeChatShare sharedWeChatShare] isAvailable]) {
                            [array removeObject:obj];
                        }
                    }
                    //微信好友
                    if ([objType isEqualToString:TTActivityContentItemTypeWechat]) {
                        if (![[TTWeChatShare sharedWeChatShare] isAvailable]) {
                            [array removeObject:obj];
                        }
                        
                    }
                    if ([objType isEqualToString:TTActivityContentItemTypeQQFriend]){
                        if (![[TTQQShare sharedQQShare] isAvailable]) {
                            [array removeObject:obj];
                        }
                    }
                    if ([objType isEqualToString:TTActivityContentItemTypeQQZone]) {
                        if (![[TTQQShare sharedQQShare] isAvailable]){
                            [array removeObject:obj];
                        }
                    }
                }
            }];
            
            if (array.count > 2) {
                activitySequenceArr = [array copy];
            }else{
                return;
            }
        }
        
        BOOL is568Screen = [TTDeviceHelper is568Screen];
        if (!_shareView) {
            self.shareView = [[UIView alloc] init];
            self.shareView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.shareView];
        }
        
        //适配屏幕大小
        CGFloat width = 140;
       if (is568Screen){
            width = 100;
       }
        self.shareView.size = CGSizeMake(width, adBottomContainerViewHeight());

        if (!_shareTitleButton) {
            _shareTitleButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, KShareTitleWidth, adBottomContainerViewHeight())];
            _shareTitleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            _shareTitleButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
            [_shareTitleButton setTitleColor:[UIColor tt_themedColorForKey:kColorText1]  forState:UIControlStateNormal];
            [_shareTitleButton setTitle:@"分享" forState:UIControlStateNormal];
            [_shareTitleButton sizeToFit];
            [_shareTitleButton addTarget:self action:@selector(bottomViewShareAction) forControlEvents:UIControlEventTouchUpInside];
            [self.shareView addSubview:_shareTitleButton];
            
        }
        
        int hasbutton = 0;
        for (int i = 0; i < activitySequenceArr.count; i++){
            
            id obj = [activitySequenceArr objectAtIndex:i];
            if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                NSString *itemType;
                if ([obj isKindOfClass:[NSNumber class]]) {
                    TTActivityType objType = [obj integerValue];
                    itemType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:objType];
                }else{
                    itemType = (NSString *)obj;
                }
                if (/*[itemType isEqualToString:TTActivityContentItemTypeDingTalk] ||*/ [itemType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
                    continue;
                }
                UIImage *img = [self activityImageNameWithActivity:itemType];
                NSString *title = [self activityTitleWithActivity:itemType];
                
                TTVideoShareThemedButton *button = [self buttonWithIndex:hasbutton image:img title:title];
                [self.shareView addSubview:button];
                button.activityType = itemType;
                if (hasbutton == 0) {
                    _firstShareButton = button;
                }else{
                    _secondShareButton = button;
                }

                hasbutton++;
                if (is568Screen) {
                    if (hasbutton == 1) {
                        break;
                    }
                }else{
                    if (hasbutton == 2) {
                        break;
                    }
                }
            }
        }
        [self layoutShareView];
    }
}

- (TTVideoShareThemedButton *)buttonWithIndex:(int)index image:(UIImage *)image title:(NSString *)title
{
    CGRect frame;
    TTVideoShareThemedButton *view = nil;
    frame = CGRectMake(index*KShareButtonWidth, 0, KShareButtonWidth, adBottomContainerViewHeight());
    view = [[TTVideoShareThemedButton alloc] initWithFrame:frame index:index image:image title:title needLeaveWhite:NO]; //是否需要显示nameLabel
    view.iconImage.frame = CGRectMake((KShareButtonWidth- kShareImageWidth)/2, (adBottomContainerViewHeight() - kShareImageWidth)/2, kShareImageWidth, kShareImageWidth);
    [view addTarget:self action:@selector(directShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}

- (UIImage *)activityImageNameWithActivity:(NSString *)itemType{
    UIImage *image = nil;
    if (itemType) {
        if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
            image = [UIImage imageNamed:@"video_center_share_weChat"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
            image = [UIImage imageNamed:@"video_center_share_pyq"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
            image = [UIImage imageNamed:@"video_center_share_qzone"];
        }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
            image = [UIImage imageNamed:@"video_center_share_qq"];
        }
//        else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//            image = [UIImage imageNamed:@"video_center_share_ding"];
//        }
        else {
//            UIImage * dayImage = [[TTWeitoutiaoRepostIconDownloadManager sharedManager] getWeitoutiaoRepostDayIcon];
//            if (nil == dayImage) {
//                //使用本地图片
                image = [UIImage imageNamed:@"video_center_share_weitoutiao"];
//            }else {
//                //网络图片已下载
//                image = dayImage;
//            }
        }
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            image = [self imageByApplyingAlpha:0.5 image:image];
        }
    }
    return image;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSString *)activityTitleWithActivity:(NSString *)itemType{
    if ([itemType isEqualToString:TTActivityContentItemTypeWechat]){
        return @"微信";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return @"朋友圈";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQZone]){
        return @"QQ空间";
    }else if ([itemType isEqualToString:TTActivityContentItemTypeQQFriend]){
        return @"QQ";
    }
//    else if ([itemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//        return @"钉钉";
//    }
    else {
        return [TTKitchen getString:kTTKUGCRepostWordingShareIconTitle];
    }
}

- (FRRedpackStructModel *)redpacketModel {
    NSString *activityString = self.cellEntity.originData.activity;
    if (!isEmptyString(activityString)) {
        NSError *error = nil;
        NSData *stringData = [activityString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            return [[FRRedpackStructModel alloc] initWithDictionary:[dic tt_dictionaryValueForKey:@"redpack"] error:nil];
        }
    }
    return nil;
}

- (void)setCellEntity:(TTVFeedListItem *)cellEntity
{
    super.cellEntity = cellEntity;
    @weakify(self);
    [[[RACObserve(self.cellEntity, originData.article.commentCount) distinctUntilChanged] takeUntil:self.cellEntity.cell.rac_prepareForReuseSignal]
     subscribeNext:^(NSNumber *commentCount){
         @strongify(self);
         if (commentCount.longLongValue > 0) {
             [self configureCommentButton];
         }
     }];
    
    [[RACObserve(self.cellEntity, originData.article.diggCount) takeUntil:self.cellEntity.cell.rac_prepareForReuseSignal]
     subscribeNext:^(NSNumber *commentCount){
         @strongify(self);
         [self configDiggButton];
     }];
    
    self.isShowShareView = self.cellEntity.article.userDigg;
    [self configureShareView];
    self.avatarLabel.hidden = self.isShowShareView ? YES : NO;
    self.avatarLabelButton.userInteractionEnabled = NO;
    
    [self configureUI];
    
    NSString *activityString = self.cellEntity.originData.activity;
    self.activityDic = nil;
    if (!isEmptyString(activityString)) {
        NSError *error = nil;
        NSData *stringData = [activityString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            self.activityDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    self.hasRedPacket = [self.activityDic valueForKey:@"redpack"] != nil;
    [self logShowRedPacketIfNeed];
}

- (void)configureCommentButton
{
    TTVVideoArticle *article = self.cellEntity.article;
    NSString *commentText = nil;
    int64_t cmtCnt = article.commentCount;
    commentText = cmtCnt > 0 ? [TTBusinessManager formatCommentCount:cmtCnt] : NSLocalizedString(@"评论", nil);
    [self updateCommentButtonWithText:commentText];
}

- (void)configDiggButton
{
    self.digButton.manuallySetSelectedEnabled = NO;
    TTVVideoArticle *article = self.cellEntity.article;
    self.digButton.selected = article.userDigg;
    [self.digButton setDiggCount:article.diggCount];
    [self.digButton sizeToFit];
    [self.digButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:4];
    self.digButton.manuallySetSelectedEnabled = YES;
}

- (void)configureShareView
{
    [self.shareView removeFromSuperview];
    [self.shareTitleButton removeFromSuperview];
    [self.firstShareButton removeFromSuperview];
    [self.secondShareButton removeFromSuperview];
    self.shareView = nil;
    self.firstShareButton = nil;
    self.secondShareButton = nil;
    self.shareTitleButton = nil;
}

- (void)configureUI
{
    NSString *avatarUrl = nil;
    NSString *sourceText = nil;
    NSString *typeText = self.cellEntity.originData.article.label;
    NSString *countText = nil;
    NSString *shareText = nil;
    if (self.indicatorImageView.superview) {
        [self.indicatorImageView.layer removeAnimationForKey:@"rotation"];
        [self.indicatorImageView removeFromSuperview];
        self.indicatorImageView = nil;
    }
    TTVUserInfo *userInfo = self.cellEntity.originData.videoUserInfo;
    TTVVideoArticle *article = self.cellEntity.article;
    
    avatarUrl = userInfo.avatarURL;
    sourceText = article.source;
    if ([TTVerifyIconHelper isVerifiedOfVerifyInfo:userInfo.verifiedContent]) {
        [self.avatarLabel addIconWithVerifyInfo:userInfo.verifiedContent];
    }
    
    int64_t count = article.videoDetailInfo.videoWatchCount;
    countText = [[TTBusinessManager formatPlayCount:count] stringByAppendingString:@"次播放"];
    int32_t shareCnt = article.shareCount;
    shareText = shareCnt > 0 ? [TTBusinessManager formatCommentCount:shareCnt] : @"分享";
    
    [self updateAvatarViewWithUrl:avatarUrl sourceText:sourceText];
    [self updateAvatarVerifyWithAuthInfo:userInfo.userAuthInfo userDecoration:userInfo.userDecoration userId:@(userInfo.userId).stringValue];
    [self updateAvatarLabelWithText:sourceText];
    [self updateTypeLabelWithText:typeText];
    [self configureCommentButton];
    [self configDiggButton];
    
    [self setNeedsLayout];
    
    self.avatarLabelButton.enabled = NO;
    self.avatarViewButton.enabled = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.commentButton.hidden = NO;
    self.shareButton.hidden = YES;
    self.typeLabel.hidden = YES;

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
    
    CGFloat right = self.moreButton.left;
    [_shareButton updateFrames];
    [_commentButton updateFrames];
    
    _commentButton.centerY = self.height / 2;
    _commentButton.right = right - 5;
    
    right = _commentButton.left;
    
    _digButton.centerY = self.height / 2;
    _digButton.right = right - 20;
    
//    [AKUILayout horizontalLayoutViewWith:@[_commentButton,_digButton,_shareButton]
//                                 padding:22
//                                viewSize:nil
//                            firstPadding:15
//                                 centerY:self.height / 2];
    
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
    
    //名称
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.avatarLabel.frame = CGRectMake(left, 9, self.avatarLabel.width, 28.f);
    }else{
        self.avatarLabel.left = left;
        self.avatarLabel.height = [TTDeviceUIUtils tt_newPadding:32.0];
        self.avatarLabel.centerY = self.moreButton.centerY;
    }
    
    CGFloat avatarLabelWidth = avatarLabelWidth = _digButton.left - self.avatarLabel.left - (ttvs_isVideoFeedCellHeightAjust() > 1 ? 25 : 20);
    if (!self.typeLabel.hidden) {
        avatarLabelWidth -= (self.typeLabel.width + kGapAvatarView);
    }
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
    self.typeLabel.left = left;
    self.typeLabel.height = 14;
    self.typeLabel.centerY = self.avatarLabel.centerY;
    
    //控制头像以及名称透明度按钮
    self.avatarViewButton.frame = self.avatarView.frame;
    CGFloat labelButtonHeight = adBottomContainerViewHeight();
    if (ttvs_isVideoFeedCellHeightAjust() > 2) {
        labelButtonHeight += 4; //52+4
    }
    self.avatarLabelButton.frame = CGRectMake(self.avatarView.left, 0, self.avatarLabel.right - self.avatarView.left, labelButtonHeight);
    
    //shareview
    [self layoutShareView];
}

- (void)layoutShareView
{
    if (ttvs_isVideoFeedshowDirectShare()) {
        self.shareView.top = 0;
        self.shareView.left = self.left;
        self.shareTitleButton.height = adBottomContainerViewHeight();
        self.shareView.alpha = self.isShowShareView ? 1.0 : 0.0;
        
        self.shareTitleButton.top = 0.f;
        self.firstShareButton.top = 0.f;
        self.secondShareButton.top = 0.f;
        
        if (!self.isShowShareView) {
            self.shareTitleButton.left = kShareButtonOffset;
            self.firstShareButton.left = kShareButtonOffset;
            self.secondShareButton.left = kShareButtonOffset;
        } else {
            self.shareTitleButton.left = kShareButtonOffset;
            self.firstShareButton.left = self.shareTitleButton.right;
            self.secondShareButton.left = self.firstShareButton.right;
        }
    }
}

- (void)updateCommentButtonWithText:(NSString *)commentText
{
    [self.commentButton setTitle:isEmptyString(commentText) ? @"" : commentText];
}

- (void)updateShareButtonWithText:(NSString *)shareText
{
    [self.shareButton setTitle:@""];
    self.shareButton.minWidth = 34.f;
    self.shareButton.centerAlignImage = YES;
}


- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    [self.commentButton setImage:[UIImage themedImageNamed:@"comment"] forState:UIControlStateNormal];
    [self.commentButton setImage:[UIImage themedImageNamed:@"comment"] forState:UIControlStateHighlighted];
    [self.commentButton updateThemes];
    [self.commentButton setTitleColor:[UIColor tt_themedColorForKey:kFHColorCoolGrey3] forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor tt_themedColorForKey:kFHColorCoolGrey3] forState:UIControlStateHighlighted];
    
    
    [self.shareButton setImage:[UIImage themedImageNamed:@"tab_share"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage themedImageNamed:@"tab_share"] forState:UIControlStateHighlighted];
    [self.shareButton updateThemes];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kFHColorCoolGrey3] forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor tt_themedColorForKey:kFHColorCoolGrey3] forState:UIControlStateHighlighted];
    
    [self.shareTitleButton setTitleColorThemeKey:kFHColorCoolGrey3];
    [self.shareTitleButton setHighlightedTitleColorThemeKey:kFHColorCoolGrey3];
    if (self.isShowShareView && self.shareView){
        UIImage *firstImg = [self activityImageNameWithActivity:self.firstShareButton.activityType];
        UIImage *secondImg = [self activityImageNameWithActivity:self.secondShareButton.activityType];
        if (firstImg) {
            self.firstShareButton.iconImage.image = firstImg;
        }
        if (secondImg) {
            self.secondShareButton.iconImage.image = secondImg;
        }
    }
}

#pragma mark - shareview
- (void)openShareView
{
    [self addDirectShareButtons];

    if (!self.isShowShareView && ttvs_isVideoFeedshowDirectShare() && self.shareView) {
        self.isShowShareView = YES;
        [UIView animateWithDuration:0.35 customTimingFunction:CustomTimingFunctionCubicOut animation:^{
            
            self.avatarLabel.alpha = 0.0;
            self.typeLabel.alpha = 0.0;
            self.shareView.alpha = 1.0;
            self.shareTitleButton.left = kShareButtonOffset;
            self.firstShareButton.left = self.shareTitleButton.right;
            self.secondShareButton.left = self.firstShareButton.right;
        } completion:^(BOOL finished) {
            self.avatarLabelButton.userInteractionEnabled = NO;
            self.typeLabel.hidden = YES;
            self.avatarLabel.hidden = YES;
            self.avatarLabel.alpha = 1.0;

        }];
        
       // 埋点
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:self.cellEntity.categoryId forKey:@"category_name"];
        [params setValue:@"list" forKey:@"position"];
        [params setValue:[NSString stringWithFormat:@"%lld", self.cellEntity.originData.article.groupId] forKey:@"group_id"];
        [params setValue:[TTDeviceHelper is568Screen] ? @(1) : @(2) forKey:@"icon_num"];
        [params setValue:self.cellEntity.originData.itemID forKey:@"item_id"];
        [TTTrackerWrapper eventV3:@"share_icon_show" params:params];
    }
}

- (void)videoBottomContainerViewSetIsShowShareView{
    if (ttvs_isVideoFeedshowDirectShare() && self.shareView) {
        
        self.isShowShareView = NO;
        self.avatarLabel.hidden = NO;
        self.avatarLabelButton.userInteractionEnabled = NO;
        self.typeLabel.hidden = NO;
        if (self.avatarLabel.countOfIcons > 0) { // 显示认证图标时候隐藏推广
            self.typeLabel.hidden = YES;
        }
        
        self.shareView.alpha = 0.0;
        self.shareTitleButton.left = kShareButtonOffset;
        self.firstShareButton.left = kShareButtonOffset;
        self.secondShareButton.left = kShareButtonOffset;
    }
}

#pragma mark - Actions

- (void)diggButtonClicked:(TTDiggButton *)button
{
    if (self.cellEntity.article.userBury) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经踩过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    button.selected = !button.selected;
    TTVDiggActionEntity *diggEntity = [[TTVDiggActionEntity alloc] init];
    TTVFeedCellMoreActionModel *model = [TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData];
    diggEntity.groupId = model.groupId;
    diggEntity.cellEntity = self.cellEntity.originData;
    diggEntity.groupId = model.groupId;
    diggEntity.itemId = model.itemId;
    diggEntity.categoryId = self.categoryId;
    diggEntity.userDigg = model.userDigg;
    diggEntity.userBury = model.userBury;
    diggEntity.diggCount = model.diggCount;
    diggEntity.buryCount = model.buryCount;
    diggEntity.aggrType = model.aggrType;
    if (self.cellEntity.article.userDigg) {
        self.cellEntity.article.userDigg = NO;
        self.cellEntity.article.diggCount -= 1;
    } else {
        self.cellEntity.article.userDigg = YES;
        self.cellEntity.article.diggCount += 1;
    }
    TTVDiggAction *digAction = [[TTVDiggAction alloc] initWithEntity:diggEntity];
    digAction.diggActionDone = ^(BOOL digg) {
        if (digg) {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:@"house_app2c_v2" forKey:@"event_type"];
            [params setObject:model.groupId forKey:@"group_id"];
            [params setObject:model.groupId forKey:@"item_id"];
            [params setObject:@"click_category" forKey:@"enter_from"];
            [params setValue:self.cellEntity.originData.logPb forKey:@"log_pb"];
            [params setValue:@"f_shipin" forKey:@"category_name"];
            [TTTracker eventV3:@"rt_like" params:params];
        }
        self.cellEntity.article.userDigg = digg;
    };
    [digAction execute:TTActivityTypeDigUp];
    self.diggAction = digAction;
}

- (void)directShareButtonClicked:(TTVideoShareThemedButton *)button
{
    [self dealShareButtonOnBottomViewWithActivityType:button.activityType];
}

#pragma mark - TTActivityShareSequenceChangedMessage

- (void)message_shareActivitySequenceChanged{
    [self addDirectShareButtons];
}

#pragma mark - 关注互动埋点 (3.0)
- (void)followActionLogV3IsRedPacketSender:(BOOL) isRedPacketSender
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [self followActionLogV3CommonParams:params];
    if (isRedPacketSender){
        [params setValue:@"1" forKey: @"is_redpacket"];
        [params setValue:@"1048" forKey:@"server_source"];
    }else{
        [params setValue:@"0" forKey: @"is_redpacket"];
    }
    if (self.cellEntity.originData.videoUserInfo.follow){
        [TTTrackerWrapper eventV3:@"rt_unfollow" params:params];
    }else{
        
        [TTTrackerWrapper eventV3:@"rt_follow" params:params];
    }
    
}

- (NSString *)userId
{
    NSString *userId = [NSString stringWithFormat:@"%lld", self.cellEntity.originData.videoUserInfo.userId];
    return userId;
}

- (NSString *)mediaId
{
    if (self.cellEntity.originData.videoUserInfo.mediaId > 0) {
        return @(self.cellEntity.originData.videoUserInfo.mediaId).stringValue;;
    }
    return nil;
}

- (void)followActionLogV3CommonParams:(NSMutableDictionary *)params
{
    NSString *categoryName = self.cellEntity.categoryId;
    
    [params setValue:self.cellEntity.originData.itemID forKey:@"item_id"];
    [params setValue:[NSString stringWithFormat:@"%lld", self.cellEntity.originData.article.groupId] forKey:@"group_id"];
    [params setValue:@"click_category" forKey: @"enter_from"];
    [params setValue:self.cellEntity.originData.logPb forKey:@"log_pb"];
    [params setValue:@"0" forKey: @"not_default_follow_num"];
    [params setValue:categoryName forKey: @"category_name"];
    [params setValue:@"from_group" forKey: @"follow_type"];
    [params setValue:@"48" forKey:@"server_source"];
    [params setValue:[self userId] forKey: @"to_user_id"];
    [params setValue:[self mediaId] forKey: @"media_id"];
    [params setValue:@"video" forKey: @"source"];
    [params setValue:@"list" forKey:@"position"];
    [params setValue:@"1" forKey: @"follow_num"];
    [params setValue:self.cellEntity.originData.logPb forKey:@"log_pb"];
    
}

#pragma mark - 红包关注样式埋点 (3.0)

- (void)logShowRedPacketIfNeed{
    BOOL isFollowed = self.cellEntity.originData.videoUserInfo.follow;
    if (!isFollowed && self.hasRedPacket){
        NSString *categoryName = self.cellEntity.categoryId;
        NSString *groupId = self.cellEntity.originData.uniqueIDStr;
        NSString *actionType = @"show";
        NSString *position = @"list";
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:[self userId] forKey:@"user_id"];
        [param setValue:[self mediaId] forKey:@"media_id"];
        [param setValue:groupId forKey:@"group_id"];
        [param setValue:actionType forKey:@"action_type"];
        [param setValue:position forKey:@"position"];
        [param setValue:categoryName forKey:@"category_name"];
        [TTTrackerWrapper eventV3:@"red_button" params:param];
    }
}

@end
