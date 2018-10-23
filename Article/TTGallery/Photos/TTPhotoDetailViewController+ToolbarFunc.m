//
//  TTPhotoDetailViewController+ToolbarFunc.m
//  Article
//
//  Created by yuxin on 4/19/16.
//
//

#import "TTPhotoDetailViewController+ToolbarFunc.h"
#import "NewsDetailLogicManager.h"
#import "ArticleShareManager.h"
#import "ArticleFriend.h"
#import "ExploreDetailManager.h"
#import "TTReportManager.h"
#import "TTNavigationController.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "FriendDataManager.h"
#import "ExploreEntryManager.h"

#import <objc/runtime.h>
#import "TTArticleCategoryManager.h"
#import "TTModalContainerController.h"
#import "TTPhotoNewCommentViewController.h"
#import "TTAdPromotionManager.h"
#import <TTIndicatorView.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
//#import "TTShareToRepostManager.h"
#import "TTActivityShareSequenceManager.h"
#import "SSCommentInputHeader.h"

//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
//#import <TTRepostServiceProtocol.h>
//#import "TTRepostService.h"
#import "TTKitchenHeader.h"
#import "TTShareConstants.h"
#import <TTActivityContentItemProtocol.h>
#import <TTWechatTimelineContentItem.h>
#import <TTWechatContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
//#import <TTDingTalkContentItem.h>
#import "TTForwardWeitoutiaoContentItem.h"
#import <TTForwardWeitoutiaoActivity.h>
#import <TTDirectForwardWeitoutiaoActivity.h>
#import "TTDirectForwardWeitoutiaoContentItem.h"
//#import "TTRepostService.h"
//#import "TTCopyContentItem.h"
//#import <TTSystemContentItem.h>
#import "TTShareManager.h"
#import "TTShareMethodUtil.h"
#import "ArticleMomentProfileViewController.h"
#import "ExploreMomentDefine.h"

extern BOOL ttvs_isShareIndividuatioEnable(void);

@interface TTPhotoDetailViewController ()<TTModalContainerDelegate, TTActivityShareManagerDelegate,TTPhotoNewCommentViewControllerDelegate,TTShareManagerDelegate>

@property (nonatomic, strong) TTShareManager *shareManager;

@property (nonatomic, strong) TTCommentWriteView *commentWriteView;

@end

@implementation TTPhotoDetailViewController (ToolbarFunc)

#pragma mark - 关联变量

SYNTHESE_CATEGORY_PROPERTY_STRONG(shareManager, setShareManager, TTShareManager *);


#pragma mark Toolbar func 相关

- (void)_backActionFired:(id)sender {
    
    self.backButtonTouched = YES;
    
    if (self.detailModel.needQuickExit || [SSCommonLogic detailQuickExitEnabled]) {
        [self fastPopToLastCorrectController];
    }
    else {
        if ([SSCommonLogic appGallerySlideOutSwitchOn]) {
            [self.containerDelegate ttPhotoDetailViewBackBtnClick];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}

- (void)_moreActionFired:(id)sender  {
    
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = self.detailModel.article.articleType == ArticleTypeNativeContent;
        self.activityActionManager.delegate = self;
    }
    
    NSMutableArray * activityItems = @[].mutableCopy;
    if ([self.viewModel.articleInfoManager needShowAdShare]) {
        NSMutableDictionary *shareInfo = [self.viewModel.articleInfoManager makeADShareInfo];
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:NO];
    } else {
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:[self.detailModel article] adID:[self.detailModel adID] showReport:NO];
    }
    
    Article * currentArticle = [self.detailModel article];
        
    TTActivity * nightMode = [TTActivity activityOfNightMode];
    [activityItems addObject:nightMode];
    
    
    
    //非视频文章，举报放在最后
    TTActivity * reportActivity = [TTActivity activityOfReport];
    [activityItems addObject:reportActivity];
    
    
    if (self.viewModel.articleInfoManager.promotionModel) {
        TTActivity *proActivity = [TTActivity activityWithModel:self.viewModel.articleInfoManager.promotionModel];
        [activityItems insertObject:proActivity atIndex:0];
        wrapperTrackEventWithCustomKeys(@"setting_btn", @"show", self.detailModel.article.groupModel.groupID, nil, nil);
    }
    
    if (self.moreSettingActivityView) {
        self.moreSettingActivityView = nil;
    }
    self.moreSettingActivityView = [[SSActivityView alloc] init];
    [self.moreSettingActivityView refreshCancelButtonTitle:@"取消"];
    self.moreSettingActivityView.delegate = self;
    [self.moreSettingActivityView setActivityItemsWithFakeLayout:activityItems];
    //默认图集不出分享板广告,故ad_id传1
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
    [self.moreSettingActivityView show];
    
    self.shareSourceType = TTShareSourceObjectTypeArticleTop;
}

