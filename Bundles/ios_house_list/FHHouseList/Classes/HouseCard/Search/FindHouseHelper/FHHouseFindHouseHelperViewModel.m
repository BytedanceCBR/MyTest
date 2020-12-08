//
//  FHHouseFindHouseHelperViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseFindHouseHelperViewModel.h"
#import "FHUserTracker.h"
#import "NSObject+FHTracker.h"
#import "TTRoute.h"
#import "FHSearchHouseModel.h"

@interface FHHouseFindHouseHelperViewModel ()
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseFindHouseHelperViewModel

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.showed) {
        self.showed = YES;
        
        NSDictionary *params = @{
            UT_ORIGIN_FROM: self.fh_trackModel.originFrom ? : @"be_null",
            UT_EVENT_TYPE: @"house_app2c_v2",
            UT_PAGE_TYPE: self.fh_trackModel.pageType ? : @"be_null",
            UT_SEARCH_ID: self.fh_trackModel.searchId ? : @"be_null",
            UT_ELEMENT_TYPE: @"driving_find_house_card",
        };
        [FHUserTracker writeEvent:@"element_show" params:params];
    }
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    FHSearchFindHouseHelperModel *model = (FHSearchFindHouseHelperModel *)self.model;
    if (![model isKindOfClass:FHSearchFindHouseHelperModel.class]) return;
    NSString *url = model.openUrl;
    if (url.length > 0) {
        NSDictionary *tracerInfo = @{
            UT_ELEMENT_FROM: @"driving_find_house_card",
            UT_ENTER_FROM: self.fh_trackModel.pageType ?: @"be_null",
            UT_ORIGIN_FROM: self.fh_trackModel.originFrom ?: @"be_null",
        };
        
        NSURL *openUrl = [NSURL URLWithString:url];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] init];
        userInfo.allInfo = @{@"tracer": tracerInfo};
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

@end
