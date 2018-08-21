//
//  TTCommonwealUnLoginEntranceView.m
//  Article
//
//  Created by wangdi on 2017/8/10.
//
//

#import "TTCommonwealUnLoginEntranceView.h"

@interface TTCommonwealUnLoginEntranceView ()

@property (nonatomic, strong) SSThemedImageView *leftImageView;
@property (nonatomic, strong) SSThemedLabel *rightLabel;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation TTCommonwealUnLoginEntranceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = kCommonwealUnloginEntranceViewH * 0.5;
        [self setupSubview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self setTipsTitle:[self lastTitle] isSelected:[self lastIsSelected]];
    }
    return self;
}

- (void)setTipsTitle:(NSString *)title isSelected:(BOOL)isSelected
{
    self.rightLabel.text = title;
    self.isSelected = isSelected;
    [self setLastTitle:title];
    if(isSelected) {
        self.leftImageView.imageName = @"commonweal_gold";
    } else {
        self.leftImageView.imageName = @"commonweal_normal";
    }
    [self themedChange];
    [self setupSubviewFrame];
}

- (SSThemedImageView *)leftImageView
{
    if(!_leftImageView) {
        _leftImageView = [[SSThemedImageView alloc] init];
    }
    return _leftImageView;
}

- (SSThemedLabel *)rightLabel
{
    if(!_rightLabel) {
        _rightLabel = [[SSThemedLabel alloc] init];
        _rightLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _rightLabel.textColorThemeKey = kColorText10;
    }
    return _rightLabel;
}

- (void)setupSubview
{
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightLabel];
}

- (void)setupSubviewFrame
{
    self.height = kCommonwealUnloginEntranceViewH;
    self.leftImageView.left = [TTDeviceUIUtils tt_newPadding:10];
    self.leftImageView.size = CGSizeMake(16, 16);
    self.leftImageView.centerY = self.height * 0.5;
    self.rightLabel.left = self.leftImageView.right + [TTDeviceUIUtils tt_newPadding:4];
    self.rightLabel.height = [TTDeviceUIUtils tt_newPadding:14];
    self.rightLabel.centerY = self.leftImageView.centerY;
    CGFloat rightLabelWidth = [self.rightLabel.text sizeWithAttributes:@{NSFontAttributeName : self.rightLabel.font}].width;
    self.rightLabel.width = rightLabelWidth;
    self.width = self.rightLabel.right + [TTDeviceUIUtils tt_newPadding:10];
    
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    } else {
        self.backgroundColor = [UIColor colorWithRed:112 / 255.0 green:112 / 255.0 blue:112 / 255.0 alpha:0.2];
    }
}

- (void)setLastTitle:(NSString *)lastTitle
{
    [[NSUserDefaults standardUserDefaults] setObject:lastTitle forKey:@"tt_commonweal_unlogin_last_title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastTitle
{
    NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_unlogin_last_title"];
    if(isEmptyString(title)) {
        if([self lastIsSelected]) {
            title = @"0公益金待领取";
        } else {
            title = @"今日阅读1分钟";
        }
    }
    return title;
}

- (void)setLastIsSelected:(BOOL)isSelected
{
    [[NSUserDefaults standardUserDefaults] setBool:isSelected forKey:@"tt_commonweal_unlogin_last_is_selected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)lastIsSelected
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_commonweal_unlogin_last_is_selected"];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    [self setLastIsSelected:isSelected];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
