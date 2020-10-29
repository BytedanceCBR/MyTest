//
//  FHHouseNewBillboardViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardViewModel.h"
#import "FHHouseNewBillboardContentViewModel.h"
#import "FHSearchHouseModel.h"

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
    if (data) {
        _loading = NO;
        _contentViewModel = [[FHHouseNewBillboardContentViewModel alloc] initWithModel:data];
        [self fireObservers];
    }
}

- (BOOL)isValid {
    return YES;
}

@end
