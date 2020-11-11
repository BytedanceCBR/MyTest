//
//  FHIMActivity.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/9.
//

#import "FHIMActivity.h"
#import <FHDetailOldModel.h>
#import <TTRoute.h>

@implementation FHIMActivity

- (nonnull NSString *)contentItemType {
    return FHActivityContentItemTypeIM;
}

- (void)performActivityWithCompletion:(BDUGActivityCompletionHandler _Nullable)completion {
    if(self.contentItem.imShareInfo) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        dict[@"shareInfo"] = self.contentItem.imShareInfo;
        dict[@"tracer"] = self.contentItem.tracer;
        dict[@"extra_info"] = self.contentItem.extraInfo;
        TTRouteUserInfo* info = [[TTRouteUserInfo alloc] initWithInfo:dict];

        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.contentItem.imShareInfo.shareUrl] userInfo:info];
    }
    
}


@end
