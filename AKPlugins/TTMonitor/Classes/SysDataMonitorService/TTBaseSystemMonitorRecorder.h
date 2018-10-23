//
//  TTBaseSystemMonitorRecorder.h
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import <Foundation/Foundation.h>
#import "TTMonitorConfiguration.h"

@interface TTBaseSystemMonitorRecorder : NSObject

@property (nullable,nonatomic, strong)NSString * type;
@property (nonatomic, assign)double value;
@property (nonatomic, assign)double monitorInterval;

- (BOOL)isEnabled;

- (void)recordIfNeeded:(BOOL)isTermite;

- (void)handleAppEnterBackground;
- (void)handleAppEnterForground;

+ (nullable NSString *)latestActionKey:(nullable NSString *)type;

@end
