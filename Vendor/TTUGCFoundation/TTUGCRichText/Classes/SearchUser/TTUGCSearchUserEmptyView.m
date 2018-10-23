//
//  TTUGCSearchUserEmptyView.m
//  Article
//
//  Created by Jiyee Sheng on 15/09/2017.
//
//

#import "TTUGCSearchUserEmptyView.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "SSThemed.h"
#import "TTDeviceUIUtils.h"
#import "TTThemeManager.h"

@implementation TTUGCSearchUserEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;

        [self addSubview:self.errorImage];
        [self addSubview:self.errorMsg];

        [self.errorMsg sizeToFit];
        self.errorMsg.centerX = self.width / 2;
        self.errorMsg.centerY = self.height / 2;

        int imageWidth = [TTDeviceHelper isScreenWidthLarge320]? 298: 254;
        int imageHeight = [TTDeviceHelper isScreenWidthLarge320]? 426: 363;

        self.errorImage.width = imageWidth;
        self.errorImage.height = imageHeight;
        self.errorImage.centerX = self.width / 2;
        self.errorImage.centerY = self.height / 2;

        [self reloadThemeUI];
    }

    return self;
}

- (void)reloadThemeUI {
    [super reloadThemeUI];

    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.errorImage.alpha = 0.5;
    } else {
        self.errorImage.alpha = 1.0;
    }
}

- (SSThemedLabel *)errorMsg {
    if (!_errorMsg) {
        _errorMsg = [[SSThemedLabel alloc] init];
        _errorMsg.text = @"没有联系人";
        _errorMsg.textColorThemeKey = kColorText1;
        _errorMsg.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_padding:17.0]];
    }

    return _errorMsg;
}

- (SSThemedImageView *)errorImage {
    if (!_errorImage) {
        _errorImage = [[SSThemedImageView alloc] initWithImage:[UIImage imageNamed:@"follow_empty_bg"]];
    }

    return _errorImage;
}

@end
