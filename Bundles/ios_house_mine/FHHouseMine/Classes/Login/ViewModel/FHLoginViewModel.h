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

@interface FHLoginSharedModel : NSObject

+ (instancetype)sharedModel;

@property (nonatomic, assign) BOOL hasPushedLoginProcess;
@property (nonatomic, assign) BOOL hasRequestedApis;

- (void)loadOneKayAndDouyinConfigs:(void (^)(void))completion;

@property (nonatomic, assign) BOOL disableDouyinOneClickLoginSetting;
@property (nonatomic, assign) BOOL disableDouyinIconLoginSetting;

@property (nonatomic, assign) BOOL isOneKeyLogin;
@property (nonatomic, copy) NSString *mobileNumber;
@property (nonatomic, assign) BOOL *douyinCanQucikLogin;


@end

@interface FHLoginViewModel : NSObject<FHLoginViewDelegate>

- (instancetype)initWithController:(FHLoginViewController *)viewController;

@property (nonatomic, assign) FHLoginProcessType processType;
@property (nonatomic, strong) TTAcountFLoginDelegate *loginDelegate;
@property (nonatomic, assign) BOOL needPopVC;
@property (nonatomic, assign) BOOL present;
@property (nonatomic, assign)   BOOL  isNeedCheckUGCAdUser;
@property (nonatomic, copy) NSString *mobileNumber;

/// 抖音登录冲突，选择绑定手机号流程，保存profilekey参数
@property (nonatomic, copy) NSString *profileKey;


/// 这个回调，是请求判断是否支持运营商登录，请求判断是否支持抖音一键登录以后的回调
/// 只适用于FHLoginViewController 回调，type变化后view会跟着变化
@property (nonatomic, copy) void (^loginViewViewTypeChanged)(FHLoginViewType type);

/// 验证码页面的回调
@property (nonatomic, copy) void (^updateTimeCountDownValue)(NSInteger secondsValue);

/// 验证码错误回调，需要清除验证码
@property (nonatomic, copy) void (^clearVerifyCodeWhenError)(void);

/// 请求运营商和抖音登录的权限
- (void)startLoadData;

/// 用户协议
/// @param viewType 根据 type 不同返回不同的协议
- (NSAttributedString *)protocolAttrTextByIsOneKeyLoginViewType:(FHLoginViewType )viewType;

/// 如果是运营商，返回运营商名称
+ (NSString *)serviceName;

/// 包含苹果登录，如果没有抖音登录，则没有三方登录
- (BOOL)shouldShowDouyinIcon;

- (void)viewWillAppear;

+ (NSMutableAttributedString *)protocolAttrTextForOneKeyLoginViewType;

@end

NS_ASSUME_NONNULL_END
