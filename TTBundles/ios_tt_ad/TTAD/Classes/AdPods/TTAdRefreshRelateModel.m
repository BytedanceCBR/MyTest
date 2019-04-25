//
//  TTAdRefreshRelateModel1.m
//  Article
//
//  Created by ranny_90 on 2017/3/20.
//
//

#import "TTAdRefreshRelateModel.h"
#import <TTBaseLib/TTBaseMacro.h>

@implementation TTAdRefreshItemModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"adID"}];
}

-(void)updateDisplayDate{
    
    if (self.display_after.longValue < 0) {
        self.display_after = @(0);
    }

    self.displayStartTime = [NSDate dateWithTimeIntervalSinceNow:self.display_after.longValue];
    
    if (self.expire_seconds.longValue < 0) {
        self.expire_seconds = @(0);
    }
    self.displayExpiredTime = [NSDate dateWithTimeIntervalSinceNow:self.expire_seconds.longValue];
}

-(BOOL)isSuitableTimeToDisplayWithDate:(NSDate *)date{
    
    if (!date) {
        return NO;
    }
    
    NSDate *displayStartDate = self.displayStartTime;
    NSDate *displayExpiredDate = self.displayExpiredTime;
    
    if (!self.displayStartTime || ([date compare:displayStartDate] == NSOrderedDescending) || ([date compare:displayStartDate] == NSOrderedSame)) {
        
        if (!displayExpiredDate || ([date compare:displayExpiredDate] == NSOrderedAscending) || ([date compare:displayExpiredDate] == NSOrderedSame)) {
            return YES;
        }
    }
    
    return NO;
}



@end



@implementation TTAdRefreshRelateModel

-(void)updateAdItemsDictionary{
    
    if (SSIsEmptyArray(self.ad_item)) {
        self.adItemsDictionary = nil;
        return;
    }
    
    NSMutableDictionary *adDic = [[NSMutableDictionary alloc] init];
    
    [self.ad_item enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj && [obj isKindOfClass:[TTAdRefreshItemModel class]]) {
            
            TTAdRefreshItemModel *itemModel = (TTAdRefreshItemModel *)obj;
            
            NSString *channelid = itemModel.channel_id;
            if (!isEmptyString(channelid)) {
                
                id channelAdArrayData = [adDic objectForKey:channelid];
                if (!channelAdArrayData || ![channelAdArrayData isKindOfClass:[NSMutableArray class]]) {
                    channelAdArrayData = [[NSMutableArray alloc] init];
                    [adDic setValue:channelAdArrayData forKey:channelid];
                }
                
                if (channelAdArrayData && [channelAdArrayData isKindOfClass:[NSMutableArray class]]) {
                    NSMutableArray *channerAdArray = (NSMutableArray *)channelAdArrayData;
                    [channerAdArray addObject:itemModel];
                }
                
            }
            
        }
        
    }];
    if (!SSIsEmptyDictionary(adDic)) {
        self.adItemsDictionary = [adDic copy];
    }
    else {
        self.adItemsDictionary = nil;
    }
    
}


@end


@implementation TTADRefreshChannelShowTimeModel

-(id)init{
    
    return [self initWithChannelId:nil];
}

-(id)initWithChannelId:(NSString *)channelId{
    
    self = [super init];
    if (self) {
        
        _channelId = channelId;
        _showDate = [NSDate date];
        _showTimes = @(0);
    }
    
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.channelId = [aDecoder decodeObjectForKey:@"channelId"];
        self.showTimes = [aDecoder decodeObjectForKey:@"showTimes"];
        self.showDate = [aDecoder decodeObjectForKey:@"showDate"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.channelId forKey:@"channelId"];
    [aCoder encodeObject:self.showTimes forKey:@"showTimes"];
    [aCoder encodeObject:self.showDate forKey:@"showDate"];
}

@end

@implementation TTADRefreshShowTimeModel

-(id)init{
    self = [super init];
    if (self) {
       
        _showLimitDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.showLimitDic = [aDecoder decodeObjectForKey:@"showLimitDic"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.showLimitDic forKey:@"showLimitDic"];
}


@end
