//
//  FHNewHouseDetailRelatedCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHDetailBaseCell.h"
#import "FHHouseBase/FHHouseListBaseItemModel.h"



@interface FHNewHouseDetailRelatedCollectionCell : FHDetailBaseCollectionCell <FHDetailScrollViewDidScrollProtocol>

- (void)refreshWithData:(id)data withLast:(BOOL) isLast;

@end

@interface FHNewHouseDetailTRelatedCollectionCellModel : NSObject

@property (nonatomic, strong) FHHouseListDataModel *relatedModel;

@end
