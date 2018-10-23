//
//  TTCertificationOperationView.m
//  Article
//
//  Created by wangdi on 2017/5/17.
//
//

#import "TTCertificationOperationView.h"

@implementation TTCertificationOperationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.style = TTCertificationOperationViewStyleRed;
        [self baseSetup];
    }
    return self;
}

- (void)baseSetup
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
}

- (void)setStyle:(TTCertificationOperationViewStyle)style
{
    _style = style;
    if(style == TTCertificationOperationViewStyleRed) {
        self.backgroundColors = nil;
        self.backgroundColorThemeKey = kColorBackground7;
        self.titleColorThemeKey = kColorText12;
        self.borderColorThemeKey = nil;
        self.layer.borderWidth = 0;
    } else if (style == TTCertificationOperationViewStyleLightRed) {
        self.backgroundColorThemeKey = nil;
        self.backgroundColors = SSThemedColors(@"f859597f", @"f8595940");
        self.titleColorThemeKey = kColorText12;
        self.borderColorThemeKey = nil;
        self.layer.borderWidth = 0;
    } else {
        self.backgroundColors = nil;
        self.borderColorThemeKey = kColorLine1;
        self.backgroundColorThemeKey = kColorBackground3;
        self.titleColorThemeKey = kColorText1;
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
}

@end
 
