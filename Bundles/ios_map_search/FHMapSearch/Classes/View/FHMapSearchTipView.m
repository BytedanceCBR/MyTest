//
//  FHMapSearchTipView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchTipView.h"
#import <UIColor+TTThemeExtension.h>
#import "UIColor+Theme.h"
#import <UIViewAdditions.h>

#define kHorPadding 10
#define kViewHeight 40

@interface FHMapSearchTipView ()

@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHMapSearchTipView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIVisualEffectView *frost = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        frost.frame = CGRectMake(0, 0,[[UIScreen mainScreen]bounds].size.width , kViewHeight);
        [self addSubview:frost];
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = RGBA(0x08, 0x1f, 0x33, 1);
        [self addSubview:_tipLabel];
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)removeTip
{
    [self removeFromSuperview];
}

-(void)showIn:(UIView *)view at:(CGPoint)topLeft content:(NSString *)content duration:(NSTimeInterval)duration above:(UIView *)aboveView
{
    if (view == self) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeTip) object:nil];
    self.frame = CGRectMake(topLeft.x, topLeft.y, view.width, kViewHeight);
    _tipLabel.text = content;
    [_tipLabel sizeToFit];
    if (_tipLabel.width > self.width - 2*kHorPadding) {
        _tipLabel.width = self.width - 2*kHorPadding;
    }
    _tipLabel.center = CGPointMake(self.width/2, kViewHeight/2);
    
    if (aboveView) {
        [view insertSubview:self aboveSubview:aboveView];
    }else{
        [view addSubview:self];
    }
    
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 1);
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
    [self performSelector:@selector(removeTip) withObject:nil afterDelay:duration];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
