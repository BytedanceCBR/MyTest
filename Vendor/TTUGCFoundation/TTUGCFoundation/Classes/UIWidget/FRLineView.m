//
//  FRLineView.m
//  Forum
//
//  Created by zhu chao on 15/4/12.
//
//

#import "FRLineView.h"
#import "UIColor+TTThemeExtension.h"

@implementation FRLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.borderType = FRBorderTypeBottom;
}

- (void)setTtColorKey:(NSString *)ttColorKey
{
    [self setBorderColor:[UIColor tt_themedColorForKey:ttColorKey]];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}



@end
