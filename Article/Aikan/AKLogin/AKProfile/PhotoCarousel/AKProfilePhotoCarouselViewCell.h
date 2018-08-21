//
//  AKProfilePhotoCarouselViewCell.h
//  Article
//
//  Created by chenjiesheng on 2018/3/7.
//

#import <UIKit/UIKit.h>

#import "AKPhotoCarouselView.h"
@class AKPhotoCarouselCellModel;

@interface AKProfilePhotoCarouselViewCell : UITableViewCell

@property (nonatomic, strong, readonly)AKPhotoCarouselView           *carouselView;

- (void)refreshPhotoCarouselViewWithCellModels:(NSArray<AKPhotoCarouselCellModel *> *)cellModels;
- (void)refreshPhotoCarouselViewScrollDuration:(NSTimeInterval)duration;
@end
