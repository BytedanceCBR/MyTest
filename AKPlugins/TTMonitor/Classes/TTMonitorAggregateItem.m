//
//  TTMonitorAggregateItem.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/3.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTMonitorAggregateItem.h"

@interface TTMonitorAggregateItem()

@property(nonatomic, assign, readwrite)TTMonitorAggregateItemType type;

@property(nonatomic, strong)NSMutableDictionary * pool;
@property(nonatomic, strong)NSMutableDictionary * noArrregateList;
@end

@implementation TTMonitorAggregateItem

- (id)copyWithZone:(nullable NSZone *)zone
{
    TTMonitorAggregateItem * item = [[TTMonitorAggregateItem allocWithZone:zone] init];
    item.type = _type;
    item.pool = _pool;
    item.retryCount = _retryCount;
    return item;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        @try {
            self.type = [aDecoder decodeInt64ForKey:@"type"];
            self.retryCount = [aDecoder decodeInt64ForKey:@"retryCount"];
            self.pool = [aDecoder decodeObjectForKey:@"pool"];
            self.noArrregateList = [aDecoder decodeObjectForKey:@"noaggregate"];
        }
        @catch (NSException *exception) {
            self.type = TTMonitorAggregateItemTypeTimeNotAssign;
            self.retryCount = 10;//默认发送4次， 10 是随便写的， 超过4，接下来的逻辑就直接丢弃了。(>^ω^<)
            self.pool = nil;
            self.noArrregateList = nil;
        }
        @finally {
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    @try {
        if ([_pool isKindOfClass:[NSDictionary class]] && [self.pool count] > 0) {
            [aCoder encodeObject:_pool forKey:@"pool"];
        }
        if ([_noArrregateList isKindOfClass:[NSDictionary class]] && [self.noArrregateList count]>0) {
            [aCoder encodeObject:_noArrregateList forKey:@"noaggregate"];
        }
        [aCoder encodeInt64:_type forKey:@"type"];
        [aCoder encodeInt64:_retryCount forKey:@"retryCount"];
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
}

- (id)initWithType:(TTMonitorAggregateItemType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        
        self.pool = [[NSMutableDictionary alloc] initWithCapacity:100];
        self.noArrregateList = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    return self;
}

- (void)event:(NSString *)type label:(NSString *)label attribute:(float)attribute needAggregate:(BOOL)needAggr
{
    if (!([type isKindOfClass:[NSString class]] &&
          [type length] > 0 &&
          [label isKindOfClass:[NSString class]] &&
          [label length] > 0)) {
        //无效数据
        return;
    }
    
    //保护外层
    if ([_pool count] > 5000) {//如果已经超过5000个，随机删除一个老的数据。 保护机制，一般不会出现，防止雪崩时疯狂打点
        NSString * key = [[_pool allKeys] firstObject];
        [_pool removeObjectForKey:key];
    }
    if (!needAggr) {
        NSString * key = [NSString stringWithFormat:@"%@_%@",type,label];
        [self.noArrregateList setValue:@(NO) forKey:key];
    }
    NSMutableDictionary * dict = [_pool objectForKey:type];
    
    //保护内层
    if ([dict count] > 5000) {//如果已经超过5000个，随机删除一个老的数据。 保护机制，一般不会出现，防止雪崩时疯狂打点
        NSString * key = [[_pool allKeys] firstObject];
        [dict removeObjectForKey:key];
    }
    
    if (![dict isKindOfClass:[NSMutableDictionary class]] || [dict count] == 0) {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [_pool setValue:dict forKey:type];
    }
    
    NSMutableArray<NSNumber *> * array = [dict objectForKey:label];
    if (![array isKindOfClass:[NSMutableArray class]] || [array count] == 0) {
        array = (NSMutableArray<NSNumber *> *)[NSMutableArray arrayWithCapacity:10];
        [dict setValue:array forKey:label];
    }
    [array addObject:@(attribute)];
    
    if ([array count] >= 5000) {//如果数据超过5000个，进行一次聚合，保护逻辑， o(>﹏<)o
        [self aggregateAllData];
    }
}

- (void)aggregateAllData
{
    NSMutableDictionary * aggregatedResults = [NSMutableDictionary dictionaryWithCapacity:50];
    NSDictionary * noNeedAggrDict = [self.noArrregateList copy];
    for (NSString * outerKey in [_pool allKeys]) {//for 是最快的，因为数据量可能比较大，所以不用enumerateKeysAndObjectsUsingBlock等
        
        NSDictionary * outerDict = [_pool objectForKey:outerKey];
        
        NSMutableDictionary * aggregateInnerDict = [NSMutableDictionary dictionaryWithCapacity:50];
        for (NSString * innerKey in [outerDict allKeys]) {
            NSString * key = [NSString stringWithFormat:@"%@_%@",outerKey,innerKey];
            NSMutableArray<NSNumber *> * innerNumbers = [outerDict objectForKey:innerKey];
            NSMutableArray<NSNumber *> * aggregatedInnerNumbers;
            if ([noNeedAggrDict valueForKey:key] && ![[noNeedAggrDict valueForKey:key] boolValue]) {
                aggregatedInnerNumbers = [innerNumbers copy];
            }else{
                aggregatedInnerNumbers = [self aggregate:[innerNumbers copy]];
            }
            
            if ([aggregatedInnerNumbers count] > 0) {
                [aggregateInnerDict setValue:aggregatedInnerNumbers forKey:innerKey];
            }
        }
        if ([aggregateInnerDict count] > 0) {
            [aggregatedResults setValue:aggregateInnerDict forKey:outerKey];
        }
    }
    self.pool = aggregatedResults;
}

- (NSMutableArray<NSNumber *> *)aggregate:(NSArray<NSNumber *> *)array
{
    NSMutableArray * resultM = [NSMutableArray arrayWithCapacity:10];
    if (![array isKindOfClass:[NSArray class]]) {
        return resultM;
    }
    float total = 0;
    for (NSNumber * num in array) {
        total += [num doubleValue];
    }
    float result = 0;
    if (_type == TTMonitorAggregateItemTypeCount) {
        result = total;
    }
    else if (_type == TTMonitorAggregateItemTypeTime) {
        result = total / (float)[array count];
    }
    [resultM addObject:@(result)];
    return resultM;
}

- (BOOL)isEmpty
{
    if ([_pool count] > 0) {
        return NO;
    }
    return YES;
}

- (NSDictionary *)currentPool
{
    return _pool;
}

- (void)clear
{
    [_pool removeAllObjects];
    self.retryCount = 0;
}

@end
