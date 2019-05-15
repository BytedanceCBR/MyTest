//
//  AKTaskSettingHelper.h
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import <Foundation/Foundation.h>

#define kAKBenefitSettingValueUpdateNotification @"kAKBenefitSettingValueUpdateNotification"

@interface AKTaskSettingHelper : NSObject

+ (instancetype)shareInstance;

//显示金币获得提示框
- (BOOL)isEnableShowCoinTip;
- (void)setShowCoinTip:(BOOL)enable;

//显示任务入口
- (BOOL)isEnableShowTaskEntrance;
- (void)setShowTaskEntrance:(BOOL)enable;
- (BOOL)akBenefitEnable;
- (BOOL)appIsReviewing;//审核期间的开关，主要控一些敏感信息

//setting下来之后，更新benefitEnable
- (void)updateBenefitValue;

- (BOOL)isEnableWith:(NSString *)key;
- (void)setEnable:(BOOL)enable key:(NSString *)key;
@end
