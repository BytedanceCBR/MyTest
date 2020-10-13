//
//  FHNeighborhoodDetailSpaceCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

//#import "FHNeighborhoodDetailSpaceCell.h"
//
//@implementation FHNeighborhoodDetailSpaceCell
//
//@end

#import "FHNeighborhoodDetailSpaceCell.h"

@interface FHNeighborhoodDetailSpaceCell ()

@end

@implementation FHNeighborhoodDetailSpaceCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]) {
        FHNeighborhoodDetailSpaceModel *model = (FHNeighborhoodDetailSpaceModel *)data;
        CGFloat height = model.height;
        
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailSpaceModel *model = (FHNeighborhoodDetailSpaceModel *)data;
    if (model) {
        self.contentView.backgroundColor = model.backgroundColor ?: [UIColor clearColor];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

@end

@implementation FHNeighborhoodDetailSpaceModel

@end
