//
//  TTVideoAdCellShareController.m
//  Article
//
//  Created by xiangwu on 2017/2/21.
//
//

#import "TTVideoAdCellShareController.h"

#import "Article.h"
#import "ArticleShareManager.h"
#import "ExploreCellViewBase.h"
#import "ExploreItemActionManager.h"
#import "ExploreMixListDefine.h"

#import "SSActivityView.h"
#import "TTActionSheetController.h"
#import "TTActivityShareManager.h"
#import "TTActivityShareSequenceManager.h"

#import "TTFeedDislikeView.h"
#import "TTFeedDislikeWord.h"
#import "TTIndicatorView.h"
#import "TTPlatformSwitcher.h"
#import "TTReportManager.h"
//#import "TTRepostViewController.h"

//#import "TTRepostOriginModels.h"

#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"


//#import "TTShareToRepostManager.h"
#import "TTVideoCommon.h"
#import <TTServiceKit/TTServiceCenter.h>
#import <TTSettingsManager/TTSettingsManager.h>

#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAdManagerProtocol.h"

#import "TTActivityShareSequenceManager.h"
#import "TTTrackerProxy.h"


extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTVideoAdCellShareController () <SSActivityViewDelegate, TTActivityShareManagerDelegate>

@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;
@property (nonatomic, strong) TTActivityShareManager *activityActionManager;
@property (nonatomic, strong) SSActivityView *phoneShareView;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@end

@implementation TTVideoAdCellShareController

- (instancetype)init {
    self = [super init];
    if (self) {
        _shareBtn = [[ArticleVideoActionButton alloc] init];
        _shareBtn.minHeight = [TTDeviceUIUtils tt_newPadding:28.f];
        _shareBtn.minWidth = 44.f;
        _shareBtn.centerAlignImage = YES;
        [_shareBtn addTarget:self action:@selector(shareBtnClicked:)];
    }
    return self;
}

- (void)refreshUI {
    [self.shareBtn setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateHighlighted];
    [self.shareBtn updateThemes];
}

- (void)shareBtnClicked:(id)sender {
    Article *article = self.orderedData.article;
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
        _activityActionManager.delegate = self;
    }
    
    NSNumber *adID = isEmptyString(self.orderedData.ad_id) ? nil : @(self.orderedData.ad_id.longLongValue);
    NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:_activityActionManager
                                                          setArticleCondition:article
                                                                         adID:adID
                                                                   showReport:YES];
    NSMutableArray *group1 = [NSMutableArray array];
    NSMutableArray *group2 = [NSMutableArray array];
    
    BOOL adFavorite = YES;
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    if (adModel != nil && adModel.adType == ExploreActionTypeApp) {
        adFavorite = NO;
    }
    if (adFavorite) {
        TTActivity *favorite = [TTActivity activityOfVideoFavorite];
        favorite.selected = article.userRepined;
        [group2 addObject:favorite];
    }
    
    BOOL isVideoAdCellDislikeEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"video_ad_cell_dislike" defaultValue:@NO freeze:NO] boolValue];
    if (isVideoAdCellDislikeEnabled) {
        TTActivity *dislike = [TTActivity activityOfDislike];
        [group2 addObject:dislike];
    }
    
    for (TTActivity *activity in activityItems) {
        if (activity.activityType < TTActivityTypeSystem) {
            [group1 addObject:activity];
        } else if (activity.activityType == TTActivityTypeCopy || activity.activityType == TTActivityTypeReport) {
            [group2 addObject:activity];
        }
    }
    
    _phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    if (self.orderedData.article) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        [adManagerInstance share_showInAdPage:self.orderedData.ad_id groupId:self.orderedData.article.groupModel.groupID];
    }
    [_phoneShareView showActivityItems:@[group1, group2]];
    [self sendVideoShareTrackWithItemType:TTActivityTypeShareButton];
}

#pragma mark -- Track

+ (NSString *)labelNameForShareActivityType:(TTActivityType)activityType {
    return [TTVideoCommon videoListlabelNameForShareActivityType:activityType];
}

- (void)sendVideoShareTrackWithItemType:(TTActivityType)itemType {
    NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoList];
    NSString *label = [[self class] labelNameForShareActivityType:itemType];
    NSMutableDictionary *extValueDic = [NSMutableDictionary dictionary];
    if (!isEmptyString(self.orderedData.ad_id)) {
        extValueDic[@"ext_value"] = self.orderedData.ad_id;
    }
    if ([self.orderedData.article hasVideoSubjectID]) {
        extValueDic[@"video_subject_id"] = self.orderedData.article.videoSubjectID;
    }
    wrapperTrackEventWithCustomKeys(tag, label, uniqueID, @"video", extValueDic);
}


- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.orderedData.article.uniqueID > 0) {
        [dic setObject:@(self.orderedData.article.uniqueID) forKey:@"item_id"];
    }
    if (self.orderedData.categoryID) {
        [dic setObject:self.orderedData.categoryID forKey:@"category_id"];
    }
    if ([self getRefer]) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:[self getRefer]] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}

- (NSUInteger)getRefer {
    return [self.cellView.cell refer];
}

#pragma mark - favorite

