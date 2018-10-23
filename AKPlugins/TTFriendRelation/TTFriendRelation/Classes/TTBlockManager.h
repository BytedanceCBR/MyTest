//
//  TTBlockManager.h
//  Article
//
//  Created by Huaqing Luo on 5/3/15.
//
//

#import <Foundation/Foundation.h>

#define kHasBlockedUnblockedUserNotification @"kHasBlockedUnblockedUserNotification"

#define kBlockedUnblockedUserIDKey @"kBlockedUnblockedUserIDKey"
#define kIsBlockingKey @"kIsBlockingKey"
//#define kIsBlockedKey @"kIsBlockedKey"

@class TTBlockManager;

@protocol TTBlockManagerDelegate <NSObject>

@optional
- (void)blockUserManager:(TTBlockManager *)manager blocResult:(BOOL)success blockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip;

- (void)blockUserManager:(TTBlockManager *)manager unblockResult:(BOOL)success unblockedUserID:(NSString *)userID error:(NSError *)error errorTip:(NSString *)errorTip;

- (void)blockUserManager:(TTBlockManager *)manager getBlockedUsersResult:(NSDictionary *)result error:(NSError *)error;

@end

@interface TTBlockManager : NSObject

@property(nonatomic, weak)id<TTBlockManagerDelegate> delegate;

- (void)blockUser:(NSString *)userID;
- (void)unblockUser:(NSString *)userID;
- (void)getBlockedUsersWithOffset:(NSInteger)offset count:(NSInteger)count;

@end
