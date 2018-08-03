//
//  TTInAppPurchase.h
//  Pods
//
//  Created by muhuai on 2017/10/9.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void(^TTIAPStatusHandler)(SKPaymentTransaction *transaction, NSError *error);
typedef void(^TTIAPfetchProductCallback)(NSArray<SKProduct *> *products, NSError *errpr);

//订单状态改变 无人响应时 会发通知, 主要用于启动时的 掉单检测
extern NSString *const kTTIAPUpdatedTransactionsNotification;

@interface TTInAppPurchaseManager : NSObject

+ (instancetype)sharedInstance;

/**
 本设备是否能支付

 @return 是/否
 */
+ (BOOL)canMakePayments;

/**
 根据identifier拉取product信息

 @param identifiers ITC上创建的产品标识
 @param completion 结果回调
 */
- (void)fetchProductWithIdentifiers:(NSArray<NSString *> *)identifiers completion:(TTIAPfetchProductCallback)completion;

/**
 支付identifier所对应的产品, 如果本地没有对应的product信息则去Apple拉取后再进行支付

 @param identifier ITC上创建的产品标识
 @param quantity 数量
 @param applicationUsername 自定义标识  请看@discuss
 @param handler 状态变更回调
 
 @discuss 在处理回调中, 如需使用applicationUsername 请先调用removeMarkApplicationUsername 移除标记, 避免影响业务层.
 */
- (void)payWithIdentifier:(NSString *)identifier quantity:(NSInteger)quantity applicationUsername:(NSString *)applicationUsername statusHandler:(TTIAPStatusHandler)handler;


/**
 打标, 标记本次支付是由TTInAppPurchaseManager发起的, 以防处理它其他业务方的iap
 @warning
 @param applicationUsername 业务层传入的username
 @return 打标后的username
 */
- (NSString *)markedApplicationUsername:(NSString *)applicationUsername;

/**
 删除打标

 @param applicationUsername 打标后的usernmae
 @return 去除后的username
 */
- (NSString *)removeMarkApplicationUsername:(NSString *)applicationUsername;
@end
