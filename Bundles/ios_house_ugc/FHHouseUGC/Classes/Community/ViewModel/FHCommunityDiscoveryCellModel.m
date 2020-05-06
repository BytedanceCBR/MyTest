//
//  FHCommunityDiscoveryCellModel.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/21.
//

#import "FHCommunityDiscoveryCellModel.h"
#import "FHUGCCategoryManager.h"

@implementation FHCommunityDiscoveryCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = FHCommunityCollectionCellTypeNone;
    }
    return self;
}

+ (FHCommunityDiscoveryCellModel *)cellModelForCategory:(FHUGCCategoryDataDataModel *)model {
    FHCommunityDiscoveryCellModel *cellModel = [[FHCommunityDiscoveryCellModel alloc] init];
    cellModel.type = [FHUGCCategoryManager convertCategoryToType:model.category];
    cellModel.name = model.name;
    cellModel.category = model.category;
    return cellModel;
}

@end
