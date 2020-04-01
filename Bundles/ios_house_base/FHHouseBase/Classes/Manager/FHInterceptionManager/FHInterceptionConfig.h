//
//  FHInterceptionConfig.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/3/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHInterceptionConfig : NSObject
//最大拦截时间，默认是10秒
@property(nonatomic , assign) CGFloat maxInterceptTime;
//比较参数的间隔时间，默认是1秒
@property(nonatomic , assign) CGFloat compareTime;
//参数判断失败后是否继续执行请求，默认继续执行
@property(nonatomic , assign) BOOL isContinue;
//日志上报内容
@property(nonatomic , strong) NSDictionary *category;

@end

NS_ASSUME_NONNULL_END
