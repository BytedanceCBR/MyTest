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

#define BTN_WIDTH  24
#define BG_LAYER_HEIGHT 100

@interface FHMapSimpleNavbar ()

@property(nonatomic , strong) UIButton *backButton;
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
        
        
        UIImage *backImg = SYS_IMG(@"navbar_back_dark");
    
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:backImg forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_backButton];
        [self addSubview:_titleLabel];
        
        [self initContraints];
    }
    return self;
}

-(void)backAction:(id)sender
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
}

-(void)initContraints
{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.8 , *)) {
        safeInsets = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets];
    }
    
}

-(void)setType:(FHMapSimpleNavbarType)type
{
    if (_type == type) {
        return;
    }
    
    _type = type;

    UIImage *img = (type == FHMapSimpleNavbarTypeBack)?SYS_IMG(@"navbar_back_dark"):SYS_IMG(@"icon_close");
    [self.backButton setImage:img forState:UIControlStateNormal];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
