//
//  TTAdVideoViewFactory.m
//  Article
//
//  Created by yin on 16/9/7.
//
//

#import "TTAdVideoViewFactory.h"
#import "SSThemed.h"

#define kPaddingHeight 4


@implementation TTVideoDetailBannerPaddingView

- (id)initWithWidth:(CGFloat)width{
    self = [super initWithFrame:CGRectMake(0, 0, width, kPaddingHeight)];
    if (self) {
        [self reloadThemeUI];
    }
    return self;
}

+ (float)viewHeight{
    return kPaddingHeight;
}



- (instancetype)initWithWidth:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow
{
    self = [self initWithWidth:width];
    if (self) {
        [self setSubViewsTopLineShow:topShow bottomLineShow:bottomShow];
    }
    return self;
}

- (void)setSubViewsTopLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow
{
    self.backgroundColorThemeKey = kColorBackground3;
    SSThemedLabel* line1 = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel])];
    line1.backgroundColorThemeKey = kColorLine1;
    [self addSubview:line1];
    line1.hidden = !topShow;
    SSThemedLabel* line2 = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, [[self class] viewHeight] - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
    line2.backgroundColorThemeKey = kColorLine1;
    [self addSubview:line2];
    line2.hidden = !bottomShow;
}

- (void)dealloc
{
    
}

@end

@implementation TTAdVideoViewFactory

+ (UIView*)detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow
{
    return [[TTVideoDetailBannerPaddingView alloc] initWithWidth:width topLineShow:topShow bottomLineShow:bottomShow];
}

@end
