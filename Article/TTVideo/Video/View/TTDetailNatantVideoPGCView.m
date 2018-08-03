//
//  TTDetailNatantVideoPGCView.m
//  Article
//
//  Created by Ray on 16/4/15.
//
//

#import "TTDetailNatantVideoPGCView.h"
#import "Article.h"
#import "Article+TTVArticleProtocolSupport.h"
#import "TTRoute.h"
#import "UIButton+TTAdditions.h"
#import "ExploreEntryManager.h"
#import "TTAlphaThemedButton.h"
#import "TTIconLabel.h"
#import "TTVideoCommon.h"
#import "ArticleInfoManager.h"
#import "TTDetailModel.h"
#import "TTUISettingHelper.h"
#import "ArticleMomentProfileViewController.h"
#import <TTAccountBusiness.h>
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"
#import "TTFollowThemeButton.h"
#import "TTRecommendCollectionViewCell.h"
#import "TTRecommendModel.h"
#import "TTNetworkManager.h"
#import "UIButton+TTAdditions.h"
#import "PGCAccountManager.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "FriendDataManager.h"
#import "SSImpressionManager.h"
#import "ExploreAvatarView+VerifyIcon.h"
//#import "TTRedPacketManager.h"
#import <TTUIResponderHelper.h>

#define kPGCViewHeight (([TTDeviceHelper isPadDevice]) ? 84 : 66)
#define kPGCAvatarSize                      (([TTDeviceHelper isPadDevice]) ? 44 : 36)
#define kPGCRecommendViewHeight             222
#define kAvatarRightSpace                   8.f
#define kSubscribeButtonWidthScreenAspect   0.1875f
#define kVideoDetailItemCommonEdgeMargin (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kPGCViewHeightOnTop 44

extern BOOL ttvs_enabledVideoRecommend(void);
extern BOOL ttvs_enabledVideoNewButton(void);

@interface TTDetailNatantVideoPGCView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, nullable) TTAlphaThemedButton *backgroundView;
@property (nonatomic, strong, nullable) ExploreAvatarView   *pgcAvatar;
@property (nonatomic, strong, nullable) TTIconLabel         *pgcName;
@property (nonatomic, strong, nullable) TTFollowThemeButton *subscribeButton;
@property (nonatomic, strong, nullable) SSThemedButton      *arrowImage;
@property (nonatomic, strong, nullable) id<TTVArticleProtocol>             article;
@property (nonatomic, assign) BOOL isAnimation;                                  //修复快速连续点击关注按出现的UI问题
@property (nonatomic, strong) NSMutableArray                *recommendArray;
@property (nonatomic, strong) NSMutableArray                *recommendRangeArray;
@property (nonatomic, strong) NSDictionary                  *recommendResponse;
@property (nonatomic, assign) BOOL                           hasFailedRequest;
@property (nonatomic, strong, nullable) NSDictionary        *contentInfo;
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@property (nonatomic, assign) NSInteger                     initHeight;
@property (nonatomic, assign) BOOL                          hasRedpacket;
@property (nonatomic, assign) NSInteger                     themedButtonStyle;
@end

@implementation TTDetailNatantVideoPGCView

@synthesize contentInfo = _contentInfo;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        [self reloadThemeUI];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)refreshWithArticle:(id<TTVArticleProtocol> )article
{
    if (_article != article) {
        _article = article;

        if (!article) {
            self.height = 0;
        } else {
            if (self.onTop) {
                self.height = [TTDeviceUIUtils tt_newPadding:kPGCViewHeightOnTop];
            } else {
                self.height = [TTDeviceUIUtils tt_newPadding:kPGCViewHeight];
            }
            [self buildView];
            [self refreshUI];
            [self reloadThemeUI];
        }
    }
}

//- (void)setRedpacketModel:(FRRedpackStructModel *)redpacketModel
//{
//    if (_redpacketModel != redpacketModel) {
//        _redpacketModel = redpacketModel;
//        self.hasRedpacket = YES;
//        self.themedButtonStyle = [redpacketModel.button_style integerValue];
//    }
//}

- (void)layoutSubviews
{
    [self refreshUI];
    [super layoutSubviews];
}

