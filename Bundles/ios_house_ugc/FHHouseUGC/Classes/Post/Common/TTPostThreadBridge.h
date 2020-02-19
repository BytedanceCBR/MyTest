//
//  TTPostThreadBridge.h
//  TTPostImage
//
//  Created by SongChai on 2018/5/18.
//

#import <Foundation/Foundation.h>
#import "TTPostThreadTask.h"
//#import "TTRepostThreadModel.h"
#import "TTRichSpanText.h"
#import <TTImagePicker/TTImagePickerTrackManager.h>
#import <TTImagePicker/TTAssetModel.h>

#ifndef kTTWeitoutiaoCategoryID
#define kTTWeitoutiaoCategoryID @"weitoutiao"      //微头条频道
#endif

#ifndef kTTFollowCategoryID
#define kTTFollowCategoryID     @"关注"
#endif

#ifndef kTTMainConcernID
#define kTTMainConcernID        @"6286225228934679042"
#endif

#ifndef kTTWeitoutiaoConcernID
#define kTTWeitoutiaoConcernID  @"6368255615201970690"
#endif

#ifndef KTTFollowPageConcernID
#define KTTFollowPageConcernID  @"6454692306795629069"
#endif



@protocol TTPostThreadBridgeDelegate<NSObject>

@required
/**
 高德的key
 如果用地理位置服务必须要实现
 
 @return 高德key
 */
- (NSString *)amapKey;


/**
 未登陆情况下会先校验是否登陆，弹起带回掉的小登陆框
 必须实现，除非永远是登陆状态
 
 @param source 来源
 @param view 当前viewController.view
 @param completionHandler tips YES表示未登陆，NO表示已登陆
 */
- (void)showLoginAlertWithSource:(NSString *)source superView:(UIView *)view completion:(void (^)(BOOL tips))completionHandler;

@optional
/**
 未登陆情况小登陆框返回登陆未成功，会调用该方法，走大登陆框
 可以不实现
 
 @param vc 当前vc
 @param source 来源
 */
- (void)presentQuickLoginFromVC:(UIViewController *)vc source:(NSString *)source;

/**
 *  由task构造fake thread的dictionary
 *  不需要fake cell不需要实现
 *  @param task 发送任务
 *
 *  @return fake thread dictionary
 */
- (NSDictionary *)fakeThreadDictionary:(TTPostThreadTask *)task;


/**
 处理发送成功后的一些弹窗 -> 头条一般谈引导认证 或者 引导转发抽奖之类
 不需要弹窗不需要实现
 @param dict 发送后的server返回数据
 */
- (void)showGuideViewIfNeedWithDictionary:(NSDictionary *)dict;


/**
 发帖和转发前会从server校验手机号是否需要绑定。
 不实现将不提示绑定手机号，只要登陆就发送

 @param completionHandler 绑定成功时返回
 @return 绑定手机号的viewController
 */
- (UIViewController *)pushBindPhoneNumberWhenPostThreadWithCompletion:(void (^)(void))completionHandler;


/**
 图片选择器埋点
 如果没有可以不实现

 @param eventName 图片选择器的埋点EventName
 @param extraParams 图片选择器的埋点的params
 @return 该埋点发送代理
 */
- (id<TTImagePickTrackDelegate>)imagePickerTrackerWithEventName:(NSString *)eventName extraParams:(NSDictionary *)extraParams;


/**
 是否需要绑定手机号，会在发送和转发前，不请求网络直接调用
 可以不实现

 @return YES标示需要弹绑定手机号
 */
- (BOOL)shouldBindPhone;


/**
 和上述成对使用
 可以不实现

 @param params 一些参数
 */
- (void)jumpToBindPhonePageWithParams:(NSDictionary *)params;

@end

@class TTRepostThreadModel;

typedef NS_ENUM(NSUInteger, TTPostThreadStatus) {
    TTPostThreadStatusImageUploadFailed = 97, //图片上传失败
    TTPostThreadstatusPostThreadFailed = 98, //图片上传成功，但发帖失败
    TTPostThreadstatusPostThreadJSONModelFailed = 100, //JSONModel解析错误
    TTPostThreadStatusPostThreadSucceed = 1, //发帖成功
};

@interface TTPostThreadBridge : NSObject<TTPostThreadBridgeDelegate>

@property (nonatomic, strong) id<TTPostThreadBridgeDelegate> postThreadBridgeDelegate;

+ (instancetype)sharedInstance;

- (void)monitorPostThreadStatus:(TTPostThreadStatus)status
                        extra:(NSDictionary *)extra
                        retry:(BOOL)retry;

- (void)monitorShareSDKParamsSerializationFailureWithExtra:(NSDictionary *)extra;

- (void)trackRepostWithEvent:(NSString *)event label:(NSString *)label repostModel:(TTRepostThreadModel *)repostModel extra:(NSDictionary *)extra;
- (void)trackRepostV3WithEvent:(NSString *)event repostModel:(TTRepostThreadModel *)repostModel extra:(NSDictionary *)extra;

- (void)sendRepostWithRepostModel:(TTRepostThreadModel *)repostModel
                     richSpanText:(TTRichSpanText *)richSpanText
                  isCommentRepost:(BOOL)isCommentRepost
               baseViewController:(UIViewController *)baseViewController
                        trackDict:(NSDictionary *)trackDict
                      finishBlock:(void (^)(void))finishBlock;
@end
