//
//  FHHouseSearchSecondHouseViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHHouseSearchSecondHouseViewModel.h"

@implementation FHHouseSearchSecondHouseViewModel

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

@end