- (void)buildView
{
    [self refreshAvatar];

    self.pgcName.text = [self.contentInfo ttgc_contentName];
    [self.pgcName sizeToFit];
    if (_onTop) {
        self.backgroundView.height = kPGCViewHeightOnTop;
    }
    [self addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.pgcAvatar];
    [self.backgroundView addSubview:self.pgcName];
    [self.backgroundView addSubview:self.bottomLine];

    [self addSubview:self.arrowImage];
    [self addSubview:self.subscribeButton];
    [self addSubview:self.arrowTag];
    [self addSubview:self.recommendLabel];
    if ( !self.onTop) { // ttvs_enabledVideoRecommend() &&
        [self addSubview:self.collectionView];
    }

    [self refreshSubscribeButtonTitle];
    [self refreshSubscribeButtonFrame];

    self.arrowImage.hidden = YES;
    [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@([TTDeviceUIUtils tt_newPadding:28]));
        make.width.equalTo(@([TTDeviceUIUtils tt_newPadding:28]));
        make.right.equalTo(self.backgroundView.mas_right).offset([TTDeviceUIUtils tt_newPadding:-15]);
        make.centerY.equalTo(self.pgcAvatar.mas_centerY);
    }];

    self.arrowTag.hidden = YES;
    [self.arrowTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.arrowTag.height));
        make.width.equalTo(@(self.arrowTag.width));
        make.bottom.equalTo(self.backgroundView.mas_bottom);
        make.centerX.equalTo(self.arrowImage.mas_centerX);
    }];

    if (!isEmptyString([TTAccountManager userID]) && !isEmptyString([self.contentInfo ttgc_contentID]) && [[self.contentInfo ttgc_contentID] isEqualToString:[TTAccountManager userID]]) {
        self.subscribeButton.hidden = YES;
    } else {
        self.subscribeButton.hidden = NO;
    }

    self.recommendLabel.hidden = YES;

    self.collectionView.hidden = YES;

    self.backgroundColorThemeKey = kColorBackground3;
    
    [self logRedPacketIfNeed];
}

- (void)refreshPGCSubscribeState:(NSNotification *)notification
{
    ExploreEntry *entry = [[notification userInfo] objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSDictionary *userInfo = [notification userInfo];
    NSString *uid = [userInfo stringValueForKey:kRelationActionSuccessNotificationUserIDKey defaultValue:@""];
    
    NSString *contentID = [self.contentInfo ttgc_contentID];

    NSMutableDictionary *contentInfo = [self.contentInfo mutableCopy];
//    if (entry.subscribed && self.redpacketModel && self.hasRedpacket) {
//        [self clearRedPacket];
//    }
    
    if (entry) {
        if ([self.contentInfo ttgc_contentType] == TTGeneratedContentTypeUGC) {
            if ([[entry.userID stringValue] isEqualToString:contentID]) {
                contentInfo[@"follow"] = entry.subscribed;
            }
        } else {
            if ([[entry.mediaID stringValue] isEqualToString:contentID]) {
                contentInfo[@"subcribed"] = entry.subscribed;
            }
        }
    } else if (!isEmptyString(uid)) {
        FriendActionType type = [userInfo tt_intValueForKey:kRelationActionSuccessNotificationActionTypeKey];
        if (type == FriendActionTypeUnfollow) {
            if ([uid isEqualToString:contentID]) {
                contentInfo[@"follow"] = @(0);
            }
        } else if (type == FriendActionTypeFollow) {
            if ([uid isEqualToString:contentID]) {
                contentInfo[@"follow"] = @(1);
            }
        }
    }
    self.contentInfo = contentInfo;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshSubscribeButtonTitle];
    });
}

- (void)refreshSubscribeButtonFrame
{
    self.subscribeButton.origin = CGPointMake(self.width - self.subscribeButton.width - [TTDeviceUIUtils tt_newPadding: 15], (self.initHeight - self.subscribeButton.height) / 2);
}

- (void)refreshSubscribeButtonTitle
{
    if (self.initHeight <= 0) {
        self.initHeight = self.height;
    }
    self.subscribeButton.followed = [self.contentInfo ttgc_isSubCribed];
    BOOL isAuthor = NO;
    PGCAccount *account = [[PGCAccountManager shareManager] currentLoginPGCAccount];
    if ([account.mediaID isEqualToString:[self.contentInfo stringValueForKey:@"media_id" defaultValue:nil]]) {
        isAuthor = YES;
    }
    self.subscribeButton.hidden = isAuthor;
    self.isAnimation = NO;
    if (self.hasRedpacket) {
        self.subscribeButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.themedButtonStyle defaultType:TTUnfollowedType201];
        self.subscribeButton.followedType = TTFollowedType101;
    }else{
        self.subscribeButton.unfollowedType = TTUnfollowedType101;
        self.subscribeButton.followedType = TTFollowedType101;
    }
    [self reloadThemeUI];
    [self.subscribeButton refreshUI];
}

- (void)refreshUI
{

    if ([TTDeviceHelper isPadDevice]) {
        //暂且不对ipad做新的处理
    }

    self.pgcName.text = [self.contentInfo ttgc_contentName];

    [self.pgcName sizeToFit];
    self.pgcName.centerY = _pgcAvatar.centerY;
    self.pgcName.left = _pgcAvatar.right + kAvatarRightSpace;

    [self refreshAvatar];

    if ([TTDeviceHelper isPadDevice]) {
        self.bottomLine.hidden = YES;
    } else {
        if (!_onTop) {
            self.bottomLine.hidden = NO;
        }
        self.bottomLine.bottom = self.height;
    }
}

