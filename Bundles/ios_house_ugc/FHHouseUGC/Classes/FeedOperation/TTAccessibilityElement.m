//
//  TTAccessibilityElement.m
//  TTPlatformUIModel
//
//  Created by 王振旺 on 2018/8/15.
//

#import "TTAccessibilityElement.h"

@implementation TTAccessibilityElement

- (NSString *)accessibilityLabel {
    if (_labelBlock) {
        return _labelBlock();
    } else {
        return [super accessibilityLabel];
    }
}

- (BOOL)accessibilityActivate {
    if (_activateActionBlock) {
        return _activateActionBlock();
    } else {
        return [super accessibilityActivate];
    }
}

@end
