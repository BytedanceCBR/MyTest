//
//  TTVFeedCellMoreActionManager.m
//  Article
//
//  Created by panxiang on 2017/4/10.
//
//

#import "TTVFeedCellMoreActionManager.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "TTAdManager.h"
#import "TTAccountManager.h"
#import "TTActivityShareManager.h"
#import "TTActionSheetController.h"
#import "TTReportManager.h"
#import "TTNetworkManager.h"
#import "TTFeedDislikeView.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVFeedCellActionMessage.h"
#import "TTVideoCommon.h"
#import "TTVMoreActionHeader.h"
#import "TTUIResponderHelper.h"
#import "TTVFeedListViewController.h"
#import "UIViewController+TTVHiritageSearch.h"
#import "TTVShareActionsTracker.h"
#import "TTVPlayVideo.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import <TTSettingsManager/TTSettingsManager.h>

//新分享库
#import <TTShareActivity.h>
#import <TTShareManager.h>
#import "TTPanelActivity.h"
#import "TTAdPromotionContentItem.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "TTWebImageManager.h"
#import "TTDiggActivity.h"
#import "TTBuryActivity.h"
#import "TTDislikeActivity.h"
#import "TTCommodityActivity.h"
#import "TTActivityShareSequenceManager.h"
#import "TTVideoArticleService.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import "TTVideoArticleService+Action.h"
#import "TTShareMethodUtil.h"
//#import "TTThreadDeleteContentItem.h"
#import "JSONAdditions.h"
// 设置是否可以通过转手机来转屏
#import "BDPlayerObjManager.h"

//爱看
#import "AKAwardCoinManager.h"

typedef NS_ENUM(NSUInteger, TTVActivityClickSourceFrom) {
    TTVActivityClickSourceFromPlayerMore ,
    TTVActivityClickSourceFromPlayerShare,
    TTVActivityClickSourceFromPlayerDirect,
    TTVActivityClickSourceFromCentreButton,
    TTVActivityClickSourceFromListMore,
    TTVActivityClickSourceFromListShare,
    TTVActivityClickSourceFromDetailVideoOver,
    TTVActivityClickSourceFromListVideoOver,
    TTVActivityClickSourceFromDetailBottomBar,
    TTVActivityClickSourceFromListVideoOverDirect,
    TTVActivityClickSourceFromListDirect
};

static NSString * SECTIONTYPE = @"sectionType";
static NSString * ISFULLSCREEN = @"isFullScreen";

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;
extern NSInteger ttvs_isShareTimelineOptimize(void);
extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTVFeedCellMoreActionManager()<SSActivityViewDelegate, TTShareManagerDelegate>
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@property (nonatomic ,strong)ExploreItemActionManager *itemActionManager;
@property (nonatomic, strong) NSMutableDictionary *shareSectionAndEventDic; //event3的额外字典
@property (nonatomic, strong) TTShareManager * shareManager;

@end

@implementation TTVFeedCellMoreActionModel

+ (TTVFeedCellMoreActionModel *)modelWithArticle:(TTVFeedItem *)item
{
    if ([item isKindOfClass:[TTVFeedItem class]]) {
        TTVFeedCellMoreActionModel *model = [[TTVFeedCellMoreActionModel alloc] init];
        model.userId = @(item.videoUserInfo.userId).stringValue;
        model.groupId = @(item.article.groupId).stringValue;
        model.adID = @(item.adID.longLongValue);
        model.avatarUrl = item.videoUserInfo.avatarURL;
        model.userRepined = @(item.article.userRepin);
        model.buryCount = @(item.article.buryCount);
        model.commentCount = @(item.article.commentCount);
        model.diggCount = @(item.article.diggCount);
        model.userDigg = @(item.article.userDigg);
        model.userBury = @(item.article.userBury);
        model.videoSubjectID = item.article.videoDetailInfo.videoSubjectId;
        model.refer = 1;
        model.isSubscribe = @(item.videoUserInfo.follow);
        model.filterWords = [[item article] filterWordsJsonValue];
        model.logExtra = item.logExtra;
        model.aggrType = item.aggrType;
        model.commoditys = item.commoditys;
        TTShareModel *share = [TTShareModel shareModelWithFeedItem:item];
        model.shareModel = share;
        model.videoSource = item.article.videoSource;
        model.hasVideo = NO;
        model.itemId = [NSString stringWithFormat:@"%lld",item.article.itemId];
        if ([item.article hasVideo] || !isEmptyString([item.article videoId])){
            model.hasVideo = YES;
        }
        return model;
    }
    return nil;
}

@end
typedef void(^TTActivityAction)(NSString *type);
@interface TTVFeedCellMoreActionManager ()<TTActivityShareManagerDelegate>
@property (nonatomic, strong) SSActivityView           *phoneShareView;
@property (nonatomic, copy) TTActivityAction           activityAction;
@property (nonatomic, strong) TTActivityShareManager   *activityActionManager;
@property (nonatomic ,strong)TTVFeedCellMoreActionModel *model;
@property (nonatomic ,strong)NSMutableDictionary *actions;
@end

@implementation TTVFeedCellMoreActionManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.getPresentingViewControllerOfShare = ^UIViewController *(UIResponder *responder) {
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:2];
            if ([TTVFeedListViewController class]) {
                [mutableArray addObject:[TTVFeedListViewController class]];
                [mutableArray addObject:NSClassFromString(@"TTVVideoDetailHeaderPosterViewController")];
                
            }
            return [UIViewController ttv_topViewControllerFor:responder exceptClasses:[mutableArray copy]];
        };
    }
    return self;
}

//不感兴趣
- (void)addDislike:(NSMutableArray *)group2
{
    TTActivity *dislikeActivity = [TTActivity activityOfDislike];
    [group2 addObject:dislikeActivity];

    TTVDislikeActionEntity *entity = [[TTVDislikeActionEntity alloc] init];
    entity.filterWords = self.model.filterWords;
    entity.dislikePopFromView = self.dislikePopFromView;
    entity.groupId = self.model.groupId;
    entity.adID = self.model.adID;
    entity.logExtra = self.model.logExtra;
    entity.cellEntity = self.cellEntity;

    TTVDislikeAction *action = [[TTVDislikeAction alloc] initWithEntity:entity];
    action.didClickDislikeSubmitButtonBlock = self.didClickDislikeSubmitButtonBlock;
    @weakify(self);
    action.didTrakDislikeSubmiteActionBlock = ^(NSArray *filterWords) {
        @strongify(self);
        [self.shareSectionAndEventDic setValue:filterWords forKey:@"filter_words"];
        [self shareTrackEventV3WithActivityType:TTActivityTypeDislike];
    };
    [self addAction:action];
}

