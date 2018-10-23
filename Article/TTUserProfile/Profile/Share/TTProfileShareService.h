//
//  TTProfileShareModule.h
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import <Foundation/Foundation.h>


/**
 *  个人（自己或者好友）主页分享服务模块
 *  当用户进入个人主页（h5或RN）时，会将分享的内容发送给native，native保存在本地
 *
 *
 *  window.ToutiaoJSBridge.call('init_profile',{
 *      data : {
 *      user_id : userId,
 *      name : screenName ,
 *      avatar_url : userLogo,
 *      description : userDescription,
 *      share_url : location.href
 *      }
 *  });
 */
@interface TTProfileShareService : NSObject
+ (NSDictionary *)shareObjectForUID:(NSString *)uid;
+ (void)setShareObject:(NSDictionary *)data forUID:(NSString *)uid;
+ (BOOL)isBlockingForUID:(NSString *)uid;
+ (void)setBlocking:(BOOL)isBlocking forUID:(NSString *)uid;
@end
