//
//  TTMomentProfileBaseView.m
//  Article
//
//  Created by Chen Hong on 16/8/18.
//
//

#import "TTMomentProfileBaseView.h"
#import "TTBlockManager.h"
#import "TTThemedAlertController.h"
#import "TTPhotoScrollViewController.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import "TTNavigationController.h"
#import "ExploreDeleteManager.h"
#import "ExploreMomentDefine.h"
#import "FriendDataManager.h"
#import "TTReportManager.h"
#import "SSIndicatorTipsManager.h"
#import "TTPhotoScrollViewController.h"
#import "FriendModel.h"
#import "TTProfileShareService.h"
#import "TTActionSheetController.h"
#import "TTUGCDefine.h"
#import "TTArticleCategoryManager.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import <FRApiModel.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import "ArticleURLSetting.h"
#import <TTInteractExitHelper.h>

#import <TTAccountBusiness.h>
#import <TTBatchItemAction/DetailActionRequestManager.h>
//#import "TTShareToRepostManager.h"
#import "TTActivityShareSequenceManager.h"
#import "TSVShortVideoOriginalData.h"
#import "ExploreMomentDefine.h"
#import "TTCommentDataManager.h"
#import <TTKitchen/TTKitchenHeader.h>



// 编辑资料完成后，向h5或rn页面发送通知名称
extern NSString *const kTTEditUserInfoDidFinishNotificationName;
extern BOOL ttvs_isShareIndividuatioEnable(void);


@interface TTMomentProfileBaseView()
<
FriendDataManagerDelegate,
TTBlockManagerDelegate,
SSActivityViewDelegate,
TTActivityShareManagerDelegate
>

@property(nonatomic, strong)FriendDataManager * friendManager;
@property(nonatomic, strong)TTBlockManager * blockUserManager;
@property(nonatomic, strong)TTActivityShareManager *activityActionManager;
@property(nonatomic, strong)SSActivityView *phoneShareView;

//@property(nonatomic, strong)ArticleJSBridge *jsbridge; // 分享个人主页
@property(nonatomic, strong)TTActionSheetController *actionSheetController;
@end


