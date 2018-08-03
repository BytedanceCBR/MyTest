//
//  TTXiguaLiveManager.h
//  Article
//
//  Created by lishuangyang on 2017/12/14.
//

#import <Foundation/Foundation.h>
#import "TTLRoomManager.h"

static NSString * const TTXiguaGroupSource = @"22";

@interface TTXiguaLiveManager : NSObject<TTLRoomManagerDelegate>

+ (instancetype)sharedManager;
/**
 * 创建直播房间
 */
- (UIViewController *)boadCastRoomWithExtraInfo:(NSDictionary *)extra;
/**
 *根据直播用户UserID获取直播房间 「优先使用UserID获取房间,使用该方法则认为无法获取userId」
 */
- (UIViewController *)audienceRoomWithUserID:(NSString *)userID extraInfo:(NSDictionary *)extra;
/**
 *根据直播用户UserID获取直播房间
 */
- (UIViewController *)audienceRoomWithRoomID:(NSString *)roomID extraInfo:(NSDictionary *)extra;
/**
 *主播钱包入口
 */
- (__kindof UIViewController *)walletViewControllerWithExtraInfo:(NSDictionary *)extraInfo;
/**
 *判断是否已经在即将进入的直播间
 */
- (BOOL)isAlreadyInThisRoom:(NSString *)roomID userID:(NSString *)userID;

- (void)setTrackLogDictionary:(NSDictionary *)extraTrackDic;

@end
