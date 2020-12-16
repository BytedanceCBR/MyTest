//
//  FHNeighborhoodDetailSurroundingHouse.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/12/10.
//

#import "FHNeighborhoodDetailSurroundingHouseSM.h"
#import "FHHouseCardUtils.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHCommonDefines.h"

@implementation FHNeighborhoodDetailSurroundingHouseSM

- (void)updateWithDataModel:(FHDetailRelatedHouseResponseDataModel *)data {
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
    self.model = data;
    self.items = arrayM.copy;
    self.total = data.total;
    self.moreTitle = [NSString stringWithFormat:@"查看在售%@套房源", data.total];
}

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}

@end