- (void)_writeCommentActionFired:(id)sender {
    BOOL switchToEmojiInput = (sender == self.toolbarView.emojiButton);
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
                                                             @"status" : @"no_keyboard",
                                                             @"source" : @"comment"
                                                             }];
    }

    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:self.detailModel.article.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:[NSNumber numberWithBool:self.detailModel.article.hasImage] forKey:kQuickInputViewConditionHasImageKey];
    [condition setValue:self.detailModel.adID forKey:kQuickInputViewConditionADIDKey];
    [condition setValue:self.detailModel.article.mediaInfo[@"media_id"] forKey:kQuickInputViewConditionMediaID];

    NSString *fwID = self.detailModel.article.groupModel.groupID;

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
         *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];
    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;

    // writeCommentView 禁表情
    self.commentWriteView.banEmojiInput = self.commentViewController.banEmojiInput;

    [self.commentWriteView showInView:nil animated:YES];

    double readPct = (float)(self.maximumVisibleIndex) / (float)self.detailModel.article.galleries.count;
    double currentReadPct = (float)self.currentVisibleIndex / (float)self.detailModel.article.galleries.count;

    [NewsDetailLogicManager trackEventTag:@"comment" label:@"write_button" value:@(self.detailModel.article.uniqueID) extValue:self.detailModel.adID fromID:nil params:@{@"location":currentReadPct>1 ? @"related":@"content"} groupModel:self.detailModel.article.groupModel];

    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self.detailModel.sharedDetailManager currentStayDuration]);
    self.commentViewController.readQuality = qualityModel;
    //   _hasShowNatant = YES;
}

- (void)_showCommentActionFired:(id)sender {
 
    if (0 == self.detailModel.article.commentCount) {
        self.commentViewController.automaticallyTriggerCommentAction = YES;
    }
    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    double readPct = (float)(self.maximumVisibleIndex) / (float)self.detailModel.article.galleries.count;
    double currentReadPct = (float)(self.currentVisibleIndex) / (float)self.detailModel.article.galleries.count;
    
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self.dataSource stayPageTimeInterValForDetailView:self]);
    self.commentViewController.readQuality = qualityModel;
    
    TTPhotoNewCommentViewController *commentViewController = [[TTPhotoNewCommentViewController alloc] initViewModel:self.detailModel];
    commentViewController.infoManager = self.commentViewController.infoManager;
    commentViewController.readQuality = qualityModel;
    commentViewController.delegate = self;
    TTModalContainerController *navVC = [[TTModalContainerController alloc] initWithRootViewController:commentViewController];
    navVC.containerDelegate = self;
    commentViewController.automaticallyTriggerCommentAction = !self.detailModel.article.commentCount;
    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.hasCommentVCAppear = YES;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:navVC animated:NO completion:nil];
        self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    else {
        navVC.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:navVC animated:NO completion:nil];
    }
    
    [NewsDetailLogicManager trackEventTag:@"detail" label:@"comment_button" value:@(self.detailModel.article.uniqueID) extValue:self.detailModel.adID fromID:nil params:@{@"location":currentReadPct>1 ? @"related":@"content"} groupModel:self.detailModel.article.groupModel];
    
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:3];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extra setValue:@"pic" forKey:@"source"];
    [extra setValue:@"click" forKey:@"action"];
    wrapperTrackEventWithCustomKeys(@"enter_comment", [NSString stringWithFormat:@"click_%@",self.detailModel.categoryID], self.detailModel.article.groupModel.groupID, @"click", extra);
    
    [NewsDetailLogicManager trackEventTag:@"slide_detail" label:@"handle_open_drawer" value:@(self.detailModel.article.uniqueID) extValue:self.detailModel.adID fromID:nil params:@{@"location":currentReadPct>1 ? @"related":@"content"} groupModel:self.detailModel.article.groupModel];
    
    self.commentShowDate = [NSDate date];
}

