//
//  CommonwealManager.h
//  Article
//
//  Created by wangdi on 2017/8/7.
//
//

#import <Foundation/Foundation.h>


@interface TTCommonwealManager : NSObject

+ (instancetype)sharedInstance;

- (void)startMonitor;
- (NSTimeInterval)todayUsingTime;
- (NSString *)commonwealSkipURL;
- (BOOL)shouldShowTips;
- (void)setHasShowCommonwealTips:(BOOL)hasShow;
- (BOOL)getHasShowCommonwealTips;
- (BOOL)receiveMoneyEnable;
- (double)receiveMoney;
- (void)trackerWithSource:(NSString *)source;
- (void)uploadTodayUsingTimeWithCompletion:(void (^)(BOOL canGetMoney,double money,NSTimeInterval todayUsingTime))completion;

@end
