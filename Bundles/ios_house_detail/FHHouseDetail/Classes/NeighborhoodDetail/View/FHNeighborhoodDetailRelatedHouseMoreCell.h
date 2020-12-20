//
//  FHNeighborhoodDetailRelatedHouseMoreCell.h
//  FHHouseDetail
//
//  Created by xubinbin on 2020/12/10.
//

#import "FHDetailBaseCell.h"
#import <IGListKit/IGListKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailRelatedHouseMoreCell : FHDetailBaseCollectionCell

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIImageView *arrowsImg;

- (void)refreshWithTitle:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
