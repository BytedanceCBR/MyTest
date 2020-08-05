//
//  FHBuildingDetailTopImageView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import <UIKit/UIKit.h>
#import "FHBuildingDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHBuildingDetailTopImageView : UIView
@property (nonatomic, copy) FHBuildingIndexDidSelect buttonDidSelect;
@property (nonatomic, strong, readonly) UIImageView *imageView;

- (void)updateWithData:(id)data;

- (void)updateWithIndexModel:(FHBuildingIndexModel *)indexModel;

- (void)showAllButton;
@end

NS_ASSUME_NONNULL_END
