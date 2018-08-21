//
//  TTVideoFloatViewController+Share.m
//  Article
//
//  Created by panxiang on 16/7/14.
//
//

#import "TTVideoFloatViewController+Share.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "TTNavigationController.h"
#import "TTReportManager.h"
#import "ExploreDetailManager.h"


@implementation TTVideoFloatViewController (Share)

- (void)shareActionWithCellEntity:(TTVideoFloatCellEntity *)cellEntity
{
    self.shareArticle = cellEntity.article;
    //点击分享按钮统计
    NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:self.shareArticle adID:self.detailModel.adID showReport:YES];
    if (self.activityActionManager.useDefaultImage) {
        UIImage *image = [self.movieShotView logoImage];
        if (image) {
            self.activityActionManager.shareImage = image;
            self.activityActionManager.systemShareImage = image;
        }
    }
    
    SSActivityView *phoneShareView = [[SSActivityView alloc] init];
    
    phoneShareView.delegate = self;
    phoneShareView.activityItems = activityItems;
    [phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor: self] useShareGroupOnly:NO];
    
    //点击分享按钮统计
    [self.detailModel sendDetailTrackEventWithTag:@"video_float" label:@"share_button"];
}

#pragma mark -
#pragma mark SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeReport) {
        
        self.actionSheetController = [[TTActionSheetController alloc] init];
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            if (parameters[@"report"]) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.detailModel.article.groupModel.groupID;
                model.videoID = self.detailModel.article.videoID;
                NSString *contentType = kTTReportContentTypePGCVideo;
                if ([self.detailModel.article isVideoSourceUGCVideo]) {
                    contentType = kTTReportContentTypeUGCVideo;
                } else if ([self.detailModel.article isVideoSourceHuoShan]) {
                    contentType = kTTReportContentTypeHTSVideo;
                }
                
                [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:YES];
            }
        }];
    } else {
        NSString *groupId = [NSString stringWithFormat:@"%lld", self.shareArticle.uniqueID];
        [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:TTShareSourceObjectTypeVideoList uniqueId:groupId adID:nil platform:TTSharePlatformTypeOfMain groupFlags:self.shareArticle.groupFlags];
        NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeVideoFloat];
        if (itemType == TTActivityTypeNone) {
            tag = @"video_float";
        }
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
        [self.detailModel sendDetailTrackEventWithTag:tag label:label];
    }
    self.shareArticle = nil;
}

@end
