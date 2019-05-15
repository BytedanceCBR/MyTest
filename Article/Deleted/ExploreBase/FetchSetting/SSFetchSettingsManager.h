//
//  SSFetchSettingsManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-23.
//
//

#import <Foundation/Foundation.h>

@interface SSFetchSettingsManager : NSObject

@property(nonatomic, copy) NSString *from;
@property(nonatomic, strong, readonly)NSDictionary *settingsDict;

+ (SSFetchSettingsManager *)shareInstance;

//获取默认设置，每个应用仅获取一次。
+ (void)startFetchDefaultInfoIfNeed;


//protected method, don`t invoke
- (void)dealDefaultSettingsResult:(NSDictionary *)dSettings;
- (void)dealAppSettingResult:(NSDictionary *)dSettings;

// Debug method
- (void)startFetchDefaultSettingsWithDefaultInfo:(BOOL)defaultInfo forceRefresh:(BOOL)forceRefresh;

@end