- (void)_collectActionFired:(id)sender {
    if (!TTNetworkConnected()){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    self.toolbarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
    self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    self.toolbarView.collectButton.alpha = 1.f;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        self.toolbarView.collectButton.alpha = 0.f;
    } completion:^(BOOL finished){
        
        [self triggerFavoriteAction];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.toolbarView.collectButton.alpha = 1.f;
        } completion:^(BOOL finished){
        }];
    }];
}

- (void)triggerFavoriteAction {
    
    double currentReadPct = (float)(self.currentVisibleIndex) / (float)self.detailModel.article.galleries.count;

    //    [self.detailModel.sharedDetailManager changeFavoriteButtonClicked:currentReadPct];
    // 调用新增方法，传入控制器，以吊起登录弹窗
    [self.detailModel.sharedDetailManager changeFavoriteButtonClicked:currentReadPct viewController:self];
    //AB测结束 下掉代码 @zengruihuan
}

- (void)_shareActionFired:(id)sender {
    //点击分享按钮统计
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = self.detailModel.article.articleType == ArticleTypeNativeContent;
        self.activityActionManager.delegate = self;
    }
    NSMutableArray * activityItems = @[].mutableCopy;
    if ([self.viewModel.articleInfoManager needShowAdShare]) {
        NSMutableDictionary *shareInfo = [self.viewModel.articleInfoManager makeADShareInfo];
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:NO];
    } else {
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:[self.detailModel article] adID:[self.detailModel adID] showReport:NO];
    }
    
    if (self.viewModel.articleInfoManager.promotionModel) {
        TTActivity *proActivity = [TTActivity activityWithModel:self.viewModel.articleInfoManager.promotionModel];
        [activityItems insertObject:proActivity atIndex:0];
        wrapperTrackEventWithCustomKeys(@"share_btn", @"show", self.detailModel.article.groupModel.groupID, nil, nil);
    }
    
//    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCShareBoardDisplayRepost]) {
//        if (!self.shareManager) {
//            self.shareManager = [[TTShareManager alloc] init];
//            self.shareManager.delegate = self;
//
//        }
//        NSArray *contentItems = [self forwardSharePanelContentItemsWithTTActivities:activityItems];
//        [self.shareManager displayForwardSharePanelWithContent:contentItems];
//    } else {
        self.phoneShareView = [[SSActivityView alloc] init];
        self.phoneShareView.delegate = self;
        self.phoneShareView.activityItems = activityItems;
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        [adManagerInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
        [self.phoneShareView showOnViewController:self useShareGroupOnly:NO];
//    }
    
    //点击分享按钮统计
    double currentReadPct = (float)(self.currentVisibleIndex) / (float)self.detailModel.article.galleries.count;
    [self.tracker tt_sendDetailTrackEventWithTag:@"detail" label:@"share_button" extra:@{@"location":currentReadPct>1 ? @"related":@"content"}];
    
    self.shareSourceType = TTShareSourceObjectTypeArticle;
}

- (UIView *)commentWriteView {
    return objc_getAssociatedObject(self, @selector(commentWriteView));
}

