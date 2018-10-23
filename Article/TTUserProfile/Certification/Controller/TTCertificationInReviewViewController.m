//
//  TTCertificationInReviewViewController.m
//  Article
//
//  Created by wangdi on 2017/5/22.
//
//

#import "TTCertificationInReviewViewController.h"
#import "TTPersonalHomeViewController.h"
#import "SSWebViewController.h"
@interface TTCertificationInReviewViewController ()

@end

@implementation TTCertificationInReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.title = @"爱看认证";
    [self themeChanged:nil];
    [self setupSubview];
}

- (void)themeChanged:(NSNotification*)notification {
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
        _iconView.alpha = 1;
    }else {
        _iconView.alpha = 0.5f;
    }
}

- (SSThemedImageView *)iconView
{
    if(!_iconView) {
        _iconView = [[SSThemedImageView alloc] init];
        _iconView.width = [TTDeviceUIUtils tt_newPadding:179];
        _iconView.height = [TTDeviceUIUtils tt_newPadding:77];
        _iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _iconView.top = [TTDeviceUIUtils tt_newPadding:157];
        if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
            _iconView.alpha = 1;
        }else {
            _iconView.alpha = 0.5f;
        }
        _iconView.centerX = self.view.width * 0.5;
    }
    return _iconView;
}

- (SSThemedLabel *)descLabel
{
    if(!_descLabel) {
        _descLabel = [[SSThemedLabel alloc] init];
        _descLabel.textColorThemeKey = kColorText1;
        _descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.left = 0;
        _descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _descLabel.top = self.iconView.bottom + [TTDeviceUIUtils tt_newPadding:30];
        _descLabel.width = self.view.width;
        _descLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
    }
    return _descLabel;
}

- (SSThemedLabel *)timeLabel
{
    if(!_timeLabel) {
        _timeLabel = [[SSThemedLabel alloc] init];
        _timeLabel.textColorThemeKey = kColorText1;
        _timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _timeLabel.left = [TTDeviceUIUtils tt_newPadding:15];
        _timeLabel.top = self.descLabel.bottom + [TTDeviceUIUtils tt_newPadding:5];
        _timeLabel.width = self.view.width - 2 * _timeLabel.left;
        _timeLabel.height = [TTDeviceUIUtils tt_newPadding:17];
    }
    return _timeLabel;
}

- (void)questionButtonClick:(id)sender {
    if (!isEmptyString(self.questionUrl)) {
        [SSWebViewController openWebViewForNSURL:[NSURL URLWithString:self.questionUrl] title:@"常见问题" navigationController:self.navigationController supportRotate:NO];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCertificationPressQuestionsEntranceNotification object:nil];
    }
}

- (SSThemedButton *)questionButton {
    if (!_questionButton) {
        _questionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _questionButton.width = [TTDeviceUIUtils tt_newPadding:70];
        _questionButton.height = [TTDeviceUIUtils tt_newPadding:20];
        _questionButton.bottom = self.view.bottom - [TTDeviceUIUtils tt_newPadding:10] - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
        _questionButton.centerX = self.view.centerX;
        _questionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _questionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
        [_questionButton setTitle:@"常见问题" forState:UIControlStateNormal];
        _questionButton.titleColorThemeKey = kColorText6;
        _questionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [_questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionButton;
}

- (void)setupSubview
{
    [self.view addSubview:self.iconView];
    [self.view  addSubview:self.descLabel];
    [self.view addSubview:self.timeLabel];
    [self.view addSubview:self.questionButton];
}

@end
