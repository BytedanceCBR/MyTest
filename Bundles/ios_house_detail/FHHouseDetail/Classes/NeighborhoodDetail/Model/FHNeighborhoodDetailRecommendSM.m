//
//  FHNeighborhoodDetailRecommendSM.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendSM.h"
#import "FHHouseCardUtils.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHCommonDefines.h"

@implementation FHNeighborhoodDetailRecommendSM

- (void)updateWithDataModel:(FHSearchHouseDataModel *)data {
    self.recommendCellModel = [[FHNeighborhoodDetailRecommendCellModel alloc] init];
    self.recommendCellModel.data = data;
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    for (FHSearchHouseDataItemsModel *item in data.items) {
        item.advantageDescription = nil;
        id obj = [FHHouseCardUtils getEntityFromModel:item];
        if (obj && [obj isKindOfClass:[FHHouseSecondCardViewModel class]]) {
            FHHouseSecondCardViewModel *model = (FHHouseSecondCardViewModel *)obj;
            model.tagListMaxWidth = SCREEN_WIDTH - 21 * 2 - 90 - 8;
            [model cutTagListWithFont:[UIFont themeFontRegular:10]];
            [model setTitleMaxWidth:SCREEN_WIDTH - 30 * 2 - 84 - 8 + 18];
            [arrayM addObject:obj];
        }
    }
    self.items = arrayM.copy;
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
