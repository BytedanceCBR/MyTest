//
//  AKPhotoCarouselCellView.h
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import <UIKit/UIKit.h>

@class AKPhotoCarouselCellModel;
@interface AKPhotoCarouselCellView : UIView
@property (nonatomic, assign)NSInteger      ownIndex;

- (void)setupContentWithModel:(AKPhotoCarouselCellModel *)cellModel;
@end
