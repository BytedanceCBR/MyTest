//
//  FHNewHouseDetailHeaderMediaSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailHeaderMediaSC.h"
#import "FHNewHouseDetailHeaderMediaSM.h"

@implementation FHNewHouseDetailHeaderMediaSC

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)didUpdateToObject:(id)object {
    if (object && [object isKindOfClass:[FHNewHouseDetailHeaderMediaSM class]]) {
        
    }
}

- (NSInteger)numberOfItems {
    return 0;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    return nil;
}

@end
