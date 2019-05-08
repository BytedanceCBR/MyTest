//
//  TTVVideoDetailNatantPGCAuthorView.m
//  Article
//
//  Created by lishuangyang on 2017/5/23.
//
//

#import "TTVVideoDetailNatantPGCAuthorView.h"
#import "PGCAccountManager.h"
#import "TTVideoCommon.h"
#import "TTRoute.h"
#import "TTDeviceUIUtils.h"
#import "TTAccountManager.h"
#import "TTAlphaThemedButton.h"
#import "TTIconLabel+VerifyIcon.h"
#import "TTImageView.h"
//#import "TTRedPacketManager.h"
#import "ExploreEntryManager.h"  //下面两个使用的是通知的定义
#import "SSImpressionManager.h"
#import "TTFollowThemeButton.h"
#import "TTAsyncCornerImageView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "TTRelevantDurationTracker.h"
#import "TTUGCTrackerHelper.h"
#import "ExploreMomentDefine.h"

#define kPGCViewHeight (([TTDeviceHelper isPadDevice]) ? 84 : 66)
#define kPGCAvatarSize                      (([TTDeviceHelper isPadDevice]) ? 44 : 36)
#define kPGCRecommendViewHeight             222
#define kAvatarRightSpace                   8.f
#define kSubscribeButtonWidthScreenAspect   0.1875f
#define kVideoDetailItemCommonEdgeMargin (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kPGCViewHeightOnTop 44
#define KPGCNameBottomPadding 0

extern BOOL ttvs_enabledVideoNewButton(void);
extern BOOL ttvs_enabledVideoRecommend(void);
extern BOOL ttsettings_articleNavBarShowFansNumEnable(void);
extern NSInteger ttsettings_navBarShowFansMinNum(void);
extern NSArray *tt_ttuisettingHelper_detailViewBackgroundColors(void);

@interface TTVVideoDetailNatantPGCAuthorView ()

@property (nonatomic, strong, nullable) TTAlphaThemedButton *backgroundView;
@property (nonatomic, strong, nullable) TTAsyncCornerImageView *pgcAvatar;
@property (nonatomic, strong, nullable) TTIconLabel         *pgcName;
@property (nonatomic, strong, nullable) TTIconLabel         *pgcFansLabel;
@property (nonatomic, strong, nullable) TTFollowThemeButton *subscribeButton;
@property (nonatomic, strong, nullable) SSThemedButton      *subscribeIndicator;
@property (nonatomic, strong, nullable) SSThemedButton      *arrowImage;
//@property (nonatomic, strong, nullable) TTImageView         *arrowTag;
//@property (nonatomic, strong, nullable) FRRedpackStructModel *redpacketModel;

@property (nonatomic, assign) BOOL isAnimating;               //防止按钮触发多次
@property (nonatomic, assign) BOOL hasRedpacket;
//@property (nonatomic, assign) NSInteger themedButtonStyle;
@end

@implementation TTVVideoDetailNatantPGCAuthorView
    
- (instancetype)initWithInfoModel: (TTVVideoDetailNatantPGCModel *) PGCInfo andWidth:(float) width{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        TTVVideoDetailNatantPGCViewModel *viewModel = [[TTVVideoDetailNatantPGCViewModel alloc]initWithPGCModel:PGCInfo];
        self.viewModel = viewModel;
//        if (!SSIsEmptyDictionary(PGCInfo.activityDic)) {
//            if ([PGCInfo.activityDic.allKeys containsObject:@"redpack"]) {
//                self.redpacketModel = [[FRRedpackStructModel alloc] initWithDictionary:[PGCInfo.activityDic tt_dictionaryValueForKey:@"redpack"]
//                                                                                 error:nil];
//            }else {
//                self.redpacketModel = nil;
//            }
//        }
//        self.hasRedpacket = self.redpacketModel != nil;
        self.hasRedpacket = NO;
//        self.themedButtonStyle = [self.redpacketModel.button_style integerValue];
        [self reloadThemeUI];
        [self buildView];
        [self refreshWithViewModel];

        self.clipsToBounds = NO;
    }
    return self;
}

