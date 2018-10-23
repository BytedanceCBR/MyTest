//
//  TTArticleDetailViewController+Report.m
//  Article
//
//  Created by muhuai on 2017/7/31.
//
//

#import "TTArticleDetailViewController+Report.h"
#import "TTDislikeManager.h"
#import "SSCommonLogic.h"
#import "ExploreMixListDefine.h"
#import "ExploreItemActionManager.h"
#import "Article+TTADComputedProperties.h"
#import <TTReporter/TTReportManager.h>
#import <TTUIWidget/TTThemedAlertController.h>
#import <objc/runtime.h>
#import "ExploreOrderedData+TTAd.h"

@implementation TTArticleDetailViewController (Report)
@dynamic dislikeDictionary, dislikeContainer, actionSheetController, shouldSentDislikeNotification;

- (void)report_dealloc {
    if ([SSCommonLogic isDislikeRefactorEnabled] && self.shouldSentDislikeNotification && [self.detailModel.adID longLongValue] == 0) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [userInfo setValue:@(TTDislikeSourceTypeDetail).stringValue forKey:@"dislike_source"];
        [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
        [userInfo setValue:self.detailModel.orderedData forKey:@"orderedData"];
        [userInfo setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
        [userInfo setValue:self.detailModel.orderedData forKey:kExploreMixListNotInterestItemKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
    }
    else {
        if (self.dislikeDictionary[@"dislike"] && !self.dislikeDictionary[@"report"]) {
            
            if (!self.detailModel.orderedData) {
                NSArray *filterWords = [self.dislikeDictionary[@"dislike"] componentsSeparatedByString:@","];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                if (filterWords.count > 0) {
                    [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
                    [userInfo setValue:@(TTDislikeSourceTypeDetail).stringValue forKey:@"dislike_source"];
                    [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
                    [userInfo setValue:self.detailModel.orderedData forKey:@"orderedData"];
                    [userInfo setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TTDISLIKEMANAGER_SEND_DISLIKE object:nil userInfo:userInfo];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            NSArray *filterWords = [self.dislikeDictionary[@"dislike"] componentsSeparatedByString:@","];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
            [userInfo setValue:self.detailModel.orderedData forKey:kExploreMixListNotInterestItemKey];
            if (filterWords.count > 0) {
                [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
                [userInfo setValue:@(TTDislikeSourceTypeDetail).stringValue forKey:@"dislike_source"];
                [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
                [userInfo setValue:self.detailModel.orderedData forKey:@"orderedData"];
                [userInfo setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
                [[NSNotificationCenter defaultCenter] postNotificationName:TTDISLIKEMANAGER_SEND_DISLIKE object:nil userInfo:userInfo];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
            
        }
        else if (self.dislikeDictionary && self.dislikeDictionary[@"dislike"] && self.dislikeDictionary[@"report"]) {
            
            if (!self.detailModel.orderedData) {
                NSArray *filterWords = [self.dislikeDictionary[@"dislike"] componentsSeparatedByString:@","];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                if (filterWords.count > 0) {
                    [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
                    [userInfo setValue:@(TTDislikeSourceTypeDetail).stringValue forKey:@"dislike_source"];
                    [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
                    [userInfo setValue:self.detailModel.orderedData forKey:@"orderedData"];
                    [userInfo setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TTDISLIKEMANAGER_SEND_DISLIKE object:nil userInfo:userInfo];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.detailModel.article.groupModel.groupID;
                model.itemID = self.detailModel.article.groupModel.itemID;
                model.aggrType = @(self.detailModel.article.groupModel.aggrType);
                NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
                
                [[TTReportManager shareInstance] startReportContentWithType:self.dislikeDictionary[@"report"] inputText:self.dislikeDictionary[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:NO];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            NSArray *filterWords = [self.dislikeDictionary[@"dislike"] componentsSeparatedByString:@","];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
            [userInfo setValue:self.detailModel.orderedData forKey:kExploreMixListNotInterestItemKey];
            if (filterWords.count > 0) {
                [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = self.detailModel.article.groupModel.groupID;
            model.itemID = self.detailModel.article.groupModel.itemID;
            model.aggrType = @(self.detailModel.article.groupModel.aggrType);
            NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
            
            [[TTReportManager shareInstance] startReportContentWithType:self.dislikeDictionary[@"report"] inputText:self.dislikeDictionary[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:NO];
            
        }
        else if (!self.dislikeDictionary[@"dislike"] && self.dislikeDictionary[@"report"]) {
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = self.detailModel.article.groupModel.groupID;
            model.itemID = self.detailModel.article.groupModel.itemID;
            model.aggrType = @(self.detailModel.article.groupModel.aggrType);
            NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
            
            [[TTReportManager shareInstance] startReportContentWithType:self.dislikeDictionary[@"report"] inputText:self.dislikeDictionary[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:NO];
        }
    }
}

- (void)report_showReportOnNatantView:(NSString *)style source:(TTActionSheetSourceType)source trackSource:(NSString *)trackSource {
    if ([SSCommonLogic isDislikeRefactorEnabled]) {
        
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [extra setValue:style forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"detail", trackSource, self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
        
        if (!self.dislikeContainer) {
            self.dislikeContainer = [[TTDislikeContainer alloc] init];
            self.dislikeContainer.detailModel = self.detailModel;
        }
        self.dislikeContainer.type = (source == TTActionSheetSourceTypeReport) ? TTDislikeTypeOnlyReport : TTDislikeTypeDislikeAndReport;
        [self.dislikeContainer insertDislikeOptions:self.articleInfoManager.dislikeWords reportOptions:[TTReportManager fetchReportArticleOptions]];
        WeakSelf;
        [self.dislikeContainer showDislikeViewAfterComplete:^(NSArray * _Nullable dislikeOptions, NSArray * _Nullable reportOptions, NSDictionary * _Nullable extraDict) {
            StrongSelf;
            //请求dislike接口
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
            [userInfo setValue:dislikeOptions forKey:kExploreMixListNotInterestWordsKey];
            TTDislikeSourceType type = TTDislikeSourceTypeDetail;
            if (reportOptions.count > 0 || [extraDict tt_stringValueForKey:@"criticism"]) {
                type = TTDislikeSourceTypeDetailReport;
            }
            [userInfo setValue:@(type).stringValue forKey:@"dislike_source"];
            [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
            [userInfo setValue:self.detailModel.orderedData forKey:@"orderedData"];
            [userInfo setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
            ExploreOrderedData *orderData = [userInfo tt_objectForKey:@"orderData"];
            NSMutableDictionary *adExtra = [[NSMutableDictionary alloc] init];
            [adExtra setValue:orderData.log_extra forKey:@"log_extra"];
            if ([userInfo tt_objectForKey:kExploreMixListNotInterestWordsKey]) {
                if (!self.itemActionManager) {
                    self.itemActionManager = [[ExploreItemActionManager alloc] init];
                }
                NSNumber *adID = isEmptyString(orderData.ad_id) ? nil : @(orderData.ad_id.longLongValue);
                [self.itemActionManager startSendDislikeActionType:DetailActionTypeNewVersionDislike source:[userInfo tt_intValueForKey:@"dislike_source"] groupModel:[userInfo tt_objectForKey:@"groupModel"] filterWords:[userInfo tt_objectForKey:kExploreMixListNotInterestWordsKey] cardID:nil actionExtra:orderData.actionExtra adID:adID adExtra:adExtra widgetID:nil threadID:nil finishBlock:nil];
                //退出页面发送广播，请求dislike动画
                self.shouldSentDislikeNotification = YES;
                //防止发送请求之后杀掉应用，没有删除本地数据
                self.detailModel.article.notInterested = @(YES);
                [self.detailModel.article save];
                [[TTMonitor shareManager] trackService:@"article_detail_dislike" status:1 extra:userInfo];
            }
            else {
                [[TTMonitor shareManager] trackService:@"article_detail_dislike" status:0 extra:userInfo];
            }
            
            //请求report接口
            if (reportOptions.count > 0) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.detailModel.article.groupModel.groupID;
                model.itemID = self.detailModel.article.groupModel.itemID;
                model.aggrType = @(self.detailModel.article.groupModel.aggrType);
                NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
                
                [[TTReportManager shareInstance] startReportContentWithType:[[reportOptions valueForKey:@"description"] componentsJoinedByString:@","] inputText:[extraDict tt_stringValueForKey:@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:NO];
            }
            
            //Toast
            if (reportOptions.count > 0) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐\n举报已成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
        }];
    }
    else {
        WeakSelf;
        //创建单例TTDislikeManager，在delloc中发送dislike请求
        [TTDislikeManager sharedInstance];
        
        NSMutableDictionary * extDict = [[NSMutableDictionary alloc] init];
        [extDict setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [extDict setValue:style forKey:@"style"];

        if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
            [extDict setObject:self.detailModel.orderedData.ad_id forKey:@"aid"];
        }
        if (!self.actionSheetController) {
            self.actionSheetController = [[TTActionSheetController alloc] init];
            self.actionSheetController.itemID = self.detailModel.article.itemID;
            self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
            self.actionSheetController.adID = self.detailModel.adID;
            self.actionSheetController.isSendTrack = YES;
            self.actionSheetController.source = self.detailModel.clickLabel;
            self.actionSheetController.trackBlock = ^{
                StrongSelf;
                wrapperTrackEventWithCustomKeys(@"detail", @"report_click", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extDict);
            };
        }
        self.actionSheetController.extra = @{@"position": @"detail_mid"};
        wrapperTrackEventWithCustomKeys(@"detail", trackSource, self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extDict);
        [self.actionSheetController insertDislikeArray:self.articleInfoManager.dislikeWords reportArray:[TTReportManager fetchReportArticleOptions]];
        
        [self.actionSheetController performWithSource:source completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            
            if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                return;
            }
            else if (self.dislikeDictionary[@"dislike"] || self.dislikeDictionary[@"report"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else if (parameters[@"dislike"] && !parameters[@"report"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else if (parameters[@"dislike"] && parameters[@"report"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐\n举报已成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else if (!parameters[@"dislike"] && parameters[@"report"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            self.dislikeDictionary = parameters;
        }];
    }
}

- (void)report_showReportOnSharePannel {
    if ([SSCommonLogic isDislikeRefactorEnabled] && [self.detailModel.adID longLongValue] == 0) {
        
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [extra setValue:@"report" forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"detail", @"report_click", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
        
        if (!self.dislikeContainer) {
            self.dislikeContainer = [[TTDislikeContainer alloc] init];
            self.dislikeContainer.detailModel = self.detailModel;
        }
        self.dislikeContainer.type = TTDislikeTypeOnlyReport;
        [self.dislikeContainer insertDislikeOptions:nil reportOptions:[TTReportManager fetchReportArticleOptions]];
        WeakSelf;
        [self.dislikeContainer showDislikeViewAfterComplete:^(NSArray * _Nullable dislikeOptions, NSArray * _Nullable reportOptions, NSDictionary * _Nullable extraDict) {
            StrongSelf;
            //请求report接口
            if (reportOptions.count > 0) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.detailModel.article.groupModel.groupID;
                model.itemID = self.detailModel.article.groupModel.itemID;
                model.aggrType = @(self.detailModel.article.groupModel.aggrType);
                NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
                
                [[TTReportManager shareInstance] startReportContentWithType:[[reportOptions valueForKey:@"description"] componentsJoinedByString:@","] inputText:[extraDict tt_stringValueForKey:@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:NO];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
        }];
        
    }
    else {
        if (!self.actionSheetController) {
            self.actionSheetController = [[TTActionSheetController alloc] init];
            self.actionSheetController.itemID = self.detailModel.article.itemID;
            self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
            self.actionSheetController.adID = self.detailModel.adID;
            self.actionSheetController.isSendTrack = YES;
            self.actionSheetController.source = self.detailModel.clickLabel;
        }
        if ([self.detailModel.adID longLongValue] > 0) {
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportADOptions]];
        }
        else {
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
        }
        
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
            if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                return;
            }
            else if (self.dislikeDictionary[@"report"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else if (parameters[@"report"]){
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            self.dislikeDictionary = parameters;
            
        }];
    }
}

- (void)report_showReportOnTopSharePannel {
    if ([SSCommonLogic isDislikeRefactorEnabled] && [self.detailModel.adID longLongValue] == 0) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
        [extra setValue:@"report" forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"detail", @"report_click", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
        
        if (!self.dislikeContainer) {
            self.dislikeContainer = [[TTDislikeContainer alloc] init];
            self.dislikeContainer.detailModel = self.detailModel;
        }
        self.dislikeContainer.type = TTDislikeTypeOnlyReport;
        [self.dislikeContainer insertDislikeOptions:nil reportOptions:[TTReportManager fetchReportArticleOptions]];
        WeakSelf;
        [self.dislikeContainer showDislikeViewAfterComplete:^(NSArray * _Nullable dislikeOptions, NSArray * _Nullable reportOptions, NSDictionary * _Nullable extraDict) {
            StrongSelf;
            //请求report接口
            if (reportOptions.count > 0) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.detailModel.article.groupModel.groupID;
                model.itemID = self.detailModel.article.groupModel.itemID;
                model.aggrType = @(self.detailModel.article.groupModel.aggrType);
                NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
                
                [[TTReportManager shareInstance] startReportContentWithType:[[reportOptions valueForKey:@"description"] componentsJoinedByString:@","] inputText:[extraDict tt_stringValueForKey:@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:NO];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
        }];
    }
    else {
        if (!self.actionSheetController) {
            self.actionSheetController = [[TTActionSheetController alloc] init];
            self.actionSheetController.itemID = self.detailModel.article.itemID;
            self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
            self.actionSheetController.adID = self.detailModel.adID;
            self.actionSheetController.isSendTrack = YES;
            self.actionSheetController.source = self.detailModel.clickLabel;
        }
        self.actionSheetController.extra = @{@"position": @"detail_more"};
        
        if ([self.detailModel.adID longLongValue] > 0) {
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportADOptions]];
        }
        else {
            [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
        }
        
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
            if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                return;
            }
            else if (self.dislikeDictionary[@"report"]) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else if (parameters[@"report"]){
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            self.dislikeDictionary = parameters;
            
        }];
    }

}
- (void)tt_articleDetailViewWillShowDislike:(NSDictionary *)result {
    WeakSelf;
    if ([SSCommonLogic isDislikeRefactorEnabled]) {
        switch ([result tt_integerValueForKey:@"options"]) {
                case TTActionSheetWebTypeDislike: {
                    if (!self.actionSheetController) {
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        self.actionSheetController.itemID = self.detailModel.article.itemID;
                        self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
                        self.actionSheetController.isSendTrack = YES;
                        self.actionSheetController.source = self.detailModel.clickLabel;
                    }
                    self.actionSheetController.extra = @{@"position": @"detail_mid"};
                    
                    [self.actionSheetController insertDislikeArray:self.articleInfoManager.dislikeWords];
                    
                    [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
                        StrongSelf;
                        if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                            return;
                        }
                        else if (self.dislikeDictionary[@"dislike"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"dislike"]){
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        self.dislikeDictionary = parameters;
                    }];
                }
                break;
                case TTActionSheetWebTypeReport: {
                    if (!self.actionSheetController) {
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        self.actionSheetController.itemID = self.detailModel.article.itemID;
                        self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
                        self.actionSheetController.isSendTrack = YES;
                        self.actionSheetController.source = self.detailModel.clickLabel;
                    }
                    self.actionSheetController.extra = @{@"position": @"detail_mid"};
                    
                    [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
                    
                    [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
                        StrongSelf;
                        if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                            return;
                        }
                        else if (self.dislikeDictionary[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"report"]){
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        self.dislikeDictionary = parameters;
                        
                    }];
                }
                break;
                case TTActionSheetTypeDislikeAndReport: {
                    if (!self.actionSheetController) {
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        self.actionSheetController.itemID = self.detailModel.article.itemID;
                        self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
                        self.actionSheetController.isSendTrack = YES;
                        self.actionSheetController.source = self.detailModel.clickLabel;
                    }
                    self.actionSheetController.extra = @{@"position": @"detail_mid"};
                    
                    [self.actionSheetController insertDislikeArray:self.articleInfoManager.dislikeWords reportArray:[TTReportManager fetchReportArticleOptions]];
                    
                    [self.actionSheetController performWithSource:TTActionSheetSourceTypeDislike completion:^(NSDictionary * _Nonnull parameters) {
                        StrongSelf;
                        if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                            return;
                        }
                        else if (self.dislikeDictionary[@"dislike"] || self.dislikeDictionary[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"dislike"] && !parameters[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"dislike"] && parameters[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐\n举报已成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (!parameters[@"dislike"] && parameters[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        self.dislikeDictionary = parameters;
                    }];
                }
                break;
        }
    }
    else {
        switch ([result tt_integerValueForKey:@"options"]) {
                case TTActionSheetWebTypeDislike: {
                    if (!self.actionSheetController) {
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        self.actionSheetController.itemID = self.detailModel.article.itemID;
                        self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
                        self.actionSheetController.isSendTrack = YES;
                        self.actionSheetController.source = self.detailModel.clickLabel;
                    }
                    self.actionSheetController.extra = @{@"position": @"detail_mid"};
                    
                    [self.actionSheetController insertDislikeArray:self.articleInfoManager.dislikeWords];
                    
                    [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
                        StrongSelf;
                        if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                            return;
                        }
                        else if (self.dislikeDictionary[@"dislike"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"dislike"]){
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        self.dislikeDictionary = parameters;
                    }];
                }
                break;
                case TTActionSheetWebTypeReport: {
                    if (!self.actionSheetController) {
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        self.actionSheetController.itemID = self.detailModel.article.itemID;
                        self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
                        self.actionSheetController.isSendTrack = YES;
                        self.actionSheetController.source = self.detailModel.clickLabel;
                    }
                    self.actionSheetController.extra = @{@"position": @"detail_mid"};
                    
                    [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
                    
                    [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
                        StrongSelf;
                        if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                            return;
                        }
                        else if (self.dislikeDictionary[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"report"]){
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        self.dislikeDictionary = parameters;
                        
                    }];
                }
                break;
                case TTActionSheetTypeDislikeAndReport: {
                    if (!self.actionSheetController) {
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        self.actionSheetController.itemID = self.detailModel.article.itemID;
                        self.actionSheetController.groupID = self.detailModel.article.groupModel.groupID;
                        self.actionSheetController.isSendTrack = YES;
                        self.actionSheetController.source = self.detailModel.clickLabel;
                    }
                    self.actionSheetController.extra = @{@"position": @"detail_mid"};
                    
                    [self.actionSheetController insertDislikeArray:self.articleInfoManager.dislikeWords reportArray:[TTReportManager fetchReportArticleOptions]];
                    
                    [self.actionSheetController performWithSource:TTActionSheetSourceTypeDislike completion:^(NSDictionary * _Nonnull parameters) {
                        StrongSelf;
                        if ([parameters isEqualToDictionary:self.dislikeDictionary]) {
                            return;
                        }
                        else if (self.dislikeDictionary[@"dislike"] || self.dislikeDictionary[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"修改成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"dislike"] && !parameters[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (parameters[@"dislike"] && parameters[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将减少类似推荐\n举报已成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        else if (!parameters[@"dislike"] && parameters[@"report"]) {
                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"举报成功" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                        }
                        self.dislikeDictionary = parameters;
                    }];
                }
                break;
        }
    }
}

- (void)tt_articleDetailViewTypos:(NSArray *)resultArray {
    NSMutableDictionary *wrongWords = [[NSMutableDictionary alloc] init];
    if (resultArray) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [wrongWords setObject:jsonString forKey:@"wrong_words"];
    }
    if ([SSCommonLogic isReportTyposEnabled]) {
        NSString *title;
        if (resultArray.count > 2) {
            NSString *keyWord = [resultArray objectAtIndex:1];
            if (keyWord.length > 3) {
                keyWord = [keyWord substringToIndex:3];
                keyWord = [keyWord stringByAppendingString:@"..."];
            }
            title = [NSString stringWithFormat:@"举报\"%@\"为错别字？", keyWord];
        }
        else {
            title = @"是否举报错别字?";
        }
        
        WeakSelf;
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:@"" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", @"取消") actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            StrongSelf;
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
            [extra setValue:@"article" forKey:@"group_type"];
            [extra setValue:@"detail_long_press" forKey:@"position"];
            [extra setValue:@"report" forKey:@"style"];
            if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
                [extra setValue:self.detailModel.orderedData.ad_id forKey:@"aid"];
            }
            wrapperTrackEventWithCustomKeys(@"pop", @"report_pop_cancel", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
        }];
        [alert addActionWithTitle:NSLocalizedString(@"确定", @"确定") actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            StrongSelf;
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = self.detailModel.article.groupModel.groupID;
            model.itemID = self.detailModel.article.groupModel.itemID;
            model.aggrType = @(self.detailModel.article.groupModel.aggrType);
            NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
            
            [[TTReportManager shareInstance] startReportContentWithType:@"12" inputText:nil contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:wrongWords animated:YES];
            NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
            [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
            [extra setValue:@"article" forKey:@"group_type"];
            [extra setValue:@"detail_long_press" forKey:@"position"];
            [extra setValue:@"report" forKey:@"style"];
            if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
                [extra setValue:self.detailModel.orderedData.ad_id forKey:@"aid"];
            }
            wrapperTrackEventWithCustomKeys(@"pop", @"report_pop_confirm", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
        }];
        [alert showFrom:self animated:YES];
        [self reportTyposAlertTrack];
    }
    else {
        TTReportContentModel *model = [[TTReportContentModel alloc] init];
        model.groupID = self.detailModel.article.groupModel.groupID;
        model.itemID = self.detailModel.article.groupModel.itemID;
        model.aggrType = @(self.detailModel.article.groupModel.aggrType);
        NSString *contentType = self.detailModel.adID.longLongValue ? kTTReportContentTypeAD : kTTReportContentTypeArticle;
        
        [[TTReportManager shareInstance] startReportContentWithType:@"12" inputText:nil contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:wrongWords animated:YES];
        [self reportTyposTrack];
    }
}

- (void)reportTyposTrack {
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extra setValue:@"article" forKey:@"group_type"];
    [extra setValue:@"detail_long_press" forKey:@"position"];
    [extra setValue:@"report" forKey:@"style"];
    if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
        [extra setValue:self.detailModel.orderedData.ad_id forKey:@"aid"];
    }
    wrapperTrackEventWithCustomKeys(@"detail", @"report_click", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
}

- (void)reportTyposAlertTrack {
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    [extra setValue:@"article" forKey:@"group_type"];
    [extra setValue:@"detail_long_press" forKey:@"position"];
    [extra setValue:@"report" forKey:@"style"];
    if (!isEmptyString(self.detailModel.orderedData.ad_id)) {
        [extra setValue:self.detailModel.orderedData.ad_id forKey:@"aid"];
    }
    wrapperTrackEventWithCustomKeys(@"pop", @"report_pop_show", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
}

#pragma mark - getter & setter

static char kShouldSentDislikeNotificationKey;
- (void)setShouldSentDislikeNotification:(BOOL)shouldSentDislikeNotification {
    objc_setAssociatedObject(self, &kShouldSentDislikeNotificationKey, @(shouldSentDislikeNotification), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)shouldSentDislikeNotification {
    return [objc_getAssociatedObject(self, &kShouldSentDislikeNotificationKey) boolValue];
}

SYNTHESE_CATEGORY_PROPERTY_STRONG(dislikeDictionary, setDislikeDictionary, NSDictionary *)
SYNTHESE_CATEGORY_PROPERTY_STRONG(actionSheetController, setActionSheetController, TTActionSheetController *)
SYNTHESE_CATEGORY_PROPERTY_STRONG(dislikeContainer, setDislikeContainer, TTDislikeContainer *)


@end
