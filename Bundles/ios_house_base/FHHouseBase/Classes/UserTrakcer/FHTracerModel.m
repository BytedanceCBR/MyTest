//
//  FHTracerModel.m
//  AFgzipRequestSerializer
//
//  Created by 春晖 on 2018/12/4.
//

#import "FHTracerModel.h"

@interface FHTracerModel ()

@property(nonatomic , strong) NSMutableDictionary *extra; //附加信息

@end

@implementation FHTracerModel

+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+(BOOL)propertyIsIgnored:(NSString *)propertyName
{
    //[propertyName isEqualToString:@"eventName"] ||
    if ([propertyName isEqualToString:@"extra"]) {
        return YES;
    }
    return NO;
}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

-(NSMutableDictionary *)extra
{
    if (!_extra) {
        _extra = [NSMutableDictionary new];
    }
    return _extra;
}


-(void)addExtraValue:(id)value forKey:(NSString *)key
{
    if (key.length == 0) {
        return;
    }
    self.extra[key] = value;
}

-(void)addExtraFromDict:(NSDictionary *)dict
{
    [self.extra addEntriesFromDictionary:dict];
}

-(void)clearExtra
{
    [_extra removeAllObjects];
}

-(NSMutableDictionary *)logDict
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict addEntriesFromDictionary:[self toDictionary]];
    
    if (_extra) {
        [dict addEntriesFromDictionary:_extra];
    }
    
    return dict;
}

-(NSDictionary *)neatLogDict
{
    return [self toDictionary];
}

/*
 * 构建FHTracerModel，字典中，log_pb只能为：字典或者字典字符串
 */
+ (FHTracerModel *)makerTracerModelWithDic:(NSDictionary *)dicParams {
    NSError *error = NULL;
    FHTracerModel *model = [[FHTracerModel alloc] initWithDictionary:dicParams error:&error];
    if (model == NULL || error != NULL) {
        model = [[FHTracerModel alloc] init];
        model.originFrom = dicParams[@"origin_from"];
        model.elementFrom = dicParams[@"element_from"];
        model.enterFrom = dicParams[@"enter_from"];
        model.categoryName = dicParams[@"category_name"];
        model.searchId = dicParams[@"search_id"];
        model.originSearchId = dicParams[@"origin_search_id"];
        // log_pb特殊处理
        if (model) {
            id logPb = dicParams[@"log_pb"];
            if (logPb != NULL) {
                model.logPb = NULL;
                if ([logPb isKindOfClass:[NSDictionary class]]) {
                    model.logPb = logPb;
                } else if ([logPb isKindOfClass:[NSString class]]) {
                    // 字符串转字典
                    NSError *error = nil;
                    NSDictionary *logPbDict = [NSJSONSerialization JSONObjectWithData:[((NSString *)logPb) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                    if (!error) {
                        model.logPb = logPbDict;
                    }
                }
            } else {
                model.logPb = NULL;
            }
        }
    }
    return model;
}

-(void)setLogPbWithNSString:(NSString *)logpb
{
    if ([logpb isKindOfClass:[NSString class]]) {
        @try {
            NSData *data = [logpb dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.logPb = dict;
        } @catch (NSException *exception) {
#if DEBUG
            NSLog(@"exception is: %@",exception);
#endif
        }
    }
}


@end
