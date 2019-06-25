//
//  FHMessageNotificationManager.h
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "TTMessageNotificationModel.h"
#import "FHMessageNotificationMacro.h"

@class TTMessageNotificationTipsModel;
@class FHUnreadMsgDataUnreadModel;

@interface FHMessageNotificationManager : NSObject

+ (instancetype)sharedManager;

@property(nonatomic, strong) NSNumber *curListReadCursor;

/** 定时轮询未读消息通知，在拉取到消息后会发出Notification */
- (void)startPeriodicalFetchUnreadMessageNumberWithChannel:(NSString *)channel;

/** 取消未读消息的定时轮询 */
- (void)stopPeriodicalFetchUnreadMessageNumber;

/** 手动拉取未读消息通知，在拉取到消息后会发出Notification */
- (void)fetchUnreadMessageWithChannel:(NSString *)channel callback:(void(^)(FHUnreadMsgDataUnreadModel *))callback;

- (void)fetchMessageListWithChannel:(NSString *)channel // 如果为nil默认为all
                             cursor:(NSNumber *)cursor // 如果为nil默认为0
                    completionBlock:(void(^)(NSError *error, TTMessageNotificationResponseModel *response))completionBlock;

@end
