//
//  TTPhotoDetailCellHelper.h
//  Article
//
//  Created by 曹清然 on 2017/7/11.
//
//

#import <Foundation/Foundation.h>
#import "TTPhotoDetailCellProtocol.h"

@interface TTPhotoDetailCellHelper : NSObject

+ (TTPhotoDetailCellHelper *)shareManager;

-(void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView;

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView  ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath;

@end
