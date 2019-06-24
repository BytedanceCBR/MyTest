//
//  TTLaunchManager.h
//  TTAppRuntime
//
//  Created by 春晖 on 2019/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTLaunchManager : NSObject

+(instancetype)sharedInstance;

-(void)launchWithApplication:(UIApplication *)application andOptions:(NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
