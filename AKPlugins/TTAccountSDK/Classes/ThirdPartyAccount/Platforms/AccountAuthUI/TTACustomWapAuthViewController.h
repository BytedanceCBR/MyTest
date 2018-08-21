//
//  TTACustomWapAuthViewController.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/21/17.
//
//

#import <UIKit/UIKit.h>
#import "TTAccountAuthDefine.h"



@class TTACustomWapAuthViewController;
@protocol TTACustomWapAuthViewControllerDelegate <NSObject>
@optional
/**
 *  手动点击或滑动触发（通过Dismiss Or Pop or 滑动）返回时回调
 *
 *  @param  wapViewController auth容器实例
 *  @param  dismissOrPop 通过dismiss还是pop返回ViewController
 */
- (void)wapLoginViewController:(TTACustomWapAuthViewController *)wapViewController
      didBackManuallyByDismiss:(BOOL)dismissOrPop;

/**
 *  WAP登录失败的回调
 *
 *  @param  wapViewController auth容器实例
 *  @param  error 错误信息
 */
- (void)wapLoginViewController:(TTACustomWapAuthViewController *)wapViewController
              didFailWithError:(NSError *)error;

/**
 *  WAP登录成功的回调
 *
 *  @param  wapViewController auth容器实例
 *  @param  resultDict 第三方平台回调返回的信息@{@"code": ***, @"state": ***}
 *
 */
- (void)wapLoginViewController:(TTACustomWapAuthViewController *)wapViewController
           didFinishWithResult:(NSDictionary *)resultDict;
@end



@interface TTACustomWapAuthViewController : UIViewController

/**
 *  初始化
 *
 *  @param url  request url
 */
- (instancetype)initWithURL:(NSURL *)url;

/**
 *  URL
 */
@property (nonatomic, strong) NSURL *url;

/**
 *  Delegate
 */
@property (nonatomic,   weak) id<TTACustomWapAuthViewControllerDelegate> delegate;

/**
 *  第三方平台类型
 */
@property (nonatomic, assign) TTAccountAuthType authPlatformType;

/**
 *  第三方平台名称
 */
@property (nonatomic,   copy) NSString *authPlatformName;

/**
 *  是否隐藏SNSBar
 */
@property (nonatomic, assign) BOOL snsBarHidden;

/**
 *  SendToSNSBottomBar文案
 */
@property (nonatomic,   copy) NSString *snsText;

/**
 *  Wap登录成功后，服务端重定向的URL scheme前缀 [Default: snssdk]
 */
@property (nonatomic,   copy) NSString *schemePrefix;

@end



@interface UINavigationController (CustomWapAuthInit)

- (instancetype)initWithWapAuthViewController:(TTACustomWapAuthViewController *)wapAuthVC;

@end



#define TTACCOUNTSDK_PRESENT_WAPAUTHVIEWCONTROLLER()   \
({  \
TTACustomWapAuthViewController *wapAuthVC = [TTACustomWapAuthViewController new];   \
wapAuthVC.title   = [self.class displayName];   \
wapAuthVC.snsText = [[TTAccount accountConf] tta_SNSBarTextForPlatformType:[self.class platformType]];  \
wapAuthVC.snsBarHidden = [[TTAccount accountConf] tta_SNSBarHiddenForPlatformType:[self.class platformType]];   \
wapAuthVC.authPlatformType = [self.class platformType]; \
wapAuthVC.authPlatformName = [self.class platformName]; \
wapAuthVC.delegate = self;  \
\
UINavigationController *navController = [[UINavigationController alloc] initWithWapAuthViewController:wapAuthVC];   \
UIViewController *currentVC = [[TTAccount accountConf] tta_currentViewController];  \
[currentVC presentViewController:navController animated:YES completion:^{}];    \
})

