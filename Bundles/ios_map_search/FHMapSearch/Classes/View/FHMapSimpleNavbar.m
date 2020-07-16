//
//  FHMapSimpleNavbar.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/7/2.
//

#import "FHMapSimpleNavbar.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseType.h>
#import <TTRoute.h>

#define BTN_WIDTH  24
#define BG_LAYER_HEIGHT 100

@interface FHMapSimpleNavbar ()

@property(nonatomic , strong) UIButton *backButton;
@property(nonatomic , strong) UIButton *rightButton;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) CALayer *bgLayer;

@end

@implementation FHMapSimpleNavbar


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        _bgLayer = [CALayer layer];
        _bgLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, BG_LAYER_HEIGHT);
        UIImage *bgImg = SYS_IMG(@"map_search_nav_bg");
        bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
        _bgLayer.contents = (id)[bgImg CGImage];
        
        [self.layer addSublayer:_bgLayer];
        
        UIImage *backImg = SYS_IMG(@"navbar_back_dark");
    
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:backImg forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIImage *searImg = ICON_FONT_IMG(24, @"\U0000e675",[UIColor themeGray1]);
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setImage:searImg forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_backButton];
        [self addSubview:_titleLabel];
        [self addSubview:_rightButton];
        
        [self initContraints];
    }
    return self;
}

-(void)backAction:(id)sender
{
    if (self.backActionBlock) {
        self.backActionBlock(self.type);
    }
}

-(void)rightBtnClick:(id)sender{
     NSMutableDictionary *tracerParams = [NSMutableDictionary new];
     tracerParams[@"enter_type"] = @"click";
     tracerParams[@"element_from"] = @"map_search";
     tracerParams[@"enter_from"] = @"map_search";
     
     NSMutableDictionary *infos = [NSMutableDictionary new];
     infos[@"house_type"] = @(FHHouseTypeSecondHandHouse);
     infos[@"tracer"] = tracerParams;
     infos[@"from_home"] = @(1);
     TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
     [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://house_search"] userInfo:userInfo];
}

-(void)initContraints
{
    SAFE_AREA
    CGFloat top = 0;
    if (safeInsets.top == 0) {
        top = 27;
    }else{
        
        top = safeInsets.top + 7;
    }
    
    CGFloat left = 18;
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.mas_equalTo(top);
        make.size.mas_equalTo(CGSizeMake(BTN_WIDTH, BTN_WIDTH));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self.backButton);
        make.left.mas_equalTo(left+BTN_WIDTH);
        make.right.mas_equalTo(-(left+BTN_WIDTH));
    }];
    
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-18);
        make.top.mas_equalTo(top);
        make.size.mas_equalTo(CGSizeMake(BTN_WIDTH, BTN_WIDTH));
    }];
}

-(void)setType:(FHMapSimpleNavbarType)type
{
    if (_type == type) {
        return;
    }
    
    _type = type;
    
    UIImage *img = nil;
    if(type == FHMapSimpleNavbarTypeClose){
        img = ICON_FONT_IMG(24, @"\U0000e673",[UIColor themeGray1]);
    }else if(type == FHMapSimpleNavbarTypeDrawLine){
        img = ICON_FONT_IMG(24, @"\U0000e673",[UIColor themeGray1]);
        [_rightButton setImage:[UIImage imageNamed:@"draw_line_btn"] forState:UIControlStateNormal];
    }else{
        img = ICON_FONT_IMG(22, @"\U0000e68a",[UIColor themeGray1]);
        UIImage *searImg = ICON_FONT_IMG(24, @"\U0000e675",[UIColor themeGray1]);
        [_rightButton setImage:searImg forState:UIControlStateNormal];
    }

    [self.backButton setImage:img forState:UIControlStateNormal];
}

-(void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

-(NSString *)title
{
    return _titleLabel.text;
}

-(CGFloat)titleBottom
{
    return CGRectGetMaxY(self.titleLabel.frame);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
