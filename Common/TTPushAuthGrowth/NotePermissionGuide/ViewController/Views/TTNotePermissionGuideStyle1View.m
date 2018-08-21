//
//  TTNotePermissionGuideStyle1View.m
//  Article
//
//  Created by liuzuopeng on 02/07/2017.
//
//

#import "TTNotePermissionGuideStyle1View.h"



@interface TTNotePermissionGuideStyle1View ()

@property (nonatomic, strong) SSThemedView *seperatorView;

@property (nonatomic, strong) NSMutableArray<SSThemedButton *> *buttonArray;

@end

@implementation TTNotePermissionGuideStyle1View

- (void)dealloc
{
    [self.buttonArray removeAllObjects];
}

- (void)setupTappedTextButtons
{
    [self addSubview:self.continueUseButton];
    [self addSubview:self.seperatorView];
    [self addSubview:self.openSysSettingButton];
    
    [self.buttonArray addObject:self.continueUseButton];
    [self.buttonArray addObject:self.openSysSettingButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = [self.class viewWidth];
    CGFloat insetBottom = [TTDeviceUIUtils tt_newPadding:48.f];
    CGFloat buttonToSep = [TTDeviceUIUtils tt_newPadding:42.f];
    
    // layout Buttons
    self.continueUseButton.right = width / 2 - buttonToSep;
    self.continueUseButton.bottom = self.height - insetBottom;
    
    self.openSysSettingButton.left = width / 2 + buttonToSep;
    self.openSysSettingButton.bottom = self.continueUseButton.bottom;
    
    // layout Separators
    self.seperatorView.centerY = self.continueUseButton.centerY;
    self.seperatorView.centerX = [self.class viewWidth] / 2;
}

#pragma mark - events

- (void)actionForDidTapButton:(id)sender
{
    NSInteger idx = [self.buttonArray indexOfObject:sender];
    if (idx == NSNotFound) return;
    
    if (sender == self.continueUseButton) {
        [self hideWithCompletion:^{
            
        }];
    } else if (sender == self.openSysSettingButton) {
        [self.class openAppSystemSettings];
        
        [self hideWithCompletion:^{
            
        }];
    }
}

- (SSThemedButton *)buttonAtIndex:(NSUInteger)idx
{
    if (idx >= [self.buttonArray count])
        return nil;
    return self.buttonArray[idx];
}

- (SSThemedButton *)createButton
{
    SSThemedButton *aButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    aButton.titleColorThemeKey = kColorText7;
    aButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    aButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [aButton.titleLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:28.f]]];
    [aButton setTitle:@"现在开启" forState:UIControlStateNormal];
    [aButton addTarget:self
                action:@selector(actionForDidTapButton:)
      forControlEvents:UIControlEventTouchUpInside];
    return aButton;
}

- (SSThemedView *)createSeparator
{
    CGFloat lineHeight = [TTDeviceUIUtils tt_newPadding:48.f];
    SSThemedView *lineView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], lineHeight)];
    lineView.backgroundColors = SSThemedColors(@"979797", @"979797");
    return lineView;
}

#pragma mark - setter/getter

- (NSMutableArray<SSThemedButton *> *)buttonArray
{
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray arrayWithCapacity:2];
    }
    return _buttonArray;
}

- (SSThemedView *)seperatorView
{
    if (!_seperatorView) {
        _seperatorView = [self createSeparator];
    }
    return _seperatorView;
}

- (SSThemedButton *)continueUseButton
{
    if (!_continueUseButton) {
        _continueUseButton = [self createButton];
        _continueUseButton.titleColorThemeKey = kColorText3;
    }
    return _continueUseButton;
}

- (SSThemedButton *)openSysSettingButton
{
    if (!_openSysSettingButton) {
        _openSysSettingButton = [self createButton];
        _openSysSettingButton.titleColorThemeKey = kColorText6;
    }
    return _openSysSettingButton;
}
@end
