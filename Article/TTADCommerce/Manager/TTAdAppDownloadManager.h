//
//  TTAdAppDownloadManager.h
//  Article
//
//  Created by yin on 2017/1/4.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"


@interface  TTAdAppModel: JSONModel <TTAd, TTAdAppAction>

@property (nonatomic, copy) NSString<Optional>* ad_id;
@property (nonatomic, copy) NSString<Optional>* log_extra;
@property (nonatomic, copy) NSString<Optional>* download_url;
@property (nonatomic, copy) NSString<Optional>* apple_id;
@property (nonatomic, copy) NSString<Optional>* open_url;
@property (nonatomic, copy) NSString<Optional>* ipa_url;
@property (nonatomic, copy) NSString<Optional>* appUrl;
@property (nonatomic, copy) NSString<Optional>* tabUrl;

@end

@class ExploreOrderedData;

@protocol TTAdAppDownloadManagerProtocol <NSObject>

- (void)startStayTracker;

- (void)endStayTrackerWithAd_id:(NSString *)ad_id log_extra:(NSString *)log_extra;

@end

@class SKStoreProductViewController;
@interface TTAdAppDownloadManager : NSObject

@property (nonatomic, strong) id<TTAdAppDownloadManagerProtocol> stay_page_traker;

+ (instancetype)sharedManager;

+ (BOOL)downloadApp:(id<TTAd, TTAdAppAction>)model;
+ (void)downloadAppDict:(NSDictionary *)dict;
- (void)preloadAppStoreAppleId:(NSString *)appleId;
- (void)preloadAppStoreDict:(NSDictionary*)dict;
- (BOOL)openAppStoreAppleID:(NSString*)appleID controller:(UIViewController*)controller;

- (void)pushSkController:(SKStoreProductViewController*)skController controller:(UIViewController*)controller  completion:(void(^)(void))completion;
- (void)pushSkController:(SKStoreProductViewController*)skController controller:(UIViewController*)controller  completion:(void(^)(void))completion postNoti:(BOOL)post;


/**
 获取预加载的app store组件

 @param appleID 下载id
 @return skVC
 */
- (SKStoreProductViewController *)SKViewControllerPreloadId:(NSString *)appleID;

/**
 *  针对一个itunsId进行预加载，并且返回对应的SKStoreProductViewController
 *
 *  @param appleID    预加载的itunsId.
 *  @param animated   dismiss时是否有动画效果
 *  @param block      预加载成功后的回调block.
 */
- (SKStoreProductViewController *)SKViewControllerPreloadId:(NSString *)appleID
                                            dismissAnimated:(BOOL)animated
                                            completionBlock:(void(^)(BOOL result))block;

// 用来设置广告stay_page相关属性
- (void)initStayTrackerWithAd_id:(NSString *)ad_id log_extra:(NSString *)log_extra;
//当外部dismiss掉skcontroller时需要手动调用
- (void)clearResource;
@end