@implementation TTMomentProfileBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.friendManager = [[FriendDataManager alloc] init];
        self.friendManager.delegate = self;
        
        self.blockUserManager = [[TTBlockManager alloc] init];
        self.blockUserManager.delegate = self;
        
        // 这是动态转发通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getForwardMomentDoneNotification:) name:kForwardMomentItemDoneNotification object:nil];
        
        // 这是微头条转发通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weitoutiaoPostSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weitoutiaoPostSuccess:) name:kCommentRepostSuccessNotification object:nil];
        
        // 评论成功通知（postMessage）
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postMessageDidFinish:) name:kPostMessageFinishedNotification object:nil];
        
        // 点赞
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiggComment:) name:kCommentDigNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDiggComment:) name:kCommentUnDigNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiggMoment:) name:kDidDiggMomentNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiggThread:) name:kFRThreadEntityDigNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDiggThread:) name:kFRThreadEntityCancelDigNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiggShortVideo:) name:@"TSVShortVideoDiggCountSyncNotification" object:nil];
        
        // 删除动态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMomentNotification:) name:kDeleteMomentNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteShortVideoNotification:) name:kTSVShortVideoDeleteNotification object:nil];
        
        // 删除评论/评论转发转发页面
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveDeleteMomentNotification:)
                                                     name:kDeleteCommentNotificationKey
                                                   object:nil];
        // 删除动态评论
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMomentCommentNeedDeleteNotification:) name:kDeleteMomentCommentNotificationKey object:nil];
        
        // 删除帖子评论
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveThreadCommentNeedDeleteNotification:) name:kDeleteCommentNotificationKey object:nil];
        
        // 拉黑
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBlockUserNotification:) name:kTTJSOrRNBlockOrUnBlockUserNotificationName object:nil];
        
        // 举报
        if(![KitchenMgr getBOOL:kKCUGCPersonHomeNativeEnable]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveReportUserNotification:) name:kTTJSOrRNReportUserNotificationName object:nil];
        }
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveReportUserNotification:) name:kTTJSOrRNReportUserNotificationName object:nil];
        
        /**
         *  用户编辑信息完成后并且返回时发送通知
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishEditingUserInfoNotification:) name:kTTEditUserInfoDidFinishNotificationName object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDetailDeleteUGCMovieNotification:) name:kDetailDeleteUGCMovieNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDeleteThreadNotification:) name:kTTForumDeleteThreadNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{

}
//- (void)forwardToWeitoutiao {
//    // 个人主页列表的转发
//    if (self.shareMoment.itemType == MomentItemTypeArticle && self.shareMoment.group.groupType == ArticleMomentGroupArticle) { //文章评论，转发的内容是文章，操作的对象是评论，个人主页列表中帖子评论不能被转发（现在也没推出来）
//        TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] init];
//        originArticle.groupID = self.shareMoment.group.ID;
//        originArticle.itemID = self.shareMoment.group.itemID;
//        originArticle.title = self.shareMoment.group.title;
//        originArticle.isVideo = (self.shareMoment.group.mediaType == ArticleWithVideo);
//        originArticle.userID = self.shareMoment.group.user.ID;
//        originArticle.userName = self.shareMoment.group.user.name;
//        originArticle.userAvatar = self.shareMoment.group.user.avatarURLString;
//        originArticle.isDeleted = self.shareMoment.group.deleted;
//        if (!isEmptyString(self.shareMoment.group.thumbnailURLString)) {
//            originArticle.thumbImage = [[FRImageInfoModel alloc] initWithURL:self.shareMoment.group.thumbnailURLString];;
//        }
//        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithText:self.shareMoment.content userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                        originArticle:originArticle
//                                                                         originThread:nil
//                                                                       originShortVideoOriginalData:nil
//                                                                    operationItemType:TTRepostOperationItemTypeComment
//                                                                      operationItemID:self.shareMoment.commentID
//                                                                       repostSegments:segments];
//    }
//    else if (self.shareMoment.itemType == MomentItemTypeForum) {
//        //个人主页中的帖子，MomentItemTypeForum，MomentItemTypeForum都是单纯的帖子
//        TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
//        originThread.threadID = self.shareMoment.ID;
//        originThread.content = self.shareMoment.content;
//        originThread.userID = self.shareMoment.user.ID;
//        originThread.userName = self.shareMoment.user.screen_name;
//        originThread.userAvatar = self.shareMoment.user.avatarURLString;
//        if ([self.shareMoment.thumbImageList count] > 0) {
//            if ([[self.shareMoment.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                originThread.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.thumbImageList firstObject] urlStringAtIndex:0]];
//            }
//        }
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeThread
//                                                                        originArticle:nil
//                                                                         originThread:originThread
//                                                                       originShortVideoOriginalData:nil
//                                                                    operationItemType:TTRepostOperationItemTypeThread
//                                                                      operationItemID:self.shareMoment.ID
//                                                                       repostSegments:nil];
//    }
//    else if (self.shareMoment.itemType == MomentItemTypeRepostedArticle) {
//        //转发文章生成的帖子，实际转发对象为文章，操作对象为帖子
//        TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] init];
//        originArticle.groupID = self.shareMoment.originGroup.ID;
//        originArticle.itemID = self.shareMoment.originGroup.itemID;
//        originArticle.title = self.shareMoment.originGroup.title;
//        originArticle.isVideo = (self.shareMoment.originGroup.mediaType == ArticleWithVideo);
//        originArticle.isDeleted = self.shareMoment.originGroup.deleted;
//        originArticle.userID = self.shareMoment.originGroup.user.ID;
//        originArticle.userName = self.shareMoment.originGroup.user.name;
//        originArticle.userAvatar = self.shareMoment.originGroup.user.avatarURLString;
//        originArticle.isDeleted = self.shareMoment.originGroup.deleted;
//        if (!isEmptyString(self.shareMoment.originGroup.thumbnailURLString)) {
//            originArticle.thumbImage = [[FRImageInfoModel alloc] initWithURL:self.shareMoment.originGroup.thumbnailURLString];;
//        }
//
//        NSString *contentUnescape = self.shareMoment.contentUnescape;
//        if (isEmptyString(contentUnescape)) {
//            contentUnescape = self.shareMoment.content;
//        }
//        NSString *contentRichSpan = self.shareMoment.contentRichSpan;
//        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:contentUnescape richSpans:[TTRichSpans richSpansForJSONString:contentRichSpan]];
//        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:richSpanText userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                        originArticle:originArticle
//                                                                         originThread:nil
//                                                                       originShortVideoOriginalData:nil
//                                                                    operationItemType:TTRepostOperationItemTypeThread
//                                                                      operationItemID:self.shareMoment.ID
//                                                                       repostSegments:segments];
//    }
//    else if (self.shareMoment.itemType == MomentItemTypeRepostedThread) {
//        //转发帖子生成的帖子，实际转发对象为原帖，操作对象为帖子
//        TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
//        originThread.threadID = self.shareMoment.originThread.threadID;
//        originThread.content = self.shareMoment.originThread.content;
//        originThread.userID = self.shareMoment.originThread.user.ID;
//        originThread.userName = self.shareMoment.originThread.user.screen_name;
//        originThread.userAvatar = self.shareMoment.originThread.user.avatarURLString;
//        originThread.isDeleted = [self.shareMoment.originThread isThreadDeleted];
//        originThread.showOrigin = self.shareMoment.originThread.showOrigin;
//        originThread.showTips = self.shareMoment.originThread.showTips;
//        if ([self.shareMoment.originThread.thumbImageList count] > 0) {
//            if ([[self.shareMoment.originThread.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                originThread.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.originThread.thumbImageList firstObject] urlStringAtIndex:0]];
//            }
//        }
//
//        NSString *contentUnescape = self.shareMoment.contentUnescape;
//        if (isEmptyString(contentUnescape)) {
//            contentUnescape = self.shareMoment.content;
//        }
//        NSString *contentRichSpan = self.shareMoment.contentRichSpan;
//        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:contentUnescape richSpans:[TTRichSpans richSpansForJSONString:contentRichSpan]];
//        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:richSpanText userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeThread
//                                                                        originArticle:nil
//                                                                         originThread:originThread
//                                                                       originShortVideoOriginalData:nil
//                                                                    operationItemType:TTRepostOperationItemTypeThread
//                                                                      operationItemID:self.shareMoment.ID
//                                                                       repostSegments:segments];
//    }
//    else if (self.shareMoment.itemType == MomentItemTypeRepostedIESVideo) {
//        //转发抖音生成的帖子，实际转发对象为抖音，操作对象为帖子
//        TTRepostOriginShortVideoOriginalData *originShortVideoOriginalData = [[TTRepostOriginShortVideoOriginalData alloc] init];
//        originShortVideoOriginalData.shortVideoID = self.shareMoment.originThread.threadID;
//        originShortVideoOriginalData.title = self.shareMoment.originThread.content;
//        originShortVideoOriginalData.userID = self.shareMoment.originThread.user.ID;
//        originShortVideoOriginalData.userName = self.shareMoment.originThread.user.name;
//        originShortVideoOriginalData.userAvatar = self.shareMoment.originThread.user.avatarURLString;
//        originShortVideoOriginalData.showOrigin = self.shareMoment.showOrigin;
//        originShortVideoOriginalData.showTips = self.shareMoment.showTips;
//        if ([self.shareMoment.originThread.thumbImageList count] > 0) {
//            if ([[self.shareMoment.originThread.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                originShortVideoOriginalData.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.originThread.thumbImageList firstObject] urlStringAtIndex:0]];
//            }
//        }
//        NSString *contentUnescape = self.shareMoment.contentUnescape;
//        if (isEmptyString(contentUnescape)) {
//            contentUnescape = self.shareMoment.content;
//        }
//        NSString *contentRichSpan = self.shareMoment.contentRichSpan;
//        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:contentUnescape richSpans:[TTRichSpans richSpansForJSONString:contentRichSpan]];
//        TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:richSpanText userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//        NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeShortVideo
//                                                                        originArticle:nil
//                                                                         originThread:nil
//                                                                       originShortVideoOriginalData:originShortVideoOriginalData
//                                                                    operationItemType:TTRepostOperationItemTypeThread
//                                                                      operationItemID:self.shareMoment.ID
//                                                                       repostSegments:segments];
//    }
//    else if (self.shareMoment.itemType == MomentItemTypeIESVideo) {
//        TTRepostOriginShortVideoOriginalData *originShortVideoOriginalData = [[TTRepostOriginShortVideoOriginalData alloc] init];
//        originShortVideoOriginalData.shortVideoID = self.shareMoment.ID;
//        originShortVideoOriginalData.title = self.shareMoment.content;
//        originShortVideoOriginalData.userID = self.shareMoment.user.ID;
//        originShortVideoOriginalData.userName = self.shareMoment.user.name;
//        originShortVideoOriginalData.userAvatar = self.shareMoment.user.avatarURLString;
//        originShortVideoOriginalData.showOrigin = self.shareMoment.showOrigin;
//        originShortVideoOriginalData.showTips = self.shareMoment.showTips;
//        if ([self.shareMoment.thumbImageList count] > 0) {
//            if ([[self.shareMoment.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                originShortVideoOriginalData.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.thumbImageList firstObject] urlStringAtIndex:0]];
//            }
//        }
//        [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeShortVideo
//                                                                        originArticle:nil
//                                                                         originThread:nil
//                                                                       originShortVideoOriginalData:originShortVideoOriginalData
//                                                                    operationItemType:TTRepostOperationItemTypeShortVideo
//                                                                      operationItemID:self.shareMoment.ID
//                                                                       repostSegments:nil];
//    }
//}

- (void)openForwardView
{
   
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(NSError *)error {
    if (!error) {
//        if (self.shareMoment.itemType == MomentItemTypeForum) {
//            //个人主页中的帖子，MomentItemTypeForum，MomentItemTypeForum都是单纯的帖子
//            TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
//            originThread.threadID = self.shareMoment.ID;
//            originThread.content = self.shareMoment.content;
//            originThread.userID = self.shareMoment.user.ID;
//            originThread.userName = self.shareMoment.user.screen_name;
//            originThread.userAvatar = self.shareMoment.user.avatarURLString;
//            if ([self.shareMoment.thumbImageList count] > 0) {
//                if ([[self.shareMoment.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                    originThread.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.thumbImageList firstObject] urlStringAtIndex:0]];
//                }
//            }
//            [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                       repostType:TTThreadRepostTypeThread
//                                                                operationItemType:TTRepostOperationItemTypeThread
//                                                                  operationItemID:self.shareMoment.ID
//                                                                    originArticle:nil
//                                                                     originThread:originThread
//                                                                   originShortVideoOriginalData:nil
//                                                                originWendaAnswer:nil
//                                                                   repostSegments:nil];
//        }
//        if (self.shareMoment.itemType == MomentItemTypeRepostedArticle) {
//            //转发文章生成的帖子，实际转发对象为文章，操作对象为帖子
//            TTRepostOriginArticle *originArticle = [[TTRepostOriginArticle alloc] init];
//            originArticle.groupID = self.shareMoment.originGroup.ID;
//            originArticle.itemID = self.shareMoment.originGroup.itemID;
//            originArticle.title = self.shareMoment.originGroup.title;
//            originArticle.isVideo = (self.shareMoment.originGroup.mediaType == ArticleWithVideo);
//            originArticle.isDeleted = self.shareMoment.originGroup.deleted;
//            originArticle.userID = self.shareMoment.originGroup.user.ID;
//            originArticle.userName = self.shareMoment.originGroup.user.name;
//            originArticle.userAvatar = self.shareMoment.originGroup.user.avatarURLString;
//            originArticle.isDeleted = self.shareMoment.originGroup.deleted;
//            if (!isEmptyString(self.shareMoment.originGroup.thumbnailURLString)) {
//                originArticle.thumbImage = [[FRImageInfoModel alloc] initWithURL:self.shareMoment.originGroup.thumbnailURLString];;
//            }
//
//            NSString *contentUnescape = self.shareMoment.contentUnescape;
//            if (isEmptyString(contentUnescape)) {
//                contentUnescape = self.shareMoment.content;
//            }
//            NSString *contentRichSpan = self.shareMoment.contentRichSpan;
//            TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:contentUnescape richSpans:[TTRichSpans richSpansForJSONString:contentRichSpan]];
//            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:richSpanText userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//            [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                       repostType:TTThreadRepostTypeArticle
//                                                                operationItemType:TTRepostOperationItemTypeThread
//                                                                  operationItemID:self.shareMoment.ID
//                                                                    originArticle:originArticle
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:nil
//                                                                originWendaAnswer:nil
//                                                                   repostSegments:segments];
//        }else if (self.shareMoment.itemType == MomentItemTypeRepostedThread) {
//            //转发帖子生成的帖子，实际转发对象为原帖，操作对象为帖子
//            TTRepostOriginThread *originThread = [[TTRepostOriginThread alloc] init];
//            originThread.threadID = self.shareMoment.originThread.threadID;
//            originThread.content = self.shareMoment.originThread.content;
//            originThread.userID = self.shareMoment.originThread.user.ID;
//            originThread.userName = self.shareMoment.originThread.user.screen_name;
//            originThread.userAvatar = self.shareMoment.originThread.user.avatarURLString;
//            originThread.isDeleted = [self.shareMoment.originThread isThreadDeleted];
//            originThread.showOrigin = self.shareMoment.originThread.showOrigin;
//            originThread.showTips = self.shareMoment.originThread.showTips;
//            if ([self.shareMoment.originThread.thumbImageList count] > 0) {
//                if ([[self.shareMoment.originThread.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                    originThread.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.originThread.thumbImageList firstObject] urlStringAtIndex:0]];
//                }
//            }
//
//            NSString *contentUnescape = self.shareMoment.contentUnescape;
//            if (isEmptyString(contentUnescape)) {
//                contentUnescape = self.shareMoment.content;
//            }
//            NSString *contentRichSpan = self.shareMoment.contentRichSpan;
//            TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:contentUnescape richSpans:[TTRichSpans richSpansForJSONString:contentRichSpan]];
//            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:richSpanText userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//            [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                       repostType:TTThreadRepostTypeThread
//                                                                operationItemType:TTRepostOperationItemTypeThread
//                                                                  operationItemID:self.shareMoment.ID
//                                                                    originArticle:nil
//                                                                     originThread:originThread
//                                                                   originShortVideoOriginalData:nil
//                                                                originWendaAnswer:nil
//                                                                   repostSegments:segments];
//        }
//        if (self.shareMoment.itemType == MomentItemTypeRepostedIESVideo) {
//            //转发抖音生成的帖子，实际转发对象为抖音，操作对象为帖子
//            TTRepostOriginShortVideoOriginalData *originShortVideoOriginalData = [[TTRepostOriginShortVideoOriginalData alloc] init];
//            originShortVideoOriginalData.shortVideoID = self.shareMoment.originThread.threadID;
//            originShortVideoOriginalData.title = self.shareMoment.originThread.content;
//            originShortVideoOriginalData.userID = self.shareMoment.originThread.user.ID;
//            originShortVideoOriginalData.userName = self.shareMoment.originThread.user.name;
//            originShortVideoOriginalData.userAvatar = self.shareMoment.originThread.user.avatarURLString;
//            originShortVideoOriginalData.showOrigin = self.shareMoment.showOrigin;
//            originShortVideoOriginalData.showTips = self.shareMoment.showTips;
//            if ([self.shareMoment.originThread.thumbImageList count] > 0) {
//                if ([[self.shareMoment.originThread.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                    originShortVideoOriginalData.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.originThread.thumbImageList firstObject] urlStringAtIndex:0]];
//                }
//            }
//            NSString *contentUnescape = self.shareMoment.contentUnescape;
//            if (isEmptyString(contentUnescape)) {
//                contentUnescape = self.shareMoment.content;
//            }
//            NSString *contentRichSpan = self.shareMoment.contentRichSpan;
//            TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:contentUnescape richSpans:[TTRichSpans richSpansForJSONString:contentRichSpan]];
//            TTRepostContentSegment *segment = [[TTRepostContentSegment alloc] initWithRichSpanText:richSpanText userID:self.shareMoment.user.ID username:self.shareMoment.user.name];
//            NSArray *segments = [[NSArray alloc] initWithObjects:segment, nil];
//            [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                       repostType:TTThreadRepostTypeShortVideo
//                                                                operationItemType:TTRepostOperationItemTypeThread
//                                                                  operationItemID:self.shareMoment.ID
//                                                                    originArticle:nil
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:originShortVideoOriginalData
//                                                                originWendaAnswer:nil
//                                                                   repostSegments:segments];
//        }else if (self.shareMoment.itemType == MomentItemTypeIESVideo) {
//            TTRepostOriginShortVideoOriginalData *originShortVideoOriginalData = [[TTRepostOriginShortVideoOriginalData alloc] init];
//            originShortVideoOriginalData.shortVideoID = self.shareMoment.ID;
//            originShortVideoOriginalData.title = self.shareMoment.content;
//            originShortVideoOriginalData.userID = self.shareMoment.user.ID;
//            originShortVideoOriginalData.userName = self.shareMoment.user.name;
//            originShortVideoOriginalData.userAvatar = self.shareMoment.user.avatarURLString;
//            originShortVideoOriginalData.showOrigin = self.shareMoment.showOrigin;
//            originShortVideoOriginalData.showTips = self.shareMoment.showTips;
//            if ([self.shareMoment.thumbImageList count] > 0) {
//                if ([[self.shareMoment.thumbImageList firstObject] isKindOfClass:[TTImageInfosModel class]]) {
//                    originShortVideoOriginalData.thumbImage = [[FRImageInfoModel alloc] initWithURL:[[self.shareMoment.thumbImageList firstObject] urlStringAtIndex:0]];
//                }
//            }
//            [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                       repostType:TTThreadRepostTypeShortVideo
//                                                                operationItemType:TTRepostOperationItemTypeShortVideo
//                                                                  operationItemID:self.shareMoment.ID
//                                                                    originArticle:nil
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:originShortVideoOriginalData
//                                                                originWendaAnswer:nil
//                                                                   repostSegments:nil];
//        }
    }
}

#pragma mark - 删除动态
- (void)deleteMoment:(NSString *)momentID {
    if (![TTAccountManager isLogin]) {
        [self showLoginViewWithSource:@"social_other"];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        [[ExploreDeleteManager shareManager] deleteMomentForMomentID:momentID];
    }
}

#pragma mark - 删除自己评论
- (void)deleteMomentComment:(NSString *)commentID {
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    else {
        [[ExploreDeleteManager shareManager] deleteMomentCommentForCommentID:commentID];
    }
}

#pragma mark - 举报
- (void)report:(NSDictionary *)parameters {
    // "update_id": 动态id, "reply_id": 评论id, "user_id": 用户id, "source": 页面来源ID
    /*
     int source = [parameters objectForKey:@"source"] ? [parameters tt_intValueForKey:@"source"] : ReportSourceUser;
     NSString *update_id = [parameters tt_stringValueForKey:@"update_id"];
     NSString *reply_id = [parameters tt_stringValueForKey:@"reply_id"];
     NSString *user_id = [parameters tt_stringValueForKey:@"user_id"];
     */
    int source = 0;
    NSString *update_id = nil;
    NSString *reply_id = nil;
    NSString *user_id = nil;
    if(![KitchenMgr getBOOL:kKCUGCPersonHomeNativeEnable]) {
        source = [parameters objectForKey:@"source"] ? [parameters tt_intValueForKey:@"source"] : TTReportSourceUser;
        update_id = [parameters tt_stringValueForKey:@"update_id"];
        reply_id = [parameters tt_stringValueForKey:@"reply_id"];
        user_id = [parameters tt_stringValueForKey:@"user_id"];
    } else {
        source = [parameters objectForKey:@"source"] ? [parameters tt_intValueForKey:@"source"] : TTReportSourceUser;
        update_id = [parameters tt_stringValueForKey:@"id"];
        reply_id = parameters[@"moment"][@"comment_id"];
        user_id = [parameters tt_stringValueForKey:@"uid"];
        
    }
    //    NSMutableDictionary *mutParams = [NSMutableDictionary dictionaryWithCapacity:2];
    //    [mutParams setValue:update_id forKey:@"update_id"];
    //    [mutParams setValue:reply_id forKey:@"reply_id"];
    //    [mutParams setValue:user_id forKey:@"user_id"];
    //    tt_openReportWapPage(nil, source, mutParams);
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull param) {
        if (param[@"report"]) {
            NSNumber *updateId = parameters[@"id"];
            NSNumber *gType = [parameters tt_dictionaryValueForKey:@"moment"][@"type"];
            NSMutableDictionary *tmpParam = [NSMutableDictionary dictionary];
            if(updateId) {
                tmpParam[@"update_id"] = updateId;
            }
            if(gType) {
                tmpParam[@"gtype"] = gType;
            }
            if(tmpParam.count > 0) {
                wrapperTrackEventWithCustomKeys(@"profile_more", @"confirm_report", user_id, nil,tmpParam);
            }
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = user_id;
            model.commentID = reply_id;
            model.groupID = update_id;
            [[TTReportManager shareInstance] startReportUserWithType:param[@"report"] inputText:param[@"criticism"] message:nil source:@(source).stringValue userModel:model animated:YES];
        }
    }];
}

