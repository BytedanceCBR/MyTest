//
//  TTInfiniteLoopFetchNewsListRefreshTipManager.h
//  Article
//
//  Created by 王霖 on 2017/6/4.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTInfiniteLoopFetchNewsListRefreshTipManager : NSObject

+ (instancetype)sharedManager;

- (void)newsListLastHadRefreshWithCategoryID:(NSString *)categoryID minBehotTime:(NSTimeInterval)minBehotTime;

- (void)startInfiniteLoopFetchFollowChannelRefreshTip;
- (void)stopInfiniteLoopFetchFollowChannelRefreshTip;

- (void)setChannelTipPollingInterval:(NSArray *)channelTipPollingInterval;
- (NSTimeInterval)getChannelTipPollingIntervalWithcategoryID:(NSString *)categoryID;

@end

NS_ASSUME_NONNULL_END
