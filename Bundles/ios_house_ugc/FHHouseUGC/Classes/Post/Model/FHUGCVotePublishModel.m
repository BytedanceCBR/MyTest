//
//  FHUGCVotePublishModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import "FHUGCVotePublishModel.h"

@implementation FHUGCVotePublishCityInfo
@end

@implementation FHUGCVotePublishModel
-(instancetype)init {
    if(self = [super init]) {
        self.options = [NSMutableArray array];
        [self.options addObject:@""];
        self.cityInfo = [FHUGCVotePublishCityInfo new];
    }
    return self;
}
@end
