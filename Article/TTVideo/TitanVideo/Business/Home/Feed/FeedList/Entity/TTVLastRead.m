//
//  TTVLastRead.m
//  Article
//
//  Created by pei yun on 2017/4/7.
//
//

#import "TTVLastRead.h"

@implementation TTVLastRead

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_refreshDate forKey:@"refreshDate"];
    [aCoder encodeObject:_lastDate forKey:@"lastDate"];
    [aCoder encodeObject:_showRefresh forKey:@"showRefresh"];
    [aCoder encodeObject:_orderIndex forKey:@"orderIndex"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _refreshDate = [aDecoder decodeObjectForKey:@"refreshDate"];
        _lastDate = [aDecoder decodeObjectForKey:@"lastDate"];
        _showRefresh = [aDecoder decodeObjectForKey:@"showRefresh"];
        _orderIndex = [aDecoder decodeObjectForKey:@"orderIndex"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"_refreshDate = %@, _lastDate = %@, _orderIndex = %@", _refreshDate, _lastDate, _orderIndex];
}

@end
