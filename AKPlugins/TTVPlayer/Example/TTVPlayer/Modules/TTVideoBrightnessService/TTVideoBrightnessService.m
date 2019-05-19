//
//  TTVideoBrightnessService.m
//  Article
//
//  Created by 赵晶鑫 on 27/08/2017.
//
//

#import "TTVideoBrightnessService.h"

@implementation TTVideoBrightnessService

- (instancetype)init {
    self = [super init];
    if (self) {
        _enableBrightnessView = NO;
    }
    return self;
}

#pragma mark -
#pragma mark public methods

- (CGFloat)currentBrightness {
    return [UIScreen mainScreen].brightness;
}

- (void)updateBrightnessValue:(CGFloat)value {
    CGFloat validValue = MIN(MAX(0.0f, value), 1.0f);
    
    if (self.enableBrightnessView && self.brightnessDidChange) {
        self.brightnessDidChange(validValue);
    }
    
    [[UIScreen mainScreen] setBrightness:validValue];
}

@end
