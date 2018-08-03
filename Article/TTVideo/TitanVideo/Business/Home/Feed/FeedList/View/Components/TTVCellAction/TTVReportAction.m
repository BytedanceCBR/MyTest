//
//  TTVReportAction.m
//  Article
//
//  Created by panxiang on 2017/4/11.
//
//

#import "TTVReportAction.h"
#import "TTActionSheetController.h"
#import "TTReportManager.h"
#import "TTVShareActionsTracker.h"

@implementation TTVReportActionEntity

@end

@interface TTVReportAction ()
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end

@implementation TTVReportAction
@dynamic entity;


- (instancetype)initWithEntity:(TTVMoreActionEntity *)entity
{
    self = [super initWithEntity:entity];
    if (self) {
        self.type = TTActivityTypeReport;
    }
    return self;
}

- (void)execute:(TTActivityType)type
{
    if (type != self.type) {
        return;
    }
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:self.entity.groupId forKey:@"group_id"];
    [eventContext setValue:self.entity.itemId forKey:@"item_id"];
//    NSString * screenName = [NSString stringWithFormat:@"channel_%@", self.entity.categoryId];
//    [TTLogManager logEvent:@"click_report" context:eventContext screenName:screenName];

    self.actionSheetController = [[TTActionSheetController alloc] init];
    if (self.entity.adID.longLongValue) {
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportADOptions]];
    } else {
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
    }
    @weakify(self);
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
        @strongify(self);
        if (parameters[@"report"]) {
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = self.entity.groupId;
            model.videoID = self.entity.itemId;
            NSString *contentType = kTTReportContentTypePGCVideo;
            if (!isEmptyString(self.entity.videoSource) && [self.entity.videoSource isEqualToString:@"ugc_video"]) {
                contentType = kTTReportContentTypeUGCVideo;
            } else if (!isEmptyString(self.entity.videoSource) && [self.entity.videoSource isEqualToString:@"huoshan"]) {
                contentType = kTTReportContentTypeHTSVideo;
            } else if (self.entity.adID.longLongValue) {
                contentType = kTTReportContentTypeAD;
            }
            
            [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(nil, self.entity.categoryId) contentModel:model extraDic:nil animated:YES];
            self.didTrackReportSubmiteActionBlock(parameters);
        }
    }];
}

@end