- (void)refreshAvatar
{
    NSString *avatarUrl = [self.contentInfo ttgc_contentAvatarURL];
    NSString *userAuthInfo = [self.contentInfo ttgc_userAuthInfo];
    BOOL isVerified = [TTVerifyIconHelper isVerifiedOfVerifyInfo:userAuthInfo];
    __weak typeof(self) wself = self;
    [self.pgcAvatar.imageView setImageWithURLString:avatarUrl placeholderImage:[UIImage themedImageNamed:@"pgcloading_allshare.png"] options:0 success:^(UIImage *image, BOOL cached) {
        __strong typeof(wself) self = wself;
        if (isVerified && image) {
            [self.pgcAvatar showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
            self.pgcName.labelMaxWidth = [self nameButtonMaxLen] - self.pgcName.iconContainerWidth;
        } else {
            [self.pgcAvatar showOrHideVerifyViewWithVerifyInfo:nil decoratorInfo:nil sureQueryWithID:YES userID:nil];
            self.pgcName.labelMaxWidth = [self nameButtonMaxLen];
        }
    } failure:nil];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    if (ttvs_enabledVideoNewButton() || ttvs_enabledVideoRecommend()) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            [self.arrowTag setImage:[UIImage imageNamed:@"video_detail_arrow"]];
        }
        else {
            [self.arrowTag setImage:[UIImage imageNamed:@"video_detail_arrow_night"]];
        }
        self.collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }

    if ([TTDeviceHelper isPadDevice]) {
        self.backgroundView.backgroundColorThemeKey = kColorBackground18;
    } else {
        self.backgroundView.backgroundColor = SSGetThemedColorInArray([TTUISettingHelper detailViewBackgroundColors]);
    }

}

- (void)willAppear{
    [super willAppear];
}

#pragma mark -- TTDetailNatantViewBase protcol implmenation
- (void)trackEventIfNeeded{

}

-(void)reloadData:(id)object{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager * articleInfo = (ArticleInfoManager *)object;
    [self refreshWithArticle:articleInfo.detailModel.article];
}

#pragma mark - Action

- (void)showPGCView
{
    NSString *openURL;
    if ([self.contentInfo ttgc_contentType] == TTGeneratedContentTypePGC) {
        openURL = [TTVideoCommon PGCOpenURLWithMediaID:[self.contentInfo ttgc_contentID] enterType:kPGCProfileEnterSourceVideoArticleTopAuthor];
        openURL = [openURL stringByAppendingString:[NSString stringWithFormat:@"&page_source=%@", @(1)]];
        //增加item_id
        openURL = [NSString stringWithFormat:@"%@&item_id=%@",openURL,self.article.itemID];
        wrapperTrackEvent(@"detail", @"detail_enter_pgc");
    } else {
        openURL = [NSString stringWithFormat:@"sslocal://pgcprofile?uid=%@&page_source=%@&gd_ext_json=%@&page_type=0", [self.contentInfo ttgc_contentID], @(1), kPGCProfileEnterSourceVideoArticleTopAuthor];
        NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] init];
        [extraDict setValue:@{@"ugc":@(1)} forKey:@"extra"];
        [extraDict setValue:[self.contentInfo ttgc_contentID] forKey:@"ext_value"];
        NSString *uniqueID = [NSString stringWithFormat:@"%lld",_article.uniqueID];
        wrapperTrackEventWithCustomKeys(@"detail", @"detail_enter_profile", uniqueID, nil, extraDict);
        wrapperTrackEvent(@"detail", @"detail_enter_ugc");
    }
    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURL]];
}

- (void)changeSubscribeCount:(NSNotification *)notification {
    [SSCommonLogic setSubscribeCount:0];
}

- (void)subscribeButtonPressed
{
    if (self.isAnimation){
        return;
    }
    [self didExecuteSubscribe];
}

- (void)arrowButtonPressed {
    CGFloat marginal = [TTDeviceUIUtils tt_newPadding:kPGCViewHeight];
    if (self.height > marginal) {
        self.originViewHeight = self.height;
        self.changedViewHeight = marginal;
        self.arrowImage.imageName = @"video_detail_open";
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.article.itemID forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"video_detail", @"click_arrow_up", nil, @"video_detail", extra);
    }
    else {
        self.originViewHeight = self.height;
        self.changedViewHeight = [TTDeviceUIUtils tt_newPadding:(kPGCViewHeight + kPGCRecommendViewHeight)];
        self.arrowImage.imageName = @"video_detail_stop";
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.article.itemID forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"video_detail", @"click_arrow_down", nil, @"video_detail", extra);
        [self collectionViewWillDisplayAtIndex:0];
        [self collectionViewWillDisplayAtIndex:1];
        [self collectionViewWillDisplayAtIndex:2];
    }
    [self.delegate updateRecommendView];
}

//- (void)clearRedPacket
//{
//    self.redpacketModel = nil;
//    self.hasRedpacket = NO;
//    self.themedButtonStyle = 0;
//    if ([self.delegate respondsToSelector:@selector(videoPGCViewClearRedpacket)]) {
//        [self.delegate videoPGCViewClearRedpacket];
//    }
//}

// 按钮被点击，订阅，取消订阅
- (void)didExecuteSubscribe {
//    NSString *contentID = [self.contentInfo ttgc_contentID];
    BOOL hasSubscribed = [self.contentInfo ttgc_isSubCribed];
    FriendActionType actionType;
    if (hasSubscribed) {
        actionType = FriendActionTypeUnfollow;
    }
    else {
        actionType = FriendActionTypeFollow;
    }

    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.article.itemID forKey:@"item_id"];

    [self startIndicatorAnimating:hasSubscribed];
    
    BOOL isRedPacketSender = NO;
    TTFollowNewSource source = TTFollowNewSourceVideoDetail;
