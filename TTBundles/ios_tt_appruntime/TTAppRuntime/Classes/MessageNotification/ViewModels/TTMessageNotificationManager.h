//
//  TTMessageNotificationManager.h
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "TTMessageNotificationModel.h"
#import "TTMessageNotificationMacro.h"

@interface TTMessageNotificationManager : NSObject

+ (instancetype)sharedManager;

@property(nonatomic, strong) NSNumber *curListReadCursor;

/** 定时轮询未读消息通知，在拉取到消息后会发出Notification */
- (void)startPeriodicalFetchUnreadMessageNumberWithChannel:(NSString *)channel;

/** 取消未读消息的定时轮询 */
- (void)stopPeriodicalFetchUnreadMessageNumber;

/** 手动拉取未读消息通知，在拉取到消息后会发出Notification */
- (void)fetchUnreadMessageWithChannel:(NSString *)channel;

- (void)fetchMessageListWithChannel:(NSString *)channel // 如果为nil默认为all
                             cursor:(NSNumber *)cursor // 如果为nil默认为0
                    completionBlock:(void(^)(NSError *error, TTMessageNotificationResponseModel *response))completionBlock;

/** 判断当前的cursor是否达到了已读/未读的分界线cursor */
- (BOOL)isReachUnreadWithCursor:(NSNumber *)cursor readCursor:(NSNumber *)readCursor;

@end