#pragma mark - 拉黑/取消拉黑
- (void)block:(NSString *)userID isBlock:(BOOL)isBlock {
    //通知回调当中必须判断当前视图是否在顶层
    if (self.viewController != [[TTUIResponderHelper topNavigationControllerFor:self] topViewController]) {
        return;
    }
    
    if (userID && [userID isKindOfClass:[NSNumber class]]) {
        userID = [((NSNumber *)userID) stringValue];
    }
    
    if (![TTAccountManager isLogin]) {
        [self showLoginViewWithSource:@"social_other"];
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请先登录" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        if (!TTNetworkConnected()) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"无网络链接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            if (!isBlock) {
                [self.blockUserManager unblockUser:userID];
                wrapperTrackEvent(@"profile_more", @"deblacklist");
            } else {
                wrapperTrackEvent(@"profile_more", @"click_blacklist");
                
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"确定拉黑该用户？" message:@"拉黑后此用户不能关注你，也无法给你发送任何消息" preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                    wrapperTrackEvent(@"blacklist", @"quit_blacklist");
                }];
                [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    wrapperTrackEvent(@"blacklist", @"confirm_blacklist");
                    
                    [self.blockUserManager blockUser:userID];
                }];
                [alert showFrom:self.viewController animated:YES];
            }
        }
    }
}

