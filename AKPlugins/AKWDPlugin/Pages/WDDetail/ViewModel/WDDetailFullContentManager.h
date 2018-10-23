//
//  WDDetailFullContentManager.h
//  wenda
//
//  Created by xuzichao on 2017/2/20.
//  Copyright © 2017年 延晋 张. All rights reserved.
//

#import "TTServiceCenter.h"
#import "WDApiModel.h"

extern NSString * const kWDFullAnswerData;
extern NSString * const kWDFullExtraData;

@class WDAnswerEntity;
@protocol WDDetailFullContentManagerDelegate ;


@interface WDDetailFullContentManager : NSObject <TTService>


@property (nonatomic, assign) double threadPriority;//default is 0.5
@property (nonatomic, weak) id<WDDetailFullContentManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)fetchDetailForAnswerEntity:(WDAnswerEntity *)entity
                            useCDN:(BOOL)useCDN;

- (void)fetchDetailForAnswerEntity:(WDAnswerEntity *)entity
             withOperationPriority:(NSOperationQueuePriority)priority
                           atIndex:(NSUInteger)index
                       notifyError:(BOOL)notifyError
                            useCDN:(BOOL)useCDN;

- (void)cancelAllRequests;
- (void)suspendAllRequests;
- (void)resumeAllRequests;

@end

@protocol WDDetailFullContentManagerDelegate <NSObject>

- (void)fetchDetailManager:(WDDetailFullContentManager *)manager finishWithResult:(NSDictionary *)result;

@end
