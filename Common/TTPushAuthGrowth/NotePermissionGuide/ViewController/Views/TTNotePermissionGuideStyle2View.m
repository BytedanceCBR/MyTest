//
//  TTNotePermissionGuideStyle2View.m
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import "TTNotePermissionGuideStyle2View.h"



@implementation TTNotePermissionGuideStyle2View

- (void)setupDismissButtons
{
    [self addSubview:self.closeButton];
}

- (void)setupTappedTextButtons
{
    [self addSubview:self.openSysSettingButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat insetBottom = [TTDeviceUIUtils tt_newPadding:50.f];
    
    self.openSysSettingButton.bottom = self.height - insetBottom;
    self.openSysSettingButton.centerX = [self.class viewWidth] / 2;
}

#pragma mark - events

- (void)actionForDidTapCloseButton:(id)sender
{
    [self hideWithCompletion:^{
        
    }];
}

- (void)actionForDidTapOpenSysSettingButton:(id)sender
{
    [self.class openAppSystemSettings];
    [self hideWithCompletion:^{
        
    }];
}

#pragma mark - setter/getter

- (SSThemedButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.imageName = @"icon_popup_close";
        _closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _closeButton.layer.cornerRadius = 6.f;
        _closeButton.clipsToBounds = YES;
        [_closeButton addTarget:self
                         action:@selector(actionForDidTapCloseButton:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (SSThemedButton *)openSysSettingButton
{
    if (!_openSysSettingButton) {
        _openSysSettingButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _openSysSettingButton.titleColorThemeKey = kColorText6;
        _openSysSettingButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _openSysSettingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_openSysSettingButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:28.f]]];
        [_openSysSettingButton setTitle:@"现在开启" forState:UIControlStateNormal];
        [_openSysSettingButton addTarget:self
                                  action:@selector(actionForDidTapOpenSysSettingButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    }
    return _openSysSettingButton;
}

@end
