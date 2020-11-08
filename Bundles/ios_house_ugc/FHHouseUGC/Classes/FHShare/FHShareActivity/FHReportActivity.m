//
//  FHReportActivity.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/8.
//

#import "FHReportActivity.h"
#import <BDUGShareAdapterSetting.h>

@implementation FHReportActivity

@synthesize dataSource = _dataSource;

- (nonnull NSString *)contentItemType {
    return FHActivityContentItemTypeReport;
}

- (void)performActivityWithCompletion:(BDUGActivityCompletionHandler _Nullable)completion {
    NSString *desc = @"举报成功，将减少类似推荐";
    if(completion){
        completion(self,nil,desc);
    }
    [[BDUGShareAdapterSetting sharedService] activityHasSharedWith:self error:nil desc:desc];
}

@end