#pragma mark - buildView
- (void)buildView
{
    
    if (!_pgcName) {
        _pgcName = [[TTIconLabel alloc] init];
        _pgcName.font = [UIFont boldSystemFontOfSize:[[self class] nameLabelFontSize]];
        _pgcName.textColorThemeKey = kColorText1;
        _pgcName.userInteractionEnabled = NO;
    }
    
    if (!_pgcFansLabel) {
        _pgcFansLabel = [[TTIconLabel alloc] init];
        _pgcFansLabel.font = [UIFont systemFontOfSize:12.f];
        _pgcFansLabel.textColorThemeKey = kColorText1;
        _pgcFansLabel.userInteractionEnabled = NO;
    }
    
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    
    if (!_subscribeIndicator) {
        _subscribeIndicator = [[SSThemedButton alloc] init];
        _subscribeIndicator.imageName = @"loading_video_details";
        _subscribeIndicator.userInteractionEnabled = NO;
        _subscribeIndicator.alpha = 0;
    }
    
    if (!_subscribeButton) {
        _subscribeButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType102 followedType:TTFollowedType101];
        _subscribeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-9, -13, -9, -15);
        _subscribeButton.constWidth = [TTDeviceUIUtils tt_newPadding: 72];
        _subscribeButton.constHeight = [TTDeviceUIUtils tt_newPadding: 28];
        [_subscribeButton addTarget:self action:@selector(subscribeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//        _subscribeButton.hidden = NO;
        // add by zjing 去掉关注按钮
        self.subscribeButton.hidden = YES;

    }
    
    if (!_arrowImage) {
        _arrowImage = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _arrowImage.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:6];
        _arrowImage.layer.masksToBounds = YES;
        _arrowImage.borderColorThemeKey = kColorLine1;
        _arrowImage.layer.borderWidth = 1.f;
        _arrowImage.imageName = @"personal_home_arrow";
        [_arrowImage addTarget:self action:@selector(arrowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_arrowImage setHitTestEdgeInsets:UIEdgeInsetsMake(0, 0, 0, [TTDeviceUIUtils tt_newPadding:-15])];
    }

//    if (!_arrowTag) {
//        UIImage *icon = nil;
//        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
//            icon = [UIImage imageNamed:@"video_detail_arrow"];
//        }
//        else {
//            icon = [UIImage imageNamed:@"video_detail_arrow_night"];
//        }
//        _arrowTag = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, icon.size.width, icon.size.height)];
//        [_arrowTag setImage:icon];
//        _arrowTag.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        _arrowTag.enableNightCover = NO;
//    }
    [self logRedPacketIfNeed];

}

- (void)buildChoiceView
{
    [self buildOnTop];

    self.arrowImage.hidden = YES;
    [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:28]));
        make.width.equalTo(@([TTDeviceUIUtils tt_newPadding:28]));
        make.right.equalTo(self.backgroundView.mas_right).offset([TTDeviceUIUtils tt_newPadding:-15]);
        make.centerY.equalTo(self.pgcAvatar.mas_centerY);
    }];
    
//    if ([self isAuthorSelf]) {
//        self.subscribeButton.hidden = YES;
//    } else {
//        self.subscribeButton.hidden = NO;
//    }
    
    // add by zjing 去掉关注按钮
    self.subscribeButton.hidden = YES;

    [self.subscribeIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.subscribeButton);
    }];

    self.backgroundColorThemeKey = kColorBackground3;
}

- (BOOL)isAuthorSelf
{
    return (!isEmptyString([TTAccountManager userID]) && !isEmptyString([self.viewModel.pgcModel.contentInfo ttgc_contentID])) && ([[self.viewModel.pgcModel.contentInfo ttgc_contentID] isEqualToString:[TTAccountManager userID]] || [self.viewModel.pgcModel.mediaUserID isEqualToString:[TTAccountManager userID]]);
}


- (void)buildOnTop
{
    if (!_backgroundView) {
        CGFloat  height = kPGCViewHeightOnTop;
        _backgroundView = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceUIUtils tt_newPadding:height])];
        // add by zjing 去掉头像点击
        _backgroundView.userInteractionEnabled = NO;
