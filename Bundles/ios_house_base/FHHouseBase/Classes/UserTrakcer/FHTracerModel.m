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

@end
