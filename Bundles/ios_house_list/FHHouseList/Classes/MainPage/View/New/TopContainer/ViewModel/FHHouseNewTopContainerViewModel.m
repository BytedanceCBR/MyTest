//
//  FHHouseNewTopContainerViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewTopContainerViewModel.h"
#import "NSObject+FHTracker.h"

@interface FHHouseNewTopContainerViewModel()

@property (nonatomic, strong, readwrite) FHHouseNewEntrancesViewModel *entrancesViewModel;
@property (nonatomic, strong, readwrite) FHHouseNewBillboardViewModel *billboardViewModel;

@end

@implementation FHHouseNewTopContainerViewModel

- (FHHouseNewEntrancesViewModel *)entrancesViewModel {
    if (!_entrancesViewModel) {
        _entrancesViewModel = [[FHHouseNewEntrancesViewModel alloc] init];
        _entrancesViewModel.fh_trackModel = self.fh_trackModel;
    }
    return _entrancesViewModel;
}

- (FHHouseNewBillboardViewModel *)billboardViewModel {
    if (!_billboardViewModel) {
        _billboardViewModel = [[FHHouseNewBillboardViewModel alloc] init];
        _billboardViewModel.fh_trackModel = self.fh_trackModel;
    }
    return _billboardViewModel;
}

- (BOOL)isValid {
    return [self.entrancesViewModel isValid] || [self.billboardViewModel isValid];
}

- (void)startLoading {
    self.billboardViewModel.loading = YES;
}

- (void)loadFinishWithData:(nullable FHCourtBillboardPreviewModel *)data {
    [self.billboardViewModel loadFinishWithData:data];
}

- (void)loadFailedWithError:(nullable NSError *)error {
    [self loadFinishWithData:nil];
}

@end
