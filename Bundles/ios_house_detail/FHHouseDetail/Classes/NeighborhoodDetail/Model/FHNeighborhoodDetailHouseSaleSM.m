//
//  FHNeighborhoodDetailHouseSaleSM.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleSM.h"
#import "FHHouseCardUtils.h"
#import "FHHouseSecondCardViewModel.h"
#import "FHCommonDefines.h"

@implementation FHNeighborhoodDetailHouseSaleSM

-(void)updateWithDataModel:(FHDetailSameNeighborhoodHouseResponseDataModel *)model {
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    for (FHSearchHouseDataItemsModel *item in model.items) {
        item.advantageDescription = nil;
        id obj = [FHHouseCardUtils getEntityFromModel:item];
        if (obj && [obj isKindOfClass:[FHHouseSecondCardViewModel class]]) {
            FHHouseSecondCardViewModel *model = (FHHouseSecondCardViewModel *)obj;
            [model setTitleMaxWidth:SCREEN_WIDTH - 30 * 2 - 84 - 8 + 18];
            [arrayM addObject:obj];
        }

    }
    self.items = arrayM.copy;
    self.moreTitle = [NSString stringWithFormat:@"查看在售%@套房源", model.total];
    self.model = model;
}

@end
