//
//  SSCommonDefines.h
//  Pods
//
//  Created by jinqiushi on 2018/2/8.
//  从SSCommonLogic中拷贝过来的宏定义。

#ifndef SSCommonDefines_h
#define SSCommonDefines_h

// error definition
#define kCommonErrorDomain                  @"kCommonErrorDomain"
#define kNoNetworkErrorCode                 1001
#define kAuthenticationFailCode             1002
#define kSessionExpiredErrorCode            1003
#define kChangeNameExistsErrorCode          1004
#define kUserNotExistErrorCode              1006
#define kMissingSessionKeyErrorCode         1007
#define kInvalidDataFormatErrorCode         1009
#define kUndefinedErrorCode                 1010
#define kExceptionErrorCode                 1011 // note: not all exceptions are error, exception should be handled individually, not by handleError method
#define kMissingKeywordCode                 1012
#define kListHasNoMoreDataErrorCode         1013
#define kInvalidSeverStatusErrorCode        1014
#define kServerUnAvailableErrorCode         1015
#define kUGCAntispamErrorCode               1016
#define kAccountBoundForbidCode             1017 // 禁止绑定切换
#define kUGCUserPostTooFastErrorCode        1018
#define kTTResolveServerDataErrorCode       1019

//手机号注册相关
#define kPRNeedCaptchaCode                  1020
#define kPRWrongCaptchaErrorCode            1021
#define kPRExpiredCaptchaErrorCode          1022
#define kPRHasRegisteredErrorCode           1023
#define kPROtherErrorCode                   1024
#define kPRPhoneNumberEmptyErrorCode        1025

#define kInvalidURLErrorCode                1026    //非法URL
#define kListConditionChangedErrorCode      1027    //列表条件改变

#define kTTUserIsBlockedErrorCode           1408    //用户被拉黑错误码

#define kWebContentProtectDefaultInterval   3.f

#define kDataErrorTipMessage                NSLocalizedString(@"数据出现问题，请稍后再试", nil)
#define kJSONParseErrorTipMessage           NSLocalizedString(@"获取网络失败，请稍后重试", nil)
#define kNoNetworkTipMessage                NSLocalizedString(@"没有网络连接，请稍后再试", nil)
#define kNetworkConnectionErrorTipMessage   NSLocalizedString(@"网络出现问题，请稍后再试", nil)
#define kNetworkConnectionTimeoutTipMessage NSLocalizedString(@"连接超时，请稍后再试", nil)
#define kNetworkConnectionHijackTipMessage  NSLocalizedString(@"网络被劫持，请稍后再试", nil)
#define kSessionExpiredTipMessage           NSLocalizedString(@"帐号已过期，请重新登录", nil)
#define kUserNotExistTipMessage             NSLocalizedString(@"用户不存在", nil)
#define kUserAuthErrorTipMessage            NSLocalizedString(@"用户验证失败，请重新登录", nil)
#define kExceptionTipMessage                NSLocalizedString(@"服务异常，请稍后重试", nil)
#define kUGCAntispamTipMessage              NSLocalizedString(@"内容不符合规定", nil)
#define kAccountBountForbidMessage          NSLocalizedString(@"此账号已存在绑定！为了保证账号安全，请您退出和原账号的绑定以继续。", nil)
#define kUGCUserPostTooFastTipMessage       NSLocalizedString(@"你发的太快了，休息一会", nil)

#define kNotInterestTipUserLogined          NSLocalizedString(@"将减少推荐类似内容", nil)
#define kNotInterestTipUserUnLogined        NSLocalizedString(@"将减少类似内容，登录后推荐更准确", nil)
#define kNotInterestTipUserRepined          NSLocalizedString(@"将减少推荐类似内容，并取消收藏该文章", nil)

#define kTTResolveServerDataErrorMessage    NSLocalizedString(@"服务端返回数据格式与规定不一致，解析错误", nil)

#define kErrorDisplayMessageKey             @"message"
#define kResponseStatusCodeKey              @"kResponseStatusCodeKey"

// userinfo key
#define kExpiredPlatformKey                 @"kExpiredPlatformKey"

// notification
//#define kSessionExpiredNotification         @"kSessionExpiredNotification"
//#define kPlatformExpiredNotification        @"kPlatformExpiredNotification"

#define kAccountBoundForbidAlertShowNotification     @"kAccountBoundForbidAlertShowNotification"

#define kRNCellNewUserActionInterestWordsDictionary @"kRNCellNewUserActionInterestWordsDictionary"
#define kTTRNCellActiveRefreshListViewNotification @"kTTRNCellActiveRefreshListViewNotification"
#define kUserDefaultNewUserActionKey @"kUserDefaultNewUserActionKey"

#define TTLiveMainVCDeallocNotice          @"TTLiveMainVCDeallocNotice"
#define TTLiveMainVCIncreaseNewFollowNotice @"TTLiveMainVCIncreaseNewFollowNotice"
#define kClearCacheHeightNotification       @"kClearCacheHeightNotification"
#define kClearCachedCellTypeNotification    @"kClearCachedCellTypeNotification"
#define kRootViewWillTransitionToSize       @"kRootViewWillTransitionToSize"
#define kExpandRecommendCardNotification @"kExpandRecommendCardNotification"


#define forwardCommentMaxLength             137
#define TTNavigationBarHeight               44.f
#define kUIInitializedNotification          @"kUIInitializedNotification"

#define kFeedItemIndexUnixTimeMultiplyPara          (10000 * 100000)


#endif /* SSCommonDefines_h */
