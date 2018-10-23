//
//  AccountManager.h
//  ShareOne
//
//  Created by Dianwei Hu on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTThirdPartyAccountInfoBase.h"
#import "TTAccountManagerDefine.h"
#import "TTAccountManagerConst.h"
#import "SSMyUserModel.h"



extern NSString * const SSWeiboExpiredKey;
extern NSString * const SSWeiboExpiredNeedAlertKey;

@interface AccountManager : NSObject
@property (nonatomic, strong) SSMyUserModel *myUser;
@property (nonatomic,   copy) NSString      *userName;
@property (nonatomic,   copy) NSString      *userID;
@property (nonatomic,   copy) NSString      *avatarURLString;
@property (nonatomic,   copy) NSString      *avatarLargeURLString;
@property (nonatomic,   copy) NSString      *bgImageURLString;
@property (nonatomic,   copy) NSString      *userDescription; // 用户签名
@property (nonatomic, assign) BOOL          userVerified;
@property (nonatomic,   copy) NSString      *userGender;

// 使用头条号账号登录，对文章发表评论时可以推荐给自己的粉丝
@property (nonatomic, assign, setter=setRecommendAllowed:) BOOL isRecommendAllowed;
@property (nonatomic,   copy) NSString      *recommendHintMessage;

/*
 当用户第一次授权后(后台返回字段告知是否是第一次授权 liuyuzhang负责)
 如果授权前的场景如下, 则授权成功后跳转到"添加好友"页面.
 
 1.用户点击动态页面的"马上登录"
 2.用户从splash引导页授权
 3.点击头条/动态页左上角头像按钮, 进入未登录个人页面, 然后选择其中的平台授权.
 */
@property (nonatomic, strong) NSNumber      *isNewPlatform;    // 用户第一次在这个平台授权
@property (nonatomic, strong) NSNumber      *isNewUser;        // 保留参数，暂时没有用到
@property (nonatomic,   copy) NSString      *draftMobile;
@property (nonatomic, assign) BOOL          isLogin;

/** 账号合并新增 */
@property (nonatomic,   copy) NSString      *mediaID;
@property (nonatomic,   copy) NSString      *showInfo;//我的Tab顶部用户名下面文案
@property (nonatomic,   copy) NSString      *followingString;
@property (nonatomic, assign) long long     followingCount;
@property (nonatomic,   copy) NSString      *followerString;
@property (nonatomic, assign) long long     followerCount;
@property (nonatomic,   copy) NSString      *visitorString;
@property (nonatomic, assign) long long     visitorCount;
@property (nonatomic,   copy) NSString      *momentString;
@property (nonatomic, assign) long long     momentCount;
@property (nonatomic,   copy) NSString      *userAuthInfo; //头条认证展现

+ (AccountManager *)sharedManager;

// return whether has valid session id in key chain in order to auto login
- (BOOL)tryAssignAccountInfoFromKeychain;

@end