//顶踩
- (void)addDiggBury:(NSMutableArray *)group2
{
    {
        TTActivity *digUpActivity = [TTActivity activityOfDigUpWithCount:[NSString stringWithFormat:@"%@",self.model.diggCount]];
        digUpActivity.selected = [self.model.userDigg boolValue];
        [group2 addObject:digUpActivity];
        
        TTVDiggActionEntity *diggEntity = [[TTVDiggActionEntity alloc] init];
        diggEntity.groupId = self.model.groupId;
        diggEntity.cellEntity = self.cellEntity;
        diggEntity.groupId = self.model.groupId;
        diggEntity.itemId = self.model.itemId;
        diggEntity.categoryId = self.categoryId;
        diggEntity.userDigg = self.model.userDigg;
        diggEntity.userBury = self.model.userBury;
        diggEntity.diggCount = self.model.diggCount;
        diggEntity.buryCount = self.model.buryCount;
        diggEntity.aggrType = self.model.aggrType;
        
        TTVDiggAction *diggAction = [[TTVDiggAction alloc] initWithEntity:diggEntity];
        @weakify(self);
        diggAction.diggActionDone = ^(BOOL digg) {
            @strongify(self);
            self.model.userDigg = @(digg);
        };
        [self addAction:diggAction];

        TTActivity *digDownActivity = [TTActivity activityOfDigDownWithCount:[NSString stringWithFormat:@"%@",self.model.buryCount]];
        digDownActivity.selected = [self.model.userBury boolValue];
        [group2 addObject:digDownActivity];
        
        TTVDiggActionEntity *buryEntity = [[TTVDiggActionEntity alloc] init];
        buryEntity.groupId = self.model.groupId;
        buryEntity.cellEntity = self.cellEntity;
        buryEntity.groupId = self.model.groupId;
        buryEntity.itemId = self.model.itemId;
        buryEntity.categoryId = self.categoryId;
        buryEntity.userDigg = self.model.userDigg;
        buryEntity.userBury = self.model.userBury;
        buryEntity.diggCount = self.model.diggCount;
        buryEntity.buryCount = self.model.buryCount;
        buryEntity.aggrType = self.model.aggrType;
        
        TTVBuryAction *buryAction = [[TTVBuryAction alloc] initWithEntity:buryEntity];
        buryAction.buryActionDone = ^(BOOL bury) {
            @strongify(self);
            self.model.userBury = @(bury);
        };
        [self addAction:buryAction];
        
        diggAction.buryAction = buryAction;
        buryAction.diggAction = diggAction;
    }
}

//app分享
- (void)addShare
{
    TTVShareActionEntity *entity = [[TTVShareActionEntity alloc] init];
    entity.groupId = self.model.groupId;
    entity.adID = self.model.adID;
    entity.cellEntity = self.cellEntity;
    entity.itemId = self.model.itemId;
    entity.videoSubjectID = self.model.videoSubjectID;
    entity.adID = self.model.adID;
    entity.responder = self.responder;
    entity.groupFlags = self.model.groupFlags;

    TTVShareAction *action = [[TTVShareAction alloc] initWithEntity:entity];
    action.activityActionManager = self.activityActionManager;
    action.getPresentingViewControllerOfShare = self.getPresentingViewControllerOfShare;
    [self addAction:action];
}

//举报
- (void)addReport
{
    TTVReportActionEntity *entity = [[TTVReportActionEntity alloc] init];
    entity.groupId = self.model.groupId;
    entity.cellEntity = self.cellEntity;
    entity.itemId = self.model.itemId;
    entity.categoryId = self.categoryId;
    entity.videoSource = self.model.videoSource;
    entity.adID = self.model.adID;

    TTVReportAction *action = [[TTVReportAction alloc] initWithEntity:entity];
    @weakify(self);
    action.didTrackReportSubmiteActionBlock = ^(NSDictionary *reportReason){
        @strongify(self);
        id reason = [reportReason objectForKey:@"report"];
        [self.shareSectionAndEventDic setValue:reason forKey:@"reason"];
        [self shareTrackEventV3WithActivityType:TTActivityTypeReport];
    };
    [self addAction:action];
}

//pgc
- (void)addPGC
{
    TTVPGCActionEntity *entity = [[TTVPGCActionEntity alloc] init];
    entity.groupId = self.model.groupId;
    entity.cellEntity = self.cellEntity;
    entity.groupId = self.model.groupId;
    entity.itemId = self.model.itemId;
    entity.categoryId = self.categoryId;
    entity.aggrType = self.model.aggrType;
    entity.refer = self.model.refer;
    entity.isSubscribe = self.model.isSubscribe;

    TTVPGCAction *action = [[TTVPGCAction alloc] initWithEntity:entity];
    [self addAction:action];
}

//删除
- (void)addDelete
{
    TTVDeleteActionEntity *entity = [[TTVDeleteActionEntity alloc] init];
    entity.groupId = self.model.groupId;
    entity.cellEntity = self.cellEntity;
    entity.itemId = isEmptyString(self.model.itemId) ? self.model.groupId : self.model.itemId;
    entity.userId = self.model.userId;
    TTVDeleteAction *action = [[TTVDeleteAction alloc] initWithEntity:entity];
    [self addAction:action];
}

//收藏
- (void)addFavorite:(NSMutableArray *)group2
{
    TTActivity * favorite = [TTActivity activityOfVideoFavorite];
    favorite.selected = [self.model.userRepined boolValue];
    [group2 addObject:favorite];

    TTVFavoriteActionEntity *entity = [[TTVFavoriteActionEntity alloc] init];
    entity.groupId = self.model.groupId;
    entity.cellEntity = self.cellEntity;
    entity.itemId = self.model.itemId;
    entity.adId = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;
    entity.aggrType = self.model.aggrType;
    entity.userRepined = self.model.userRepined.boolValue;
    entity.categoryId = self.categoryId;
    TTVFavoriteAction *action = [[TTVFavoriteAction alloc] initWithEntity:entity];
    @weakify(self);
    action.favoriteActionDone = ^(BOOL favorite) {
        @strongify(self);
        self.model.userRepined = @(favorite);
        if (favorite) {
            NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
            UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
            [self showIndicatorViewWithTip:tipMsg andImage:image dismissHandler:nil];
        }else{
            NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
            UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
            [self showIndicatorViewWithTip:tipMsg andImage:image dismissHandler:nil];
        }
    };
    [self addAction:action];
}

//特卖
- (void)addCommodity:(NSMutableArray *)group2
{
    TTActivity * favorite = [TTActivity activityOfVideoCommodity];
    [group2 addObject:favorite];
    
    TTVFavoriteActionEntity *entity = [[TTVFavoriteActionEntity alloc] init];
    entity.groupId = self.model.groupId;
    entity.cellEntity = self.cellEntity;
    entity.itemId = self.model.itemId;
    entity.adId = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;
    entity.aggrType = self.model.aggrType;
    entity.userRepined = self.model.userRepined.boolValue;
    entity.categoryId = self.categoryId;
    TTVCommodityAction *action = [[TTVCommodityAction alloc] initWithEntity:entity];
    [self addAction:action];
    [self commodityLogV3WithEventName:@"commodity_recommend_show"];
}

- (BOOL)showCommodity
{
    return self.model.commoditys.count > 0 && ![TTDeviceHelper isPadDevice] && isEmptyString(self.cellEntity.article.adId);
}

#pragma marl - 旧分享库添加activityItems

- (SSActivityView *)createPhoneShareViewShowAd:(BOOL)showAd
{
    SSActivityView *phoneShareView = [[SSActivityView alloc] init];
    phoneShareView.delegate = self;
    if (!isEmptyString(self.model.groupId)) {
        if (showAd) {
            [TTAdManageInstance share_showInAdPage:self.model.adID.stringValue groupId:self.model.groupId];
        }
        else{
            [TTAdManageInstance share_showInAdPage:@"1" groupId:self.model.groupId];
        }
    }
    return phoneShareView;
}

- (void)makeShareOrderWithGroup2:(NSMutableArray *)group2 group1:(NSMutableArray *)group1 sourceClick:(TTVActivityClickSourceFrom)clickSource
{
    self.activityActionManager = [[TTActivityShareManager alloc] init];
    self.activityActionManager.delegate = self;
    self.activityActionManager.isVideoSubject = YES;
    [self addClickSourceFromClickSource:clickSource];
    BOOL showReport = (clickSource == TTVActivityClickSourceFromListMore || clickSource == TTVActivityClickSourceFromPlayerMore);
    NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareModel:self.model.shareModel showReport:showReport];
    
    [self addShare];
    if (clickSource == TTVActivityClickSourceFromListMore || clickSource == TTVActivityClickSourceFromPlayerMore) {
        if ([self showCommodity]) {
            [self addCommodity:group2];
        }
        if (!(self.cellEntity.adCell.hasApp)) {
            [self addFavorite:group2];
        }
        if (clickSource == TTVActivityClickSourceFromListMore) {
            [self addDislike:group2];
        }
        [self addReport];
        if (isEmptyString(self.cellEntity.article.adId)) {
            [self addDiggBury:group2];
            [self addPGC];
            [self addDelete];
            [self changeUPGToDelete:activityItems];
        }
        
    }
    
    BOOL showAd = NO;
    if (clickSource == TTVActivityClickSourceFromListShare || clickSource == TTVActivityClickSourceFromListMore || clickSource == TTVActivityClickSourceFromListVideoOver) {
        showAd = YES;
    }
    [self insertReportToLastWithActivityItems:activityItems group2:group2 group1:group1];
    self.phoneShareView = [self createPhoneShareViewShowAd:showAd];
}

