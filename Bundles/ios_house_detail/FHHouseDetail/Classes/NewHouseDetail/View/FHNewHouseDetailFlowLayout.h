//
//  FHNewHouseDetailFlowLayout.h
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailSectionModel;

@interface FHNewHouseDetailFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) NSArray<FHNewHouseDetailSectionModel *> *sectionModels;

@end

NS_ASSUME_NONNULL_END
