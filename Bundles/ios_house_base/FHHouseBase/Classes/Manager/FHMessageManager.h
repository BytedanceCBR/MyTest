//
//  FHMessageManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageManager : NSObject

- (void)startSyncMessage;
- (void)stopSyncMessage;
- (void)reduceSystemMessageTabBarBadgeNumber:(NSInteger)reduce;
- (NSInteger)getTotalUnreadMessageCount;
- (void)writeUnreadSystemMsgCount:(NSUInteger)count;
- (void)writeUnreadChatMsgCount:(NSUInteger)unreadCount;
- (void)refreshBadgeNumber;

- (NSInteger)systemMsgUnreadNumber;
- (NSInteger)ugcMsgUnreadNumber;
- (NSInteger)chatMsgUnreadNumber;
@end

NS_ASSUME_NONNULL_END
