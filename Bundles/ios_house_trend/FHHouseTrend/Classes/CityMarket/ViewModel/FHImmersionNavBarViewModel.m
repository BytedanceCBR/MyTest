//
//  FHImmersionNavBarViewModel.m
//  Pods
//
//  Created by leo on 2019/3/29.
//

#import "FHImmersionNavBarViewModel.h"

@implementation FHImmersionNavBarViewModel

- (void)setCurrentContentOffset:(CGPoint)currentContentOffset {
    [self willChangeValueForKey:@"currentContentOffset"];
    NSLog(@"setCurrentContentOffset : %@", currentContentOffset);
    _currentContentOffset = currentContentOffset;
    [self didChangeValueForKey:@"currentContentOffset"];
}

@end
