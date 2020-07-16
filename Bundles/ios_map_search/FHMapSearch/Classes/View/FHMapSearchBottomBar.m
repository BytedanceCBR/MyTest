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
#import <TTBaseLib/UIViewAdditions.h>

@interface FHMapSearchBottomBar ()

//@property(nonatomic , strong) UIButton *closeButton;
@property(nonatomic , strong) UIView *drawLineBgView;
@property(nonatomic , strong) UILabel *drawLineLabel;
@property(nonatomic , strong) UIView *verticalLine;
@property(nonatomic , strong) UILabel *drawTitleLineLabel;
@property(nonatomic , strong) UIImageView *drawLineIndicator;
@property(nonatomic , strong) UIImageView *topIconImage;

//@property(nonatomic , strong) UIControl *subwayBgView;
//@property(nonatomic , strong) UIImageView *subwayIconView;
//@property(nonatomic , strong) UILabel *subwayLabel;

@end

@implementation FHMapSearchBottomBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_closeButton setBackgroundImage:SYS_IMG(@"mapsearch_close") forState:UIControlStateNormal];
//        [_closeButton addTarget:self action:@selector(onCloseAction) forControlEvents:UIControlEventTouchUpInside];
//
//        [self addSubview:_closeButton];
        
        [self initDrawLines];
//        [self initSubways];
        
        [self initConstraints];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)initDrawLines
{
//    UIImage *img = SYS_IMG(@"mapsearch_round_white_bg");
//    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
//    UIImage *searchTopIcon = SYS_IMG(@"map_search_top_icon");
    
    _drawLineBgView = [[UIView alloc] init];
//    _drawLineBgView.layer.contents = (id)[img CGImage];
//    [_drawLineBgView addTarget:self action:@selector(onDrawLineInfo) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onDrawLineInfo)];
    [_drawLineBgView addGestureRecognizer:tapGest];
    _drawLineBgView.layer.masksToBounds = YES;
    _drawLineBgView.layer.cornerRadius = 26;
    _drawLineBgView.layer.borderWidth = 0.6;
    _drawLineBgView.layer.borderColor = [UIColor themeOrange1].CGColor;
    [_drawLineBgView setBackgroundColor:[UIColor whiteColor]];

    _drawLineLabel = [[UILabel alloc]init];
    _drawLineLabel.font = [UIFont themeFontRegular:14];
    _drawLineLabel.textColor = [UIColor themeGray1];
    
    _verticalLine = [UIView new];
    [_verticalLine setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    
    _drawTitleLineLabel = [[UILabel alloc] init];
    _drawTitleLineLabel.font = [UIFont themeFontRegular:14];
    _drawTitleLineLabel.textColor = [UIColor themeGray1];
//    [_drawTitleLineLabel setBackgroundColor:[UIColor redColor]];
    
    _drawLineIndicator = [[UIImageView alloc] initWithImage:SYS_IMG(@"mapsearch_indicator")];
    _topIconImage = [[UIImageView alloc] initWithImage:SYS_IMG(@"map_search_top_icon")];
    [_drawLineBgView addSubview:_topIconImage];
    [_drawLineBgView addSubview:_verticalLine];
    [_drawLineBgView addSubview:_drawTitleLineLabel];
    [_drawLineBgView addSubview:_drawLineLabel];
    [_drawLineBgView addSubview:_drawLineIndicator];
    
    
    [self addSubview:_drawLineBgView];
    
    _drawLineBgView.hidden = YES;
}

//-(void)initSubways
//{
//    UIImage *img = SYS_IMG(@"mapsearch_round_white_bg");
//    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
//
//    _subwayBgView = [[UIControl alloc] init];
//    _subwayBgView.layer.contents = (id)[img CGImage];
//    [_subwayBgView addTarget:self action:@selector(onSubwayInfo) forControlEvents:UIControlEventTouchUpInside];
//
//    _subwayLabel = [[UILabel alloc]init];
//    _subwayLabel.font = [UIFont themeFontRegular:14];
//    _subwayLabel.textColor = [UIColor themeGray1];
//
//    img = SYS_IMG(@"mapsearch_subway");
//    _subwayIconView = [[UIImageView alloc] initWithImage:img];
//
//    [_subwayBgView addSubview:_subwayIconView];
//    [_subwayBgView addSubview:_subwayLabel];
//
//    [self addSubview:_subwayBgView];
//
//    _subwayBgView.hidden = YES;
//}

-(void)initConstraints
{
//    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(HOR_MARGIN - 6);
//        make.size.mas_equalTo(CGSizeMake(58, 58));
//        make.top.mas_equalTo(0);
//    }];
    
//    BOOL smallScreen = ( SCREEN_WIDTH < 321);
//    CGFloat centerXOffset = smallScreen?20:0;
    
    [_drawLineBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(0);
        make.width.mas_equalTo(180);
        make.bottom.mas_equalTo(self).offset(0);
    }];
    
    [_topIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(self.drawLineBgView).offset(15);
      make.centerY.mas_equalTo(self.drawLineBgView);
      make.width.mas_equalTo(21);
      make.height.mas_equalTo(21);
    }];
    
    [_verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.drawLineBgView).offset(8);
        make.left.mas_equalTo(41);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(36);
    }];
    
    [_drawTitleLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.drawLineBgView).offset(0);
       make.left.mas_equalTo(50);
