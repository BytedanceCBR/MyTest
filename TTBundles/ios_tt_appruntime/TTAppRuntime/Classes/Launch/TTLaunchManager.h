//
//  TTLaunchManager.h
//  TTAppRuntime
//
//  Created by 春晖 on 2019/5/30.
//

#import <Foundation/Foundation.h>
#import "TTLaunchDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTLaunchManager : NSObject

@property(nonatomic , strong, readonly) NSMutableDictionary *lauchGroupsDict;

+(instancetype)sharedInstance;

+(void)setPreMainDate:(NSDate *)date;

+ (NSTimeInterval)processStartTime;//timestamp in ms

+(void)dumpLaunchDuration;

-(void)launchWithApplication:(UIApplication *)application andOptions:(NSDictionary *)options;

- (NSString *)taskTypeToString:(FHTaskType)type;

@end

NS_ASSUME_NONNULL_END