//    if ( self.redpacketModel && self.hasRedpacket) {
//        source = TTFollowNewSourceVideoDetailRedPacket;
//        isRedPacketSender = YES;
//    }
    [self followActionLogV3IsRedPacketSender:isRedPacketSender];
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:actionType userID:self.article.mediaUserID  platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(source) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        StrongSelf;
        [self p_finishChangeSubscribeStatus:error hasSubscribed:hasSubscribed conentType:[self.contentInfo ttgc_contentType] result:result action:actionType];
    }];
}

- (void)p_finishChangeSubscribeStatus:(NSError *)error hasSubscribed:(BOOL)hasSubscribed conentType:(TTGeneratedContentType)contentType result:(NSDictionary *)result action:(FriendActionType)actionType
{
//    BOOL showRedPacket = NO;
//    if (!hasSubscribed && self.redpacketModel && self.hasRedpacket && !error) {
//        TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//        redPacketTrackModel.userId = [self UserId];
//        redPacketTrackModel.mediaId = [self MediaId];
//        redPacketTrackModel.categoryName = _categoryName;
//        redPacketTrackModel.source = @"video";
//        redPacketTrackModel.position = @"detail";
//        [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:self.redpacketModel
//                                                                   source:redPacketTrackModel
//                                                           viewController:[TTUIResponderHelper topViewControllerFor:self]];
//        [self clearRedPacket];
//        showRedPacket = YES;
//    }
    
    if (!error) {
        NSMutableDictionary *saveDic = [NSMutableDictionary dictionaryWithDictionary:self.contentInfo];
        if ([saveDic ttgc_contentType] == TTGeneratedContentTypeUGC) {
            [saveDic setValue:@(!hasSubscribed) forKey:@"follow"];
        } else {
            [saveDic setValue:@(!hasSubscribed) forKey:@"subcribed"];
        }
        [saveDic setValue:self.article.videoID forKey:@"video_id"];
        self.contentInfo = [saveDic copy];

        if (contentType == TTGeneratedContentTypePGC) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVideoDetailPGCSubscribeStatusChangedNotification object:saveDic];
        }

        if (!hasSubscribed && !self.recommendResponse && !self.onTop) {
            NSString *urlString = @"http://isub.snssdk.com/2/relation/follow_recommends";
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[self.contentInfo ttgc_contentID] forKey:@"to_user_id"];
            //35表示视频详情页，给推荐组进行统计和服务优化用，详情见文档https://wiki.bytedance.net/pages/viewpage.action?pageId=70851470
            [params setObject:@(35) forKey:@"page"];
            WeakSelf;
            [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
                StrongSelf;
                if (!error) {
                    self.recommendResponse = jsonObj;
                    NSDictionary *data = [self.recommendResponse tt_dictionaryValueForKey:@"data"];
                    self.recommendArray = [TTRecommendModel arrayOfModelsFromDictionaries:[data tt_arrayValueForKey:@"recommend_users"]];
                    for (int i = 0; i < self.recommendArray.count; i++) {
                        TTRecommendModel *model = [self.recommendArray objectAtIndex:i];
                        if (isEmptyString(model.avatarUrlString) || isEmptyString(model.nameString) || isEmptyString(model.reasonString) || isEmptyString(model.userID)) {
                            [self.recommendArray removeObject:model];
                            i--;
                        }
                    }
                    if (self.recommendArray.count < 3) {
                        self.hasFailedRequest = YES;
                    }
                    else {
                        CGSize size = self.flowLayout.itemSize;
                        NSRange firstRange = NSMakeRange(10, size.width);
                        [self.recommendRangeArray addObject:[NSValue valueWithRange:firstRange]];
                        for (int i = 1; i < self.recommendArray.count; i++) {
                            NSValue *valueObject = self.recommendRangeArray[i - 1];
                            NSInteger left = [valueObject rangeValue].location + [valueObject rangeValue].length;
                            NSRange range = NSMakeRange(left + self.flowLayout.minimumLineSpacing, size.width);
                            [self.recommendRangeArray addObject:[NSValue valueWithRange:range]];
                        }
                        [self.collectionView reloadData];
                    }
                }
                else {
                    self.hasFailedRequest = YES;
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self stopIndicatorAnimatingShowRedPacket:NO];
//                    [self stopIndicatorAnimatingShowRedPacket:showRedPacket];
                });
            }];
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self stopIndicatorAnimatingShowRedPacket:NO];
//                [self stopIndicatorAnimatingShowRedPacket:showRedPacket];
            });
        }
    }
    else {
        NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
        if (isEmptyString(hint)) {
            hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopIndicatorAnimatingShowRedPacket:NO];
//            [self stopIndicatorAnimatingShowRedPacket:showRedPacket];
        });
    }
}

