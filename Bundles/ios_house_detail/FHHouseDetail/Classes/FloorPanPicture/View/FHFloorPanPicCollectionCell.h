//
//  FHFloorPanPicCollectionCell.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/12.
//

#import <UIKit/UIKit.h>
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanPicCollectionCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageV;
@property (nonatomic,strong) UILabel *lab;
@property (nonatomic,strong) FHDetailHouseDataItemsHouseImageModel *dataModel;

@end

NS_ASSUME_NONNULL_END
