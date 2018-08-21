//
//  TTAdShareBoardModel.m
//  Article
//
//  Created by yin on 2016/11/11.
//
//

#import "TTAdShareBoardModel.h"

#define kShareBoardDefaultCloseInterval  2592000

@implementation TTAdShareBoardModel

@end

@implementation TTAdShareBoardDataModel

- (void)updateDate
{
    if (self.request_after.longValue < 0) {
        self.requestTime = [NSDate date];
        return;
    }
    self.requestTime = [NSDate dateWithTimeIntervalSinceNow:self.request_after.longValue];
}

- (void)updateShowCloseTime
{
    if (!self.close_expire_time) {
        self.closeShowTime = [NSDate dateWithTimeIntervalSinceNow:kShareBoardDefaultCloseInterval];
    }
    else{
        if (self.close_expire_time.longValue != -1) {
            self.closeShowTime = [NSDate dateWithTimeIntervalSinceNow:self.close_expire_time.longValue];
        }
        else
        {
            self.closeShowTime = [NSDate distantFuture];
        }
    }
    
}

- (void)readShowCloseTime:(TTAdShareBoardModel*)model
{
    if (model&&model.data.closeShowTime) {
        self.closeShowTime = model.data.closeShowTime;
    }
}

@end



@implementation TTAdShareBoardItemModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"ID"}];
}

- (TTAdShareDisplayType)displayType
{
    if (self.display_type.integerValue == 2) {
        return TTAdShareDisplayType_Small;
    }
    else if (self.display_type.integerValue == 3)
    {
        return TTAdShareDisplayType_Large;
    }
    else if (self.display_type.integerValue == 4)
    {
        return TTAdShareDisplayType_Group;
    }
    else if (self.display_type.integerValue == 5)
    {
        return TTAdShareDisplayType_Video;
    }
    return TTAdShareDisplayType_Large;
}

- (void)updateDate
{
    if (self.display_after.longValue < 0) {
        self.display_after = @0;
    }
    if (self.expire_seconds.longValue < 0) {
        self.expire_seconds = @0;
    }
    self.startTime = [NSDate dateWithTimeIntervalSinceNow:self.display_after.longValue];
    self.endTime = [NSDate dateWithTimeIntervalSinceNow:self.expire_seconds.longValue];
    
}


@end