- (void)setCommentWriteView:(UIView *)commentWriteView {
    objc_setAssociatedObject(self, @selector(commentWriteView), commentWriteView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - TTCommentWriteManagerDelegate

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    if(![responseData objectForKey:@"error"])  {
        //动画推进
        [commentView dismissAnimated:YES];
        commentWriteManager.delegate = nil;

        double currentReadPct = (float)self.currentVisibleIndex / (float)self.detailModel.article.galleries.count;

        [NewsDetailLogicManager trackEventTag:@"slide_detail" label:@"handle_open_drawer" value:@(self.detailModel.article.uniqueID) extValue:self.detailModel.adID fromID:nil params:@{@"location":currentReadPct>1 ? @"related":@"content"} groupModel:self.detailModel.article.groupModel];


        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:[responseData objectForKey:@"data"]];

        TTPhotoNewCommentViewController *commentViewController = [[TTPhotoNewCommentViewController alloc] initViewModel:self.detailModel];
        commentViewController.infoManager = self.commentViewController.infoManager;
        commentViewController.readQuality = self.commentViewController.readQuality;
        commentViewController.delegate = self;
        TTModalContainerController *navVC = [[TTModalContainerController alloc] initWithRootViewController:commentViewController];
        self.modalContainerController = navVC;
        navVC.containerDelegate = self;
        commentViewController.automaticallyTriggerCommentAction = NO;
        navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.hasCommentVCAppear = YES;
        if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
            self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self presentViewController:navVC animated:NO completion:^{
                [commentViewController insertCommentWithDict:data];
            }];
            self.view.window.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        else {
            navVC.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:navVC animated:NO completion:^{
                [commentViewController insertCommentWithDict:data];
            }];
        }

        self.commentShowDate = [NSDate date];
    }
}