- (void)startIndicatorAnimating:(BOOL)hasSubscribed
{
    self.isAnimation = YES;
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
    NSInteger hasSubscribedLeft = self.width - self.subscribeButton.width - [TTDeviceUIUtils tt_newPadding: 49];
    NSInteger unSubscribedLeft = self.width - self.subscribeButton.width - [TTDeviceUIUtils tt_newPadding: 15];
    if (ttvs_enabledVideoRecommend() && !self.hasFailedRequest && !self.onTop && !showRedPacket) {
        [self refreshSubscribeButtonTitle];
        [UIView animateWithDuration:0.25f delay:0 options:0 animations:^{
            BOOL hasSubscribed = [self.contentInfo ttgc_isSubCribed];
            if (hasSubscribed) {
                self.subscribeButton.left = hasSubscribedLeft;
                self.subscribeButton.centerY = self.pgcAvatar.centerY;
            }else{
                self.subscribeButton.left = unSubscribedLeft;
                self.subscribeButton.centerY = self.pgcAvatar.centerY;
            }
        } completion:^(BOOL finished) {
            BOOL hasSubscribed = [self.contentInfo ttgc_isSubCribed];
            if (hasSubscribed) {
                self.subscribeButton.left = hasSubscribedLeft;
                self.subscribeButton.centerY = self.pgcAvatar.centerY;
                self.originViewHeight = self.height;
                self.changedViewHeight = [TTDeviceUIUtils tt_newPadding:(kPGCViewHeight + kPGCRecommendViewHeight)];
                self.arrowImage.hidden = NO;
                self.arrowImage.imageName = @"video_detail_stop";
                self.arrowImage.alpha = 0;
                [UIView animateWithDuration:0.4f animations:^{
                    [self layoutIfNeeded];
                    self.arrowImage.alpha = 1;
                } completion:^(BOOL finished) {
                    [self collectionViewWillDisplayAtIndex:0];
                    [self collectionViewWillDisplayAtIndex:1];
                    [self collectionViewWillDisplayAtIndex:2];
                }];
            }
            else {
                self.subscribeButton.left = unSubscribedLeft;
                self.subscribeButton.centerY = self.pgcAvatar.centerY;
                self.originViewHeight = self.height;
                self.changedViewHeight = [TTDeviceUIUtils tt_newPadding:kPGCViewHeight];
                self.arrowImage.alpha = 1;
                [UIView animateWithDuration:0.4f animations:^{
                    self.arrowImage.alpha = 0;
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                    self.arrowImage.hidden = YES;
                }];
                
            }
            [self.delegate updateRecommendView];
        }];

    }else{
        [self refreshSubscribeButtonTitle];
        [self refreshSubscribeButtonFrame];
    }

    
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommendArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item >= self.recommendArray.count) {
        
        return nil;
    }
    
    TTRecommendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TTRecommendCollectionViewCellIdentifier forIndexPath:indexPath];
    
    TTRecommendModel *model = self.recommendArray[indexPath.item];
    __weak typeof(cell) wCell = cell;
    cell.followPressed = ^{
        FriendDataManager *dataManager = [FriendDataManager sharedManager];
        FriendActionType actionType;
        if (model.isFollowing) {
            actionType = FriendActionTypeUnfollow;
        }
        else {
            actionType = FriendActionTypeFollow;
        }
        [self cellFollowActionLogV3:indexPath IsRedPacketSender:NO];
        [[TTFollowManager sharedManager] startFollowAction:actionType userID:model.userID platform:nil name:nil from:nil reason:nil newReason:model.reason newSource:@(TTFollowNewSourceVideoDetailRecommend) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
            if (!error) {
                NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                model.isFollowing = [user tt_boolValueForKey:@"is_following"];
                if (model.isFollowing) {
                    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                    [extra setValue:self.article.itemID forKey:@"item_id"];
                    wrapperTrackEventWithCustomKeys(@"video_detail", @"sub_rec_subscribe", model.userID, @"video_detail", extra);
                }
                else {
                    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
                    [extra setValue:self.article.itemID forKey:@"item_id"];
                    wrapperTrackEventWithCustomKeys(@"video_detail", @"sub_rec_unsubscribe", model.userID, @"video_detail", extra);
                }
                [wCell.subscribeButton stopLoading:^{
                    if (model.isFollowing) {
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"关注成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                    }
                }];
            }
            else {
                
                [wCell.subscribeButton stopLoading:^{
                    NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                    if (isEmptyString(hint)) {
                        hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                    }
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                }];
            }
        }];
    };
    [cell configWithModel:model];
    return cell;
}

//iOS8以上埋点逻辑，为了兼容iOS7，自定义willDisplay

//#ifdef __IPHONE_8_0
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    TTRecommendCollectionViewCell *displayCell = (TTRecommendCollectionViewCell *)cell;
//    if (!displayCell.model.isTracked) {
//        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
//        [extra setValue:self.article.itemID forKey:@"item_id"];
//        wrapperTrackEventWithCustomKeys(@"video_detail", @"sub_rec_impression", displayCell.model.userID, @"video_detail", extra);
//        displayCell.model.isTracked = YES;
//    }
//    TTRecommendModel *model = self.recommendArray[indexPath.item];
//    [[SSImpressionManager shareInstance] recordVideoRecommendListWithUserID:model.userID status:SSImpressionStatusRecording];
//}
//
//#endif

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger left = 0;
        NSInteger right = self.recommendRangeArray.count - 1;
        NSInteger indexLeft = [self quickQueryIndex:scrollView.contentOffset.x leftIndex:left rightIndex:right];
        [self collectionViewWillDisplayAtIndex:indexLeft];
        NSInteger indexRight = [self quickQueryIndex:(scrollView.contentOffset.x + self.collectionView.width) leftIndex:left rightIndex:right];
        [self collectionViewWillDisplayAtIndex:indexRight];
    });
}

