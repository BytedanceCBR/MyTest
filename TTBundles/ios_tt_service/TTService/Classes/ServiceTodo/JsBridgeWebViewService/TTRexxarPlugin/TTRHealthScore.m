//
//  TTRHealthScore.m
//  Article
//
//  Created by chenjiesheng on 2017/9/24.
//

// fix healthkit
/*
#import "TTRHealthScore.h"
#import <TTRexxar/TTRJSBForwarding.h>
#import <HealthKit/HealthKit.h>
#import <TTSettingsManager.h>

typedef NS_ENUM(NSInteger,TTHealthScoreCode)
{
    TTHealthScoreCodeSuccess = 1,
    TTHealthScoreCodeNoAuthorization = 2,
    TTHealthScoreCodeUnAvailable = 3,
};

@implementation TTRHealthScore

+ (void)load
{
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRHealthScore.healthStepCount" for:@"healthStepCount"];
}

- (void)healthStepCountWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSNumber * settingEnable = [[TTSettingsManager sharedManager] settingForKey:@"tt_health_score" defaultValue:@(NO) freeze:YES];
    if (settingEnable.boolValue) {
        if ([HKHealthStore isHealthDataAvailable]){
            HKHealthStore *store = [[HKHealthStore alloc] init];
            HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            NSSet *readType = [NSSet setWithObject:stepCountType];
            [store requestAuthorizationToShareTypes:nil readTypes:readType completion:^(BOOL success, NSError * _Nullable error) {
                if (!success || error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(TTRJSBMsgSuccess,@{@"code":@(TTHealthScoreCodeUnAvailable)});
                    });
                }else{
                    NSNumber *durationValue = [param tt_objectForKey:@"duration"];
                    NSInteger duration = durationValue ? durationValue.integerValue : 30;
                    [TTRHealthScore fetchStepCountDataWithStore:store duration:duration completion:^(NSArray * list) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSDictionary *data = @{@"list":list,
                                                   @"code":@(TTHealthScoreCodeSuccess)};
                            callback(TTRJSBMsgSuccess,data);
                        });
                    }];
                }
            }];
        }else{
            callback(TTRJSBMsgSuccess, @{@"code":@(TTHealthScoreCodeUnAvailable)});
        }
    } else {
        callback(TTRJSBMsgSuccess, @{@"code":@(TTHealthScoreCodeUnAvailable)});
    }

    return;
}

+ (void)fetchStepCountDataWithStore:(HKHealthStore *)store duration:(NSInteger)duration completion:(void(^)(NSArray *))completion
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    NSDateComponents *anchorComponent = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:[[NSDate alloc] init]];
    anchorComponent.day = anchorComponent.day + 1;
    anchorComponent.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponent];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDate *endDate = [[NSDate alloc] init];
    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                             value:-duration
                                            toDate:anchorDate
                                           options:0];
    if (!startDate){
        startDate = endDate;
    }
    __block NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    NSTimeInterval oneDayTimeInterval = 86400.f;
    NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        NSInteger stepCount = 0;
        NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:duration];
        for (HKQuantitySample *sample in results) {
            HKQuantity *resultQuantity = sample.quantity;
            NSInteger value = [resultQuantity doubleValueForUnit: [HKUnit countUnit]];
            NSTimeInterval sampleTimeInterval = sample.endDate.timeIntervalSince1970;
            while (sampleTimeInterval - startTimeInterval > oneDayTimeInterval) {
                [valueArray addObject:@{@"step":@(stepCount),
                                        @"date":@(startTimeInterval)
                                        }];
                startTimeInterval = MIN(startTimeInterval + oneDayTimeInterval, endTimeInterval);
                stepCount = 0;
            }
            NSDictionary *dict = (NSDictionary *)sample.metadata;
            NSInteger wasUserEntered = [dict tt_integerValueForKey:@"HKWasUserEntered"];
            if (!wasUserEntered) {
                stepCount += value;
            }
        }
        [valueArray addObject:@{@"step":@(stepCount),
                                @"date":@(startTimeInterval)
                                }];
        if (completion){
            completion([[valueArray reverseObjectEnumerator] allObjects]);
        }

    }];
    [store executeQuery:query];
}

@end
 
 */
