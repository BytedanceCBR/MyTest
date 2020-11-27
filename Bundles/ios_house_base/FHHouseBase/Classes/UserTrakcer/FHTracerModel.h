//
//  FHTracerModel.h
//  AFgzipRequestSerializer
//
//  Created by 春晖 on 2018/12/4.
//

#import "JSONModel.h"
#import "FHUserTrackerDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTracerModel : JSONModel

/*
 * 构建FHTracerModel，字典中，log_pb只能为：字典或者字典字符串
 */
+ (FHTracerModel *)makerTracerModelWithDic:(NSDictionary *)dicParams;

/*
 * 总入口配置
 */
@property(nonatomic , copy) NSString *originFrom;
/*
 * 上级页面配置
 */
@property(nonatomic , copy) NSString *elementFrom; //上级页面 组件名称
@property(nonatomic , copy) NSString *enterFrom; //上级页面名称
@property(nonatomic , copy) NSString *enterType; //上级页面名称

/*
 * 当前页面
 */
@property (nonatomic, copy) NSString *pageType; //当前页面名称
@property (nonatomic, copy) NSString *elementType; //当前页面 组件名称
@property(nonatomic , copy) NSString *categoryName; //当前页面名称
@property(nonatomic , strong) NSDictionary *logPb;
@property(nonatomic , copy) NSString *searchId;
@property(nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *imprId;
@property (nonatomic , copy) NSString *Id;
@property (nonatomic , copy) NSString *groupId;

//@property(nonatomic , copy) NSString *eventName;//事件名称

-(void)addExtraValue:(id)value forKey:(NSString *)key;

-(void)addExtraFromDict:(NSDictionary *)dict;

-(void)clearExtra;

-(NSMutableDictionary *)logDict;

-(NSDictionary *)neatLogDict;

+ (NSDictionary *)getLogPbParams:(id)logPb;

@end

NS_ASSUME_NONNULL_END