//当视频是ugc视频时将举报按钮替换成删除按钮
- (void)changeUPGToDelete:(NSMutableArray *)activityItems
{
    NSString *uid = self.model.userId;
    if (!isEmptyString(uid) && !isEmptyString([TTAccountManager userID]) && [uid isEqualToString:[TTAccountManager userID]]) { //ugc视频
        [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.activityType == TTActivityTypeReport) {
                [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                *stop = YES;
            }
        }];
    }
}

//分开放，举报放最后边
- (void)insertReportToLastWithActivityItems:(NSArray *)activityItems group2:(NSMutableArray *)group2 group1:(NSMutableArray *)group1
{
    if (isEmptyString(self.cellEntity.article.adId)) {
        for (TTActivity *activity in activityItems) {
            if (activity.activityType == TTActivityTypeReport || activity.activityType == TTActivityTypeDetele) {
                [group2 addObject:activity];
            }
            else {
                [group1 addObject:activity];
            }
        }
    }else{
        for (TTActivity *activity in activityItems) {
            if (activity.activityType == TTActivityTypeReport || activity.activityType == TTActivityTypeCopy) {
                [group2 addObject:activity];
            }
            else if(activity.activityType < TTActivityTypeSystem){
                [group1 addObject:activity];
            }
        }
    }
}

- (void)addAction:(TTVMoreAction *)action
{
    if (!_actions) {
        _actions = [NSMutableDictionary dictionary];
    }
    if (action.type != TTActivityTypeNone) {
        [self.actions setValue:action forKey:@(action.type).stringValue];
    }
}

//分享面板收起动画
- (void)dismissWithAnimation:(BOOL)animated
{
    [self.phoneShareView dismissWithAnimation:animated];
    self.phoneShareView = nil;
}

- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

#pragma mark - button actions 

//cell上外露的更多按钮
- (void)moreButtonClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction
{
    self.model = model;
    self.activityAction = activityAction;
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_moreActionFiredWithClickSource:TTVActivityClickSourceFromListMore];
        [self addClickSourceFromClickSource:TTVActivityClickSourceFromListMore];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }else{
        NSMutableArray *group1 = [NSMutableArray array];
        NSMutableArray *group2 = [NSMutableArray array];
        [self makeShareOrderWithGroup2:group2 group1:group1 sourceClick:TTVActivityClickSourceFromListMore];
        [self.phoneShareView showActivityItems:@[group1, group2] isFullSCreen:NO];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

//全屏右上角更多按钮
- (void)moreActionOnMovieTopViewWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void (^)(NSString *type))activityAction
{
    self.model = model;
    self.activityAction = activityAction;
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_moreActionFiredWithClickSource:TTVActivityClickSourceFromPlayerMore];
        [self addClickSourceFromClickSource:TTVActivityClickSourceFromPlayerMore];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }else{
        NSMutableArray *group1 = [NSMutableArray array];
        NSMutableArray *group2 = [NSMutableArray array];
        [self makeShareOrderWithGroup2:group2 group1:group1 sourceClick:TTVActivityClickSourceFromPlayerMore];
        [self.phoneShareView showActivityItems:@[group1, group2] isFullSCreen:YES];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

//全屏右上角分享按钮
- (void)shareActionOnMovieTopViewWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void (^)(NSString *type))activityAction
{
    self.model = model;
    self.activityAction = activityAction;
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFiredWithClickSource:TTVActivityClickSourceFromPlayerShare];
        [self addClickSourceFromClickSource:TTVActivityClickSourceFromPlayerShare];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }else{
        NSMutableArray *group1 = [NSMutableArray array];
        NSMutableArray *group2 = [NSMutableArray array];
        [self makeShareOrderWithGroup2:group2 group1:group1 sourceClick:TTVActivityClickSourceFromPlayerShare];
        NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareModel:self.model.shareModel showReport:NO];
        self.phoneShareView.activityItems = activityItems;
        [self.phoneShareView showOnViewController:nil useShareGroupOnly:NO isFullScreen: YES];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }
    [self setIsCanFullScreenFromOrientationMonitor:NO];
    
}

//点击底部露出的分享按钮
- (void)shareButtonClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction
{
    self.model = model;
    self.activityAction = activityAction;
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFiredWithClickSource:TTVActivityClickSourceFromListShare];
        [self addClickSourceFromClickSource:TTVActivityClickSourceFromListShare];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }else{
        NSMutableArray *group1 = [NSMutableArray array];
        NSMutableArray *group2 = [NSMutableArray array];
        [self makeShareOrderWithGroup2:group2 group1:group1 sourceClick:TTVActivityClickSourceFromListShare];
        NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareModel:self.model.shareModel showReport:NO];
        self.phoneShareView.activityItems = activityItems;
        [self.phoneShareView showOnViewController:nil useShareGroupOnly:NO isFullScreen: NO];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

//视频播放结束后,点击视频上面的分享按钮
- (void)shareButtonOnMovieClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction
{
    self.model = model;
    self.activityAction = activityAction;
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFiredWithClickSource:TTVActivityClickSourceFromListVideoOver];
        [self addClickSourceFromClickSource:TTVActivityClickSourceFromListVideoOver];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }else{
        NSMutableArray *group1 = [NSMutableArray array];
        NSMutableArray *group2 = [NSMutableArray array];
        [self makeShareOrderWithGroup2:group2 group1:group1 sourceClick:TTVActivityClickSourceFromListVideoOver];
        NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareModel:self.model.shareModel showReport:NO];
        self.phoneShareView.activityItems = activityItems;
        [self.phoneShareView showOnViewController:nil useShareGroupOnly:NO isFullScreen: NO];
        [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    }
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

- (void)shareButtonOnShareViewClickedWithModel:(TTVFeedCellMoreActionModel *)model activityAction:(void(^)(NSString *type))activityAction
{
    self.model = model;
    self.activityAction = activityAction;
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFiredWithClickSource:TTVActivityClickSourceFromListShare];
        [self addClickSourceFromClickSource:TTVActivityClickSourceFromListShare];
    }else{
        NSMutableArray *group1 = [NSMutableArray array];
        NSMutableArray *group2 = [NSMutableArray array];
        [self makeShareOrderWithGroup2:group2 group1:group1 sourceClick:TTVActivityClickSourceFromListShare];
        NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareModel:self.model.shareModel showReport:NO];
        self.phoneShareView.activityItems = activityItems;
        [self.phoneShareView showOnViewController:nil useShareGroupOnly:NO isFullScreen: NO];
    }
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

