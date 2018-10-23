//
//  TTPhotoDetailCellManager.m
//  Article
//
//  Created by ranny_90 on 2017/7/12.
//
//

#import "TTPhotoDetailCellManager.h"
#import "ExploreImageCollectionView.h"


@implementation TTPhotoDetailCellManager

static TTPhotoDetailCellManager *s_manager;

+ (TTPhotoDetailCellManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTPhotoDetailCellManager alloc] init];
    });
    return s_manager;
}

-(void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView WithCellType:(TTPhotDetailCellType)cellType{
    
    if (collectionView) {
        if (cellType == TTPhotDetailCellType_Photo){
            
            [collectionView registerClass:[ExploreImageCollectionViewCell class] forCellWithReuseIdentifier:@"ExploreImageCollectionViewCell"];
        }
        
        else if (cellType == TTPhotDetailCellType_Recommend){
            [collectionView registerClass:[TTImageRecommendCell class] forCellWithReuseIdentifier:@"TTImageRecommendCell"];
        }
    }
    
}

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *phototCell = nil;
    
    if (collectionView) {
        if (cellType == TTPhotDetailCellType_Photo) {
            @try {
                phototCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExploreImageCollectionViewCell" forIndexPath:indexPath];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
        }
        else if (cellType == TTPhotDetailCellType_Recommend){
            @try {
                 phototCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImageRecommendCell" forIndexPath:indexPath];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
    
    return phototCell;
    
}

@end
