//
//  TSVDetailViewModel.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 19/09/2017.
//

#import "TSVDetailViewModel.h"
#import "TSVControlOverlayViewModel.h"
#import "AWEVideoPlayTrackerBridge.h"
#import "TSVMonitorManager.h"

@interface TSVDetailViewModel ()

@end

@implementation TSVDetailViewModel

- (instancetype)init
{
    if (self = [super init]) {

    }

    return self;
}

- (void)didShareToActivityNamed:(NSString *)activityName
{
    [[NSUserDefaults standardUserDefaults] setObject:activityName forKey:TSVLastShareActivityName];
}

- (void)willShowLoadingCell
{
    [self trackLoadingCellShowEvent];
}

- (void)trackLoadingCellShowEvent
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (self.commonTrackingParameter[@"enter_from"]) {
        [params setValue:self.commonTrackingParameter[@"enter_from"] forKey:@"enter_from"];
    }
    
    if (self.commonTrackingParameter[@"category_name"]) {
        [params setValue:self.commonTrackingParameter[@"category_name"] forKey:@"category_name"];
    }
    
    if ([self.dataFetchManager numberOfShortVideoItems]) {
        TTShortVideoModel *videoDetail = [self.dataFetchManager itemAtIndex:[self.dataFetchManager numberOfShortVideoItems] - 1];//取最后一个
        [params setValue:videoDetail.listEntrance forKey:@"list_entrance"];
        
        if (videoDetail.categoryName) {
            [params setValue:videoDetail.categoryName forKey:@"category_name"];
        }
        
        if (videoDetail.enterFrom) {
            [params setValue:videoDetail.enterFrom forKey:@"enter_from"];
        }
    }
    [AWEVideoPlayTrackerBridge trackEvent : @"black_load"
                                   params : params];
    
    [[TSVMonitorManager sharedManager] trackDetailLoadingCellShowWithExtraInfo:params];
}

@end
