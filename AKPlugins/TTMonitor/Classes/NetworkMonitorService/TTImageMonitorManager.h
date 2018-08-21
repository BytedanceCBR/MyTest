//
//  TTImageMonitorManager.h
//  Pods
//
//  Created by 苏瑞强 on 2017/6/8.
//
//

#import <Foundation/Foundation.h>
#import "TTNetworkMonitorTransaction.h"

@interface TTImageMonitorManager : NSObject

@property (nonatomic, strong) NSMutableDictionary * imageTrackers;
@property (nonatomic, assign) NSInteger pollingInterval;

+ (instancetype)sharedImageMonitor;

+ (BOOL)isImageRequest:(NSString *)url;

- (void)recordIfNeed:(TTNetworkMonitorTransaction *)transaction;

- (NSArray *)packageImageMonitorData;
@end

