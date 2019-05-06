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

@end

@implementation FHMapSearchWayChooseView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _subwayButton = [self buttonWithTitle:@"地铁找房" icon:nil];
        _drawLineButton = [self buttonWithTitle:@"画圈找房" icon:SYS_IMG( @"mapsearch_draw_line")];
        
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
        _contentView.backgroundColor = [UIColor whiteColor];
        [_contentView addSubview:_drawLineButton];
        
        self.layer.shadowRadius = 6;
        self.layer.shadowColor = [[UIColor colorWithWhite:0 alpha:0.4] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 1;
        
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
    
    [button setBackgroundColor:[UIColor whiteColor]];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    
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
    _contentView.frame = self.bounds;
    _drawLineButton.frame = self.contentView.bounds;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
