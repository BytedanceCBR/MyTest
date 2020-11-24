//
//  FHReportActivity.m
//  FHHouseShare
//
//  Created by bytedance on 2020/11/8.
//

#import "FHReportActivity.h"

@implementation FHReportActivity

- (nonnull NSString *)contentItemType {
    return FHActivityContentItemTypeReport;
}

- (void)performActivityWithCompletion:(BDUGActivityCompletionHandler _Nullable)completion {
    if(self.contentItem.reportBlcok) {
        self.contentItem.reportBlcok();
        return;
    }
    NSString *desc = @"将减少类似推荐";
    if(completion){
        completion(self,nil,desc);
    }
}

@end
