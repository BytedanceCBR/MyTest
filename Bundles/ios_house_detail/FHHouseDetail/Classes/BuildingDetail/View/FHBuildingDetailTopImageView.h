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
- (void)move:(CGSize)newSize;

- (void)updateWithIndexModel:(FHBuildingIndexModel *)indexModel;
@end

NS_ASSUME_NONNULL_END
