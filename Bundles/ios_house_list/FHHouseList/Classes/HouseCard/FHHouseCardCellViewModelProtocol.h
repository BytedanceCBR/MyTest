//
//  FHHouseCardCellViewModelProtocol.h
//  Pods
//
//  Created by bytedance on 2020/11/30.
//

#ifndef FHHouseCardCellViewModelProtocol_h
#define FHHouseCardCellViewModelProtocol_h


#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseCardCellViewModelProtocol <FHHouseNewComponentViewModelProtocol>

@optional
- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)hideCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)cardWillEnterForground;

- (void)cardDidEnterBackground;


@end

NS_ASSUME_NONNULL_END

#endif /* FHHouseCardCellViewModelProtocol_h */
