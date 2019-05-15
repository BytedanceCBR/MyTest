//
//  ExploreDetailNatantRelateEnterView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "ExploreDetailNatantRelateEnterView.h"
#import "SSAppPageManager.h"
#import "SSThemed.h"
#import "TTStringHelper.h"
#define kHeight 44

@interface ExploreDetailNatantRelateEnterView()
@property(nonatomic, retain)UIButton * button;
@property(nonatomic, retain)NSString * urlStr;
@end

@implementation ExploreDetailNatantRelateEnterView

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        CGRect frame = self.frame;
        frame.size.height = kHeight;
        self.frame = frame;
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = self.bounds;
        _button.backgroundColor = [UIColor clearColor];
        _button.titleLabel.font = [UIFont systemFontOfSize:16];
        [_button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_button];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [_button setTitleColor:[UIColor colorWithDayColorName:@"464646" nightColorName:@"707070"] forState:UIControlStateNormal];
}

- (void)refreshWithWidth:(CGFloat)width
{
    [super refreshWithWidth:width];
}


- (void)refreshWithJson:(NSDictionary *)jsonDict
{
    self.urlStr = [jsonDict objectForKey:@"url"];
    [self refreshButtonTitleWithJson:jsonDict];
}

- (void)refreshButtonTitleWithJson:(NSDictionary *)jsonDict
{
    NSString *title = [jsonDict objectForKey:@"text"];
    NSString *highlightedTitle = [jsonDict objectForKey:@"highlighted"];
    NSMutableAttributedString *aTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [aTitle addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText4) range:[title rangeOfString:highlightedTitle]];
    [_button setAttributedTitle:aTitle forState:UIControlStateNormal];
}

- (void)buttonClick
{
    if (!isEmptyString(_urlStr)) {
        [[SSAppPageManager sharedManager] openURL:[TTStringHelper URLWithURLString:_urlStr]];
    }
}

@end
