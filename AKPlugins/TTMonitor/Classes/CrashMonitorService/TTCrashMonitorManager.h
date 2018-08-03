//
//  TTCrashMonitorManager.h
//  Article
//
//  Created by 苏瑞强 on 16/10/25.
//
//

#import <Foundation/Foundation.h>

@interface TTCrashMonitorManager : NSObject

@property (nonatomic, assign) BOOL enabled;


+ (instancetype)defaultMonitorManager;

- (void)cacheOneSStrackItemlog:(NSDictionary *)applogData;

- (void)cacheOneDevItemDevLog:(NSString *)devData;

- (void)cacheOneMonitorItemLog:(NSString *)devData;

- (void)cacheAppSettings:(NSDictionary *)settingsData;

- (void)sendMonitedData;

- (void)saveToDisk:(id)sender;
@end