- (void)showLoginViewWithSource:(NSString *)source
{
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeSocial source:source completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:source completion:^(TTAccountLoginState state) {
            }];
        }
    }];
}

#pragma mark - FriendDataManagerDelegate
- (void)friendDataManager:(FriendDataManager *)dataManager finishActionType:(FriendActionType)type error:(NSError *)error result:(NSDictionary *)result
{
    if (error) {
        NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
        if (isEmptyString(hint)) {
            hint = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    } else {
        NSString *hint = nil;
        switch (type) {
            case FriendActionTypeFollow: {
                hint = NSLocalizedString(@"关注成功", nil);
                break;
            }
            case FriendActionTypeUnfollow:
            default:
                break;
        }
        
        if (!isEmptyString(hint)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        }
        
        
        
        // send notification to synchronize old friend information
        NSMutableDictionary *dict = [@{@"action_type": @(type)} mutableCopy];
        [dict setValue:result[@"result"][@"data"][@"user"] forKey:@"user_data"];
        [dict setValue:@(YES) forKey:@"sendlog"];
        [[NSNotificationCenter defaultCenter] postNotificationName:KFriendModelChangedNotification object:nil userInfo:dict];
    }
}

#pragma mark - TTBlockManagerDelegate
- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip {
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拉黑成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        [TTProfileShareService setBlocking:YES forUID:userID];
    }
}

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip;
{
    if (error) {
        NSString * failedDescription = @"操作失败，请重试";
        if (!isEmptyString(errorTip)) {
            failedDescription = errorTip;
        }
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:failedDescription indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    } else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"已解除黑名单" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        [TTProfileShareService setBlocking:NO forUID:userID];
    }
}

