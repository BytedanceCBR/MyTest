//
//  FHNewHouseDetailMapResultCollectionCell.h
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHDetailBaseCell.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailMapResultCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *subTitleLabel;

@end

NS_ASSUME_NONNULL_END
