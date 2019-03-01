//
//  TTVPlayerStateModel.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerStateModel.h"
#import "TTVPlayerWatchTimer.h"
BOOL TTVHasShownNewTrafficAlert = NO;
BOOL TTVHasShownOldTrafficAlert = NO;
@interface TTVPlayerStateModel()
@property (nonatomic, weak) TTVPlayerWatchTimer *watchTimer;
@end
@implementation TTVPlayerStateModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableSmothlySwitch = NO;
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setPlayerWatchTimer:(TTVPlayerWatchTimer *)watchTimer
{
    _watchTimer = watchTimer;
}

- (NSTimeInterval)totalWatchTime
{
    return (long long)(_watchTimer.total * 1000);
}

- (void)setIsInDetail:(BOOL)isInDetail
{
    _isInDetail = isInDetail;
    if (isInDetail) {
        self.hasEnterDetail = YES;
    }
}

- (NSInteger)playPercent
{
    return [self ttv_playPercent];
}

- (BOOL)isPlaybackEnded
{
    return [self ttv_isPlaybackEnded];
}

- (BOOL)ttv_isPlaybackEnded
{
    BOOL ttv_isPlaybackEnded = (self.duration > 0 && self.currentPlaybackTime + 2 > self.duration);
    return ttv_isPlaybackEnded;
}

- (NSInteger)ttv_playPercent
{
    int p = 0;
    if (self.duration > 0) {
        if ([self ttv_isPlaybackEnded]) {
            p = 100;
        } else {
            p =  (int)((((CGFloat)self.currentPlaybackTime / (CGFloat)self.duration)) * 100.f);
        }
    }
    return p;
}

- (NSString *)ttv_position
{
    if (self.isInDetail) {
        return @"detail";
    }
    return @"list";
}

- (NSMutableDictionary *)ttv_logV3CommonDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.ttv_position forKey:@"position"];
    [dic setValue:self.playerModel.logPb forKey:@"log_pb"];
    [dic setValue:self.playerModel.enterFrom forKey:@"enter_from"];
    [dic setValue:self.playerModel.groupID forKey:@"group_id"];
    [dic setValue:self.playerModel.itemID forKey:@"item_id"];
    [dic setValue:self.playerModel.categoryName forKey:@"category_name"];
    [dic setValue:@(self.playerModel.aggrType) forKey:@"aggr_type"];
    [dic addEntriesFromDictionary:self.playerModel.commonExtra];
    return dic;
}

+ (NSString *)typeStringForType:(TTVPlayerResolutionType)type {
    if (type < [self typeStrings].count) {
        return [self typeStrings][type];
    }
    return [[self typeStrings] firstObject];
}

+ (NSArray *)typeStrings {
    return @[@"标清", @"高清", @"超清"];
}

- (NSNumber *)minResolution
{
    NSNumber *min = [self.supportedResolutionTypes firstObject];
    for (NSNumber *number in self.supportedResolutionTypes) {
        if (number.integerValue < min.integerValue) {
            min = number;
        }
    }
    return min;
}
@end
