//
//  TTPersonalHomeFollowButton.m
//  Article
//
//  Created by wangdi on 2017/3/28.
//
//

#import "TTPersonalHomeFollowButton.h"

@implementation TTPersonalHomeFollowButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        
        self.titleColorThemeKey = kColorText6;
        self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
        self.backgroundColorThemeKey = nil;
        self.borderColorThemeKey = kColorLine3;
        self.layer.borderWidth = 1;

    }
    return self;
}

@end
