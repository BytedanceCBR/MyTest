//
//  TTActivitiesManager.h
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/1.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityProtocol.h"

@interface TTActivitiesManager : NSObject

+ (instancetype)sharedInstance;

- (void)addValidActivitiesFromArray:(NSArray *)activities;

- (void)addValidActivity:(id <TTActivityProtocol>)activity;

- (NSArray *)validActivitiesForContent:(NSArray *)contentArray;

- (id <TTActivityProtocol>)getActivityByItem:(id <TTActivityContentItemProtocol>)item;

@end
