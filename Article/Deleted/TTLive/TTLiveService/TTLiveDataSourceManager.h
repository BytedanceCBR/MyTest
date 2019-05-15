//
//  TTLiveDataSourceManager.h
//  Article
//
//  Created by matrixzk on 8/2/16.
//
//

#import <Foundation/Foundation.h>

@class TTLiveMainViewController, TTLiveTabCategoryItem, TTLiveTopBannerInfoModel, TTLiveStreamDataModel;

@interface TTLiveDataSourceManager : NSObject

- (instancetype)initWithChatroom:(TTLiveMainViewController *)chatroom;

- (void)fetchHeaderInfoWithLiveId:(NSString *)liveId finishBlock:(void(^)(NSError *error, TTLiveTopBannerInfoModel *headerInfo, NSString *tips))finishBlock;

// 获取数据流数据
- (void)fetchStreamDataWithChannelItem:(TTLiveTabCategoryItem *)channelItem
                             isPolling:(BOOL)isPolling
                           resultBlock:(void (^)(NSError *error, TTLiveStreamDataModel *streamDataModel))resultBlock;

- (void)adjustPollingTimerWithTimeInterval:(NSTimeInterval)newInterval;

/// 将 NSDate 格式化为 hh:mm 的字符串格式。
- (NSString *)formattedTimeWithDate:(NSDate *)date;

- (void)uploadParise;
- (void)pauseTimer;
- (void)resumeTimer;

@end