//        [_backgroundView addTarget:self action:@selector(showPGCView) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:kEntrySubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:RelationActionSuccessNotification object:nil];
    }
    if (!_pgcAvatar) {
        
        CGFloat  avatarSize;
        avatarSize = [TTDeviceUIUtils tt_newPadding:24];
        if (ttsettings_articleNavBarShowFansNumEnable()){
            avatarSize = [TTDeviceUIUtils tt_newPadding:kPGCAvatarSize];
        }
        CGFloat totalHeigth = [TTDeviceUIUtils tt_newPadding:kPGCViewHeightOnTop];
        
        _pgcAvatar = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding: kVideoDetailItemCommonEdgeMargin], [TTDeviceUIUtils tt_newPadding: (totalHeigth - avatarSize) / 2.f], avatarSize, avatarSize) allowCorner:YES];
        _pgcAvatar.borderWidth = 0;
        _pgcAvatar.userInteractionEnabled = NO;
        _pgcAvatar.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _pgcAvatar.cornerRadius = avatarSize / 2;
        _pgcAvatar.borderColor = [UIColor clearColor];
        _pgcAvatar.placeholderName = @"big_defaulthead_head";
        [_pgcAvatar setupVerifyViewForLength:kPGCAvatarSize adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        
        
        UIView *view = [[UIView alloc] initWithFrame:_pgcAvatar.bounds];
        view.layer.cornerRadius = view.width / 2.f;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        [_pgcAvatar insertSubview:view belowSubview:_pgcAvatar.verifyView];
        [self addSubview:_pgcAvatar];
    }
    
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.pgcAvatar];
    [self.backgroundView addSubview:self.pgcName];
    [self.backgroundView addSubview:self.pgcFansLabel];
    [self.backgroundView addSubview:self.bottomLine];
    self.bottomLine.hidden = YES;
    [self addSubview:self.subscribeIndicator];
    [self addSubview:self.arrowImage];
    [self addSubview:self.subscribeButton];
//    [self addSubview:self.arrowTag];
    
    self.subscribeButton.backgroundColorThemeKey = nil;
    self.subscribeButton.titleColorThemeKey = kColorText6;
    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:28]));
        make.width.equalTo(@([TTDeviceUIUtils tt_newPadding:70]));
        make.right.equalTo(self.backgroundView.mas_right).offset([TTDeviceUIUtils tt_newPadding:-15]);
        make.centerY.equalTo(self.pgcAvatar.mas_centerY);
    }];
    _subscribeButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    
}

#pragma mark - refreshData
- (void)refreshWithViewModel
{
    if (!self) {
        self.height = 0;
    } else {
        self.height = [TTDeviceUIUtils tt_newPadding:kPGCViewHeightOnTop];
        [self buildChoiceView];
        [self refreshAvatar];
        [self refreshUI];
        [self reloadThemeUI];
    }
}

- (void)refreshUI
{
    self.pgcName.text = [self.viewModel.pgcModel.contentInfo ttgc_contentName];
    self.pgcName.labelMaxWidth = self.width - self.pgcName.left - 5 - 72 - 15;
    [self.pgcName sizeToFit];

    self.pgcName.centerY = _pgcAvatar.centerY;
    self.pgcFansLabel.hidden = YES;
    self.pgcName.left = _pgcAvatar.right + kAvatarRightSpace;

    if (ttsettings_articleNavBarShowFansNumEnable()) {
        long long fansNum = [self.viewModel.pgcModel.contentInfo ttgc_fansCount];
        
        if (fansNum >= ttsettings_navBarShowFansMinNum()){
            fansNum = fansNum < 0 ? 0 : fansNum;
            self.pgcName.top = _pgcAvatar.top + 2;
            self.pgcFansLabel.text = [NSString stringWithFormat:@"%@粉丝", [TTBusinessManager formatCommentCount:fansNum]];
            [self.pgcFansLabel sizeToFit];
            self.pgcFansLabel.top = self.pgcName.bottom + KPGCNameBottomPadding;
            self.pgcFansLabel.left = self.pgcName.left;
            self.pgcFansLabel.hidden = NO;
        }
    }
   
    [self refreshSubscribeButtonTitle];

    if ([TTDeviceHelper isPadDevice]) {
        self.bottomLine.hidden = YES;
    } else {
        self.bottomLine.bottom = self.height;
    }
}

