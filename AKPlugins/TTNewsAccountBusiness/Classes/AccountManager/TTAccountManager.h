//
//  TTAccountManager.h
//  Article
//
//  Created by liuzuopeng on 5/19/17.
//
//

#import <Foundation/Foundation.h>
#import <TTAccountLoginManager.h>
#import "TTAccountManagerDefine.h"
#import "TTThirdPartyAccountsHeader.h"
#import "AccountInfoFactory.h"
#import "TTPlatformAccountManager.h"
#import "TTAccountVersionAdapter.h"
#import "TTAccountUserAuditSet+MethodsHelper.h"



/**
 *  封装新的账号TTAccount，并兼容老的账号AccountManager相关信息
 */
@class SSMyUserModel;
@interface TTAccountManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic,   copy, class) NSString *draftMobile;

#pragma mark - 用户信息

/** 用户信息实体 */
+ (TTAccountUserEntity *)currentUser;

// 兼容老版本
@property (nonatomic, strong) SSMyUserModel *myUser;

- (void)synchronizeOldMyUser;

@property (nonatomic, assign, class) BOOL isLogin;

+ (NSString *)sessionKey;

@property (nonatomic,   copy, class, readonly) NSString *userID;

+ (long long)userIDLongInt;

+ (TTAccountUserType)accountUserType;

@property (nonatomic,   copy, class, readonly) NSString *mediaID;

+ (long long)mediaIDLongInt;

@property (nonatomic,   copy, class) NSString *userName;

@property (nonatomic,   copy, class) NSString *avatarURLString;

@property (nonatomic,   copy, class, readonly) NSString *userDecoration;

// https://wiki.bytedance.net/pages/viewpage.action?pageId=76126155
@property (nonatomic,   copy, class) NSString *userAuthInfo; //头条认证展现

@property (nonatomic,   copy, class) NSString *userGender;

// 我的Tab顶部用户名下面文案
@property (nonatomic,   copy, class) NSString *showInfo;

/** 判断某个用户是否是登录用户 */
- (BOOL)isAccountUserOfUID:(NSString *)uid;

/** 判断用户认证信息是否是通过头条认证 */
+ (BOOL)isVerifiedOfUserVerifyInfo:(NSString *)verifyInfo;

@end



@interface TTAccountManager (FriendRelationshipTextHelper)
// 好友关系（关注、粉丝、游客、动态）文案
@property (nonatomic, copy, class) NSString *followingString;
@property (nonatomic, copy, class) NSString *followerString;
@property (nonatomic, copy, class) NSString *visitorString;
@property (nonatomic, copy, class) NSString *momentString;
@end



#pragma mark - TTAccountManager (AccountUserSynchronization)

/**
 *  与服务端同步账号用户状态
 */
@interface TTAccountManager (AccountUserSynchronization)

+ (void)startGetAccountStatus:(BOOL)displayExpirationError;

+ (void)startGetAccountStatus:(BOOL)displayExpirationError
                      context:(id)context;

+ (BOOL)tryAssignAccountInfoFromKeychain;

@end



#pragma mark - TTAccountManager (LoginPanelPresentor)

@interface TTAccountManager (LoginPanelPresentor)

/**
 *  弹起大登录弹窗
 *
 *  @param vc               presenting vc
 *  @param type             弹窗标题文案类型
 *  @param source           调起登录的来源，从pm文档里查找
 *  @param isPasswordStyle  调起大弹窗默认是否是账号密码页面
 *  @param completion       回调
 */
+ (void)presentQuickLoginFromVC:(UIViewController *)vc
                           type:(TTAccountLoginDialogTitleType)type
                         source:(NSString *)source
                isPasswordStyle:(BOOL)isPasswordStyle
                     completion:(TTAccountLoginCompletionBlock)completedBlock;

+ (void)presentQuickLoginFromVC:(UIViewController *)vc
                           type:(TTAccountLoginDialogTitleType)type
                         source:(NSString *)source
                     completion:(TTAccountLoginCompletionBlock)completedBlock;

+ (void)presentQuickLoginFromVC:(UIViewController *)vc
                           type:(TTAccountLoginDialogTitleType)type
                         source:(NSString *)source
            subscribeCompletion:(TTAccountLoginCompletionBlock)completedBlock;

+ (void)presentQuickLoginFromHTSModuleWithType:(TTAccountLoginDialogTitleType)type
                                        source:(NSString *)source;

/**
 *  弹出小登录弹窗，点击更多按钮执行回调参数为TTAccountAlertCompletionEventTypeTip
 *
 *  @param type      弹窗标题文案类型
 *  @param source    调起登录的来源，从pm文档里查找
 *  @param completedBlock 回调
 */
+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

/**
 *  弹出小登录弹窗，点击更多按钮不会执行TTAccountAlertCompletionEventTypeTip的回调直接打开登录大窗
 *
 *  @param type      弹窗标题文案类型
 *  @param source    调起登录的来源，从PM文档里查找
 *  @param completedBlock 回调
 */
+ (TTAccountLoginAlert *)showQuickLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                              source:(NSString *)source
                                          completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

+ (TTAccountLoginAlert *)showLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                         source:(NSString *)source
                                    inSuperView:(UIView *)superView
                                     completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

+ (TTAccountLoginAlert *)showQuickLoginAlertWithType:(TTAccountLoginAlertTitleType)type
                                              source:(NSString *)source
                                         inSuperView:(UIView *)superView
                                          completion:(TTAccountLoginAlertPhoneInputCompletionBlock)completedBlock;

@end