//视频播放结束后，分享渠道外露动作
- (void)directShareOnMovieFinishViewWithModel:(TTVFeedCellMoreActionModel *)model activityType:(NSString *)itemType activityAction:(void (^)(NSString *))activityType
{
    self.model = model;
    self.activityActionManager = [[TTActivityShareManager alloc] init];
    if (ttvs_isShareIndividuatioEnable()) {
        [self ttv_directshareWithActivityType:itemType];
        TTActivityType activityType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:itemType];
        [self addClickSourceFromClickSource: TTVActivityClickSourceFromListVideoOverDirect];
        [self directShareTrackEventV3WithActivityType:activityType];
    }else{
        TTActivityType activityType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:itemType];
        self.activityActionManager.delegate = self;
        self.activityActionManager.isVideoSubject = YES;
        [self addClickSourceFromClickSource: TTVActivityClickSourceFromListVideoOverDirect];
        [ArticleShareManager shareActivityManager:self.activityActionManager shareModel:self.model.shareModel showReport:NO];
        [self addShare];
        TTVMoreAction *action = [self.actions valueForKey:@(TTShareKey).stringValue];//201表示所有的分享
        if ([action isKindOfClass:[TTVMoreAction class]]) {
            [action execute:activityType];
            //埋点3.0
            [self directShareTrackEventV3WithActivityType:activityType];
        }
    }
}
//视频全屏播放，分享渠道外露动作
- (void)directShareOnMovieViewWithModel:(TTVFeedCellMoreActionModel *)model activityType:(NSString *)itemType activityAction:(void (^)(NSString *))activityType
{
    TTActivityType enumActivityType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:itemType];
    [self addClickSourceFromClickSource: TTVActivityClickSourceFromPlayerDirect];
    [self directShareTrackEventV3WithActivityType:enumActivityType];
    self.model = model;
    self.activityActionManager = [[TTActivityShareManager alloc] init];
    [self ttv_directshareWithActivityType:itemType];
}

- (void)directShareOnBottomViewWithModel:(TTVFeedCellMoreActionModel *)model activityType:(NSString *)itemType activityAction:(void (^)(NSString *))activityType
{
    TTActivityType enumActivityType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:itemType];
    [self addClickSourceFromClickSource: TTVActivityClickSourceFromListDirect];
    [self directShareTrackEventV3WithActivityType:enumActivityType];
    self.model = model;
    self.activityActionManager = [[TTActivityShareManager alloc] init];
    [self ttv_directshareWithActivityType:itemType];
}

#pragma mark - shareManagerDelegate
- (void)activityView:(SSActivityView *)view button:(UIButton *)button didCompleteByItemType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeFavorite) {
        
        NSString *activityType = [TTActivityShareSequenceManager activityStringTypeFromActivityType:itemType];
        button.selected = !button.selected;
        if (self.activityAction) {
            self.activityAction(activityType);
        }
        TTVMoreAction *action = [self.actions valueForKey:@(itemType).stringValue];
        [self shareTrackEventV3WithActivityType:itemType favouriteButton:button];
        if ([action isKindOfClass:[TTVMoreAction class]]) {
            [action execute:itemType];
            //埋点3.0
        }
    }
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    [self setIsCanFullScreenFromOrientationMonitor:YES];
    if ([AKAwardCoinManager isShareTypeWithActivityType:itemType]) {
        [AKAwardCoinManager requestShareBounsWithGroup:self.model.groupId fromPush:NO completion:nil];
    }
    if (view == _phoneShareView) {
        if (itemType == TTActivityTypeWeitoutiao || itemType == TTActivityTypeDislike || itemType ==TTActivityTypeReport || itemType == TTActivityTypeEMail || itemType == TTActivityTypeSystem ||itemType == TTActivityTypeMessage) {
            if (self.playVideo) {
                if (self.playVideo.player.context.isFullScreen) {
                    if (itemType == TTActivityTypeReport){
                        [self.playVideo exitFullScreen:YES completion:^(BOOL finished) {
                            dispatch_after(0, dispatch_get_main_queue(), ^(void){
                    
                                TTVMoreAction *action = [self.actions valueForKey:@(itemType).stringValue];
                                if ([action isKindOfClass:[TTVMoreAction class]]) {
                                    [action execute:itemType];
                                    [self shareTrackEventV3WithActivityType:itemType];
                                }
                            });
                        }];
                        return;
                    }else{
                        [self.playVideo exitFullScreen:YES completion:nil];
                    }
                }
            }
        }
        
        NSString *activityType = [TTVideoCommon newshareItemContentTypeFromActivityType:itemType];
        BOOL processed = NO;
        if (self.didClickActivityItemAndQueryProcess) {
            processed = self.didClickActivityItemAndQueryProcess(activityType);
            if (processed) {
                [self shareTrackEventV3WithActivityType:itemType];
            }
        }
        if (!processed) {
            TTVMoreAction *action = [self.actions valueForKey:@(itemType).stringValue];
            if ([action isKindOfClass:[TTVMoreAction class]]) {
                [action execute:itemType];
                //埋点3.0
                if (itemType == TTActivityTypeDigUp || itemType == TTActivityTypeDigDown) {
                    [self shareDiggBuryActionLogWithActictyType:itemType];
                }else{
                    [self shareTrackEventV3WithActivityType:itemType];
                }
            }
            else{
                action = [self.actions valueForKey:@(TTShareKey).stringValue];//201表示所有的分享
                if ([action isKindOfClass:[TTVMoreAction class]]) {
                    [action execute:itemType];
                    //埋点3.0
                    [self shareTrackEventV3WithActivityType:itemType];
                }
            }
        }
        if (self.activityAction) {
            if ([activityType isEqualToString:TTActivityContentItemTypeCommodity]){
                [self commodityLogV3WithEventName:@"commodity_recommend_click"];
            }
            self.activityAction(activityType);
        }
    }
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(nonnull TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(nullable NSError *)error
{
    if (!error && self.shareToRepostBlock) {
        self.shareToRepostBlock(activityType);
    }
}

#pragma mark - 分享action 回调

//更新model 顶踩数据
- (void)shareDiggBuryActionLogWithActictyType:(TTActivityType )itemType
{
    if (_model.userBury.boolValue && itemType == TTActivityTypeDigUp) {
        NSString * tipMsg = NSLocalizedString(@"您已经踩过", nil);
        [self showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
    }else if (_model.userDigg.boolValue && itemType == TTActivityTypeDigDown){
        NSString * tipMsg = NSLocalizedString(@"您已经顶过", nil);
        [self showIndicatorViewWithTip:tipMsg andImage:nil dismissHandler:nil];
    }else{
        [self shareTrackEventV3WithActivityType:itemType];
        
    }
}

//弹窗
- (void)showIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler{
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:self.phoneShareView.panelController.backWindow.rootViewController.view];
}

#pragma mark - old share pod log related
// add activityManager clickSource
- (void)addClickSourceFromClickSource:(TTVActivityClickSourceFrom )clickSource
{
    NSNumber *isFullScreen = @(0);
    NSString *fromSource = nil;
    TTActivitySectionType sectionType;
    if (clickSource == TTVActivityClickSourceFromPlayerMore) {
        fromSource = @"player_more";
        sectionType = TTActivitySectionTypePlayerMore;
        isFullScreen = @(1);
    }else  if (clickSource == TTVActivityClickSourceFromPlayerShare) {
        fromSource = @"player_share";
        sectionType = TTActivitySectionTypePlayerShare;
        isFullScreen = @(1);
    }else  if (clickSource == TTVActivityClickSourceFromListMore) {
        fromSource = @"list_more";
        sectionType = TTActivitySectionTypeListMore;
    }else  if (clickSource == TTVActivityClickSourceFromListShare) {
        fromSource = @"list_share";
        sectionType = TTActivitySectionTypeListShare;
    }else  if (clickSource == TTVActivityClickSourceFromListVideoOver) {
        fromSource = @"list_video_over";
        sectionType = TTActivitySectionTypeListVideoOver;
    }else if (clickSource == TTVActivityClickSourceFromListVideoOverDirect) {
        fromSource = @"list_video_over_direct";
        sectionType = TTActivitySectionTypeListVideoOver;
    }else if (clickSource == TTVActivityClickSourceFromListDirect) {
        fromSource = @"list_direct";
        sectionType = TTActivitySectionTypeListDirect;
    }else if (clickSource == TTVActivityClickSourceFromPlayerDirect) {
        fromSource = @"player_direct";
        sectionType = TTActivitySectionTypePlayerDirect;
        isFullScreen = @(1);
    }else {
        fromSource = nil;
        sectionType = 1000;
    }
    self.activityActionManager.clickSource = fromSource;
    [self.shareSectionAndEventDic setValue:@(sectionType) forKey:SECTIONTYPE ];
    [self.shareSectionAndEventDic setValue:isFullScreen forKey:ISFULLSCREEN];
    [self.shareSectionAndEventDic setValue:fromSource forKey:@"fromSource"];
}

- (void)shareTrackEventV3WithActivityType:(TTActivityType )itemType{
    [self shareTrackEventV3WithActivityType:itemType favouriteButton:nil];
}

- (void)shareTrackEventV3WithActivityType:(TTActivityType )itemType favouriteButton:(UIButton *)button{
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    if (itemType == TTActivityTypeFavorite)
    {
        BOOL userRepined = [self.model.userRepined boolValue];
        [extra setValue: !userRepined ? @"rt_favorite" : @"rt_unfavorite" forKey:@"favorite_name"];
    }
    
    NSString *fromSource = _activityActionManager.clickSource;
    [extra setValue:fromSource forKey:@"fromSource"];
    [extra setValue:_model.userDigg forKey:@"userDigg"];
    [extra setValue:_model.userBury forKey:@"userBury"];
    [extra addEntriesFromDictionary:_shareSectionAndEventDic];
    BOOL isFullScreen = NO;
    if ([[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] isKindOfClass:[NSNumber class]]) {
        isFullScreen = [(NSNumber *)[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] boolValue];
    }
    SAFECALL_MESSAGE(TTVShareActionTrackMessage, @selector(message_shareTrackWithGroupID:ActivityType:extraDic:fullScreen:),message_shareTrackWithGroupID:self.cellEntity.uniqueIDStr ActivityType:itemType extraDic:extra fullScreen:isFullScreen);
    [_shareSectionAndEventDic removeAllObjects];
    [_shareSectionAndEventDic setValue:[extra valueForKey:SECTIONTYPE] forKey:SECTIONTYPE];
    [_shareSectionAndEventDic setValue:[extra valueForKey:ISFULLSCREEN] forKey:ISFULLSCREEN];
    [_shareSectionAndEventDic setValue:[extra valueForKey:@"fromSource"] forKey:@"fromSource"];
}

- (void)shareTrackAdEventWithTag:(NSString *)tag label:(NSString *)label
{
    if (_model.adID.longLongValue > 0) {
        SAFECALL_MESSAGE(TTVShareActionTrackMessage, @selector(message_shareTrackAdEventWithAdId:logExtra:tag:label:extra:), message_shareTrackAdEventWithAdId:_model.adID.stringValue logExtra:_model.logExtra tag:tag label:label extra:nil);
    }
}


- (void)shareTrackAdEventConfirmWithTag:(NSString *)tag label:(NSString *)label filterWords:(NSArray *)filterWords
{
    if (_model.adID.longLongValue > 0) {
        NSMutableDictionary *dict = [@{} mutableCopy];
        [dict setValue:filterWords forKey:@"filter_words"];
        SAFECALL_MESSAGE(TTVShareActionTrackMessage, @selector(message_shareTrackAdEventWithAdId:logExtra:tag:label:extra:), message_shareTrackAdEventWithAdId:_model.adID.stringValue logExtra:_model.logExtra tag:tag label:label extra:@{@"ad_extra_data":[dict tt_JSONRepresentation]});
    }
}

//分享渠道外露埋点
- (void)directShareTrackEventV3WithActivityType:(TTActivityType )itemType
{
    NSString *fromSource = _activityActionManager.clickSource;
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:fromSource forKey:@"fromSource"];
    [extra addEntriesFromDictionary:_shareSectionAndEventDic];
    BOOL isFullScreen = NO;
    if ([[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] isKindOfClass:[NSNumber class]]) {
        isFullScreen = [(NSNumber *)[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] boolValue];
    }
    SAFECALL_MESSAGE(TTVShareActionTrackMessage, @selector(message_exposedShareTrackWithGroupID:ActivityType:extraDic:fullScreen:),message_exposedShareTrackWithGroupID:self.cellEntity.uniqueIDStr ActivityType:itemType extraDic:extra fullScreen:isFullScreen);
    [_shareSectionAndEventDic removeAllObjects];
    [_shareSectionAndEventDic setValue:[extra valueForKey:SECTIONTYPE] forKey:SECTIONTYPE];
    [_shareSectionAndEventDic setValue:[extra valueForKey:ISFULLSCREEN] forKey:ISFULLSCREEN];
    [_shareSectionAndEventDic setValue:[extra valueForKey:@"fromSource"] forKey:@"fromSource"];    
}

