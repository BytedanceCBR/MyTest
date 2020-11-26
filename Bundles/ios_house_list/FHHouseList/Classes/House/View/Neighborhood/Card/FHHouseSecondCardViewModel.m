//
//  FHHouseSecondCardViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseSecondCardViewModel.h"
#import "FHHouseTitleAndTagViewModel.h"
#import "FHCommonDefines.h"
#import "FHHouseRecommendViewModel.h"

@implementation FHHouseSecondCardViewModel

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        _titleAndTag = [[FHHouseTitleAndTagViewModel alloc] initWithModel:model];
        _titleAndTag.maxWidth = SCREEN_WIDTH - 30 * 2 - 84 - 8;
        _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:model.advantageDescription];
    }
    return self;
}

- (FHImageModel *)leftImageModel {
    return [self.model.houseImage firstObject];
}

- (NSString *)subtitle; {
    return self.model.displaySubtitle;
}

- (NSArray<FHHouseTagsModel *> *)tagList {
    return self.model.tags;
}

- (NSString *)price {
    return self.model.displayPrice;
}

- (NSString *)pricePerSqm {
    return self.model.displayPricePerSqm;
}

- (BOOL)hasVr {
    return self.model.vrInfo.hasVr;
}

@end
