//
//  FHHouseNewBillboardViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardViewModel.h"
#import "FHHouseNewBillboardContentViewModel.h"
#import "FHSearchHouseModel.h"
#import "NSObject+FHTracker.h"

@interface FHHouseNewBillboardViewModel()
@property (nonatomic, strong, readwrite) FHHouseNewBillboardContentViewModel *contentViewModel;
@end

@implementation FHHouseNewBillboardViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _loading = YES;
    }
    return self;
}

- (void)fireObservers {
    for (id<FHHouseNewBillboardViewModelObserver> observer in [_observers allObjects]) {
        if ([observer respondsToSelector:@selector(onBillboardDataChanged:)]) {
            [observer onBillboardDataChanged:self];
        }
    }
}

- (void)loadFinishWithData:(FHCourtBillboardPreviewModel *)data {
    if (data && [data isKindOfClass:FHCourtBillboardPreviewModel.class]) {
        _loading = NO;
        _contentViewModel = [[FHHouseNewBillboardContentViewModel alloc] initWithModel:data tracerModel:self.fh_trackModel];
        [self fireObservers];
    } else {
        _loading = NO;
        [self fireObservers];
    }
}

- (BOOL)isValid {
    return YES;
}

@end
