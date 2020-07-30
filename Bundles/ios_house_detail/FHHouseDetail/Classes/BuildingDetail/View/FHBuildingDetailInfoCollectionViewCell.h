//
//  FHBuildingDetailInfoCollectionViewCell.h
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHDetailBaseCell.h"
#import "FHPropertyListCorrectingRowView.h"
#import "FHBuildingDetailModel.h"
NS_ASSUME_NONNULL_BEGIN
//楼栋详情页 信息
@interface FHBuildingDetailInfoCollectionViewCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic, copy) FHBuildingIndexDidSelect infoIndexDidSelect;


@end

@interface FHBuildingDetailInfoListCell : FHDetailBaseCollectionCell

//@property (nonatomic, strong) FHBuildingDetailDataItemModel

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *saleStatusLabel;
@property (nonatomic, copy) NSArray<FHPropertyListCorrectingRowView *> *infosView;

@end

NS_ASSUME_NONNULL_END
