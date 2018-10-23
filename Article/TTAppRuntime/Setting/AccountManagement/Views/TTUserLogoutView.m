//
//  TTUserLogoutView.m
//  Article
//
//  Created by it-test on 8/4/16.
//
//

#import "TTUserLogoutView.h"
#import "TTSettingConstants.h"


@interface TTUserLogoutView ()
@property(nonatomic, strong) SSThemedLabel *logoutTitleLabel;
@end

@implementation TTUserLogoutView

- (instancetype)init {
    if ((self = [super init])) {
        [self addSubview:self.logoutTitleLabel];
        
        [self.logoutTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(self);
        }];
    }
    return self;
}

- (void)reloadWithTitle:(NSString *)title themeKey:(NSString *)titleTextThemeKey {
    if (!title) return;
    
    self.logoutTitleLabel.text = title;
    self.logoutTitleLabel.textColorThemeKey = titleTextThemeKey;
}


#pragma mark - lazied load for setter/getter properties

- (SSThemedLabel *)logoutTitleLabel {
    if (!_logoutTitleLabel) {
        _logoutTitleLabel = [[SSThemedLabel alloc] init];
        _logoutTitleLabel.textAlignment = NSTextAlignmentCenter;
        _logoutTitleLabel.textColorThemeKey = [self.class colorkeyOfLogoutText];
        _logoutTitleLabel.backgroundColor = [UIColor clearColor];
        _logoutTitleLabel.font = [UIFont systemFontOfSize:[self.class fontSizeOfLogoutText]];
    }
    return _logoutTitleLabel;
}

+ (CGFloat)fontSizeOfLogoutText {
    return [TTDeviceUIUtils tt_fontSize:kTTSettingLogoutFontSize];
}

+ (NSString *)colorkeyOfLogoutText {
    return kTTSettingLogoutColorKey;
}
@end

