//
//  TTAccountUserAuditSet+MethodsHelper.h
//  Article
//
//  Created by liuzuopeng on 04/06/2017.
//
//

#import <TTAccountSDK/TTAccountSDK.h>



@interface TTAccountUserAuditSet (MethodsHelper)

- (BOOL)isAuditing;
- (BOOL)modifyUserInfoEnabled;

/**
 *  审核中展示的信息
 */
- (NSString *)username;
- (NSString *)userDescription;
- (NSString *)userAvatarURLString;

/**
 *  可在个人信息中显示的信息
 */
- (NSString *)showingUsername;
- (NSString *)showingUserDescription;
- (NSString *)showingUserAvatarURLString;

- (void)setUsername:(NSString *)name;
- (void)setUserDescription:(NSString *)desp;
- (void)setUserAvatarURLString:(NSString *)imageURLString;

@end
