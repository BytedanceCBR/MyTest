//
//  TTMonitorStoreItem.h
//  Article
//
//  Created by ZhangLeonardo on 16/3/28.
//
//

#import <Foundation/Foundation.h>

@interface TTMonitorStoreItem : NSObject<NSCoding, NSCopying>

@property(nonatomic, assign)NSInteger retryCount;

- (void)event:(NSString *)type label:(NSString *)label attribute:(float)attribute;

- (BOOL)isEmpty;

- (void)clear;

- (NSArray *)currentPool;

@end
