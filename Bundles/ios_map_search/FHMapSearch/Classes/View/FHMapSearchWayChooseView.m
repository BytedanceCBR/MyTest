//
//  FHMapSearchWayChooseView.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import "FHMapSearchWayChooseView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>

@interface FHMapSearchWayChooseView ()

@property(nonatomic , strong) UIButton *subwayButton;
@property(nonatomic , strong) UIButton *drawLineButton;

@end

@implementation FHMapSearchWayChooseView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _subwayButton = [self buttonWithTitle:@"地铁找房" icon:nil];
        _drawLineButton = [self buttonWithTitle:@"画圈找房" icon:nil];
        
        [self addSubview:_drawLineButton];
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
    
    [button setBackgroundColor:[UIColor whiteColor]];
    
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

-(void)layoutSubviews
{
    [super layoutSubviews];
    _drawLineButton.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
