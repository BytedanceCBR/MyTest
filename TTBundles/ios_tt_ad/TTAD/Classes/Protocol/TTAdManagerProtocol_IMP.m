//
//  TTAdManagerProtocolIMP.m
//  Article
//
//  Created by yin on 2017/6/28.
//
//

#import "TTAdManagerProtocol_IMP.h"
#import "TTAdManager.h"

@implementation TTAdManagerProtocol_IMP

+ (id)sharedInstance
{
    return (id)[TTAdManager sharedManager];
}

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath {
    return [[self.class sharedInstance] dequeueTableCellForcollectionView:collectionView ForCellType:cellType atIndexPath:indexPath];
}

- (void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView WithCellType:(TTPhotDetailCellType)cellType {
    [[self.class sharedInstance] registerPhotoDetailCellWithCollectionView:collectionView WithCellType:cellType];
}


@end
