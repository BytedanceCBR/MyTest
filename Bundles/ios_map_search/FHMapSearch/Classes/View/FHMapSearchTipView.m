//
//  FHMapSearchTipView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchTipView.h"
#import "UIColor+TTThemeExtension.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHCommonDefines.h>

#define kHorPadding 20
#define kViewHeight 45

@interface FHMapSearchTipView ()

@property(nonatomic , strong) UILabel *tipLabel;

@end

@implementation FHMapSearchTipView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        UIVisualEffectView *frost = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
//        frost.frame = CGRectMake(0, 0,[[UIScreen mainScreen]bounds].size.width , kViewHeight);
//        [self addSubview:frost];
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontMedium:16];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.textColor = [UIColor whiteColor];
        [self addSubview:_tipLabel];
        
//        UIImage *img = SYS_IMG(@"mapsearch_round_white_bg");
//        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40)];
//        self.layer.contents = (id)[img CGImage];
        self.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.8];
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
//        self.layer.borderColor = [UIColor themeOrange1].CGColor;
//        self.layer.borderWidth = 0.6;

//        self.backgroundColor = [UIColor themeRed2];
//
//        self.layer.cornerRadius = 20;
//        self.layer.borderColor = [[UIColor themeRed3]CGColor];
//        self.layer.borderWidth = 0.5;
//        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)removeTip
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.top -= self.height/2;
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

-(void)showIn:(UIView *)view at:(CGPoint)topCenter content:(NSString *)content duration:(NSTimeInterval)duration above:(UIView *)aboveView
{
    if (view == self) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeTip) object:nil];
    
    CGFloat width = SCREEN_WIDTH - 2*HOR_MARGIN;
    _tipLabel.text = content;
    [_tipLabel sizeToFit];
    if (_tipLabel.width > width - 2*kHorPadding) {
        _tipLabel.width = self.width - 2*kHorPadding;
    }else{
        width = _tipLabel.width + 2*kHorPadding;
    }
    
    self.frame = CGRectMake(topCenter.x - width/2, topCenter.y, width, kViewHeight);
    _tipLabel.center = CGPointMake(self.width/2, kViewHeight/2);
    
    if (aboveView) {
        [view insertSubview:self aboveSubview:aboveView];
    }else{
        [view addSubview:self];
    }
    
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 1);
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
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
