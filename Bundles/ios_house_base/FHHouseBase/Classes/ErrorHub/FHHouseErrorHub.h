//
//  FHHouseErrorHub.h
//  FHHouseBase
//
//  Created by liuyu on 2020/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHErrorHubType) {
    FHErrorHubTypeRequest = 1, //请求校验
    FHErrorHubTypeBuryingPoint = 2 ,//埋点校验
     FHErrorHubTypeConfig = 3, //现场保存
    FHErrorHubTypeShare = 4 ,//分享相关
    FHErrorHubTypeCustom = 5 ,//通用保存
};

@interface FHHouseErrorHub : NSObject

/// 问题名
@property (nonatomic, copy) NSString *eventName;

/// 问题信息（用于上报）
@property (nonatomic, copy) NSString *errorInfo;

/// 保存于本地的数据（必须包含@"name",@"error_info" key）
@property (nonatomic, strong) NSDictionary *saveDic;

/// 现场数组 (用于判断这个问题需要保存哪些现场数据)
@property (nonatomic, strong) NSArray *senceArr;

/// 监控上报数据
@property (nonatomic, strong) NSDictionary *extra;

///问题类型
@property (nonatomic, assign) FHErrorHubType type;


+ (FHHouseErrorHub *)initFHHouseErrorHubWithEventname:(NSString *)eventName errorInfo:(NSString *)errorInfo saveDic:(NSDictionary *)saveDic senceArr:(NSArray *)senceArr extra:(NSDictionary *)extra type:(FHErrorHubType)type;

@end

NS_ASSUME_NONNULL_END
