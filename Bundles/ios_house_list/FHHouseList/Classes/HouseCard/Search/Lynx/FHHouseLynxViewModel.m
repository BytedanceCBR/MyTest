//
//  FHHouseLynxViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseLynxViewModel.h"
#import "FHSearchHouseModel.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHUserTracker.h"

@interface FHHouseLynxViewModel ()
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseLynxViewModel

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.showed) {
        self.showed = YES;
        FHDynamicLynxModel *model = ((FHDynamicLynxCellModel *)self.model).model;
        NSDictionary *reportData = [((FHDynamicLynxModel *)model).lynxData btd_dictionaryValueForKey:@"report_params"];
        if (reportData && [reportData isKindOfClass:[NSDictionary class]]) {
            NSString *originFrom = [reportData btd_stringValueForKey:@"origin_from"];
            NSString *enterFrom = [reportData btd_stringValueForKey:@"enter_from"];
            NSString *pageType = [reportData btd_stringValueForKey:@"page_type"];
            NSString *elementType = [reportData btd_stringValueForKey:@"element_type"];
            NSString *searchId = [reportData btd_stringValueForKey:@"search_id"];
            NSDictionary *params = @{
                UT_ORIGIN_FROM: originFrom ?: UT_BE_NULL,
                UT_ENTER_FROM: enterFrom ?: UT_BE_NULL,
                UT_EVENT_TYPE: @"house_app2c_v2",
                UT_PAGE_TYPE: pageType ?: UT_BE_NULL,
                UT_ELEMENT_TYPE: elementType ?: UT_BE_NULL,
                UT_SEARCH_ID: searchId ?: UT_BE_NULL,
            };
            [FHUserTracker writeEvent:@"element_show" params:params];
        }
    }
}

@end
