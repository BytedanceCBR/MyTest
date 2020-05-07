//
//  FHLoginViewModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import <Foundation/Foundation.h>
#import "FHLoginViewController.h"
#import "FHLoginView.h"
#import "TTAccountLoginManager.h"
#import "FHLoginDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginViewModel : NSObject<FHLoginViewDelegate>

- (instancetype)initWithController:(FHLoginViewController *)viewController;

@property (nonatomic, assign) FHLoginProcessType processType;

//屏蔽TTNavigationViewController带来的键盘变化
@property (nonatomic, assign) BOOL isHideKeyBoard;
@property (nonatomic, strong) TTAcountFLoginDelegate *loginDelegate;
@property (nonatomic, assign) BOOL needPopVC;
@property (nonatomic, assign) BOOL noDismissVC;
@property (nonatomic, assign) BOOL present;
@property (nonatomic, assign) BOOL isOneKeyLogin;
@property (nonatomic, assign) BOOL isOtherLogin;
@property (nonatomic, assign) BOOL douyinCanQucikLogin;
@property (nonatomic, assign)   BOOL  isNeedCheckUGCAdUser;
@property (nonatomic , copy) NSString *mobileNumber;

/// 这个回调，是请求判断是否支持运营商登录，请求判断是否支持抖音一键登录以后的回调
/// 只适用于FHLoginViewController 回调，type变化后view会跟着变化
@property (nonatomic, copy) void (^loginViewViewTypeChanged)(FHLoginViewType type);

/// 验证码页面的回调
@property (nonatomic, copy) void (^updateTimeCountDownValue)(NSInteger secondsValue);

/// 验证码错误回调，需要清除验证码
@property (nonatomic, copy) void (^clearVerifyCodeWhenError)(void);

/// 请求运营商和抖音登录的权限
- (void)startLoadData;
- (void)addEnterCategoryLog;

/// 用户协议
/// @param viewType 根据 type 不同返回不同的协议
- (NSAttributedString *)protocolAttrTextByIsOneKeyLoginViewType:(FHLoginViewType )viewType;

/// 如果是运营商，返回运营商名称
- (NSString *)serviceName;

@end

NS_ASSUME_NONNULL_END