#pragma - follow/unfollow
- (void)follow:(NSDictionary *)info {
    [self followOrUnActionWithInfo:info action:FriendActionTypeFollow];
}

- (void)unfollow:(NSDictionary *)info {
    [self followOrUnActionWithInfo:info action:FriendActionTypeUnfollow];
}

- (void)followOrUnActionWithInfo:(NSDictionary *)info action:(FriendActionType)action {
    NSString *userID = [info tt_stringValueForKey:@"id"];
    NSNumber *newReason = @([info tt_integerValueForKey:@"new_reason"]);
    NSNumber *newSource = @([info tt_integerValueForKey:@"new_source"]);
    
    __weak typeof(self) wself = self;
    [[TTFollowManager sharedManager] startFollowAction:action userID:userID platform:nil name:nil from:nil reason:nil newReason:newReason newSource:newSource completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        __strong typeof(wself) sself = wself;
        [sself friendDataManager:sself.friendManager finishActionType:type error:error result:result];
    }];
}

#pragma mark - digg
- (void)updateDigg:(NSString *)momentID {
    
}

- (void)cancelDigg:(NSString *)momentID {
    if (!momentID) {
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentCancelDiggURLString] params:@{@"id": momentID} method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        [self didCancelDiggMoment:momentID];
    }];
}


