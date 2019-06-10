//
//  ExploreDetailNatantHeaderPaddingView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "ExploreDetailNatantHeaderPaddingView.h"
#import "UIColor+TTThemeExtension.h"

#define kPaddingHeight 15

@interface ExploreDetailNatantHeaderPaddingView()
@property(nonatomic, retain)UIView * topLineView;
@property(nonatomic, retain)UIView * bottomLineView;


@end

@implementation ExploreDetailNatantHeaderPaddingView

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, kPaddingHeight)];
    if (self) {
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
}

+ (float)viewHeight
{
    return kPaddingHeight;
}

@end
