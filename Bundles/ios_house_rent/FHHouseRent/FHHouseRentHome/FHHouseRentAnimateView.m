//
//  FHHouseRentAnimateView.m
//  FHHouseRent
//
//  Created by 春晖 on 2018/12/9.
//

#import "FHHouseRentAnimateView.h"
#import "UIViewAdditions.h"



@interface FHHouseRentAnimateView ()

@property(nonatomic , strong) UIImageView *imageView;

@end


@implementation FHHouseRentAnimateView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_imageView];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)animateWithImage:(UIImage *)image top:(CGFloat)top duration:(CGFloat)duration delay:(NSTimeInterval)delay
{    
    self.imageView.image = image;
    self.imageView.top  = top;
    self.hidden = NO;
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageView.top = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
