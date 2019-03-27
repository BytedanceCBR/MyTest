//
//  FHHouseFindHelpViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFindHelpBottomView;

@interface FHHouseFindHelpViewModel : NSObject

@property(nonatomic , copy)   void (^showNoDataBlock)(BOOL noData,BOOL isAvaiable);

-(instancetype)initWithCollectionView:(UICollectionView *)collectionView bottomView:(FHHouseFindHelpBottomView *)bottomView;

@end

NS_ASSUME_NONNULL_END
