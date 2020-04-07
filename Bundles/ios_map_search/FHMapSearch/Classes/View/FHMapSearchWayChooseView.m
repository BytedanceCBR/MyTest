//
//  FHMapSearchWayChooseView.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import "FHMapSearchWayChooseView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHCommonDefines.h>

@interface FHMapSearchWayChooseView ()

@property(nonatomic , strong) UIButton *subwayButton;
@property(nonatomic , strong) UIButton *drawLineButton;
@property(nonatomic , strong) UIView *contentView;
@property(nonatomic , strong) CALayer *splitLine;

@end

@implementation FHMapSearchWayChooseView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _subwayButton = [self buttonWithTitle:@"地铁找房" icon:SYS_IMG(@"mapsearch_subway_orange")];
        _drawLineButton = [self buttonWithTitle:@"画圈找房" icon:SYS_IMG( @"mapsearch_draw_path_orange")];
        
        UIImage *img = SYS_IMG(@"mapsearch_round_white_bg");
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.layer.contents = (id)[img CGImage];
        
        [_contentView addSubview:_subwayButton];
        [_contentView addSubview:_drawLineButton];
        
        _splitLine = [CALayer layer];
        _splitLine.backgroundColor =  [RGB(0xf2, 0xf4, 0xf5) CGColor];
        [_contentView.layer addSublayer:_splitLine];
        
        [self addSubview:_contentView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
    
}

-(UIButton *)buttonWithTitle:(NSString *)title icon:(UIImage * )icon
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont themeFontRegular:14];
    
    [button setImage:icon forState:UIControlStateNormal];
    [button setImage:icon forState:UIControlStateHighlighted];
    
    [button setBackgroundColor:[UIColor clearColor]];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(-4, -11, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(-2, 8, 0, 0);
    
    return button;
}


-(void)onAction:(id)sender
{
    if (sender == _drawLineButton) {
        
        [self.delegate chooseDrawLine];
        
    }else if (sender == _subwayButton){
        
        [self.delegate chooseSubWay];
    }
}

-(void)setType:(FHMapSearchWayChooseViewType)type
{
//    if (_type == type) {
//        return;
//    }
    _type = type;
    switch (type) {
        case FHMapSearchWayChooseViewTypeBoth:
        {
            _subwayButton.hidden = NO;
            _drawLineButton.hidden = NO;
            _splitLine.hidden = NO;
        }
            break;
        case FHMapSearchWayChooseViewTypeDraw:
        {
            _subwayButton.hidden = YES;
            _splitLine.hidden = YES;
            
        }
            break;
        case FHMapSearchWayChooseViewTypeSubway:
        {
            _drawLineButton.hidden = YES;
            _splitLine.hidden = YES;
        }
            break;
        default:
            
            break;
    }
    [self setNeedsLayout];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    _contentView.frame = self.bounds;
    CGRect frame = self.bounds;
    
    if (_subwayButton.hidden || _drawLineButton.hidden) {
        
        _subwayButton.frame = frame;
        _drawLineButton.frame = frame;
        
    }else{
        frame.size.width /= 2;
        _subwayButton.frame = frame;
        frame.origin.x = frame.size.width;
        _drawLineButton.frame = frame;
    }
    _splitLine.frame = CGRectMake(CGRectGetMidX(self.bounds), 18, 1, 18);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
