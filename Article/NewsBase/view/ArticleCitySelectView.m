//
//  ArticleCitySelectView.m
//  Article
//
//  Created by Kimimaro on 13-6-16.
//
//

#import "ArticleCitySelectView.h"

#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"

@interface ArticleCitySelectView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation ArticleCitySelectView
@synthesize citySelectButton, lineView, titleLabel, iconView;
/*
- (void)dealloc
{
    self.titleLabel = nil;
    self.iconView = nil;
    self.lineView = nil;
    self.citySelectButton = nil;
    [super dealloc];
}*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.citySelectButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        citySelectButton.backgroundColorThemeKey = kColorBackground4;
        citySelectButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        [self addSubview:citySelectButton];
        
        self.titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:[ArticleCitySelectView titleFontSize]];
        titleLabel.text = NSLocalizedString(@"点击选择其他城市", nil);
        [self addSubview:titleLabel];
        
        self.iconView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"city_native.png"]];
        [self addSubview:iconView];
        
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
        [self addSubview:lineView];
        
        [self updateFrames];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    //[citySelectButton setBackgroundImage:[UIImage themedImageNamed:@"city_context.png"] forState:UIControlStateNormal]
    titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    iconView.image = [UIImage themedImageNamed:@"city_native.png"];
    //lineView.image = [UIImage themedImageNamed:@"city_alternation.png"];
    lineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
}

- (void)updateFrames
{
    [titleLabel sizeToFit];
    [iconView sizeToFit];
    
    citySelectButton.frame = CGRectMake(0, 0, self.width, ArticleCitySelectViewHeight);
    
    CGFloat leftMargin = (self.width - (titleLabel.width + 6.f + iconView.width))/2;
    
    titleLabel.origin = CGPointMake(leftMargin, (ArticleCitySelectViewHeight - titleLabel.height)/2);
    iconView.origin = CGPointMake(titleLabel.right + 6, (ArticleCitySelectViewHeight - iconView.height)/2);
    lineView.origin = CGPointMake(0, ArticleCitySelectViewHeight - lineView.height);
    
    self.height = ArticleCitySelectViewHeight;
}

static CGFloat s_titleFontSize = 0;
+ (CGFloat)titleFontSize
{
    if (s_titleFontSize == 0) {
        if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            s_titleFontSize = 14.f;
        } else {
            s_titleFontSize = 12.f;
        }
    }
    
    return s_titleFontSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrames];

}
@end
