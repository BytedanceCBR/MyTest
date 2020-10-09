//
//  FHNewHouseDetailRelatedCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHDetailBaseCell.h"
#import "FHHouseBase/FHHouseListBaseItemModel.h"



@interface FHNewHouseDetailRelatedCollectionCell : FHDetailBaseCollectionCell <FHDetailScrollViewDidScrollProtocol>

@property (nonatomic, copy) void(^clickCell)(id data, NSInteger index);
@property (nonatomic, copy) void(^houseShow)(id data, NSInteger index);

@end

@interface FHNewHouseDetailTRelatedCollectionCellModel : NSObject

@property (nonatomic, strong) FHHouseListDataModel *relatedModel;

@end
