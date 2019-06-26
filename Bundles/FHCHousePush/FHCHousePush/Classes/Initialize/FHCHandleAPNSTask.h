//
//  FHCHandleAPNSTask.h
//  FHCHousePush
//
//  Created by 张静 on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import <TTAppRuntime/TTStartupTask.h>

@protocol ArticleAPNsManagerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface FHCHandleAPNSTask : TTStartupTask<ArticleAPNsManagerDelegate,UIApplicationDelegate>

+ (NSString *)deviceTokenString;

@end

NS_ASSUME_NONNULL_END
