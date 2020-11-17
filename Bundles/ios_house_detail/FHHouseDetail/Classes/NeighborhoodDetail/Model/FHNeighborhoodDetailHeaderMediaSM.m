//
//  FHNeighborhoodDetailHeaderMediaSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailHeaderMediaSM.h"

@implementation FHNeighborhoodDetailHeaderMediaSM

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return YES;
}

- (void)updateDetailModel:(FHDetailNeighborhoodModel *)model {
    // 添加头滑动图片 && 视频
    FHNeighborhoodDetailHeaderMediaModel *headerCellModel = [[FHNeighborhoodDetailHeaderMediaModel alloc] init];
    headerCellModel.albumInfo = model.data.albumInfo;
    headerCellModel.neighborhoodTopImage = model.data.neighborhoodTopImages;
    self.headerCellModel = headerCellModel;
    self.items = [NSArray arrayWithObject:self.headerCellModel];
}

- (void)updateWithContactViewModel:(FHHouseDetailContactViewModel *)contactViewModel {
    self.headerCellModel.contactViewModel = contactViewModel;
}

@end
