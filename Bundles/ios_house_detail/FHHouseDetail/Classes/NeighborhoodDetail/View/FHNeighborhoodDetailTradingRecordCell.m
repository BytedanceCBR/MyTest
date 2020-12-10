//
//  FHNeighborhoodDetailTradingRecordCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/12/10.
//

#import "FHNeighborhoodDetailTradingRecordCell.h"

@implementation FHNeighborhoodDetailTradingRecordCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailTradingRecordModel class]]) {
        return CGSizeMake(width, 52);
    }
    return CGSizeZero;
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

@end

@implementation FHNeighborhoodDetailTradingRecordModel

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}


@end
