//
//  FHHouseNewEntrancesViewModel.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHConfigDataOpDataItemsModel;
@interface FHHouseNewEntrancesViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) NSArray *items;

- (void)onClickItem:(FHConfigDataOpDataItemsModel *)item;

@end

NS_ASSUME_NONNULL_END
