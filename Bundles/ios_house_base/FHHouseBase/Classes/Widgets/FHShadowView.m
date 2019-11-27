//
// Created by fengbo on 2019-10-28.
//

#import "FHShadowView.h"
#import <FHCommonUI/UIColor+Theme.h>

@interface FHShadowView ()

@property(nonatomic , strong) UIView *contentView;

@end

@implementation FHShadowView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _contentView = [[UIView alloc] initWithFrame:self.bounds];//CGRectMake(0, 0, 1, 1)
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [self addSubview:_contentView];

        CALayer *layer = self.layer;
        layer.shadowColor = [[UIColor colorWithHexString:@"#e8e8e8"] CGColor];
        layer.shadowOffset = CGSizeMake(0, 1);
        layer.shadowRadius = 4;
        layer.shadowOpacity = 1;

        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