- (NSMutableDictionary *)shareSectionAndEventDic{
    if (!_shareSectionAndEventDic) {
        _shareSectionAndEventDic = [NSMutableDictionary dictionary];
    }
    return _shareSectionAndEventDic;
}

- (void)commodityLogV3WithEventName:(NSString *)eventName
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"point_panel" forKey:@"section"];
    [dic setValue:self.model.groupId forKey:@"group_id"];
    [dic setValue:self.model.itemId forKey:@"item_id"];
    [dic setValue:@"TEMAI" forKey:@"EVENT_ORIGIN_FEATURE"];
    BOOL isfullscreen = [TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen;
    [dic setValue:isfullscreen ? @"fullscreen" : @"nofullscreen"  forKey:@"fullscreen"];
    [dic setValue:@"list" forKey:@"position"];
    NSMutableDictionary *commodity_attr = [NSMutableDictionary dictionary];
    [commodity_attr setValue:@(self.model.commoditys.count) forKey:@"commodity_num"];
    [dic setValue:commodity_attr forKey:@"commodity_attr"];
    [TTTrackerWrapper eventV3:eventName params:dic];
}

#pragma mark
#pragma mark - new share pod
- (void)new_shareActionFiredWithClickSource:(TTVActivityClickSourceFrom )clickSource
{
    if (self.model.adID.longLongValue > 0){
        [[TTAdShareManager sharedManager] showInAdPage:self.model.adID.stringValue groupId:self.model.groupId];
    }
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self shareActionUpItemsWithClickSource:clickSource]];
//    [contentItems addObject:[self shareActionDownItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
}

- (void)new_moreActionFiredWithClickSource:(TTVActivityClickSourceFrom )clickSource
{
    if (self.model.adID.longLongValue > 0){
        [[TTAdShareManager sharedManager] showInAdPage:self.model.adID.stringValue groupId:self.model.groupId];
    }
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self moreActionUpItemsWithClickSource:clickSource]];
    [contentItems addObject:[self moreActionDownItemsWithClickSource:clickSource]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
}

//direct share actions
- (void)ttv_directshareWithActivityType:(NSString *)activityTypeString
{
    id<TTActivityContentItemProtocol> activityItem;
    if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        TTWechatTimelineContentItem *wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareTitle] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
        activityItem = wcTlItem;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechat]){
        TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
        activityItem = wcItem;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQFriend]){
        TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityItem = qqItem;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQZone]){
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityItem = qqZoneItem;
    }
//    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeDingTalk]){
//        TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
//        activityItem = ddItem;
//    }
    if (activityItem) {
        [self.shareManager shareToActivity:activityItem presentingViewController:nil];
    }
}


