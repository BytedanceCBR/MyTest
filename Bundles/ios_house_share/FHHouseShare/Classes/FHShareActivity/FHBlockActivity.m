//
//  FHBlockActivity.m
//  FHHouseShare
//
//  Created by bytedance on 2020/11/8.
//

#import "FHBlockActivity.h"

@implementation FHBlockActivity

- (nonnull NSString *)contentItemType {
    return FHActivityContentItemTypeBlock;
}

- (void)performActivityWithCompletion:(BDUGActivityCompletionHandler _Nullable)completion {
    NSString *desc = @"将减少类似推荐";
    if(completion){
        completion(self,nil,desc);
    }
}

@end
