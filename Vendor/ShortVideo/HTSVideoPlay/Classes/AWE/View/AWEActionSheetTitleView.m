//
//  TTActionSheetTitleView.m
//  Article
//
//  Created by zhaoqin on 8/31/16.
//
//

#import "AWEActionSheetTitleView.h"
#import "AWEActionSheetConst.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"

@interface AWEActionSheetTitleView ()
@property (nonatomic, strong) SSThemedImageView *backImage;
@property (nonatomic, strong) UILabel *backLabel;
@end

@implementation AWEActionSheetTitleView

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
    
    self.frame = CGRectMake(0, 0, screenWidth, AWEActionSheetNavigationBarHeight);
    [self setBackgroundColor:[UIColor colorWithDayColorName:@"ffffff" nightColorName:@"252525"]];
    
    self.titleLabel.frame = CGRectMake(0, 10, 200, AWEActionSheetTableCellHeight);
    self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.centerX = self.centerX;
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    
    self.backButton.frame = CGRectMake(27 + padding, 10, 70, AWEActionSheetTableCellHeight);
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
    self.backLabel.frame = CGRectMake(18, 0, 45, AWEActionSheetTableCellHeight);
    self.backLabel.left = self.backImage.right + [TTDeviceHelper ssOnePixel];
    [self.backLabel setFont:[UIFont systemFontOfSize:16]];
    
    self.backImage.centerY = self.backLabel.centerY;
    
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

@end
