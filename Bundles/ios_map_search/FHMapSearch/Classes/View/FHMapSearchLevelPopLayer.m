//
//  FHMapSearchLevelPopLayer.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import "FHMapSearchLevelPopLayer.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>

#define BG_WIDTH 188
#define BG_HEIGHT 36
#define ARROW_WIDTH 12
#define ARROW_HEIGHT 6

__weak FHMapSearchLevelPopLayer *_popLayer = NULL;

@interface FHMapSearchLevelPopLayer()

@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) UIButton *closeButton;
@property(nonatomic , strong) CALayer *bgLayer;
@property(nonatomic , strong) CALayer *arrowLayer;

@end

@implementation FHMapSearchLevelPopLayer

+(void)showInView:(UIView *)view atPoint:(CGPoint)point
{
    if (_popLayer) {
        return;
    }
    
    CGRect frame = CGRectMake(point.x - BG_WIDTH/2, point.y - (BG_HEIGHT + ARROW_HEIGHT), BG_WIDTH, BG_HEIGHT + ARROW_HEIGHT);
    FHMapSearchLevelPopLayer *poplayer = [[FHMapSearchLevelPopLayer alloc] initWithFrame:frame];
    [view addSubview:poplayer];
    _popLayer = poplayer;
    
    __weak typeof(poplayer) weakPop = poplayer;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakPop) {
            [weakPop removeFromSuperview];
        }
    });
    
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _tipLabel = [[UILabel alloc]init ];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont themeFontRegular:12];
        _tipLabel.text = @"请放大地图后使用画圈找房";
        [_tipLabel sizeToFit];
        
        _bgLayer = [CALayer layer];
        _bgLayer.contents = (id)[SYS_IMG(@"mapsearch_pop_bg") CGImage];
        _arrowLayer = [CALayer layer];
        _arrowLayer.contents = (id)[SYS_IMG(@"mapsearch_pop_arrow") CGImage];
        
        [self.layer addSublayer:_bgLayer];
        [self.layer addSublayer:_arrowLayer];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setImage:SYS_IMG(@"mapsearch_close_white") forState:UIControlStateNormal];
        [self addSubview:_tipLabel];
        [self addSubview:_closeButton];
        
        
    }
    return self;
}


-(void)closeAction
{
    [self removeFromSuperview];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    _bgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, BG_HEIGHT);
    _arrowLayer.frame = CGRectMake(CGRectGetMidX(self.bounds)-ARROW_WIDTH/2, BG_HEIGHT, ARROW_WIDTH, ARROW_HEIGHT);
    
    _tipLabel.frame = CGRectMake(10, 9, _tipLabel.bounds.size.width, _tipLabel.bounds.size.height);
    _closeButton.frame = CGRectMake(CGRectGetMaxX(_tipLabel.frame), 0, CGRectGetWidth(self.bounds) - CGRectGetMaxX(_tipLabel.frame), BG_HEIGHT);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
