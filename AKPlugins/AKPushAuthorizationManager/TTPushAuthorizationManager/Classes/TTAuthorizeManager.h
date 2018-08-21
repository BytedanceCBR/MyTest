//
//  TTAuthorizeManager.h
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

/**
 需求背景
 1、请求权限时机不当、收益不明确，用户授权率低。
 2、用户拒绝授权后很难再次挽回。
 
 优化方向
 1、请求权限时先弹自己的弹窗，再真正请求。
 2、合适场景多次引导开启通讯录、推送、定位权限。
 3、应用设置中的推送开关状态和系统设置一致、未开启有提醒
 
 https://wiki.bytedance.com/pages/viewpage.action?pageId=27787468
*/

#import <Foundation/Foundation.h>
#import "TTAuthorizeModel.h"
#import "TTAuthorizePushObj.h"
#import "TTAuthorizeLocationObj.h"
#import "TTAuthorizeLoginObj.h"


extern NSString * const TTFollowSuccessForPushGuideNotification;
extern NSString * const TTCommentSuccessForPushGuideNotification;
extern NSString * const TTWDFollowPublishQASuccessForPushGuideNotification; // 问答中关注问题、提问和回答、评论
extern NSString * const TTUGCPublishSuccessForPushGuideNotification; // UGC中发帖成功

#define TTAuthorizePushGuideChangeFireReason(reason)  \
do {    \
    [TTAuthorizeManager sharedManager].pushObj.authorizeModel.pushFireReason = reason;    \
} while(NO)

@interface TTAuthorizeManager : NSObject

+ (instancetype)sharedManager;

///*
// 通讯录授权
// */
//@property(nonatomic,strong)TTAuthorizeAddressBookObj *addressObj;

/*
 推送授权
 */
@property(nonatomic,strong)TTAuthorizePushObj *pushObj;

/*
 登录授权
 */
@property(nonatomic,strong)TTAuthorizeLoginObj *loginObj;

/*
 定位授权
 */
@property(nonatomic,strong)TTAuthorizeLocationObj *locationObj;

/*
 model
 */
- (TTAuthorizeModel *)authorizeModel;

@end
