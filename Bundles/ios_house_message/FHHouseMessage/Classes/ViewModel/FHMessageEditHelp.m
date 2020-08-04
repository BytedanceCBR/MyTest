//
//  FHMessageEditHelp.m
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/28.
//

#import "FHMessageEditHelp.h"

@implementation FHMessageEditHelp

+ (instancetype)shared {
    static FHMessageEditHelp *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FHMessageEditHelp alloc] init];
    });
    return instance;
}

+ (void)close {
    if ([FHMessageEditHelp shared].currentCell && [FHMessageEditHelp shared].currentCell.state == SliderMenuOpen) {
        [[FHMessageEditHelp shared].currentCell close];
    }
}

+ (void)clear {
    if ([FHMessageEditHelp shared].currentCell) {
        [FHMessageEditHelp shared].currentCell.state = SliderMenuClose;
        [FHMessageEditHelp shared].currentCell = nil;
        [FHMessageEditHelp shared].conversation = nil;
    }
}

@end