- (void)collectionViewWillDisplayAtIndex:(NSInteger)index {
    if (index >= 0 && self.recommendArray.count > index) {
        TTRecommendModel *model = self.recommendArray[index];
        if (!model.isDisplay) {
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.article.itemID forKey:@"item_id"];
            [extra setValue:[self.contentInfo ttgc_contentID] forKey:@"to_uid"];
            [extra setValue:@"1" forKey:@"aggr_type"];
            [[SSImpressionManager shareInstance] recordVideoRecommendListWithUserID:model.userID status:SSImpressionStatusRecording extra:extra];
            model.isDisplay = YES;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item >= self.recommendArray.count) {
        
        return ;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        TTRecommendModel *model = self.recommendArray[indexPath.item];
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.article.itemID forKey:@"item_id"];
        [extra setValue:[self.contentInfo ttgc_contentID] forKey:@"to_uid"];
        [extra setValue:@"1" forKey:@"aggr_type"];
        [[SSImpressionManager shareInstance] recordVideoRecommendListWithUserID:model.userID status:SSImpressionStatusEnd extra:extra];
        model.isDisplay = NO;
    });
}

- (void)recommendListWillDisplay {
    [[SSImpressionManager shareInstance] enterVideoRecommendList];
}

- (void)recommendListEndDisplay {
    [[SSImpressionManager shareInstance] leaveVideoRecommendList];
}

#pragma mark - UICollectionViewDataSource
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item >= self.recommendArray.count) {
        
        return ;
    }
    
    TTRecommendModel *model = self.recommendArray[indexPath.item];
    NSString *openPGCURL = [TTVideoCommon PGCOpenURLWithMediaID:model.userID
                                                      enterType:kPGCProfileEnterSourceVideoArticleTopAuthor];

    openPGCURL = [openPGCURL stringByAppendingString:[NSString stringWithFormat:@"&page_source=%@", @(1)]];

    //增加item_id
    openPGCURL = [NSString stringWithFormat:@"%@&item_id=%@",openPGCURL,self.article.itemID];

    NSString *replaceOpenPGCURL = [openPGCURL stringByReplacingOccurrencesOfString:@"media_id" withString:@"uid"];

    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:replaceOpenPGCURL]];

    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.article.itemID forKey:@"item_id"];
    wrapperTrackEventWithCustomKeys(@"video_detail", @"sub_rec_click", model.userID, @"video_detail", extra);

}

#pragma mark Getters
- (TTAlphaThemedButton *)backgroundView
{
    if (!_backgroundView) {
        CGFloat height = kPGCViewHeight;
        if (_onTop) {
            height = kPGCViewHeightOnTop;
        }
        _backgroundView = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceUIUtils tt_newPadding:height])];
        [_backgroundView addTarget:self action:@selector(showPGCView) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:kEntrySubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:RelationActionSuccessNotification object:nil];
    }
    return _backgroundView;
}

- (ExploreAvatarView *)pgcAvatar
{
    if (!_pgcAvatar) {
        CGFloat avatarSize = [TTDeviceUIUtils tt_newPadding:kPGCAvatarSize];
        if (_onTop) {
            avatarSize = [TTDeviceUIUtils tt_newPadding:24];
        }

        CGFloat totalHeigth = [TTDeviceUIUtils tt_newPadding:_onTop?kPGCViewHeightOnTop:kPGCViewHeight];
        _pgcAvatar = [[ExploreAvatarView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding: kVideoDetailItemCommonEdgeMargin], [TTDeviceUIUtils tt_newPadding: (totalHeigth - avatarSize) / 2.f], avatarSize, avatarSize)];
        _pgcAvatar.enableRoundedCorner = YES;
        _pgcAvatar.userInteractionEnabled = NO;
        [_pgcAvatar setupVerifyViewForLength:kPGCAvatarSize adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        UIView *view = [[UIView alloc] initWithFrame:_pgcAvatar.bounds];
        view.layer.cornerRadius = view.width / 2.f;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        [_pgcAvatar insertSubview:view belowSubview:_pgcAvatar.verifyView];
    }
    return _pgcAvatar;
}

- (TTIconLabel *)pgcName
{
    if (!_pgcName) {
        _pgcName = [[TTIconLabel alloc] init];
        _pgcName.font = [UIFont systemFontOfSize:[[self class] nameLabelFontSize]];
        _pgcName.textColorThemeKey = kColorText1;
        _pgcName.userInteractionEnabled = NO;
    }
    return _pgcName;
}

