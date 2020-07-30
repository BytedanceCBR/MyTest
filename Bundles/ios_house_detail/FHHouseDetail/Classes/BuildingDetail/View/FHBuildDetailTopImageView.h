//
//  FHBuildDetailTopImageView.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import <UIKit/UIKit.h>
#import "FHBuildingDetailModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHBuildDetailTopImageView : UIView
@property (nonatomic, copy) FHBuildingIndexDidSelect IndexDidSelect;
@property (nonatomic, strong, readonly) UIImageView *imageView;

- (void)updateWithData:(id)data;
- (void)move:(CGSize)newSize;
@end

NS_ASSUME_NONNULL_END
