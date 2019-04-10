//
//  SSBaseAlert.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-7.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^shouldAlert)(id context);

@class SSBaseAlertModel;

@interface SSBaseAlertManager : NSObject

@property (nonatomic, strong) NSMutableArray *alertModels;
@property (nonatomic, assign) BOOL isConcurrency;   // 子类自己控制并发还是外界控制
@property (nonatomic, copy) shouldAlert shouldAlertBlock;

// public
+ (id)alertManager;
- (void)startAlert;
- (void)startAlertAfterDelay:(NSTimeInterval)delay concurrency:(BOOL)isConcurrency;

// extends
- (NSString *)urlPrefix;
- (NSDictionary *)parameterDict;
- (NSArray *)handleAlert:(NSDictionary *)result;
- (void)handleError:(NSError *)error;
- (void)clickedButtonAtIndex:(NSInteger)buttonIndex alertModel:(SSBaseAlertModel *)alertModel;

@end