- (void)refreshAvatar
{
    [self.pgcName removeAllIcons];
    NSString *avatarUrl = [self.viewModel.pgcModel.contentInfo ttgc_contentAvatarURL];
    NSString *userAuthInfo = [self.viewModel.pgcModel.contentInfo ttgc_userAuthInfo];
    self.pgcAvatar.placeholderName = @"pgcloading_allshare.png";
    [self.pgcAvatar tt_setImageWithURLString:avatarUrl];
    [self.pgcName refreshIconView];
    BOOL isVerified = [TTVerifyIconHelper isVerifiedOfVerifyInfo:userAuthInfo];
    if (isVerified) {
        self.pgcFansLabel.labelMaxWidth = self.pgcName.labelMaxWidth;
        [self.pgcName refreshIconView];
    }
    [self.pgcAvatar showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:self.viewModel.pgcModel.userDecoration sureQueryWithID:YES userID:self.viewModel.pgcModel.mediaUserID];
}

- (void)refreshSubscribeButtonTitle
{
    self.subscribeButton.followed = [self ttv_isSubCribed];
//    self.subscribeButton.hidden = [self isAuthorSelf];
    
    // add by zjing 去掉关注按钮
    self.subscribeButton.hidden = YES;

    
    self.isAnimating = NO;
//    if (self.hasRedpacket) {
//        self.subscribeButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.themedButtonStyle defaultType:TTUnfollowedType201];
//        self.subscribeButton.followedType = TTFollowedType101;
//    }else{
        self.subscribeButton.unfollowedType = TTUnfollowedType101;
        self.subscribeButton.followedType = TTFollowedType101;
//    }
    [self reloadThemeUI];
    [self.subscribeButton refreshUI];
}

#pragma mark - layout
- (void)layoutSubviews
{
    [self refreshUI];
    [super layoutSubviews];
}

#pragma mark - Action

- (void)subscribeButtonPressed
{
    if (!_isAnimating) {
        self.isAnimating = YES;
        [self didExecuteSubscribe];
    }
}

// 按钮被点击，订阅，取消订阅
- (void)didExecuteSubscribe
{
    NSDictionary *contentInfo = self.viewModel.pgcModel.contentInfo;
    BOOL hasSubscribed = [self ttv_isSubCribed];
    NSString *contentID = [contentInfo ttgc_contentID];
    FriendActionType actionType;
    if (hasSubscribed) {
        actionType = FriendActionTypeUnfollow;
    }
    else {
        actionType = FriendActionTypeFollow;
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.viewModel.pgcModel.itemId forKey:@"item_id"];
    NSString *unEvent = [self.viewModel isVideoSourceUGCVideo] ? @"detail_unsubscribe_ugc" : @"detail_unsubscribe_pgc";
    NSString *doEvent = [self.viewModel isVideoSourceUGCVideo] ? @"detail_subscribe_ugc" : @"detail_subscribe_pgc";
    if (hasSubscribed) {
        wrapperTrackEventWithCustomKeys(@"video", unEvent, contentID, nil, extraDic);
    } else {
        wrapperTrackEventWithCustomKeys(@"video", doEvent, contentID, nil, extraDic);
    }
    
    BOOL isRedPacketSender = NO;
//    TTFollowNewSource source = TTFollowNewSourceVideoDetail;
////    if ( self.redpacketModel && self.hasRedpacket) {
////        source = TTFollowNewSourceVideoDetailRedPacket;
////        isRedPacketSender = YES;
////    }
    [self followActionLogV3IsRedPacketSender:isRedPacketSender];

    [self startIndicatorAnimating:hasSubscribed];
    [self.viewModel didSelectSubscribeButton:actionType andFinishBlock:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        [self p_finishChangeSubscribeStatus:error hasSubscribed:hasSubscribed conentType:[_viewModel.pgcModel.contentInfo ttgc_contentType] result:result action:actionType];
    }];
}

