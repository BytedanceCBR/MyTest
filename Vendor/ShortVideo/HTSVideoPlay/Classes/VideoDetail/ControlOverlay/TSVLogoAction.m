//
//  TSVLogoAction.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 13/12/2017.
//

#import "TSVLogoAction.h"
#import "TTShortVideoModel.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "AWEVideoConstants.h"
#import "TSVVideoDetailPromptManager.h"
#import "AWEVideoDetailTracker.h"
#import "TTSettingsManager.h"

@interface TSVLogoAction ()

@property (nonatomic, weak) TTShortVideoModel *model;
@property (nonatomic, weak) NSDictionary *commonTrackingParameter;
@property (nonatomic, weak) TSVVideoDetailPromptManager *detailPromptManager;
@property (nonatomic, weak) NSString *position;

@end

@implementation TSVLogoAction

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static TSVLogoAction *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TSVLogoAction alloc] init];
    });

    return sharedInstance;
}

- (void)clickLogoWithModel:(TTShortVideoModel *)model
       commonTrackingParameter:(NSDictionary *)commonTrackingParameter
       detailPromptManager:(TSVVideoDetailPromptManager *)detailPromptManager
                  position:(NSString *)position
{
    NSAssert(model, @"Model should not be nil");
    NSAssert(commonTrackingParameter, @"CommonTrackingParameter should not be nil");

    self.model = model;
    self.commonTrackingParameter = commonTrackingParameter;
    self.detailPromptManager = detailPromptManager;
    self.position = position;

    if (!model) {
        return;
    }

    [self sendDownloadLogoClickEvent];
    
    NSDictionary *configDict = [AWEVideoPlayTransitionBridge getConfigDictWithGroupSource:self.model.groupSource];

    if ([configDict[@"handle_click"] integerValue] == 1) {
        if ([AWEVideoPlayTransitionBridge canOpenAppWithGroupSource:self.model.groupSource]) {
            [AWEVideoPlayTransitionBridge openAppWithGroupSource:self.model.groupSource];
        } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:configDict[@"url_schemes"]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:configDict[@"url_schemes"]]];
        } else {
            [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:YES];
            [self sendDownloadAlertShowEvent];
            [AWEVideoPlayTransitionBridge openDownloadViewWithConfigDict:configDict
                                                            confirmBlock:^{
                                                                [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
                                                                [self sendDownloadAlertConfirmEvent];
                                                            }
                                                             cancelBlock:^{
                                                                 [self.detailPromptManager updateVisibleFloatingViewCountForVisibility:NO];
                                                                 [self sendDownloadAlertConfirmEvent];
                                                             }];
        }
    }
}

#pragma mark -
- (void)sendDownloadLogoClickEvent
{
    [AWEVideoDetailTracker trackEvent:@"icon_click"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:[self downloadLogoEventExtraParameter]];
}

- (void)sendDownloadAlertShowEvent
{
    [AWEVideoDetailTracker trackEvent:@"shortvideo_app_download_popup"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:[self downloadLogoEventExtraParameter]];
}

- (void)sendDownloadAlertConfirmEvent
{
    [AWEVideoDetailTracker trackEvent:@"shortvideo_app_download_click"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:[self downloadLogoEventExtraParameter]];
}

- (void)sendDownloadAlertCancelEvent
{
    NSMutableDictionary *extraParameter = [NSMutableDictionary dictionaryWithDictionary:[self downloadLogoEventExtraParameter]];
    [extraParameter setValue:@"button" forKey:@"cancel_type"];
    [AWEVideoDetailTracker trackEvent:@"shortvideo_app_download_cancel"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:[extraParameter copy]];
}

- (NSDictionary *)downloadLogoEventExtraParameter
{
    return @{@"user_id": self.model.author.userID ?: @"",
             @"follow_status": [@(self.model.author.isFollowing) stringValue],
             @"position": self.position,
             };
}

@end
