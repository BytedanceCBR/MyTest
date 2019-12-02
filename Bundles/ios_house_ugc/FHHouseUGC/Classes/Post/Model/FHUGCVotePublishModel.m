//
//  FHUGCVotePublishModel.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import "FHUGCVotePublishModel.h"

@implementation FHUGCVotePublishCityInfo
@end

@implementation FHUGCVotePublishOption
+ (instancetype)defaultOption {
    FHUGCVotePublishOption *defaultOption = [[FHUGCVotePublishOption alloc] init];
    defaultOption.content = @"";
    defaultOption.isValid = NO;
    return defaultOption;
}
@end

@implementation FHUGCVotePublishModel
-(instancetype)init {
    if(self = [super init]) {
        self.options = [NSMutableArray array];
        // 默认至少两个选项必填
        [self.options addObject:[FHUGCVotePublishOption defaultOption]];
        [self.options addObject:[FHUGCVotePublishOption defaultOption]];
        self.type = VoteType_SingleSelect;
        
    }
    return self;
}
@end
