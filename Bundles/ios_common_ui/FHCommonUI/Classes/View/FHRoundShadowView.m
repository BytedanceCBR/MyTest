//
//  FHRoundShadowView.m
//  FHCommonUI
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHRoundShadowView.h"

@interface FHRoundShadowView ()

@property(nonatomic , strong) UIView *contentView;

@end

@implementation FHRoundShadowView

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
        
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowRadius = 4;
        layer.shadowOpacity = 1;
        
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
