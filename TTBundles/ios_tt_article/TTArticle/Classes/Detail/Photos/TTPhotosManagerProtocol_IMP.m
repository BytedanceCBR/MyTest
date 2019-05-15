//
//  TTPhotosManagerProtocol_IMP.m
//  Article
//
//  Created by chenjiesheng on 2017/7/14.
//
//

#import "TTPhotosManagerProtocol_IMP.h"
#import "TTPhotoDetailCellManager.h"

@implementation TTPhotosManagerProtocol_IMP

+ (instancetype)sharedInstance
{
    return (id)[TTPhotoDetailCellManager shareManager];
}

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath {
    return [[self.class sharedInstance] dequeueTableCellForcollectionView:collectionView ForCellType:cellType atIndexPath:indexPath];
}

- (void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView WithCellType:(TTPhotDetailCellType)cellType {
    [[self.class sharedInstance] registerPhotoDetailCellWithCollectionView:collectionView WithCellType:cellType];
}

@end
