//
//  TTPhotoDetailCellProtocol.h
//  Article
//
//  Created by 曹清然 on 2017/7/11.
//
//

#import "TTShowImageView.h"

typedef enum TTPhotDetailCellType {
    TTPhotDetailCellType_None       = 0,             //容错样式
    TTPhotDetailCellType_Photo      = 1,             //图片
    TTPhotDetailCellType_OldAd      = 2,             //旧式广告
    TTPhotDetailCellType_NewAd      = 3,             //新式广告
    TTPhotDetailCellType_Recommend  = 4,             //图集推荐
}TTPhotDetailCellType;

typedef enum TTPhotoDetailCellScrollDirection {
    TTPhotoDetailCellScrollDirection_None          = 0,
    TTPhotoDetailCellScrollDirection_Front         = 1,             //前一个
    TTPhotoDetailCellScrollDirection_Current       = 2,             //当前
    TTPhotoDetailCellScrollDirection_BackFoward    = 3,             //后一个
}TTPhotoDetailCellScrollDirection;

typedef void (^TTPhotoDetailCellBlock)();




//图集cellhelper协议
@protocol TTPhotoDetailCellHelperProtocol <NSObject>

-(void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView WithCellType:(TTPhotDetailCellType)cellType;

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath;

@end




//图集cell协议
@protocol TTPhotoDetailCellProtocol <NSObject>

-(void)refreshWithData:(id)data WithContainView:(UIView *)containView WithCollectionView:(UICollectionView *)collectionView WithIndexPath:(NSIndexPath *)indexPath WithImageScrollViewDelegate:(id<TTShowImageViewDelegate>)delegate WithRefreshBlock:(TTPhotoDetailCellBlock)block;

@optional

- (void)ScrollViewDidScrollView:(UIScrollView *)scrollView ScrollDirection:(TTPhotoDetailCellScrollDirection)scrollDirection WithScrollPersent:(CGFloat)persent WithContainView:(UIView *)containView WithScrollBlock:(TTPhotoDetailCellBlock)block;

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath WithContainView:(UIView *)containView WithWillDisplayBlock:(TTPhotoDetailCellBlock)block;

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath WithContainView:(UIView *)containView WithWillEndDisplayBlock:(TTPhotoDetailCellBlock)block;

@end


