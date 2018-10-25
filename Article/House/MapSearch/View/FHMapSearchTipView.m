//
//  FHMapSearchTipView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchTipView.h"
#import <UIColor+TTThemeExtension.h>

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
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor colorWithHexString:@"0x081f33"];
        [self addSubview:_tipLabel];
        
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        
    }
    return self;
}

-(void)removeTip
{
    [self removeFromSuperview];
}

-(void)showIn:(UIView *)view at:(CGPoint)topLeft content:(NSString *)content duration:(NSTimeInterval)duration
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
    
    [view addSubview:self];
    [self performSelector:@selector(removeTip) withObject:nil afterDelay:duration];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self removeFromSuperview];
//    });
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
