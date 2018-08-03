//
//  TTAuthorizeLocationObj.h
//  Article
//
//  Created by Chen Hong on 15/4/15.
//
//

#import "TTAuthorizeBaseObj.h"

//提示窗口顺序弹出
#import "TTGuideDispatchManager.h"

typedef void (^TTAuthorizeLocationArrayParamBlock)(NSArray *);

typedef void(^TTAuthorizeLocationAuthCompleteBlock)(TTAuthorizeLocationArrayParamBlock arrayParamBlock);

/*
 定位权限
 仅对未开启GPS的用户生效。
 距上次同类弹窗时间e天。
 和其他类型弹窗间隔c天。
 */
@interface TTAuthorizeLocationObj : TTAuthorizeBaseObj<TTGuideProtocol>


/*
 点进「本地频道」
 最多弹f次
 */
- (void)showAlertAtLocalCategory:(TTThemedAlertActionBlock)completionBlock authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock sysAuthFlag:(NSInteger)flag;


/*
 进入客户端，用户位置改变。
 最多弹h次
 */
- (TTAuthorizeHintView *)showAlertWhenLocationChanged:(TTThemedAlertActionBlock)completionBlock authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock sysAuthFlag:(NSInteger)flag;
/*
 处理第一次启动请求系统定位权限时，不弹自己的定位提醒
 */
- (void)updateFirstShowTimeIfNeeded;

/*
 弹窗控制策略
 */

- (void)filterAuthorizeStrategyWithCompletionHandler:(void(^)(NSArray * placemarks))completionHandler authCompleteBlock:(TTAuthorizeLocationAuthCompleteBlock)authCompleteBlock sysAuthFlag:(NSInteger)flag;

@end