- (SSThemedButton *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _arrowImage.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:6];
        _arrowImage.layer.masksToBounds = YES;
        _arrowImage.backgroundColorThemeKey = kColorBackground2;
        _arrowImage.imageName = @"video_detail_open";
        [_arrowImage addTarget:self action:@selector(arrowButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_arrowImage setHitTestEdgeInsets:UIEdgeInsetsMake(0, 0, 0, [TTDeviceUIUtils tt_newPadding:-15])];
    }
    return _arrowImage;
}

- (TTImageView *)arrowTag {
    if (!_arrowTag) {
        UIImage *icon = nil;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
//            icon = [UIImage imageNamed:@"video_detail_arrow"];
        }
        else {
//            icon = [UIImage imageNamed:@"video_detail_arrow_night"];
        }
        _arrowTag = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, icon.size.width, icon.size.height)];
        [_arrowTag setImage:icon];
        _arrowTag.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _arrowTag.enableNightCover = NO;
    }
    return _arrowTag;
}

- (TTFollowThemeButton *)subscribeButton
{
    if (!_subscribeButton) {
        _subscribeButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType102 followedType:TTFollowedType101];
        if (!self.onTop) {
            _subscribeButton.constWidth = [TTDeviceUIUtils tt_newPadding: 72];
            _subscribeButton.constHeight = [TTDeviceUIUtils tt_newPadding: 28];
        }
        _subscribeButton.hidden = NO;
        [_subscribeButton addTarget:self action:@selector(subscribeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subscribeButton;
}

- (SSThemedView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLine;
}

- (NSDictionary *)contentInfo
{
    if ([self.article hasVideoSubjectID]) {
        if (self.article.detailUserInfo) {
            return self.article.detailUserInfo;
        } else {
            return self.article.detailMediaInfo;
        }
    } else {
        if (self.article.userInfo) {
            return self.article.userInfo;
        } else {
            return self.article.mediaInfo;
        }
    }
}

- (void)setContentInfo:(NSDictionary *)contentInfo
{
    if (_contentInfo != contentInfo) {
        _contentInfo = contentInfo;
        if (![self.article isKindOfClass:[Article class]]) {
            return;
        }
        Article *articleSpecify = (Article *)self.article;
        if ([self.article hasVideoSubjectID]) {
            if ([contentInfo ttgc_contentType] == TTGeneratedContentTypeUGC) {
                articleSpecify.detailUserInfo = contentInfo;
            } else {
                articleSpecify.detailMediaInfo = contentInfo;
            }
        } else {
            if ([contentInfo ttgc_contentType] == TTGeneratedContentTypeUGC) {
                articleSpecify.userInfo = contentInfo;
            } else {
                articleSpecify.mediaInfo = contentInfo;
            }
            [articleSpecify save];
        }
    }
}

- (SSThemedLabel *)recommendLabel {
    if (!_recommendLabel) {
        _recommendLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15], self.backgroundView.bottom + [TTDeviceUIUtils tt_newPadding:8], self.width - [TTDeviceUIUtils tt_newPadding:30.f], 0)];
        _recommendLabel.text = @"相关推荐";
        _recommendLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _recommendLabel.textColorThemeKey = kColorText1;
        _recommendLabel.height = [TTLabelTextHelper heightOfText:_recommendLabel.text fontSize:[TTDeviceUIUtils tt_fontSize:12] forWidth:CGFLOAT_MAX];
    }
    return _recommendLabel;
}

- (NSMutableArray *)recommendArray {
    if (!_recommendArray) {
        _recommendArray = [[NSMutableArray alloc] init];
    }
    return _recommendArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:144.f], [TTDeviceUIUtils tt_newPadding:182.f]);
        //flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:2];
        _flowLayout.minimumLineSpacing = [TTDeviceUIUtils tt_newPadding:4];
        //flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:2.f];
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_newPadding:10], 0, [TTDeviceUIUtils tt_newPadding:10]);
        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.recommendLabel.bottom + [TTDeviceUIUtils tt_newPadding:8], self.width, [TTDeviceUIUtils tt_newPadding:182.f]) collectionViewLayout:_flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TTRecommendCollectionViewCell class] forCellWithReuseIdentifier:TTRecommendCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (NSMutableArray *)recommendRangeArray {
    if (!_recommendRangeArray) {
        _recommendRangeArray = [[NSMutableArray alloc] init];
    }
    return _recommendRangeArray;
}