- (void)updateCommentDigg:(NSString *)commentID {
    
}

- (void)updateShortVideoDigg:(NSString *)shortVideoID {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:shortVideoID forKey:@"group_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting shortVideoDiggUpURL] params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDiggCountSyncNotification"
                                                            object:nil
                                                          userInfo:@{@"group_id" : shortVideoID ?:@"",
                                                                     @"user_digg" : @(YES),                                                         }];
    }];
}

- (void)cancelShortVideoDigg:(NSString *)shortVideoID {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:shortVideoID forKey:@"group_id"];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting shortVideoCancelDiggURL] params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDiggCountSyncNotification"
                                                            object:nil
                                                          userInfo:@{@"group_id" : shortVideoID ?:@"",
                                                                     @"user_digg" : @(NO),                                                         }];
    }];
}

#pragma mark - Gallery
- (void)showGallery:(NSDictionary *)result {
    NSArray *images = [result tt_arrayValueForKey:@"images"];
    NSArray *imageList = [result tt_arrayValueForKey:@"image_list"];
    NSArray *frameList = [result tt_arrayValueForKey:@"frames"];
    
    if (images.count > 0 || imageList.count > 0)
    {
        TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
        vc.targetView = self;
        vc.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
        vc.startWithIndex = [result tt_intValueForKey:@"index"];
        
        if(imageList.count > 0)
        {
            NSMutableArray *models = [NSMutableArray arrayWithCapacity:imageList.count];
            for(NSDictionary *dict in imageList)
            {
                TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:dict];
                if (model) {
                    [models addObject:model];
                }
            }
            vc.imageInfosModels = models;
        }
        else if(images.count > 0)
        {
            vc.imageURLs = images;
        }
        
        if (frameList.count > 0) {
            NSMutableArray * mutDisplayImageViewFrames = [NSMutableArray array];
            NSMutableArray * animateFrames = [NSMutableArray array];
            for (NSUInteger i = 0; i < frameList.count; ++i) {
                NSString *frameStr = frameList[i];
                CGRect imageFrame = CGRectFromString(frameStr);
                CGRect frame = [self convertRect:imageFrame toView:nil];
                [mutDisplayImageViewFrames addObject:[NSValue valueWithCGRect:frame]];
                [animateFrames addObject:[NSValue valueWithCGRect:imageFrame]];
            }
            
            vc.placeholderSourceViewFrames = mutDisplayImageViewFrames;
        }
        
        [vc presentPhotoScrollView];
    }
    
}

