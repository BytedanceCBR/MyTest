//
//  SSAppRecommendManager.h
//  Essay
//
//  Created by Dianwei on 12-9-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSAppRecommendManager;
@protocol SSAppRecommendManagerDelegate <NSObject>
- (void)appRecommendManager:(SSAppRecommendManager*)manager getInfoRequestFinishedWithResult:(NSDictionary*)result finished:(BOOL)finished;
- (void)appRecommendManager:(SSAppRecommendManager*)manager getStatusCountRequestFinishedWithResult:(NSDictionary*)result;

@end

@interface SSAppRecommendManager : NSObject
@property(nonatomic, assign)NSObject<SSAppRecommendManagerDelegate> *delegate;

- (void)startGetAppInfo;
- (void)startGetStatusForApps:(NSArray*)appNames;
@end
