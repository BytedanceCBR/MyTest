//
//  TTPhotoNativeDetailView.h
//  Article
//
//  Created by yuxin on 4/19/16.
//
//

#import "SSViewBase.h"
#import "TTDetailModel.h"
#import "Article.h"
#import "ExploreImageCollectionView.h"

@class TTPhotoNativeDetailView;
@protocol TTPhotoNativeDetailViewDelegate <NSObject>

- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView imagePositionType:(TTPhotoDetailImagePositon)imagePositionType tapOn:(BOOL)tapOn;
//- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView didScrollToImageRecommend:(BOOL)showRecommend;

- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView didScrollToImagePostionType:(TTPhotoDetailImagePositon)imagePositionType;
- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView didScrollToIndex:(NSUInteger)index isLastPic:(BOOL)isLastPic;

- (void)photoNativeDetailView:(TTPhotoNativeDetailView *)photoNativeDetailView scrollPercent:(CGFloat)scrollPercent;

@end

@interface TTPhotoNativeDetailView : SSViewBase <ExploreImageCollectionViewDelegate>

@property(nonatomic, strong) TTDetailModel * detailModel;

@property (nonatomic, weak) id<TTPhotoNativeDetailViewDelegate> delegate;
@property (nonatomic, assign) UIEdgeInsets   contentInset;
@property (nonatomic, strong) ExploreImageCollectionView  *imageCollectionView;

@property (nonatomic, assign) NSUInteger maximumVisibleIndex;
@property (nonatomic, assign) NSUInteger currentVisibleIndex;

- (instancetype)initWithFrame:(CGRect)frame model:(TTDetailModel *)detailModel;

@end

@interface TTPhotoNativeDetailView (ExploreCollectionViewCell)

- (TTShowImageView *)currentShowImageView;
- (UIImage *)currentNativeGalleryImage;
- (void)saveCurrentNativeGalleryIfCould;
- (void)destructSaveImageAlert;
- (CGRect)currentNativeGalleryImageViewFrame;

@end
