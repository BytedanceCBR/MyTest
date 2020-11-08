//
//  FHBlockActivity.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/8.
//

#import "FHBlockActivity.h"
#import <BDUGShareAdapterSetting.h>

@implementation FHBlockActivity

@synthesize dataSource = _dataSource;

- (nonnull NSString *)contentItemType {
    return FHActivityContentItemTypeBlock;
}

- (void)performActivityWithCompletion:(BDUGActivityCompletionHandler _Nullable)completion {
    NSString *desc = @"拉黑成功，将减少类似推荐";
    if(completion){
        completion(self,nil,desc);
    }
    [[BDUGShareAdapterSetting sharedService] activityHasSharedWith:self error:nil desc:desc];
}

@end