//- (BOOL)ttv_presendRedPacketWihtSubscribed:(BOOL)hasSubscribed
//{
//    BOOL showRedPacket = NO;
//    if (!hasSubscribed && self.redpacketModel && self.hasRedpacket) {
//        TTRedPacketTrackModel * redPacketTrackModel = [[TTRedPacketTrackModel alloc] init];
//        redPacketTrackModel.userId = [self.viewModel.pgcModel.contentInfo ttgc_contentID];
//        redPacketTrackModel.mediaId = [self.viewModel.pgcModel.contentInfo ttgc_mediaID];
//        redPacketTrackModel.categoryName = self.viewModel.pgcModel.categoryName;
//        redPacketTrackModel.source = @"detail";
//        redPacketTrackModel.position = @"title_below";
//        [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:self.redpacketModel
//                                                                   source:redPacketTrackModel
//                                                           viewController:[TTUIResponderHelper topViewControllerFor:self]];
//        [self clearRedPacket];
//        showRedPacket = YES;
//    }
//    return showRedPacket;
//}

- (void)p_finishChangeSubscribeStatus:(NSError *)error hasSubscribed:(BOOL)hasSubscribed conentType:(TTGeneratedContentType)contentType result:(NSDictionary *)result action:(FriendActionType)actionType
{
    if (!error) {
//        BOOL showRedPacket = [self ttv_presendRedPacketWihtSubscribed:hasSubscribed];
        BOOL showRedPacket = NO;
        NSMutableDictionary *saveDic = [NSMutableDictionary dictionaryWithDictionary:_viewModel.pgcModel.contentInfo];
        if ([saveDic ttgc_contentType] == TTGeneratedContentTypeUGC) {
            [saveDic setValue:@(!hasSubscribed) forKey:@"follow"];
        } else {
            [saveDic setValue:@(!hasSubscribed) forKey:@"subcribed"];
        }
        [saveDic setValue:_viewModel.pgcModel.videoID forKey:@"video_id"];
        
        long long fansCount;
        if (!hasSubscribed) {
            fansCount =  [saveDic ttgc_fansCount] + 1;
        }else{
            fansCount =  [saveDic ttgc_fansCount] - 1;
        }
        [saveDic setValue:@(fansCount) forKey:@"fans_count"];
        
        _viewModel.pgcModel.contentInfo = [saveDic copy];
        if (contentType == TTGeneratedContentTypePGC) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVideoDetailPGCSubscribeStatusChangedNotification object:saveDic];
        }
        //关注成功
        if (!hasSubscribed){
            [self.viewModel fetchRecommendArray:^(NSError *error) {
                [self stopIndicatorAnimatingShowRedPacket:showRedPacket];
                if (!error && self.viewModel.recommendArray.count > 1) {
                    if (_delegate && [_delegate respondsToSelector:@selector(updateRecommendView:isShowRedPacket:)]) {
                        [_delegate updateRecommendView:!hasSubscribed isShowRedPacket:showRedPacket];
                    }
                }
            }];
        }
        else{
            [self stopIndicatorAnimatingShowRedPacket:showRedPacket];
            if (_delegate && [_delegate respondsToSelector:@selector(updateRecommendView:isShowRedPacket:)]) {
                [_delegate updateRecommendView:!hasSubscribed isShowRedPacket:showRedPacket];
            }
        }
    }  //关注状态失败
    else {
        NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
        if (isEmptyString(hint)) {
            hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopIndicatorAnimating];
        });
    }
}

- (void)startIndicatorAnimating:(BOOL)hasSubscribed
{
    self.isAnimating = YES;
    [self.subscribeButton startLoading];
}

- (void)stopIndicatorAnimating
{
    [self stopIndicatorAnimatingShowRedPacket:NO];
}