- (void)toggleFavorite
{
    Article *article = self.orderedData.article;
    if (!_itemActionManager) {
        self.itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    
    if (article.userRepined == YES) {
        __weak __typeof__(self) wself = self;
        [self.itemActionManager unfavoriteForOriginalData:article adID:nil finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if (wself.orderedData.article.uniqueID == article.uniqueID) {
                    //[wself updateActionButtons:essayData];
                }
            }
        }];
        NSString * tipMsg = NSLocalizedString(@"取消收藏", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
        }
        wrapperTrackEvent(@"xiangping", @"video_list_unfavorite");
    }
    else {
        __weak __typeof__(self) wself = self;
        [self.itemActionManager favoriteForOriginalData:article adID:nil finishBlock:^(id userInfo, NSError *error) {
            if (!error) {
                if (wself.orderedData.article.uniqueID == article.uniqueID) {
                    //[wself updateActionButtons:essayData];
                }
            }
        }];
        NSString * tipMsg = NSLocalizedString(@"收藏成功", nil);
        UIImage * image = [UIImage themedImageNamed:@"doneicon_popup_textpage.png"];
        if (!isEmptyString(tipMsg)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
        }
        wrapperTrackEvent(@"xiangping", @"video_list_favorite");
    }
}

#pragma mark - dislike

- (void)dislikeActivityClicked {
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.article.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.shareBtn.center;
    [dislikeView showAtPoint:point
                    fromView:self.shareBtn
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
    [self trackAdDislikeClick];
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    NSArray *filterWords = [dislikeView selectedWords];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
    [self trackAdDislikeConfirm:filterWords];
}

- (void)trackAdDislikeClick
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        [self trackWithTag:@"embeded_ad" label:@"dislike" extra:nil];
    }
}

- (void)trackAdDislikeConfirm:(NSArray *)filterWords
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        NSMutableDictionary *extra = [@{} mutableCopy];
        [extra setValue:filterWords forKey:@"filter_words"];
        [self trackWithTag:@"embeded_ad" label:@"final_dislike" extra:@{@"ad_extra_data": [extra JSONRepresentation]}];
    }
}

- (void)trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSCParameterAssert(tag != nil);
    NSCParameterAssert(label != nil);
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:self.orderedData.ad_id forKey:@"value"];
    [events setValue:self.orderedData.log_extra forKey:@"log_extra"];
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTracker eventData:events];
}

#pragma mark - SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    if (view != _phoneShareView) {
        return;
    }
//    if (itemType == TTActivityTypeWeitoutiao) {
//        NSDictionary * extraDic = nil;
//        if (!isEmptyString(self.orderedData.article.groupModel.itemID)) {
//            extraDic = @{@"item_id":self.orderedData.article.groupModel.itemID};
//        }
//        wrapperTrackEventWithCustomKeys(@"list_share", @"share_weitoutiao", self.orderedData.article.groupModel.groupID, nil, extraDic);
//        [self forwardToWeitoutiao];
//        if (ttvs_isShareIndividuatioEnable()){
//            [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//        }
//
//    }
    if (itemType == TTActivityTypeDislike) {
        [self dislikeActivityClicked];
    } else if (itemType == TTActivityTypeFavorite) {
        [self toggleFavorite];
    } else if (itemType == TTActivityTypeReport) {
        self.actionSheetController = [[TTActionSheetController alloc] init];
        if (!isEmptyString(self.orderedData.ad_id)) {
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportADOptions]];
        }
        else
        {
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
        }
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            if (parameters[@"report"]) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.orderedData.article.groupModel.groupID;
                model.videoID = self.orderedData.article.videoID;
                
                [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeAD reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderedData.categoryID) contentModel:model extraDic:nil animated:YES];
            }
        }];
    } else {
        BOOL isVideo = [self.orderedData.article isVideoSubject] && [self.orderedData.article hasVideo];
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
        [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor:self.cellView] sourceObjectType:isVideo?TTShareSourceObjectTypeVideoList:TTShareSourceObjectTypeVideoListLargePic uniqueId:uniqueID adID:self.orderedData.ad_id platform:TTSharePlatformTypeOfMain groupFlags:self.orderedData.article.groupFlags];
        [self sendVideoShareTrackWithItemType:itemType];
        self.phoneShareView= nil;
    }
}

//- (void)forwardToWeitoutiao {
//    //实际转发对象为文章，操作对象为文章
//    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                    originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.orderedData.article]
//                                                                     originThread:nil
//                                                                 originShortVideoOriginalData:nil
//                                                                operationItemType:TTRepostOperationItemTypeArticle
//                                                                  operationItemID:self.orderedData.article.itemID
//                                                                   repostSegments:nil];
//}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(NSError *)error {
//    if (!error) {
//        [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                   repostType:TTThreadRepostTypeArticle
//                                                            operationItemType:TTRepostOperationItemTypeArticle
//                                                              operationItemID:self.orderedData.article.itemID
//                                                                originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.orderedData.article]
//                                                                 originThread:nil
//                                                               originShortVideoOriginalData:nil
//                                                            originWendaAnswer:nil
//                                                               repostSegments:nil];
//    }
}

@end
