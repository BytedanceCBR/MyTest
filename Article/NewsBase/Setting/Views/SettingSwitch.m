//
//  SettingSwitch.m
//  Article
//
//  Created by Chen Hong on 16/1/6.
//
//

#import "SettingSwitch.h"

@implementation SettingSwitch

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [super setOn:on animated:animated];
    [self setSelected:on];
}

@end
