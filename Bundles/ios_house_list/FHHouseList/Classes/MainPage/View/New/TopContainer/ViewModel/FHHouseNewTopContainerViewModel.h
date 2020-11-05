//
//  FHHouseNewTopContainerViewModel.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHHouseNewEntrancesViewModel.h"
#import "FHHouseNewBillboardViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHCourtBillboardPreviewModel;

@interface FHHouseNewTopContainerViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) FHHouseNewEntrancesViewModel *entrancesViewModel;

@property (nonatomic, strong, readonly) FHHouseNewBillboardViewModel *billboardViewModel;

- (void)startLoading;
- (void)loadFinishWithData:(nullable FHCourtBillboardPreviewModel *)data;
- (void)loadFailedWithError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
