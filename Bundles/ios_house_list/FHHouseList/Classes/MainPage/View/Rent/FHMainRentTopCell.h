//
//  FHMainRentTopCell.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHConfigDataRentOpDataItemsModel;
@interface FHMainRentTopCell : UICollectionViewCell

@property(nonatomic , strong) UIImageView *iconView;
@property(nonatomic , strong) UILabel *nameLabel;

-(void)updateWithIcon:(NSString *)iconUrl name:(NSString *)name;

-(void)updateWithModel:(FHConfigDataRentOpDataItemsModel *)model;

@end

NS_ASSUME_NONNULL_END