#pragma mark - Helper
+ (CGFloat)nameLabelFontSize
{
    if ([TTDeviceHelper isPadDevice]) {
        return 22.f;
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

- (NSInteger)quickQueryIndex:(CGFloat)value leftIndex:(NSInteger)left rightIndex:(NSInteger)right {
    NSInteger middle;
    NSValue *valueObject;
    NSRange range;
    while (left <= right) {
        middle = left + (right - left) / 2;
        valueObject = self.recommendRangeArray[middle];
        range = [valueObject rangeValue];
        if (value < range.location) {
            right = middle - 1;
        }
        else if (value > range.location + range.length) {
            left = middle + 1;
        }
        else {
            return middle;
        }
    }
    return -1;
}

#pragma mark - 关注互动埋点 (3.0)
- (void)followActionLogV3IsRedPacketSender:(BOOL) isRedPacketSender
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [self followActionLogV3CommonParams:params];
    if (isRedPacketSender){
        [params setValue:@"1" forKey: @"is_redpacket"];
        [params setValue:@(TTFollowNewSourceVideoDetailRedPacket) forKey:@"server_source"];
    }else{
        [params setValue:@"0" forKey: @"is_redpacket"];
    }
    if ([self.contentInfo ttgc_isSubCribed]){
        [TTTrackerWrapper eventV3:@"rt_unfollow" params:params];
    }else{
        [TTTrackerWrapper eventV3:@"rt_follow" params:params];
    }
    
}

- (void)followActionLogV3CommonParams:(NSMutableDictionary *)params
{
    NSString *groupId = [NSString stringWithFormat:@"%lld",[self.article uniqueID]];
    [params setValue:@(TTFollowNewSourceVideoDetail) forKey:@"server_source"];
    [params setValue:_categoryName forKey: @"category_name"];
    [params setValue:_enterFrom forKey:@"enter_from"];
    [params setValue:@"0" forKey: @"not_default_follow_num"];
    [params setValue:self.article.itemID forKey:@"item_id"];
    [params setValue:@"from_group" forKey: @"follow_type"];
    [params setValue:[self UserId] forKey: @"to_user_id"];
    [params setValue:[self MediaId] forKey: @"media_id"];
    [params setValue:@"detail" forKey: @"position"];
    [params setValue:groupId forKey:@"group_id"];
    [params setValue:@"1" forKey: @"follow_num"];
    [params setValue:@"video" forKey:@"source"];
    [params setValue:_logPb forKey:@"log_pb"];

}


- (void)cellFollowActionLogV3:(NSIndexPath *)indexPath IsRedPacketSender:(BOOL)isRedPacketSender
{
    TTRecommendModel *model = self.recommendArray[indexPath.item];
    NSString *order = [NSString stringWithFormat:@"%ld",(long)(indexPath.item+1)];
    NSString *groupId = [NSString stringWithFormat:@"%lld",[self.article uniqueID]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@(TTFollowNewSourceVideoDetailRecommend) forKey:@"server_source"];
    [params setValue:@"from_recommend" forKey: @"follow_type"];
    [params setValue:[self UserId] forKey: @"profile_user_id"];
    [params setValue:_categoryName forKey: @"category_name"];
    [params setValue:@"0" forKey: @"not_default_follow_num"];
    [params setValue:self.article.itemID forKey:@"item_id"];
    [params setValue:model.userID forKey: @"to_user_id"];
    [params setValue:@"detail" forKey: @"position"];
    [params setValue:@"1" forKey: @"follow_num"];
    [params setValue:groupId forKey:@"group_id"];
    [params setValue:@"video" forKey:@"source"];
    [params setValue:_logPb forKey:@"log_pb"];
    [params setValue:_enterFrom forKey:@"enter_from"];
    [params setValue:order forKey:@"order"];
    if (isRedPacketSender){
        [params setValue:@"1" forKey: @"is_redpacket"];
        [params setValue:@(TTFollowNewSourceVideoDetailRedRecommend) forKey:@"server_source"];
    }else{
        [params setValue:@"0" forKey: @"is_redpacket"];
    }
    if (model.isFollowing){
        [TTTrackerWrapper eventV3:@"rt_unfollow" params:params];
    }else{
        [TTTrackerWrapper eventV3:@"rt_follow" params:params];
    }
}

#pragma mark - 红包埋点 (3.0)

- (void)logRedPacketIfNeed{
    BOOL isFollowed = [self.contentInfo ttgc_isSubCribed];
    if (!isFollowed && self.hasRedpacket){
        
        NSString *actionType = @"show";
        NSString *position = @"detail";
        NSString *userId = [self UserId];
        NSString *mediaId = [self MediaId];
        NSString *groupId = [NSString stringWithFormat:@"%lld",[self.article uniqueID]];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:userId forKey:@"user_id"];
        [param setValue:mediaId forKey:@"media_id"];
        [param setValue:groupId forKey:@"group_id"];
        [param setValue:actionType forKey:@"action_type"];
        [param setValue:position forKey:@"position"];
        [param setValue:@"video" forKey:@"source"];
        [param setValue:_categoryName forKey:@"category_name"];
        
        [TTTrackerWrapper eventV3:@"red_button" params:param];
    }
}


- (NSString *)UserId
{
    NSDictionary *userInfo;
    if ([self.article hasVideoSubjectID]) {
        userInfo = self.article.detailUserInfo;
    } else {
        userInfo = self.article.userInfo;
    }
    if (!isNull(userInfo)) {
        return [userInfo tt_stringValueForKey:@"user_id"];
    }
    return nil;
}

- (NSString *)MediaId
{
    NSDictionary *mediaInfo;
    if ([self.article hasVideoSubjectID]) {
        mediaInfo = self.article.detailMediaInfo;
    } else {
        mediaInfo = self.article.mediaInfo;
    }
    if (!isNull(mediaInfo)) {
        return [mediaInfo tt_stringValueForKey:@"media_id"];
    }
    return nil;

}


@end
