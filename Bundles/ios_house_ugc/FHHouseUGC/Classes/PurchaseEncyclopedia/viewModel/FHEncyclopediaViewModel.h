//
//  FHEncyclopediaViewModel.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/21.
//

#import <Foundation/Foundation.h>
#import "FHEncyclopediaViewController.h"
#import "FHEncyclopediaHeader.h"
#import "FHTracerModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHEncyclopediaViewModel : NSObject
- (instancetype)initWithWithController:(FHEncyclopediaViewController *)viewController collectionView:(UICollectionView *)collectionView headerView:(FHEncyclopediaHeader *)header tracerModel:(FHTracerModel *)tracerModel lynxBaseIndexParam:(NSDictionary *)lynxBaseIndexParam;
@property(nonatomic , strong) NSNumber *currentSubTabIndex;
@property(nonatomic , strong) NSNumber *currentMainTabIndex;
@property(nonatomic, strong) FHTracerModel *tracerModel;
- (void)requestHeaderConfig;
@end

NS_ASSUME_NONNULL_END
