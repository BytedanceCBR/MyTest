//
//  FHDislikeActivity.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/8.
//

#import "FHDislikeActivity.h"
#import <BDUGShareAdapterSetting.h>

@implementation FHDislikeActivity

@synthesize dataSource = _dataSource;

- (nonnull NSString *)contentItemType {
    return FHActivityContentItemTypeDislike;
}

- (void)performActivityWithCompletion:(BDUGActivityCompletionHandler _Nullable)completion {
    NSString *desc = @"屏蔽成功，将减少类似推荐";
    if(completion){
        completion(self,nil,desc);
    }
    [[BDUGShareAdapterSetting sharedService] activityHasSharedWith:self error:nil desc:desc];
}

@end
