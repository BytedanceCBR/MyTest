//
//  FHIMShareActivity.m
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import "FHIMShareActivity.h"
#import "TTRoute.h"
#import "FHIMShareItem.h"
#import "FHDetailOldModel.h"

@implementation FHIMShareActivity
#pragma mark - Action


- (NSString *)activityImageName
{
    return @"share_im";
}

- (void)performActivityWithCompletion:(TTActivityCompletionHandler)completion
{
    NSLog(@"performActivityWithCompletion");

    if ([_contentItem isKindOfClass:[FHIMShareItem class]]) {
        FHIMShareItem* item = (FHIMShareItem*)_contentItem;
        if (item.imShareInfo == nil) {
            return;
        }
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        dict[@"shareInfo"] = item.imShareInfo;
        dict[@"tracer"] = item.tracer;
        dict[@"extra_info"] = self.extraInfo;
        TTRouteUserInfo* info = [[TTRouteUserInfo alloc] initWithInfo:dict];

        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:item.imShareInfo.shareUrl]
                                                  userInfo:info];
    }
//    if (self.contentItem.customAction) {
//        self.contentItem.customAction();
//    }
//    if (completion) {
//        completion(self, nil, nil);
//    }
}

- (NSString *)activityType {
    return @"FHIM_SHARE";
}

- (NSString *)contentItemType {
    return @"FHIM_SHARE_TYPE";
}

- (NSString *)contentTitle {
    return @"联系过的经纪人";
}

- (NSString *)shareLabel {
    return @"aaaa";
}

@end