#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
//    if ([[activity contentItemType] isEqualToString:TTActivityContentItemTypeSystem] ||
//        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeSMS] ||
//        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeEmail] ||
      if ([[activity contentItemType] isEqualToString:TTActivityContentItemTypeForwardWeitoutiao] ||
        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeReport] ||
        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeDislike])
    {
        if (self.playVideo.player.context.isFullScreen)
        {
            [self.playVideo.player exitFullScreen:YES completion:^(BOOL finished) {
                [UIViewController attemptRotationToDeviceOrientation];
            }];
        }
    }
    if (activity) {
        TTActivityType itemType = [TTVideoCommon activityTypeFromNewshareItemContentTypeFrom:[activity contentItemType]];
        if (itemType != TTActivityTypeDigUp && itemType != TTActivityTypeDigDown){
            [self shareTrackEventV3WithActivityType:itemType];
        }
    }else{
        [self shareTrackEventV3WithActivityType:TTActivityTypeNone];
        [self setIsCanFullScreenFromOrientationMonitor:YES];
    }

}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    [self setIsCanFullScreenFromOrientationMonitor:YES];
    TTActivityType activityType = [TTVideoCommon activityTypeFromNewshareItemContentTypeFrom:[activity contentItemType]];
    if ([AKAwardCoinManager isShareTypeWithActivityType:activityType]) {
        [AKAwardCoinManager requestShareBounsWithGroup:self.model.groupId fromPush:NO completion:nil];
    }
    NSString *eventName = nil;
    if(error) {
        TTVActivityShareErrorCode errorCode = [TTActivityShareSequenceManager shareErrorCodeFromItemErrorCode:error WithActivity:activity];
        switch (errorCode) {
            case TTVActivityShareErrorFailed:
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
                break;
            case TTVActivityShareErrorUnavaliable:
            case TTVActivityShareErrorNotInstalled:
            default:
                break;
        }
        eventName = @"share_fail";
    }else{
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
        eventName = @"share_done";
    }
    if (activityType != TTActivityTypeDigDown && activityType != TTActivityTypeDigUp && activityType != TTActivityTypeFavorite && activityType != TTActivityTypeDislike && activityType != TTActivityTypeReport) {
        SAFECALL_MESSAGE(TTVShareActionTrackMessage, @selector(message_shareTrackActivityWithGroupID:ActivityType:FromSource:eventName:),message_shareTrackActivityWithGroupID:self.model.groupId ActivityType:activityType FromSource: self.shareSectionAndEventDic[@"fromSource"] eventName:eventName);
    }
}

#pragma mark - share/more contentItems
- (NSArray<id<TTActivityContentItemProtocol>> *)shareActionUpItemsWithClickSource:(TTVActivityClickSourceFrom )clickSource
{
    NSMutableArray<id<TTActivityContentItemProtocol>> *shareUpItems = @[].mutableCopy;
    [shareUpItems addObjectsFromArray:[self outShareItemsWithClickSource:clickSource]];
    
    return [shareUpItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)shareActionDownItems
{
    NSMutableArray<id<TTActivityContentItemProtocol>> *shareDownItems = @[].mutableCopy;
    [shareDownItems addObjectsFromArray:[self shareItems]];
    return [shareDownItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)moreActionUpItemsWithClickSource:(TTVActivityClickSourceFrom )clickSource
{
    NSMutableArray<id<TTActivityContentItemProtocol>> *moreUpItems = @[].mutableCopy;
    [moreUpItems addObjectsFromArray:[self outShareItemsWithClickSource:clickSource]];
    if (self.model.adID.longLongValue > 0) {
    }else{
        [moreUpItems addObjectsFromArray:[self shareItems]];
    }
    return [moreUpItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)moreActionDownItemsWithClickSource:(TTVActivityClickSourceFrom )clickSource
{
    NSMutableArray<id<TTActivityContentItemProtocol>> *moreDownItems = @[].mutableCopy;
    if (self.model.adID.longLongValue > 0) {
        if (!(self.cellEntity.adCell.hasApp)) {
//            [moreDownItems addObject:[self favourateContentItem]];
        }
//        [moreDownItems addObject:[self dislikeContentItem]];
        TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:[self shareUrl]];
        [moreDownItems addObject:copyItem];
    }else{
        if ([self showCommodity]){
            [moreDownItems addObject:[self commodityContentItem]];
        }
        [moreDownItems addObject:[self favourateContentItem]];
//        if (clickSource == TTVActivityClickSourceFromListMore) {
//            [moreDownItems addObject:[self dislikeContentItem]];
//        }
        [moreDownItems addObject:[self diggContentItem]];
        [moreDownItems addObject:[self buryContentItem]];
    }
    [self addReportOrDeleteContentItem:moreDownItems];
    return [moreDownItems copy];
}

#pragma mark - share contentItems

//app分享
- (NSArray<id<TTActivityContentItemProtocol>> *)outShareItemsWithClickSource:(TTVActivityClickSourceFrom )clickSource
{
    TTWechatTimelineContentItem *wcTlItem = [self wechatTimelineCotentItem];
    TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
    TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
//    TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    
    NSArray *typeArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
    NSMutableArray *SeqArray = @[].mutableCopy;
    [typeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *objType = (NSString *)obj;
            if ([objType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
                [SeqArray addObject:wcTlItem];
            }else if ([objType isEqualToString:TTActivityContentItemTypeWechat]){
                [SeqArray addObject:wcItem];
            }else if ([objType isEqualToString:TTActivityContentItemTypeQQFriend]){
                [SeqArray addObject:qqItem];
            }else if ([objType isEqualToString:TTActivityContentItemTypeQQZone]){
                [SeqArray addObject:qqZoneItem];
            }
//            else if ([objType isEqualToString:TTActivityContentItemTypeDingTalk]){
//                [SeqArray addObject:ddItem];
//            }
            else if ([objType isEqualToString: TTActivityContentItemTypeForwardWeitoutiao]){
//                if (self.model.adID.longLongValue > 0){
//                }else{
//                    [SeqArray addObject:[self forwardWeitoutiaoContentItem]];
//                }
            }
        }
    }];
    return SeqArray;
}

//系统相关分享
- (NSArray<id<TTActivityContentItemProtocol>> *)shareItems
{
//    TTSystemContentItem *sysItem = [[TTSystemContentItem alloc] initWithDesc:[self shareDesc] webPageUrl:[self shareUrl] image:[self shareImage]];
//    TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:[self shareUrl]];
//    TTEmailContentItem *emailItem = [[TTEmailContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc]];
    return @[];
}

- (void)addReportOrDeleteContentItem:(NSMutableArray<id<TTActivityContentItemProtocol>> *)contentItems
{
    NSString *uid = self.model.userId;
    if (isEmptyString(self.cellEntity.article.adId)) {
//        if (!isEmptyString(uid) && !isEmptyString([TTAccountManager userID]) && [uid isEqualToString:[TTAccountManager userID]]) { //ugc视频
//            [contentItems addObject:[self deleteContentItem]];
//        }else{
            [contentItems addObject:[self reportItem]];
//        }
    }else{
        [contentItems addObject:[self reportItem]];
    }
}

- (TTWechatTimelineContentItem *)wechatTimelineCotentItem{
    
    NSString *timeLineText = [self shareTitle];
    UIImage *shareImg = [self shareImage];
    TTShareType shareType;

    TTWechatTimelineContentItem *wcTlItem;
    if (self.model.adID.longLongValue > 0) {
        if (self.model.hasVideo) {
            shareType = TTShareVideo;
        }else{
            shareType = TTShareWebPage;
        }
    }else{
        UIImageView *originalImageView = [[UIImageView alloc] initWithImage:[self shareImage]];
        if (ttvs_isShareTimelineOptimize() == 2) {
            shareImg = [self imageWithView:originalImageView];
        }
        if (ttvs_isShareTimelineOptimize() > 0 )
        {
            shareType = TTShareWebPage;
        }
        else{
            shareType = TTShareVideo;
        }
        
        if (ttvs_isShareTimelineOptimize() > 2) {
            timeLineText = [self timeLineTitle];
        }
    }
    wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:timeLineText desc:timeLineText webPageUrl:[self shareUrl] thumbImage:shareImg shareType:shareType];

    return wcTlItem;
}