- (void)stopIndicatorAnimatingShowRedPacket:(BOOL)showRedPacket
{
    [self.subscribeButton stopLoading:^{
        
    }];
    [self refreshSubscribeButtonTitle];
    
    //可能拆分 然后配合新的pm需求
    [UIView animateWithDuration:0.25f delay:0 options:0 animations:^{
        self.pgcFansLabel.text = [NSString stringWithFormat:@"%@粉丝", [TTBusinessManager formatCommentCount:[self.viewModel.pgcModel.contentInfo ttgc_fansCount]]];
        [self.pgcFansLabel sizeToFit];
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

- (void) subScribButtonMovement
{
    if (ttvs_enabledVideoRecommend()){
        
        BOOL hasSubscribed = [self ttv_isSubCribed];
        if (hasSubscribed) {
            if (self.viewModel.recommendArray) {
                self.arrowImage.hidden = NO;
                self.arrowImage.imageName = @"personal_home_arrow";
                self.arrowImage.alpha = 0;
//                self.arrowTag.hidden = NO;
                [self.subscribeButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.backgroundView.mas_right).offset([TTDeviceUIUtils tt_newPadding:-49]);
                }];
                self.arrowImage.imageView.transform = CGAffineTransformMakeRotation(0);
                [UIView animateWithDuration:0.25f animations:^{
                    [self layoutIfNeeded];
//                    self.arrowTag.alpha = 1;
                    self.arrowImage.alpha = 1;
                } completion:^(BOOL finished) {
                }];
            }
        }else{
            self.arrowImage.alpha = 1;
            [self.subscribeButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.backgroundView.mas_right).offset([TTDeviceUIUtils tt_newPadding: -15]);
            }];
            [UIView animateWithDuration:0.25f animations:^{
                self.arrowImage.alpha = 0;
//                self.arrowTag.alpha = 0;
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.arrowImage.hidden = YES;
//                self.arrowTag.hidden = YES;
            }];
        }
        
    }
}

- (void)notificationAction{
    [self refreshSubscribeButtonTitle];
    self.pgcFansLabel.text = [NSString stringWithFormat:@"%@粉丝", [TTBusinessManager formatCommentCount:[self.viewModel.pgcModel.contentInfo ttgc_fansCount]]];
    [self.pgcFansLabel sizeToFit];
    if (_delegate && [_delegate respondsToSelector:@selector(updateRecommendView:isShowRedPacket:)]) {
        [_delegate updateRecommendView:NO isShowRedPacket:NO];
    }
    self.arrowImage.hidden = YES;
}

- (void)arrowButtonPressed
{
    if (self.isSpread) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.viewModel.pgcModel.itemId forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"video_detail", @"click_arrow_up", nil, @"video_detail", extra);
    }
    else {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.viewModel.pgcModel.itemId forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"video_detail", @"click_arrow_down", nil, @"video_detail", extra);
    }
    [UIView animateWithDuration:0.25f animations:^{
//        self.arrowTag.alpha = self.isSpread ? 0 : 1;
        if(self.isSpread) {
            self.arrowImage.imageView.transform  =  CGAffineTransformMakeRotation(M_PI);
        } else {
            self.arrowImage.imageView.transform  = CGAffineTransformMakeRotation(0);
        }

    } completion:^(BOOL finished) {
        
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(relayoutRecommendViewFrame:isClickArrowImage:)]) {
        [self.delegate relayoutRecommendViewFrame:!self.isSpread isClickArrowImage:YES];
    }
}

