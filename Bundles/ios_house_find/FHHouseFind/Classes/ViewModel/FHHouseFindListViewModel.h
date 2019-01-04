//
//  FHHouseFindListViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"
#import "FHTracerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindListViewModel : NSObject

@property (nonatomic , assign) FHHouseType houseType;

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView;

-(void)jump2GuessVC;
-(void)setTracerModel:(FHTracerModel *)tracerModel;

@end

NS_ASSUME_NONNULL_END
