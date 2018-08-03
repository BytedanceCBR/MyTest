//
//  TTMonitorStoreItem.m
//  Article
//
//  Created by ZhangLeonardo on 16/3/28.
//
//

#import "TTMonitorStoreItem.h"

@interface TTMonitorStoreItem()

@property(nonatomic, strong)NSMutableArray * pool;

@end


@implementation TTMonitorStoreItem

- (id)copyWithZone:(nullable NSZone *)zone
{
    TTMonitorStoreItem * item = [[TTMonitorStoreItem allocWithZone:zone] init];
    item.pool = _pool;
    item.retryCount = _retryCount;
    return item;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        @try {
            self.retryCount = [aDecoder decodeInt64ForKey:@"retryCount"];
            self.pool = [aDecoder decodeObjectForKey:@"pool"];
        }
        @catch (NSException *exception) {
            self.retryCount = 10;//默认发送4次， 10 是随便写的， 超过4，接下来的逻辑就直接丢弃了。(>^ω^<)
            self.pool = nil;
        }
        @finally {
            
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    @try {
        if ([_pool isKindOfClass:[NSArray class]] && [self.pool count] > 0) {
            [aCoder encodeObject:_pool forKey:@"pool"];
        }
        [aCoder encodeInt64:_retryCount forKey:@"retryCount"];
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        self.pool = [NSMutableArray arrayWithCapacity:100];
    }
    return self;
}

- (void)event:(NSString *)type label:(NSString *)label attribute:(float)attribute
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
        [_pool removeObjectAtIndex:0];
    }
    
    NSMutableDictionary * item = [NSMutableDictionary dictionaryWithCapacity:10];
    [item setValue:type forKey:@"type"];
    [item setValue:label forKey:@"key"];
    [item setValue:@(attribute) forKey:@"value"];
    [_pool addObject:item];
}


- (BOOL)isEmpty
{
    if ([_pool count] > 0) {
        return NO;
    }
    return YES;
}

- (NSArray *)currentPool
{
    return _pool;
}

- (void)clear
{
    [_pool removeAllObjects];
    self.retryCount = 0;
}

@end