- (void)fastPopToLastCorrectController
{
    UIViewController *needDisplayVC = nil;
    for (NSInteger i = self.navigationController.viewControllers.count - 1; i > 0; i--) {
        UIViewController *vc = self.navigationController.viewControllers[i];
        if (!vc.ttDragToRoot && (i > 0)) {
            needDisplayVC = self.navigationController.viewControllers[i - 1];;
            break;
        }
    }
    if (needDisplayVC) {
        [self.navigationController popToViewController:needDisplayVC animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - TTModalContainerDelegate
- (void)didDismissModalContainerController:(TTModalContainerController *)container {
    self.hasCommentVCAppear = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
}

 - (void)ttPhotoNewCommentViewControllerDisappear:(TTPhotoNewCommentViewController *)photoCommentVC
{
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
}

- (void)ttPhotoNewCommentViewControllerAppear:(TTPhotoNewCommentViewController *)photoCommentVC
{
    
    self.commentShowDate = [NSDate date];
}

#pragma mark - share
- (void)currentGalleryShareUseActivityController {
    //图集分享单张图片，带水印
    [self.activityActionManager clearCondition];
    if (!self.activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.miniProgramEnable = self.detailModel.article.articleType == ArticleTypeNativeContent;
    }
    
    NSMutableArray * activityItems;
    UIImage *galleryImage = [self.nativeDetailView currentNativeGalleryImage];
    UIImage *maskImage = [UIImage themedImageNamed:@"photo_watermark.png"];
    UIEdgeInsets edge = UIEdgeInsetsMake(0, 0, 12.f, 9.f);
    CGFloat left = galleryImage.size.width - maskImage.size.width - edge.right;
    CGFloat top = galleryImage.size.height - maskImage.size.height - edge.bottom;
    CGFloat width = maskImage.size.width;
    CGFloat height = maskImage.size.height;
    //对长条图做简单适配
    if (left < 0) {
        width = galleryImage.size.width/2 - edge.right/2;
        height = width * maskImage.size.height / maskImage.size.width;
        left = galleryImage.size.width/2;
        top = galleryImage.size.height - height - edge.bottom/2;
    }
    CGRect maskRect = CGRectMake(left, top, width, height);
    UIImage *galleryImageWithMask = [galleryImage tt_imageWithMaskImage:maskImage inRect:maskRect];
    
    activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setNativeGalleryImage:galleryImageWithMask webGalleryURL:nil];
    
    self.currentGalleryShareView = [[SSActivityView alloc] init];
    self.currentGalleryShareView.delegate = self;
    self.currentGalleryShareView.activityItems = activityItems;
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
    [self.currentGalleryShareView showOnViewController: self
                                     useShareGroupOnly:YES];
    
    self.shareSourceType = TTShareSourceObjectTypeSingleGallery;
}


- (NSString *)currentShowGalleryURL
{
    return self.currentGalleryUrl;
}

- (void)hiddenMoreSettingActivityView
{
    [self.moreSettingActivityView cancelButtonClicked];
}

#pragma mark - SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    //分享数量统计
    if (itemType > TTActivityTypeNone && itemType <= TTActivityTypeShareButton){
        [Answers logCustomEventWithName:@"share" customAttributes:@{@"photo" : [NSString stringWithFormat:@"%d",itemType]}];
        [[TTMonitor shareManager] trackService:@"shareboard_success" status:itemType extra:@{@"source": @"photo"}];
    }
    Article *currentArticle = self.detailModel.article;
    if (view == self.phoneShareView) {
//        if (itemType == TTActivityTypeWeitoutiao) {
//            NSDictionary * extraDic = nil;
//            if (!isEmptyString(self.detailModel.article.groupModel.itemID)) {
//                extraDic = @{@"item_id":self.detailModel.article.groupModel.itemID};
//            }
//            wrapperTrackEventWithCustomKeys(@"detail_share", @"share_weitoutiao", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extraDic);
//            [self _forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//
//        }
        if (itemType == TTActivityTypePromotion) {
            [TTAdPromotionManager handleModel:self.viewModel.articleInfoManager.promotionModel  condition:nil];
            wrapperTrackEventWithCustomKeys(@"share_btn", @"click", self.detailModel.article.groupModel.groupID, nil, nil);
        } else {
            NSString *adId = nil;
            if ([self.detailModel.adID longLongValue] > 0) {
                adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
            }
            NSString *groupId = [NSString stringWithFormat:@"%lld", currentArticle.uniqueID];
            [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType: self.shareSourceType uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:currentArticle.groupFlags];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.shareSourceType];
            if (itemType == TTActivityTypeNone) {
                tag =   @"slide_detail" ;
            }
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            [self.tracker tt_sendDetailTrackEventWithTag:tag label:label extra:nil];
            
            self.phoneShareView = nil;
        }
    } else if (view == self.moreSettingActivityView) {
//        if (itemType == TTActivityTypeWeitoutiao) {
//            [self _forwardToWeitoutiao];
//            if (ttvs_isShareIndividuatioEnable()){
//                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareActivitySequenceFirstActivity:itemType];
//            }
//        }
        if (itemType == TTActivityTypeFontSetting){
            [self.moreSettingActivityView fontSettingPressed];
        }
        else if (itemType == TTActivityTypeReport){
            [self.moreSettingActivityView cancelButtonClicked];

            self.actionSheetController = [[TTActionSheetController alloc] init];

            [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
            
            [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
                if (parameters[@"report"]) {
                    TTReportContentModel *model = [[TTReportContentModel alloc] init];
                    model.groupID = self.detailModel.article.groupModel.groupID;
                    model.itemID = self.detailModel.article.groupModel.itemID;
                    model.aggrType = @(self.detailModel.article.groupModel.aggrType);
                    
                    [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeGallery reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:YES];
                }
            }];
            
            
            NSString *tag = [currentArticle isImageSubject]?@"slide_detail":@"detail";
            wrapperTrackEvent(tag, @"report_button");
        }
        else if (itemType == TTActivityTypeFavorite) {
            [self triggerFavoriteAction];
        }
        else if (itemType == TTActivityTypePromotion) {
            [TTAdPromotionManager handleModel:self.viewModel.articleInfoManager.promotionModel  condition:nil];
            wrapperTrackEventWithCustomKeys(@"setting_btn", @"click", self.detailModel.article.groupModel.groupID, nil, nil);
        }
        else { // Share
            NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.article.uniqueID];
            
            [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:self.shareSourceType uniqueId:groupId adID:nil platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.article.groupFlags];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.shareSourceType];
            if (itemType == TTActivityTypeNone) {
                tag =  @"slide_detail";
                NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
                [self.tracker tt_sendDetailTrackEventWithTag:tag label:label extra:nil];
                
                self.moreSettingActivityView = nil;
            }
            
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            [self.tracker tt_sendDetailTrackEventWithTag:tag label:label extra:nil];
//            [self recordShareEvent:itemType];

        }
    }
    else if (view == self.currentGalleryShareView) {
        NSString *fromSource = self.detailModel.clickLabel;
        self.activityActionManager.groupModel = [self.detailModel article].groupModel;
        self.activityActionManager.clickSource = fromSource;
        [self.activityActionManager performActivityActionByType:itemType
                                               inViewController:[TTUIResponderHelper topViewControllerFor: self]
                                               sourceObjectType:TTShareSourceObjectTypeSingleGallery
                                                       uniqueId:[self.detailModel article].groupModel.groupID
                                                           adID:nil
                                                       platform:TTSharePlatformTypeOfMain
                                                     groupFlags:nil];
        NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:self.shareSourceType];
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
        [self.tracker tt_sendDetailTrackEventWithTag:tag label:label extra:nil];