- (void)showPGCView
{
    [self logClickPGC];
    
    NSString *openURL;
    if ([self.viewModel.pgcModel.contentInfo ttgc_contentType] == TTGeneratedContentTypePGC) {
        openURL = [TTVideoCommon PGCOpenURLWithMediaID:[self.viewModel.pgcModel.contentInfo ttgc_contentID] enterType:kPGCProfileEnterSourceVideoArticleTopAuthor];
        openURL = [openURL stringByAppendingString:[NSString stringWithFormat:@"&page_source=%@", @(1)]];
        //增加item_id
        openURL = [NSString stringWithFormat:@"%@&item_id=%@",openURL,self.viewModel.pgcModel.itemId];
        wrapperTrackEvent(@"detail", @"detail_enter_pgc");
    } else {
        openURL = [NSString stringWithFormat:@"sslocal://pgcprofile?uid=%@&page_source=%@&gd_ext_json=%@&page_type=0", [self.viewModel.pgcModel.contentInfo ttgc_contentID], @(1), kPGCProfileEnterSourceVideoArticleTopAuthor];
        NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] init];
        [extraDict setValue:@{@"ugc":@(1)} forKey:@"extra"];
        [extraDict setValue:[self.viewModel.pgcModel.contentInfo ttgc_contentID] forKey:@"ext_value"];
        wrapperTrackEvent(@"detail", @"detail_enter_ugc");
    }
    
    id<TTVVideoDetailNatantPGCModelProtocol> pgcModel = self.viewModel.pgcModel;
    openURL = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:openURL categoryName:pgcModel.categoryName fromPage:@"detail_video" groupId:pgcModel.groupIDStr profileUserId:nil];
    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
}

- (void)refreshPGCSubscribeState:(NSNotification *)notification   
{
    ExploreEntry *entry = [[notification userInfo] objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSDictionary *userInfo = [notification userInfo];
    NSString *uid = [userInfo stringValueForKey:kRelationActionSuccessNotificationUserIDKey defaultValue:@""];
    
    NSString *contentID = [self.viewModel.pgcModel.contentInfo ttgc_contentID];
    
    NSMutableDictionary *contentInfo = [self.viewModel.pgcModel.contentInfo mutableCopy];
//    if (entry.subscribed && self.redpacketModel && self.hasRedpacket) {
//        [self clearRedPacket];
//    }
    BOOL isSelfNotification = NO;
    if (entry) {
        if ([self.viewModel.pgcModel.contentInfo ttgc_contentType] == TTGeneratedContentTypeUGC) {
            if ([[entry.userID stringValue] isEqualToString:contentID]) {
                contentInfo[@"follow"] = entry.subscribed;
                isSelfNotification = YES;
            }
        } else {
            if ([[entry.mediaID stringValue] isEqualToString:contentID]) {
                contentInfo[@"subcribed"] = entry.subscribed;
                isSelfNotification = YES;
            }
        }
    } else if (!isEmptyString(uid)) {
        FriendActionType type = [userInfo tt_intValueForKey:kRelationActionSuccessNotificationActionTypeKey];
        if (type == FriendActionTypeUnfollow) {
            if ([uid isEqualToString:contentID]) {
                contentInfo[@"follow"] = @(0);
                isSelfNotification = YES;
            }
        } else if (type == FriendActionTypeFollow) {
            if ([uid isEqualToString:contentID]) {
                contentInfo[@"follow"] = @(1);
                isSelfNotification = YES;
            }
        }
    }
    self.viewModel.pgcModel.contentInfo = contentInfo;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isSelfNotification && !self.isAnimating) {
            [self notificationAction];
        }
    });
}

#pragma  mark - themed
- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
//    if (ttvs_enabledVideoNewButton() || ttvs_enabledVideoRecommend()) {
//        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
//            [self.arrowTag setImage:[UIImage imageNamed:@"video_detail_arrow"]];
//        }
//        else {
//            [self.arrowTag setImage:[UIImage imageNamed:@"video_detail_arrow_night"]];
//        }
//    }
    
    self.backgroundView.backgroundColor = SSGetThemedColorInArray(tt_ttuisettingHelper_detailViewBackgroundColors());
}

#pragma mark - log related
#pragma mark - 关注互动埋点 (3.0)
- (void)followActionLogV3IsRedPacketSender:(BOOL) isRedPacketSender
{
    NSMutableDictionary *params = [self followActionLogV3CommonParams];
    
    if (isRedPacketSender){
        [params setValue:@"1" forKey: @"is_redpacket"];
        [params setValue:@"1031" forKey:@"server_soure"];
    }else{
        [params setValue:@"0" forKey: @"is_redpacket"];
    }
    if ([self ttv_isSubCribed]){
        [TTTrackerWrapper eventV3:@"rt_unfollow" params:params];
    }else{
        [TTTrackerWrapper eventV3:@"rt_follow" params:params];
    }
    
}

