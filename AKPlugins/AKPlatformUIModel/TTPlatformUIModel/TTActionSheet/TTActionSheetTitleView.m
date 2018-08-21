//
//  TTActionSheetTitleView.m
//  Article
//
//  Created by zhaoqin on 8/31/16.
//
//

#import "TTActionSheetTitleView.h"
#import "TTActionSheetConst.h"

#import "SSThemed.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "TTActionSheetConst.h"
#import "TTDeviceUIUtils.h"
#import "TTThemeManager.h"

@interface TTActionSheetTitleView ()
@property (nonatomic, strong) SSThemedImageView *backImage;
@property (nonatomic, strong) UILabel *backLabel;
@end

@implementation TTActionSheetTitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        _backButton = [[UIButton alloc] init];
        _backImage = [[SSThemedImageView alloc] init];
        _backLabel = [[UILabel alloc] init];
        _titleLabel = [[UILabel alloc] init];
        
        [_backButton addSubview:_backImage];
        [_backButton addSubview:_backLabel];
        
        [self addSubview:_titleLabel];
        [self addSubview:_backButton];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    
    self.frame = CGRectMake(0, 0, screenWidth, TTActionSheetNavigationBarHeight);
    [self setBackgroundColor:[UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"]];
    
    self.titleLabel.frame = CGRectMake(0, [TTDeviceUIUtils tt_padding:10], 200, TTActionSheetTableCellHeight);
    self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.centerX = self.centerX;
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]]];
    
    self.backButton.frame = CGRectMake([TTDeviceUIUtils tt_padding:27] + padding, [TTDeviceUIUtils tt_padding:10], 70, TTActionSheetTableCellHeight);
    self.backButton.centerY = self.titleLabel.centerY;
    
    self.backImage.frame = CGRectMake(0, 0, 15, 15);
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.backImage.image = [UIImage imageNamed:@"all_arrow_unlike"];
    }
    else {
        self.backImage.image = [UIImage imageNamed:@"all_arrow_unlike_night"];
    }
    
    self.backImage.contentMode = UIViewContentModeScaleAspectFit;
    
    self.backLabel.text = @"返回";
    self.backLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.backLabel.frame = CGRectMake([TTDeviceUIUtils tt_padding:18], 0, 45, TTActionSheetTableCellHeight);
    self.backLabel.left = self.backImage.right + [TTDeviceHelper ssOnePixel];
    [self.backLabel setFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]]];
    
    self.backImage.centerY = self.backLabel.centerY;
    
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