//       make.width.mas_equalTo(160);
       make.height.mas_equalTo(26);
//       make.left.mas_equalTo(43);
    }];
    
    
    [_drawLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.drawTitleLineLabel.mas_bottom).offset(0);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(26);
        make.left.mas_equalTo(50);
    }];

    
    [_drawLineIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.drawLineBgView).offset(-15);
        make.centerY.mas_equalTo(self.drawLineBgView);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    

//    //TODO: add subway
//    [_subwayBgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(88);
//        //        make.width.mas_equalTo(200);
//        make.top.mas_equalTo(self).offset(0);
//        make.bottom.mas_equalTo(self).offset(0);
//        make.right.mas_equalTo(self.subwayLabel.mas_right).offset(34);
//    }];
//
//    [_subwayIconView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(26);
//        make.centerY.mas_equalTo(self.drawLineBgView).offset(-2);
//        make.size.mas_equalTo(CGSizeMake(24, 24));
//    }];
//
//    [_subwayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(self.subwayIconView);
//        make.left.mas_equalTo(self.subwayIconView.mas_right).offset(8);
//    }];
    
}

-(void)hideContentBgView
{
    _drawLineBgView.hidden = YES;
}

-(void)showDrawLine:(NSString *)content withNum:(NSInteger)num showIndicator:(BOOL)showIndicator
{
      NSMutableAttributedString * contentAttr = [[NSMutableAttributedString alloc] initWithString:content attributes:@{
            NSForegroundColorAttributeName:[UIColor themeGray1],
            NSFontAttributeName:[UIFont themeFontRegular:14]
      }];
      NSRange numRange = [content rangeOfString:[NSString stringWithFormat:@"%ld",num]];
      [contentAttr addAttributes:@{
          NSForegroundColorAttributeName:[UIColor themeRed4],
          NSFontAttributeName:[UIFont themeFontSemibold:14]
      } range:numRange];
      
    _drawLineLabel.attributedText = contentAttr;
     _drawTitleLineLabel.text = @"区域内共找到:";
//    content = @"区域内共找到20000000123452000000012345套房源";
//    _drawLineLabel.text = content;
//    _subwayBgView.hidden = YES;
    
    
    
//    [_drawLineLabel sizeToFit];
//    CGFloat padding = 46 ; //左右间距 箭头
//    if (showIndicator) {
//        padding += 24;
//    }

    self.drawLineIndicator.hidden = !showIndicator;
//    CGFloat width = MIN(_drawLineLabel.width, (SCREEN_WIDTH - padding));
//    CGFloat left = (SCREEN_WIDTH - width - padding)/2;

//    [_drawLineLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(90);
//        make.height.mas_equalTo(52);
//    }];
//    [_drawLineBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(left);
//    }];
    
    if (showIndicator) {
        [_drawLineBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(180);
        }];
    }else{
        [_drawLineBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(160);
        }];
    }
//
    _drawLineBgView.hidden = NO;
    
}

//-(void)showSubway:(NSString *)line
//{
//    _drawLineBgView.hidden = YES;
//    _subwayBgView.hidden = NO;
//
//    _subwayLabel.text = line;
//    [_subwayLabel sizeToFit];
//    CGFloat padding = 78 ; //左右间距 箭头
//
//    CGFloat width = MIN(ceil(_subwayLabel.width), (SCREEN_WIDTH - 98 - padding));
//    CGFloat left = (SCREEN_WIDTH - width - padding)/2;
//    if (left < 78) {
//        left = 78;
//    }
//    [_subwayLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(width);
//    }];
//    [_subwayBgView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(left);
//    }];
//
//}


//-(void)onCloseAction
//{
//    [self.delegate closeBottomBar];
//}

-(void)onDrawLineInfo
{
    [self.delegate showNeighborList:self.drawLineLabel.text];
}

//-(void)onSubwayInfo
//{
//    [self.delegate showSubwayInBottombar:self];
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