//        [self recordShareEvent:itemType];
    }
}

- (void)recordShareEvent:(TTActivityType) itemType {

    NSMutableDictionary *dict = [self.detailModel.gdExtJsonDict mutableCopy];
    dict[@"source"] = nil;
    dict[@"parent_enterfrom"] = nil;
    dict[@"from_gid"] = nil;
    dict[@"enterfrom_answerid"] = nil;
    dict[@"author_id"] = nil;
    dict[@"article_type"] = nil;
    dict[@"origin_source"] = nil;
    dict[@"event_type"] = @"house_app2c_v2";

    dict[@"enter_from"] = self.detailModel.gdExtJsonDict[@"enter_from"];
    if (dict[@"enter_from"] == nil) {
        dict[@"enter_from"] = @"be_null";
    }
    [dict setValue:self.detailModel.originalGroupID forKey:@"group_id"];
    [dict setValue:self.detailModel.originalGroupID forKey:@"ansid"];
    [dict setValue:self.detailModel.originalGroupID forKey:@"qid"];
    [dict setValue:@"detail" forKey:@"position"];
    dict[@"category_name"] = self.detailModel.gdExtJsonDict[@"category_name"];
    if (dict[@"category_name"] == nil) {
        dict[@"category_name"] = @"favorite";
    }

    [dict setValue:[[self class] sharePlatformByRequestType: itemType] forKey:@"share_platform"];
    [TTTracker eventV3:@"rt_share_to_platform" params:[dict copy]];
}

+ (NSString*)sharePlatformByRequestType:(TTActivityType) activityType {
    switch (activityType) {
        case TTActivityTypeWeixinMoment:
            return @"weixin_moments";
            break;
        case TTActivityTypeWeixinShare:
            return @"weixin";
            break;
        case TTActivityTypeQQShare:
            return @"qq";
            break;
        case TTActivityTypeQQZone:
            return @"qzone";
            break;
        default:
            return @"be_null";
    }
    return @"be_null";
}

