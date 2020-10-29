//
//  FHHouseNewTopContainerViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewTopContainerViewModel.h"

@interface FHHouseNewTopContainerViewModel()

@property (nonatomic, strong, readwrite) FHHouseNewEntrancesViewModel *entrancesViewModel;
@property (nonatomic, strong, readwrite) FHHouseNewBillboardViewModel *billboardViewModel;

@end

@implementation FHHouseNewTopContainerViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _entrancesViewModel = [[FHHouseNewEntrancesViewModel alloc] init];
        _billboardViewModel = [[FHHouseNewBillboardViewModel alloc] init];
    }
    return self;
}

- (BOOL)isValid {
    return [self.entrancesViewModel isValid] || [self.billboardViewModel isValid];
}

- (void)startLoading {
    self.billboardViewModel.loading = YES;
}

- (void)loadFinishWithData:(FHCourtBillboardPreviewModel *)data {
    [self.billboardViewModel loadFinishWithData:data];
}

- (void)loadFailed {
    self.billboardViewModel.loading = NO;
}

@end
