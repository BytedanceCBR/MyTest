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
        
        _contentView = [[UIControl alloc] initWithFrame:self.bounds];//CGRectMake(0, 0, 1, 1)
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:_contentView];
        
        CALayer *layer = self.layer;
        
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowRadius = 4;
        layer.shadowColor = [UIColor colorWithRed:110.f/255.f green:110.f/255.f blue:110.f/255.f alpha:0.1].CGColor;
        layer.shadowOpacity = 0.2;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    _contentView.layer.cornerRadius = cornerRadius;
}

-(void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    self.layer.shadowColor = [shadowColor CGColor];
}

-(void)setShadowOffset:(CGSize)shadowOffset
{
    self.layer.shadowOffset = shadowOffset;
}

-(CGSize)shadowOffset
{
    return self.layer.shadowOffset;
}

-(void)setShadowOpacity:(CGFloat)shadowOpacity
{
    self.layer.shadowOpacity = shadowOpacity;
}

-(CGFloat)shadowOpacity
{
    return self.layer.shadowOpacity;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