- (NSMutableDictionary *)followActionLogV3CommonParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    id<TTVVideoDetailNatantPGCModelProtocol> pgcModel = self.viewModel.pgcModel;
    NSString *userID = [pgcModel.contentInfo ttgc_contentID];
    
    [params setValue:pgcModel.categoryName forKey: @"category_name"];
    [params setValue:@"0" forKey: @"not_default_follow_num"];
    [params setValue:pgcModel.itemId forKey:@"item_id"];
    [params setValue:@"from_group" forKey: @"follow_type"];
    [params setValue:userID forKey: @"to_user_id"];
    [params setValue:[pgcModel.contentInfo ttgc_mediaID] forKey: @"media_id"];
    [params setValue:pgcModel.enterFrom forKey: @"enter_from"];
    [params setValue:@"detail" forKey: @"position"];
    [params setValue:@"31" forKey:@"server_soure"];
    [params setValue:pgcModel.groupIDStr forKey:@"group_id"];
    [params setValue:@"1" forKey: @"follow_num"];
    [params setValue:@"video" forKey:@"source"];
    [params setValue:pgcModel.logPb forKey:@"log_pb"];
    return params;
}

- (void)logRedPacketIfNeed{
    BOOL isFollowed = [self ttv_isSubCribed];
    if (!isFollowed && self.hasRedpacket){
        
        NSString *actionType = @"show";
        NSString *position = @"detail";
        NSString *userId = [self.viewModel.pgcModel.contentInfo ttgc_contentID];
        NSString *mediaId = [self.viewModel.pgcModel.contentInfo ttgc_mediaID];
        NSString *groupId = self.viewModel.pgcModel.groupIDStr;
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:userId forKey:@"user_id"];
        [param setValue:mediaId forKey:@"media_id"];
        [param setValue:groupId forKey:@"group_id"];
        [param setValue:actionType forKey:@"action_type"];
        [param setValue:position forKey:@"position"];
        [param setValue:self.viewModel.pgcModel.categoryName forKey:@"category_name"];
        
        [TTTrackerWrapper eventV3:@"red_button" params:param];
    }
}

//点击pgc|ugc
- (void)logClickPGC
{
    NSString *contentID = [self.viewModel.pgcModel.contentInfo ttgc_contentID];
    NSMutableDictionary *eventContext = [NSMutableDictionary dictionary];
    [eventContext setValue:contentID forKey:@"user_id"];
    [eventContext setValue:@"detail" forKey:@"position"];
    [TTTrackerWrapper eventV3:@"enter_homepage" params:eventContext isDoubleSending:YES];
}

#pragma mark - Helper
+ (CGFloat)nameLabelFontSize
{
    if ([TTDeviceHelper isPadDevice]) {
        return 22.f;
    }
    
    if (ttsettings_articleNavBarShowFansNumEnable()) {
        return 14.f;
    }
    return 16.f;
}

- (CGFloat)subsribeButtonWidth
{
    if ([TTDeviceHelper isPadDevice]) {
        return 94.f;
    }
    return [[UIScreen mainScreen] bounds].size.width * kSubscribeButtonWidthScreenAspect;
}

- (CGFloat)nameButtonMaxLen
{
    return self.width - 2 * kVideoDetailItemCommonEdgeMargin - [TTDeviceUIUtils tt_newPadding:kPGCAvatarSize] - kAvatarRightSpace - [self subsribeButtonWidth];
}

- (BOOL)ttv_isSubCribed
{
    return [self.viewModel.pgcModel.contentInfo ttgc_isSubCribed];
}

//- (void)setRedpacketModel:(FRRedpackStructModel *)redpacketModel
//{
//    if (_redpacketModel != redpacketModel) {
//        _redpacketModel = redpacketModel;
//        self.hasRedpacket = YES;
//        self.themedButtonStyle = [redpacketModel.button_style integerValue];
//    }
//}

//- (void)clearRedPacket
//{
//    self.redpacketModel = nil;
//    self.hasRedpacket = NO;
//    self.themedButtonStyle = 0;
//}
@end
