//
//  FHMapSearchBottomBar.m
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import "FHMapSearchBottomBar.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHHouseBase/FHCommonDefines.h>

@interface FHMapSearchBottomBar ()

@property(nonatomic , strong) UIButton *closeButton;
@property(nonatomic , strong) UIControl *drawLineBgView;
@property(nonatomic , strong) UILabel *drawLineLabel;
@property(nonatomic , strong) UIImageView *drawLineIndicator;

@property(nonatomic , strong) UIControl *subwayBgView;
@property(nonatomic , strong) UIImageView *subwayIconView;
@property(nonatomic , strong) UILabel *subwayLabel;

@end

@implementation FHMapSearchBottomBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundImage:SYS_IMG(@"mapsearch_close_bg") forState:UIControlStateNormal];
        [_closeButton setImage:SYS_IMG(@"mapsearch_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(onCloseAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_closeButton];
        
        [self initDrawLines];
        [self initSubways];
        
        [self initConstraints];
    }
    return self;
}

-(void)initDrawLines
{
    
    _drawLineBgView = [[UIControl alloc] init];
    [_drawLineBgView addTarget:self action:@selector(onDrawLineInfo) forControlEvents:UIControlEventTouchUpInside];
    
    _drawLineLabel = [[UILabel alloc]init];
    _drawLineLabel.font = [UIFont themeFontRegular:14];
    _drawLineLabel.textColor = [UIColor themeGray1];
    
    _drawLineIndicator = [[UIImageView alloc] initWithImage:SYS_IMG(@"mapsearch_indicator")];
    
    [_drawLineBgView addSubview:_drawLineLabel];
    [_drawLineBgView addSubview:_drawLineIndicator];
    
}

-(void)initSubways
{
    
}

-(void)initConstraints
{
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.size.mas_equalTo(CGSizeMake(46, 46));
        make.top.mas_equalTo(0);
    }];
    
    BOOL smallScreen = ( SCREEN_WIDTH < 321);
    CGFloat centerXOffset = smallScreen?20:0;
    
    [_drawLineBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).offset(centerXOffset);
        make.width.mas_equalTo(200);
        make.top.bottom.mas_equalTo(self);
    }];
    
    
    [_drawLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.drawLineBgView);
        make.left.mas_equalTo(20);
    }];
    
    [_drawLineIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.drawLineLabel.mas_right).offset(6);
        make.centerY.mas_equalTo(self.drawLineLabel);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    //TODO: add subway
    
    
    
    
}

-(void)showDrawLine:(NSString *)content
{
    
}

-(void)showSubway:(NSString *)line
{
    
}


-(void)onCloseAction
{

    [self.delegate closeBottomBar];
}

-(void)onDrawLineInfo
{
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