#pragma mark - 用户信息
- (NSDictionary *)parseUserProfileData:(NSDictionary *)dict {
    NSDictionary *data = [dict tt_dictionaryValueForKey:@"data"];
    return data;
}

#pragma mark - 通知

- (void)didFinishEditingUserInfoNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if ([self.momentProfileDelegate respondsToSelector:@selector(didForwardUserInfo:)]) {
            [self.momentProfileDelegate didForwardUserInfo:userInfo];
        }
    });
}

- (void)getForwardMomentDoneNotification:(NSNotification *)notification {
    NSDictionary *momentDict = [[notification userInfo] objectForKey:@"data"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didForwardUpdate:momentDict];
    });
}

- (void)weitoutiaoPostSuccess:(NSNotification *)notification {
    NSDictionary *dataDict = [notification userInfo];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didWeitoutiaoForwardUpdate:dataDict];
    });
}

- (void)postMessageDidFinish:(NSNotification *)notification {
    NSString *groupID = [[notification userInfo] tt_stringValueForKey:@"group_id"];

    FRNewCommentStructModel *commentModel = [[notification userInfo] objectForKey:@"comment"];
    NSMutableDictionary *commentDict;
    if ([commentModel isKindOfClass:[FRNewCommentStructModel class]]) {
        commentDict = [[NSMutableDictionary alloc] init];
        [commentDict setValue:commentModel.text forKey:@"content"];
        [commentDict setValue:commentModel.create_time forKey:@"create_time"];
        [commentDict setValue:commentModel.digg_count forKey:@"digg_count"];
        [commentDict setValue:commentModel.id forKey:@"id"];
        [commentDict setValue:commentModel.is_pgc_author forKey:@"is_pgc_author"];
        [commentDict setValue:commentModel.user_digg forKey:@"user_digg"];
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setValue:commentModel.user_profile_image_url forKey:@"avatar_url"];
        [userDict setValue:commentModel.is_blocked forKey:@"is_blocked"];
        [userDict setValue:commentModel.is_blocking forKey:@"is_blocking"];
        [userDict setValue:commentModel.user_name forKey:@"name"];
        [userDict setValue:commentModel.user_name forKey:@"screen_name"];
        [userDict setValue:commentModel.user_id forKey:@"user_id"];
        [userDict setValue:commentModel.user_auth_info forKey:@"user_auth_info"];
        [userDict setValue:commentModel.verified_reason forKey:@"verified_reason"];
        [commentDict setValue:userDict forKey:@"user"];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didPublishComment:commentDict momentID:groupID];
    });
}