//举报
- (TTReportContentItem *)reportItem
{
    TTReportContentItem *reportItem = [TTReportContentItem new];
    WeakSelf;
    reportItem.customAction = ^(void) {
        StrongSelf;
        [self reportAction];
    };
    return reportItem;
}

- (void)reportAction
{
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:self.model.groupId forKey:@"group_id"];
    [eventContext setValue:self.model.itemId forKey:@"item_id"];
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    if (self.model.adID.longLongValue > 0) {
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportADOptions]];
    } else {
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
    }
    @weakify(self);
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
        @strongify(self);
        if (parameters[@"report"]) {
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = self.model.groupId;
            model.videoID = self.model.itemId;
            NSString *contentType = kTTReportContentTypePGCVideo;
            if (!isEmptyString(self.model.videoSource) && [self.model.videoSource isEqualToString:@"ugc_video"]) {
                contentType = kTTReportContentTypeUGCVideo;
            } else if (!isEmptyString(self.model.videoSource) && [self.model.videoSource isEqualToString:@"huoshan"]) {
                contentType = kTTReportContentTypeHTSVideo;
            } else if (self.model.adID.longLongValue > 0) {
                contentType = kTTReportContentTypeAD;
            }
            
            [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(nil, self.categoryId) contentModel:model extraDic:nil animated:YES];
            [self.shareSectionAndEventDic setValue:parameters[@"report"] forKey:@"reason"];
            [self shareTrackEventV3WithActivityType:TTActivityTypeReport];
        }
    }];

}

//微头条
- (TTForwardWeitoutiaoContentItem *)forwardWeitoutiaoContentItem
{
    TTForwardWeitoutiaoContentItem * contentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
    WeakSelf;
    contentItem.customAction = ^{
        StrongSelf;
        [self forwardToWeitoutiao:TTActivityContentItemTypeForwardWeitoutiao];
    };
    return contentItem;
}

- (void)forwardToWeitoutiao:(NSString *)type
{
    if (self.didClickActivityItemAndQueryProcess) {
        self.didClickActivityItemAndQueryProcess(type);
    }
}

//收藏
- (TTFavouriteContentItem *)favourateContentItem
{
    TTFavouriteContentItem *contentItem = [[TTFavouriteContentItem alloc] init];
    contentItem.selected = self.model.userRepined.boolValue;
    WeakSelf;
    @weakify(contentItem);
    contentItem.customAction = ^{
        StrongSelf;
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        if(self.model.userRepined.boolValue) {
            [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:NSLocalizedString(@"取消收藏", nil)
                andImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:nil];
        }
        else {
             [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:NSLocalizedString(@"收藏成功", nil) andImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] dismissHandler:nil];
        }

        [self triggerFavoriteAction];
        @strongify(contentItem);
        contentItem.selected = self.model.userRepined.boolValue;
    };
    return contentItem;
}

- (void)triggerFavoriteAction
{
    NSString *group_id = self.model.groupId;
    NSString *item_id = self.model.itemId;
    NSNumber *aggrType = self.model.aggrType;
    NSString *ad_id = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;
    BOOL userRepined = [self.model.userRepined boolValue];
    
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    NSString *unique_id = group_id ? group_id : ad_id;
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:unique_id forKey:@"group_id"];
    [eventContext setValue:item_id forKey:@"item_id"];
    
    TTGroupModel *model = [[TTGroupModel alloc] initWithGroupID:group_id itemID:item_id impressionID:nil aggrType:aggrType.integerValue];
    self.model.userRepined = @(!userRepined);
    if (userRepined) {
        @weakify(self);
        [self.itemActionManager favoriteForGroupModel:model adID:@(ad_id.longLongValue) isFavorite:!userRepined finishBlock:^(NSDictionary *userInfo, NSError *error) {
            @strongify(self);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:NO uniqueIDStr:unique_id);
            if ([userInfo isKindOfClass:[NSDictionary class]]) {
                [[self articleService] updateUnrepinWithActionItem:[self actionItemWithUserInfo:userInfo adId:ad_id]];
            }
        }];
        
        
    }
    else {
        @weakify(self);
        [self.itemActionManager favoriteForGroupModel:model adID:@(ad_id.longLongValue) isFavorite:!userRepined finishBlock:^(id userInfo, NSError *error) {
            @strongify(self);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCollectChanged:uniqueIDStr:), ttv_message_feedCollectChanged:YES uniqueIDStr:unique_id);
            [[self articleService] updateRepinWithActionItem:[self actionItemWithUserInfo:userInfo adId:ad_id]];
        }];
        
    }

}

- (TTVideoArticleService *)articleService
{
    TTVideoArticleService *service = [[TTServiceCenter sharedInstance] getService:[TTVideoArticleService class]];
    return service;
}

- (TTVideoArticleActionItem *)actionItemWithUserInfo:(NSDictionary *)dic adId:(NSString *)adId
{
    TTVideoArticleActionItem *item = [[TTVideoArticleActionItem alloc] init];
    item.groupId = [NSString stringWithFormat:@"%@",[dic valueForKey:@"group_id"]];
    item.adId = [NSString stringWithFormat:@"%@",adId];
    item.buryCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"bury_count"]].longLongValue);
    item.diggCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"digg_count"]].longLongValue);
    item.commentCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"comment_count"]].longLongValue);
    item.repinCount = @([NSString stringWithFormat:@"%@",[dic valueForKey:@"repin_count"]].longLongValue);
    return item;
}

//特卖
- (TTCommodityContentItem *)commodityContentItem{
    TTCommodityContentItem *contentItem = [[TTCommodityContentItem alloc] initWithDesc:@"推荐商品"];
    @weakify(self);
    contentItem.customAction = ^{
        @strongify(self);
        if (self.activityAction) {
            self.activityAction(TTActivityContentItemTypeCommodity);
            [self commodityLogV3WithEventName:@"commodity_recommend_click"];
        }
    };
    [self commodityLogV3WithEventName:@"commodity_recommend_show"];
    return contentItem;
}

//顶踩
- (TTDiggContentItem *)diggContentItem
{
    TTDiggContentItem *contentItem = [[TTDiggContentItem alloc] init];
    contentItem.count = [self.model.diggCount longLongValue];
    contentItem.selected = self.model.userDigg.boolValue;
    WeakSelf;
    @weakify(contentItem);
    contentItem.customAction = ^{
        StrongSelf;
        @strongify(contentItem);
        contentItem.banDig = NO;
        if (self.model.userBury.boolValue) {
            NSString *tip = NSLocalizedString(@"您已经踩过", nil);
            contentItem.banDig = YES;
            [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:tip
                                                                    andImage:nil dismissHandler:nil];
        }else{
            [self diggAction];
        }
    };
    return contentItem;
}

- (TTBuryContentItem *)buryContentItem
{
    TTBuryContentItem *contentItem = [[TTBuryContentItem alloc] init];
    contentItem.count = [self.model.buryCount longLongValue];
    contentItem.selected = self.model.userBury.boolValue;
    WeakSelf;
    @weakify(contentItem);
    contentItem.customAction = ^{
        StrongSelf;
        @strongify(contentItem);
        contentItem.banDig = NO;
        if (self.model.userDigg.boolValue) {
            NSString *tip = NSLocalizedString(@"您已经顶过", nil);
            contentItem.banDig = YES;
            [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:tip
                                                                    andImage:nil dismissHandler:nil];

        }else{
            [self buryAction];
        }
        
    };
    return contentItem;
}

