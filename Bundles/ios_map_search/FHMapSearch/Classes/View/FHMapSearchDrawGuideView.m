//
//  FHMapSearchDrawGuideView.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import "FHMapSearchDrawGuideView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHHouseBase/FHCommonDefines.h>
@import QuartzCore;

#define PATH_WIDTH 127
#define HAND_WIDTH 27

@interface FHMapSearchDrawGuideView ()

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) CALayer *pathLayer;
@property(nonatomic , strong) CALayer *handLayer;
@property(nonatomic , copy)   void (^dismissBlock)();

@end

@implementation FHMapSearchDrawGuideView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont themeFontRegular:14];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.text = @"用手指圈出想要的找房范围";
        [_tipLabel sizeToFit];
        
        [self addSubview:_tipLabel];
        
        _pathLayer = [CALayer layer];
        _pathLayer.contents = (__bridge id)[SYS_IMG(@"mapsearch_draw_path_orange") CGImage];
        
        _handLayer = [CALayer layer];
        _handLayer.contents = (__bridge id)[SYS_IMG(@"mapsearch_draw_hand") CGImage];
        
        [self.layer addSublayer:_pathLayer];
        [self.layer addSublayer:_handLayer];
        
        self.backgroundColor = RGBA(0, 0, 0, 0.4);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}

-(void)onTap
{
    [self removeFromSuperview];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _pathLayer.frame = CGRectMake((CGRectGetWidth(self.bounds) - PATH_WIDTH)/2, 107, PATH_WIDTH, PATH_WIDTH);
    _handLayer.frame = CGRectMake(CGRectGetMaxX(_pathLayer.frame)-HAND_WIDTH, CGRectGetMaxY(_pathLayer.frame) - HAND_WIDTH, HAND_WIDTH, HAND_WIDTH);
    
    _tipLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxX(_pathLayer.frame)+30+CGRectGetHeight(_tipLabel.frame)/2);
}

+(void)showInView:(UIView *)view dismiss:(void(^)())dismissBlock
{
    FHMapSearchDrawGuideView *gview = [[FHMapSearchDrawGuideView alloc] initWithFrame:view.bounds];
    gview.dismissBlock = dismissBlock;
    [view addSubview:gview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
