//
//  TTShortVideoStayTrackManager.m
//  Article
//
//  Created by 王双华 on 2017/7/30.
//
//

#import "TTShortVideoStayTrackManager.h"
#import "TTCategory.h"

@interface TTShortVideoStayTrackManager ()

@property(nonatomic, assign) NSTimeInterval timeIntervalForStayPage;
@property(nonatomic, strong) TTCategory *trackingCategory;

@end

@implementation TTShortVideoStayTrackManager

static TTShortVideoStayTrackManager * manager;
+ (TTShortVideoStayTrackManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTShortVideoStayTrackManager alloc] init];
    });
    return manager;
}


- (void)startTrackForCategory:(TTCategory *)category enterType:(NSString *)enterType
{
    if (self.trackingCategory && ![category isEqual:self.trackingCategory]) {
        [self endTrackForCategory:self.trackingCategory];
        [self resetStayTime];
    }
    
    self.timeIntervalForStayPage = [[NSDate date] timeIntervalSince1970];
    self.trackingCategory = category;
    self.enterType = enterType;
}

- (void)endTrackForCategory:(TTCategory *)category
{
    if (!self.trackingCategory || self.timeIntervalForStayPage <= 0) {
        
        [self resetStayTime];
        return;
    }
    
    if ([category isEqual:self.trackingCategory]) {
        
        NSTimeInterval stayTime = [[NSDate date] timeIntervalSince1970] - self.timeIntervalForStayPage;
        
        [self trackStayEventStayTime:stayTime];
        
        [self resetStayTime];
    }
}

- (void)resetStayTime
{
    self.trackingCategory = nil;
    self.timeIntervalForStayPage = 0;
}

- (void)trackStayEventStayTime:(NSTimeInterval)stayTime
{
#if !DEBUG
    @try {
#endif
        NSString *stayTimeStr = [NSString stringWithFormat:@"%.0f", stayTime * 1000];
//        [TTTrackerWrapper eventV3:@"stay_category" params:@{
//                                                            @"enter_from": @"click_category",
//                                                            @"category_name": self.trackingCategory.categoryID,
//                                                            @"list_entrance": @"main_tab",
//                                                            @"enter_type": self.enterType,
//                                                            @"stay_time": stayTimeStr,
//                                                            @"demand_id": @100380,
//                                                            }];
#if !DEBUG
    } @catch (NSException *exception) {
        ;
    } @finally {
        ;
    }
#endif
}

@end