- (void)diggAction
{
    if ([self.model.userDigg boolValue]) {
        
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.model.aggrType;
        parameter.item_id = self.model.itemId;
        parameter.group_id = self.model.groupId;
        parameter.ad_id = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;;
        NSString *unique_id = self.model.groupId ? self.model.groupId : self.model.adID.stringValue;
        @weakify(self);
        self.model.userDigg = @(NO);
        [[self articleService] cancelDigg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            int diggCount = [self.model.diggCount intValue] - 1;
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:[self.model.userDigg boolValue] uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:diggCount uniqueIDStr:unique_id);
        }];
        
    }
    else if (![self.model.userBury boolValue]){
        
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.model.aggrType;
        parameter.item_id = self.model.itemId;
        parameter.group_id = self.model.groupId;
        parameter.ad_id = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;
        NSString *unique_id = self.model.groupId ? self.model.groupId : self.model.adID.stringValue;
        @weakify(self);
        self.model.userDigg = @(YES);
        [[self articleService] digg:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            int diggCount = [self.model.diggCount intValue] + 1;
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggChanged:uniqueIDStr:), ttv_message_feedDiggChanged:YES uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedDiggCountChanged:uniqueIDStr:), ttv_message_feedDiggCountChanged:diggCount uniqueIDStr:unique_id);
        }];
    }
    [self shareDiggBuryActionLogWithActictyType:TTActivityTypeDigUp];

}

- (void)buryAction
{
    if ([self.model.userBury boolValue]) {
        
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.model.aggrType;
        parameter.item_id = self.model.itemId;
        parameter.group_id = self.model.groupId;
        parameter.ad_id = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;
        NSString *unique_id = self.model.groupId ? self.model.groupId : self.model.adID.stringValue;
        @weakify(self);
        self.model.userBury = @(NO);
        [[self articleService] cancelBurry:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            int buryCount = [self.model.buryCount intValue] - 1;
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:[self.model.userBury boolValue] uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:buryCount uniqueIDStr:unique_id);
        }];
        
    }
    else if (![self.model.userDigg boolValue]){
        
        TTVideoDiggBuryParameter *parameter = [[TTVideoDiggBuryParameter alloc] init];
        parameter.aggr_type = self.model.aggrType;
        parameter.item_id = self.model.itemId;
        parameter.group_id = self.model.groupId;
        parameter.ad_id = self.model.adID.longLongValue > 0 ? self.model.adID.stringValue : nil;
        NSString *unique_id = self.model.groupId ? self.model.groupId : self.model.adID.stringValue;
        @weakify(self);
        self.model.userBury = @(YES);
        [[self articleService] burry:parameter completion:^(TT2DataItemActionResponseModel *response, NSError *error) {
            @strongify(self);
            if (error) {
                return;
            }
            int buryCount = [self.model.buryCount intValue] + 1;
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryChanged:uniqueIDStr:), ttv_message_feedBuryChanged:YES uniqueIDStr:unique_id);
            SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedBuryCountChanged:uniqueIDStr:), ttv_message_feedBuryCountChanged:buryCount uniqueIDStr:unique_id);
        }];
    }
    [self shareDiggBuryActionLogWithActictyType:TTActivityTypeDigDown];

}

- (TTDislikeContentItem *)dislikeContentItem{
    TTVDislikeActionEntity *entity = [[TTVDislikeActionEntity alloc] init];
    entity.filterWords = self.model.filterWords;
    entity.dislikePopFromView = self.dislikePopFromView;
    entity.groupId = self.model.groupId;
    entity.adID = self.model.adID;
    entity.logExtra = self.model.logExtra;
    entity.cellEntity = self.cellEntity;
    
    TTDislikeContentItem *contentItem = [[TTDislikeContentItem alloc] init];
    contentItem.customAction = ^{
        TTVDislikeAction *action = [[TTVDislikeAction alloc] initWithEntity:entity];
        action.didClickDislikeSubmitButtonBlock = self.didClickDislikeSubmitButtonBlock;
        @weakify(self);
        action.didTrakDislikeSubmiteActionBlock = ^(NSArray *filterWords) {
            @strongify(self);
            [self.shareSectionAndEventDic setValue:filterWords forKey:@"filter_words"];
            [self shareTrackEventV3WithActivityType:TTActivityTypeDislike];
            [self shareTrackAdEventConfirmWithTag:@"embeded_ad" label:@"final_dislike" filterWords:filterWords];
        };
        [action execute:TTActivityTypeDislike];
        [self shareTrackAdEventWithTag:@"embeded_ad" label:@"dislike"];
    };
    return contentItem;
}

//- (TTThreadDeleteContentItem *)deleteContentItem{
//    TTVDeleteActionEntity *entity = [[TTVDeleteActionEntity alloc] init];
//    entity.groupId = self.model.groupId;
//    entity.cellEntity = self.cellEntity;
//    entity.itemId = isEmptyString(self.model.itemId) ? self.model.groupId : self.model.itemId;
//    entity.userId = self.model.userId;
//    TTThreadDeleteContentItem * deleteContentItem = [[TTThreadDeleteContentItem alloc] initWithTitle:NSLocalizedString(@"删除", nil)
//                                                                                       imageName:@"delete_allshare"];
//    deleteContentItem.customAction = ^{
//        TTVDeleteAction *action = [[TTVDeleteAction alloc] initWithEntity:entity];
//        [action execute:TTActivityTypeDetele];
//    };
//    return deleteContentItem;
//}
#pragma mark - share util

- (NSString *)shareTitle
{
    NSString *shareTitle;
    NSString *mediaName = self.model.shareModel.mediaName;
    if (!isEmptyString(mediaName)) {
        shareTitle = [NSString stringWithFormat:@"【%@】%@", mediaName, self.model.shareModel.title];
    }
    else {
        shareTitle = self.model.shareModel.title;
    }
    
    return shareTitle;
}


- (NSString *)timeLineTitle
{
    NSString *timeLineTitle;
    if (!isEmptyString(self.model.shareModel.title)){
        timeLineTitle = [NSString stringWithFormat:@"%@-%@", self.model.shareModel.title, @""];
    }else{
        timeLineTitle = NSLocalizedString(@"爱看", nil);
    }
    return timeLineTitle;
}

- (NSString *)shareDesc
{
    NSString *detail;
    detail = isEmptyString(self.model.shareModel.abstract) ? NSLocalizedString(@"爱看", nil) : self.model.shareModel.abstract;
    return detail;
}

- (NSString *)shareUrl
{
    NSString *shareUrl;
    if (!isEmptyString(self.model.shareModel.shareURL)) {
        shareUrl = self.model.shareModel.shareURL;
    }else{
        shareUrl = self.model.shareModel.downloadURL;
    }
    if (shareUrl.length > 512){
        NSUInteger location = [shareUrl rangeOfString:@"&"].location;
        shareUrl = [shareUrl substringToIndex:location];
    }
    return shareUrl;
}

- (UIImage *)shareImage
{
    UIImage *image;
    TTImageInfosModel *model = self.model.shareModel.infosModel;
    model.imageType = TTImageTypeLarge;
    image = [TTWebImageManager imageForModel:model];
    return image;
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIImage *iconImg = [UIImage imageNamed:@"video_play_share_icon.png"];
    UIImageView *iconImgView = [[UIImageView alloc] initWithImage:iconImg];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    //iconImgView 方形 和view高度形同大小
    view.frame = CGRectMake(0, 0, view.size.width, view.size.height);
    iconImgView.size = CGSizeMake(view.size.height, view.size.height);
    [view addSubview:iconImgView];
    iconImgView.center = view.center;
    CGSize pageSize = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
// 控制有分享面板时，是否允许视频根据设备方向转屏
- (void)setIsCanFullScreenFromOrientationMonitor:(BOOL)isCanFullScreen{
    if ([TTDeviceHelper OSVersionNumber] < 9.f) {
        [BDPlayerObjManager setIsCanFullScreenFromOrientationMonitorChanged:isCanFullScreen];
    }
}
@end
