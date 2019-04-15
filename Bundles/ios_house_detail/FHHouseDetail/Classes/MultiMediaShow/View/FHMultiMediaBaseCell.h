//
//  FHMultiMediaBaseCell.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <UIKit/UIKit.h>
#import "FHMultiMediaModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMultiMediaBaseCell : UICollectionViewCell

@property(nonatomic, strong) UIImage *placeHolder;

- (void)updateViewModel:(FHMultiMediaItemModel *)model;

@end

NS_ASSUME_NONNULL_END