- (void)didDiggMoment:(NSNotification *)notification {
    NSString *momentID = [[notification userInfo] objectForKey:@"id"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didDigUpdate:momentID];
    });
}

- (void)didCancelDiggMoment:(NSString *)mid {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didCancelDidUpdate:mid];
    });
}

- (void)didDiggComment:(NSNotification *)notification {
    NSString *momentID = [[notification userInfo] objectForKey:@"comment_id"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didDigUpdate:momentID];
    });
}

- (void)cancelDiggComment:(NSNotification *)notification {
    NSString *momentID = [[notification userInfo] objectForKey:@"comment_id"];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didCancelDidUpdate:momentID];
    });
}

- (void)didDiggThread:(NSNotification *)notification {
    NSString *threadID = [[notification userInfo] objectForKey:kFRThreadIDKey];
    if (isEmptyString(threadID)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didDigUpdate:threadID];
    });
}

- (void)cancelDiggThread:(NSNotification *)notification {
    NSString *threadID = [[notification userInfo] objectForKey:kFRThreadIDKey];
    if (![threadID isKindOfClass:[NSString class]]) {
        if ([threadID respondsToSelector:@selector(stringValue)]) {
            threadID = [threadID performSelector:@selector(stringValue)];
        } else {
            threadID = nil;
        }
    }
    if (isEmptyString(threadID)) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.momentProfileDelegate didCancelDidUpdate:threadID];
    });
}

- (void)didDiggShortVideo:(NSNotification *)notification {
    NSString *groupID = [[notification userInfo] tt_stringValueForKey:@"group_id"];
    if (isEmptyString(groupID)) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        BOOL userDigg = [[notification userInfo] tt_boolValueForKey:@"user_digg"];
        if (userDigg) {
            [self.momentProfileDelegate didDigUpdate:groupID];
        } else {
            [self.momentProfileDelegate didCancelDidUpdate:groupID];   // 这名字都拼错……
        }
    });
}

- (void)receiveDeleteMomentNotification:(NSNotification *)notification {
    NSString *momentID = [[notification userInfo] tt_stringValueForKey:@"id"];
    if (!isEmptyString(momentID)) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.momentProfileDelegate didDeleteUpdate:momentID];
        });
    }
}

- (void)receiveDeleteShortVideoNotification:(NSNotification *)notification {
    NSString *groupID = [[notification userInfo] tt_stringValueForKey:kTSVShortVideoDeleteUserInfoKeyGroupID];
    if (!isEmptyString(groupID)) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.momentProfileDelegate didDeleteUpdate:groupID];
        });
    }
}

- (void)receiveMomentCommentNeedDeleteNotification:(NSNotification *)notification {
    //@{@"cid":@(dongtaiCommentID), @"mid":@(replyDongtaiID)
    NSString *commentID = [[notification userInfo] tt_stringValueForKey:@"cid"];
    if (!isEmptyString(commentID)) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.momentProfileDelegate didDeleteComment:commentID];
        });
    }
}

- (void)receiveThreadCommentNeedDeleteNotification:(NSNotification *)notification {
    NSString *threadID = [[notification userInfo] objectForKey:@"thread_id"];
    if (!isEmptyString(threadID)) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.momentProfileDelegate didDeleteCommentInThread:threadID];
        });
    }
}

- (void)didReceiveBlockUserNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *uid = [userInfo valueForKey:@"user_id"];
    BOOL isBlocking = [TTProfileShareService isBlockingForUID:uid];
    [self block:[userInfo valueForKey:@"user_id" ] isBlock:isBlocking];
}

- (void)didReceiveReportUserNotification:(NSNotification *)notification {
    [self report:notification.userInfo];
}

- (void)didReceiveDetailDeleteUGCMovieNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.momentProfileDelegate deleteDetailUGCMovie:notification.userInfo];
    });
}

- (void)didReceiveDeleteThreadNotification:(NSNotification *)notification {
    
    NSString *threadID = @([notification.userInfo tt_longlongValueForKey:kTTForumThreadID]).stringValue;
    [self.momentProfileDelegate didDeleteThread:threadID];
}

#pragma mark - Util Methods

- (NSString *)shareLabelWithShareType:(TTActivityType)activityType {
    switch (activityType) {
        case TTActivityTypeWeixinShare:
            return @"share_weixin";
        case TTActivityTypeWeixinMoment:
            return @"share_weixin_moments";
        case TTActivityTypeQQShare:
            return @"share_qq";
        case TTActivityTypeQQZone:
            return @"share_qzone";
        case TTActivityTypeSinaWeibo:
            return @"share_weibo";
        case TTActivityTypeDingTalk:
            return @"share_dingding";
        case TTActivityTypeWeitoutiao:
            return @"share_weitoutiao";
        default:
            return nil;
    }
}

@end