- (void)orignialActionFired:(id)sender {
    NSString *mediaID = [self.detailModel.article.mediaInfo[@"media_id"] stringValue];
    NSString *enterItemId = self.detailModel.article.groupModel.itemID;
    [ArticleMomentProfileViewController openWithMediaID:mediaID enterSource:kPGCProfileEnterSourceGalleryArticleTopAuthor itemID:enterItemId];
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(NSError *)error {
    if (!error && nil == activityShareManager.shareImageStyleImage && isEmptyString(activityShareManager.shareImageStyleImageURL)) {
        NSLog(@"share image");
//        [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                   repostType:TTThreadRepostTypeArticle
//                                                            operationItemType:TTRepostOperationItemTypeArticle
//                                                              operationItemID:self.detailModel.article.itemID
//                                                                originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.detailModel.article]
//                                                                 originThread:nil
//                                                               originShortVideoOriginalData:nil
//                                                            originWendaAnswer:nil
//                                                               repostSegments:nil];
    }
}

#pragma mark something abt tip flag

#define kHasTipFavLoginUserDefaultKey @"kHasTipFavLoginUserDefaultKey"

- (void) setHasTipFavLoginUserDefaultKey:(BOOL) hasTip {
    [[NSUserDefaults standardUserDefaults] setBool:hasTip forKey:kHasTipFavLoginUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) hasTipFavLoginUserDefaultKey {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasTipFavLoginUserDefaultKey];
}

#pragma mark - 分享面板添加转发相关
- (nullable NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItemsWithTTActivities:(NSArray<TTActivity *> *)activities
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:7];
    
    NSString * questionMarkOrAmpersand = nil;
    if ([self.activityActionManager.shareURL rangeOfString:@"?"].location == NSNotFound) {
        questionMarkOrAmpersand = @"?";
    }else {
        questionMarkOrAmpersand = @"&";
    }
    NSString *shareBaseURL = [NSString stringWithFormat:@"%@%@", self.activityActionManager.shareURL, questionMarkOrAmpersand ];
    for (TTActivity *activity in activities) {
        switch (activity.activityType) {
            case TTActivityTypeWeixinShare:
            {
                NSString *weixinShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromWeixin];
                TTWechatContentItem *wcContentItem  = [[TTWechatContentItem alloc] initWithTitle:self.activityActionManager.weixinTitleText desc:self.activityActionManager.weixinText webPageUrl:weixinShareURL thumbImage:self.activityActionManager.shareImage shareType:TTShareWebPage];
                [mutableArray addObject:wcContentItem];
            }
                break;
            case TTActivityTypeWeixinMoment:
            {
                NSString *weixinMomentShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromWeixinMoment] ;
                TTWechatTimelineContentItem *wcMomentContentItem = [[TTWechatTimelineContentItem alloc] initWithTitle:self.activityActionManager.weixinMomentText
                                                                                                                 desc:self.activityActionManager.weixinMomentText
                                                                                                           webPageUrl:weixinMomentShareURL
                                                                                                           thumbImage:self.activityActionManager.shareImage
                                                                                                            shareType:TTShareWebPage];
                [mutableArray addObject:wcMomentContentItem];
            }
                break;
            case TTActivityTypeQQShare:
            {
                NSString *qqShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromQQ];
                
                TTQQFriendContentItem *qqFriendContentItem = [[TTQQFriendContentItem alloc] initWithTitle:self.activityActionManager.qqShareTitleText
                                                                                                     desc:self.activityActionManager.qqShareText
                                                                                               webPageUrl:qqShareURL
                                                                                               thumbImage:self.activityActionManager.shareImage
                                                                                                 imageUrl:self.activityActionManager.shareImageURL
                                                                                                 shareTye:TTShareWebPage];
                [mutableArray addObject:qqFriendContentItem];
            }
                break;
            case TTActivityTypeQQZone:
            {
                NSString *qqZoneShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromQQZone];
                NSString * qqZoneText = self.activityActionManager.qqZoneText;
                if (isEmptyString(qqZoneText)) {
                    qqZoneText = self.activityActionManager.qqShareText;
                }
                NSString *title = self.activityActionManager.qqZoneTitleText;
                if (isEmptyString(title)) {
                    title = self.activityActionManager.qqShareTitleText;
                }
                if (isEmptyString(title)) {
                    title = NSLocalizedString(@"好多房", nil);
                }
                UIImage *shareImage = self.activityActionManager.shareToWeixinMomentOrQZoneImage ? self.activityActionManager.shareToWeixinMomentOrQZoneImage : self.activityActionManager.shareImage;
                TTQQZoneContentItem *qqZoneContentItem = [[TTQQZoneContentItem alloc] initWithTitle:title desc:qqZoneText webPageUrl:qqZoneShareURL thumbImage:shareImage imageUrl:self.activityActionManager.shareImageURL shareTye:TTShareWebPage];
                [mutableArray addObject:qqZoneContentItem];
            }
                break;
