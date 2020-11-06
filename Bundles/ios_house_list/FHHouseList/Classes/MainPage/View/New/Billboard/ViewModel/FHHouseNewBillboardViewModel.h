//
//  FHHouseNewBillboardViewModel.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseNewBillboardViewModel;
@protocol FHHouseNewBillboardViewModelObserver <FHHouseNewComponentViewModelObserver>

- (void)onBillboardDataChanged:(FHHouseNewBillboardViewModel *)viewModel;

@end

@class FHCourtBillboardPreviewModel;
@class FHHouseNewBillboardContentViewModel;
@interface FHHouseNewBillboardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong, readonly) FHHouseNewBillboardContentViewModel *contentViewModel;

- (void)loadFinishWithData:(FHCourtBillboardPreviewModel *)data;

@end

NS_ASSUME_NONNULL_END
