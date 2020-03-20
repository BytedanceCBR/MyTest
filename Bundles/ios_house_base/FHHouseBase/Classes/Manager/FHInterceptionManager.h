//
//  FHInterceptionManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/20.
//

#import <Foundation/Foundation.h>
#import "TTNetworkManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^Condition)(void);
typedef void (^Operation)(void);
typedef void (^Complete)(BOOL success, TTHttpTask * _Nullable httpTask);
typedef TTHttpTask * _Nullable (^Task)(void);

@interface FHInterceptionManager : NSObject

//最大拦截时间，默认是5秒
@property(nonatomic , assign) CGFloat maxInterceptTime;
//比较参数的间隔时间，默认是1秒
@property(nonatomic , assign) CGFloat compareTime;
//参数判断失败后是否继续执行请求，默认不执行
@property(nonatomic , assign) BOOL isContinue;

- (TTHttpTask *)addParamInterception:(CGFloat)interval
                   condition:(Condition)condition
                   operation:(Operation)operation
                     complete:(Complete)complete
                     task:(Task)task;

@end

NS_ASSUME_NONNULL_END
