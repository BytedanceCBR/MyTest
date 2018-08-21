//
//  TTCommonwealHasLoginEntranceView.m
//  Article
//
//  Created by wangdi on 2017/8/10.
//
//

#import "TTCommonwealHasLoginEntranceView.h"

@interface TTCommonwealHasLoginEntranceView ()

@property (nonatomic, strong) SSThemedImageView *topIconView;
@property (nonatomic, strong) SSThemedLabel *topTitleLabel;
@property (nonatomic, strong) SSThemedLabel *bottomTitleLabel;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation TTCommonwealHasLoginEntranceView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self setupSubview];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self setTopTitle:[self lastTitle] bottomTitle:[self lastSubTitle] isSelected:[self lastIsSelected]];
    }
    return self;
}

- (SSThemedImageView *)topIconView
{
    if(!_topIconView) {
        _topIconView = [[SSThemedImageView alloc] init];
    }
    return _topIconView;
}

- (SSThemedLabel *)topTitleLabel
{
    if(!_topTitleLabel) {
        _topTitleLabel = [[SSThemedLabel alloc] init];
        _topTitleLabel.textColorThemeKey = kColorText10;
        _topTitleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:11]];
    }
    return _topTitleLabel;
}

- (SSThemedLabel *)bottomTitleLabel
{
    if(!_bottomTitleLabel) {
        _bottomTitleLabel = [[SSThemedLabel alloc] init];
        _bottomTitleLabel.textColorThemeKey = kColorText10;
        _bottomTitleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:11]];
    }
    return _bottomTitleLabel;
}

- (void)setupSubview
{
    [self addSubview:self.topIconView];
    [self addSubview:self.topTitleLabel];
    [self addSubview:self.bottomTitleLabel];
}

- (void)setTopTitle:(NSString *)topTitle bottomTitle:(NSString *)bottomTitle isSelected:(BOOL)isSelected
{
    self.topTitleLabel.text = topTitle;
    self.bottomTitleLabel.text = bottomTitle;
    self.isSelected = isSelected;
    [self setLastTitle:topTitle];
    [self setLastSubTitle:bottomTitle];
    if(isSelected) {
        self.topIconView.imageName = @"commonweal_gold";
    } else {
        self.topIconView.imageName = @"commonweal_normal";
    }
    [self themedChange];
    [self setupSubviewFrame];
}

- (void)setupSubviewFrame
{
    self.topIconView.size = CGSizeMake(20, 20);
    self.topIconView.left = [TTDeviceUIUtils tt_newPadding:10];
    self.topIconView.centerY = kCommonwealHasLoginEntranceViewH * 0.5;
    self.topTitleLabel.left = self.topIconView.right + [TTDeviceUIUtils tt_newPadding:7];
    self.topTitleLabel.height = [TTDeviceUIUtils tt_newPadding:11];
    self.topTitleLabel.width = kCommonwealHasLoginEntranceViewW - self.topTitleLabel.left;
    self.topTitleLabel.top = [TTDeviceUIUtils tt_newPadding:8];
    
    self.bottomTitleLabel.left = self.topTitleLabel.left;
    self.bottomTitleLabel.height = self.topTitleLabel.height;
    self.bottomTitleLabel.bottom =  kCommonwealHasLoginEntranceViewH - [TTDeviceUIUtils tt_newPadding:7];
    self.bottomTitleLabel.width = [self.bottomTitleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.bottomTitleLabel.font}].width;
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
    [[NSUserDefaults standardUserDefaults] setObject:lastTitle forKey:@"tt_commonweal_login_last_title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastTitle
{
    NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_login_last_title"];
    if(isEmptyString(title)) {
        if([self lastIsSelected]) {
            title = @"0公益金";
        } else {
            title = @"今日阅读";
        }
    }
    return title;
}

- (void)setLastSubTitle:(NSString *)lastSubTitle
{
    [[NSUserDefaults standardUserDefaults] setObject:lastSubTitle forKey:@"tt_commonweal_login_last_sub_title"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastSubTitle
{
    NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"tt_commonweal_login_last_sub_title"];
    if(isEmptyString(title)) {
        if([self lastIsSelected]) {
            title = @"待领取";
        } else {
            title = @"1分钟";
        }
    }
    return title;
}


- (void)setLastIsSelected:(BOOL)isSelected
{
    [[NSUserDefaults standardUserDefaults] setBool:isSelected forKey:@"tt_commonweal_login_last_is_selected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)lastIsSelected
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_commonweal_login_last_is_selected"];
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
