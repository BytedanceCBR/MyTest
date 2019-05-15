//
//  AKPhotoCarouselView.h
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import <UIKit/UIKit.h>

@class AKPhotoCarouselView;
@class AKPhotoCarouselCellModel;
@protocol AKPhotoCarouselViewDelegate <NSObject>

- (void)photoCarouselView:(AKPhotoCarouselView *)carouselView didSelectedAt:(NSInteger)index cellModel:(AKPhotoCarouselCellModel *)cellModel;
- (void)photoCarouselView:(AKPhotoCarouselView *)carouselView willScrollToIndex:(NSInteger)index;

@end

@class AKPhotoCarouselCellModel;
@interface AKPhotoCarouselView : UIView
@property (nonatomic, weak)NSObject<AKPhotoCarouselViewDelegate>                *delegate;
//滚动间隔，默认是2s
@property (nonatomic, assign)NSTimeInterval                                     scrollDuration;
@property (nonatomic, assign, readonly)NSInteger                                curIndex;

- (instancetype)initWithModels:(NSArray<AKPhotoCarouselCellModel *> *)cellModels;

- (void)refreshCellModel:(NSArray<AKPhotoCarouselCellModel *> *)cellModels;
- (void)updateCurIndex:(NSInteger)newIndex;

@end
