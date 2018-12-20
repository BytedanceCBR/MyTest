//
//  FHTracerModel.h
//  AFgzipRequestSerializer
//
//  Created by 春晖 on 2018/12/4.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTracerModel : JSONModel

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
@property(nonatomic , copy) NSString *categoryName; //当前页面名称
@property(nonatomic , strong) NSDictionary *logPb;
@property(nonatomic , copy) NSString *searchId;
@property(nonatomic , copy) NSString *originSearchId;


//@property(nonatomic , copy) NSString *eventName;//事件名称

-(void)addExtraValue:(id)value forKey:(NSString *)key;

-(void)addExtraFromDict:(NSDictionary *)dict;

-(void)clearExtra;

-(NSMutableDictionary *)logDict;

-(NSDictionary *)neatLogDict;

@end

NS_ASSUME_NONNULL_END
