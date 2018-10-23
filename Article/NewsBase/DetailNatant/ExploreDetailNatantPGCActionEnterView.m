//
//  ExploreDetailNatantPGCActionEnterView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-24.
//
//

#import "ExploreDetailNatantPGCActionEnterView.h"
#import "UIColor+TTThemeExtension.h"

#define kHeight 44

@interface ExploreDetailNatantPGCActionEnterView()

@property(nonatomic, retain, readwrite)UIButton * button;

@end

@implementation ExploreDetailNatantPGCActionEnterView


- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.frame = CGRectMake(0, 0, width, 44);
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = [UIFont systemFontOfSize:16];
        _button.frame = self.bounds;
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_button];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [_button setTitleColor:[UIColor colorWithDayColorName:@"3c6598" nightColorName:@"67778b"] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithDayColorName:@"233f66" nightColorName:@"4d5866"] forState:UIControlStateHighlighted];
    [_button setTitleColor:[UIColor colorWithDayColorName:@"233f66" nightColorName:@"4d5866"] forState:UIControlStateSelected];
}

- (void)refreshTitle:(NSString *)title
{
    [_button setTitle:title forState:UIControlStateNormal];
}




@end
