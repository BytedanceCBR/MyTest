//
//  TTPhotoDetailCellHelper.m
//  Article
//
//  Created by 曹清然 on 2017/7/11.
//
//

#import "TTPhotoDetailCellHelper.h"
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import "TTPhotosManagerProtocol.h"

#define TTPhotoDetailErrorCellType @"TTPhotoDetailErrorCellType"

@interface TTPhotoDetailCellHelper (){
    
    NSMutableDictionary<NSString*,id<TTPhotoDetailCellHelperProtocol>> *cellTypeHelperDic;

}

@end

@implementation TTPhotoDetailCellHelper

static TTPhotoDetailCellHelper *s_manager;

+ (TTPhotoDetailCellHelper *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[TTPhotoDetailCellHelper alloc] init];
    });
    return s_manager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
        cellTypeHelperDic = [[NSMutableDictionary alloc] init];
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        [self registerPhotoDetailCellHelper:adManagerInstance forCellType:TTPhotDetailCellType_OldAd];
        [self registerPhotoDetailCellHelper:adManagerInstance forCellType:TTPhotDetailCellType_NewAd];
        id<TTPhotosManagerProtocol> photosManagerInstane = [[TTServiceCenter sharedInstance ]getServiceByProtocol:@protocol(TTPhotosManagerProtocol)];
        [self registerPhotoDetailCellHelper:photosManagerInstane forCellType:TTPhotDetailCellType_Photo];
        [self registerPhotoDetailCellHelper:photosManagerInstane forCellType:TTPhotDetailCellType_Recommend];
        
    }
    return self;
}

- (void)registerPhotoDetailCellHelper:(id<TTPhotoDetailCellHelperProtocol>)helper forCellType:(TTPhotDetailCellType)cellType{
    
    if (helper && [helper conformsToProtocol:@protocol(TTPhotoDetailCellHelperProtocol)]) {
        [cellTypeHelperDic setValue:helper forKey:[NSString stringWithFormat:@"%@",@(cellType)]];
    }
}

-(void)registerPhotoDetailCellWithCollectionView:(UICollectionView *)collectionView{
    
    if (collectionView) {

        [cellTypeHelperDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if (key && [key isKindOfClass:[NSString class]] && obj && [obj conformsToProtocol:@protocol(TTPhotoDetailCellHelperProtocol)]) {
                
                NSInteger cellType = [key integerValue];
                [obj registerPhotoDetailCellWithCollectionView:collectionView WithCellType:(TTPhotDetailCellType)cellType];
                
            }
            
        }];
        
    }
}

- (UICollectionViewCell *)dequeueTableCellForcollectionView:(UICollectionView *)collectionView  ForCellType:(TTPhotDetailCellType)cellType atIndexPath:(NSIndexPath *)indexPath{
    
    
    if (!collectionView || !indexPath) {
        return nil;
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%@",@(cellType)];
    id<TTPhotoDetailCellHelperProtocol> cellTypeHelper = [cellTypeHelperDic objectForKey:identifier];
    
    UICollectionViewCell *cell = nil;
    if (cellTypeHelper && [cellTypeHelper conformsToProtocol:@protocol(TTPhotoDetailCellHelperProtocol)]) {
        cell = [cellTypeHelper dequeueTableCellForcollectionView:collectionView ForCellType:cellType atIndexPath:indexPath];
    }
    
    return cell;
}

@end