//            case TTActivityTypeDingTalk:
//            {
//                NSString *dingTalkShareURL = [shareBaseURL stringByAppendingString:kShareChannelFromDingTalk];
//                TTDingTalkContentItem *dingTalkContentItem = [[TTDingTalkContentItem alloc] initWithTitle:self.activityActionManager.dingtalkTitleText
//                                                                                                     desc:self.activityActionManager.dingtalkText
//                                                                                               webPageUrl:dingTalkShareURL
//                                                                                               thumbImage:self.activityActionManager.shareImage
//                                                                                                shareType:TTShareWebPage];
//                [mutableArray addObject:dingTalkContentItem];
//            }
//                break;
//            case TTActivityTypeSystem:
//            {
//                TTSystemContentItem *systemContentItem = [[TTSystemContentItem alloc] initWithDesc:self.activityActionManager.systemShareText webPageUrl:self.activityActionManager.systemShareUrl image:self.activityActionManager.systemShareImage];
//                [mutableArray addObject:systemContentItem];
//            }
//                break;
//            case TTActivityTypeCopy:
//            {
//                NSString *copyText = @"";
//                if (!isEmptyString(self.activityActionManager.copyText)) {
//                    copyText = self.activityActionManager.copyText;
//                } else if (!isEmptyString(self.activityActionManager.copyContent)) {
//                    copyText = self.activityActionManager.copyText;
//                }
//                TTCopyContentItem *copyContentItem = [[TTCopyContentItem alloc] initWithDesc:copyText];
//                [mutableArray addObject:copyContentItem];
//
//            }
//                break;
                
            default:
                break;
        }
        
    }
    
//    //再添加微头条的两个activity
//    TTForwardWeitoutiaoContentItem *forwardWeitoutiaoContentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
//    forwardWeitoutiaoContentItem.repostParams = [self repostParams];
//    WeakSelf;
//    forwardWeitoutiaoContentItem.customAction = ^{
//        StrongSelf;
//        [self _forwardToWeitoutiao];
//    };
//
//    [mutableArray addObject:forwardWeitoutiaoContentItem];
//
//    TTDirectForwardWeitoutiaoContentItem *directForwardContentItem = [[TTDirectForwardWeitoutiaoContentItem alloc] init];
//    directForwardContentItem.repostParams = [self repostParams];
//    directForwardContentItem.customAction = nil;
//    [mutableArray addObject:directForwardContentItem];
    
    return mutableArray.copy;
}

//- (NSDictionary *)repostParams
//{
//    NSDictionary *repostParams = [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeArticle
//                                                               originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.detailModel.article]
//                                                                originThread:nil
//                                                originShortVideoOriginalData:nil
//                                                           originWendaAnswer:nil
//                                                           operationItemType:TTRepostOperationItemTypeArticle
//                                                             operationItemID:self.detailModel.article.itemID
//                                                              repostSegments:nil];
//    return repostParams;
//}

//- (void)_forwardToWeitoutiao {
//    // 文章详情页的转发，实际转发对象为文章，操作对象为文章
//    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([self repostParams])];
//}

#pragma mark TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController {
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extraDic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    [extraDic setValue:@"detail_bottom_bar" forKey:@"section"];
    if (activity == nil) {
        wrapperTrackEventWithCustomKeys(@"slide_detail", [TTShareMethodUtil labelNameForShareActivity:activity], self.detailModel.article.itemID, self.detailModel.clickLabel, extraDic);
    } else if ([activity.activityType isEqualToString:TTActivityTypeForwardWeitoutiao]) {
        wrapperTrackEventWithCustomKeys(@"detail_share", @"share_weitoutiao", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extraDic);

    } else if ([activity.activityType isEqualToString:TTActivityTypeDirectForwardWeitoutiao]) {
        return;
    } else {
        wrapperTrackEventWithCustomKeys(@"detail_share", [TTShareMethodUtil labelNameForShareActivity:activity], self.detailModel.article.itemID, self.detailModel.clickLabel, extraDic);

    }
    
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    if ([activity.activityType isEqualToString:TTActivityTypeForwardWeitoutiao]
        || [activity.activityType isEqualToString:TTActivityTypeDirectForwardWeitoutiao]) {
        return;
    }
    NSString *label = [TTShareMethodUtil labelNameForShareActivity:activity shareState:(error ? NO : YES)];
    if (isEmptyString(label)) {
        return;
    }
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extraDic setValue:self.detailModel.article.aggrType forKey:@"aggr_type"];
    wrapperTrackEventWithCustomKeys(@"detail_share", label, self.detailModel.article.itemID, self.detailModel.clickLabel, extraDic);

    //分享成功或失败，触发分享item排序
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
    }else{
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
    }
}
@end
