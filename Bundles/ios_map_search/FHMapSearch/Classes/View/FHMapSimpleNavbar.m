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
#import <FHUserTracker.h>
#import <UIDevice+BTDAdditions.h>
#import "FHEnvContext.h"
#import "HMSegmentedControl.h"

#define BTN_WIDTH  24
#define BG_LAYER_HEIGHT 100

@interface FHMapSimpleNavbar ()

@property(nonatomic , strong) UIButton *backButton;
@property(nonatomic , strong) UIButton *rightButton;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *rightTitleLabel;
@property(nonatomic , strong) CALayer *bgLayer;
@property(nonatomic , strong) HMSegmentedControl *houseSegmentControl;

@property(nonatomic , assign) BOOL isShowCircle;

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
        
        _rightTitleLabel = [[UILabel alloc] init];
        _rightTitleLabel.font = [UIFont themeFontRegular:12];
        _rightTitleLabel.text = @"重画";
        _rightTitleLabel.textColor = [UIColor themeGray1];
        _rightTitleLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapReDraw = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightBtnClick:)];
        [_rightTitleLabel addGestureRecognizer:tapReDraw];
        
        
        [self addSubview:_backButton];
        [self addSubview:_titleLabel];
        [self addSubview:_rightButton];
        [self addSubview:_rightTitleLabel];

        [self initContraints];
        
        [self setUpHouseSegmentedControl];
        
    }
    return self;
}

- (NSString *)matchHouseString:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
        {
            return @"新房";
        }
            break;
        case FHHouseTypeRentHouse:
        {
            return @"租房";
        }
            break;
        case FHHouseTypeNeighborhood:
        {
            return @"小区";
        }
            break;
        case FHHouseTypeSecondHandHouse:
        {
            return @"二手房";
        }
            break;
            
        default:
            return @"";
            break;
    }
}

//匹配房源名称
- (NSArray <NSString *>*)matchHouseSegmentedTitleArray
{
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSMutableArray *titleArrays = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < configDataModel.houseTypeList.count; i++) {
        NSNumber *houseTypeNum = configDataModel.houseTypeList[i];
        if ([houseTypeNum isKindOfClass:[NSNumber class]] && ([houseTypeNum integerValue] == 2 || [houseTypeNum integerValue] == 1)) {
            NSString * houseStr = [self matchHouseString:[houseTypeNum integerValue]];
            if (kIsNSString(houseStr) && houseStr.length != 0) {
                [titleArrays addObject:houseStr];
            }
        }
    }
    return titleArrays;
}

- (void)setUpHouseSegmentedControl
{
    NSArray *titlesArray = [self matchHouseSegmentedTitleArray];
    if (!titlesArray && [titlesArray count] == 0) {
        return;
    }
    
    if (titlesArray.count >= 2) {
        _titleLabel.hidden = YES;
    }

    _houseSegmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:titlesArray];
    
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray1]};
    _houseSegmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontSemibold:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _houseSegmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _houseSegmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _houseSegmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _houseSegmentControl.isNeedNetworkCheck = NO;
    _houseSegmentControl.segmentEdgeInset = UIEdgeInsetsMake(8, 10, 0, 10);
    _houseSegmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _houseSegmentControl.selectionIndicatorWidth = 20.0f;
    _houseSegmentControl.selectionIndicatorHeight = 4.0f;
    _houseSegmentControl.selectionIndicatorCornerRadius = 2.0f;
    _houseSegmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _houseSegmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    [_houseSegmentControl setBackgroundColor:[UIColor clearColor]];

    //    _segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];
    
    __weak typeof(self) weakSelf = self;
    _houseSegmentControl.indexChangeBlock = ^(NSInteger index) {
        if (weakSelf.indexHouseChangeBlock) {
            weakSelf.indexHouseChangeBlock(index);
        }
    };
    
    _houseSegmentControl.indexRepeatBlock = ^(NSInteger index) {
    };
    
    [self addSubview:_houseSegmentControl];
    
    [_houseSegmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-10);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(50);
    }];
    
    [self updateSegementedTitles:titlesArray andSelectIndex:0];
}

- (void)updateShowBtn:(BOOL)isShow{
    self.houseSegmentControl.hidden = !isShow;
}

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles andSelectIndex:(NSInteger)index
{
    _houseSegmentControl.sectionTitles = titles;
    if (titles.count > index) {
        _houseSegmentControl.selectedSegmentIndex = index;
    }else
    {
        _houseSegmentControl.selectedSegmentIndex = _houseSegmentControl.selectedSegmentIndex;
    }
}

-(void)backAction:(id)sender
{
    if (self.backActionBlock) {
        self.backActionBlock(self.type);
    }
}

- (void)updateCicleBtn:(BOOL)isShowCircle{
//    _isShowCircle = isShowCircle;
//    UIImage *img = nil;
//    if(_type == FHMapSimpleNavbarTypeClose){
//        img = ICON_FONT_IMG(24, @"\U0000e673",[UIColor themeGray1]);
//        _rightTitleLabel.hidden = YES;
//    }else if(_type == FHMapSimpleNavbarTypeDrawLine && isShowCircle){
//        img = ICON_FONT_IMG(24, @"\U0000e673",[UIColor themeGray1]);
//        [_rightButton setImage:[UIImage imageNamed:@"draw_line_btn"] forState:UIControlStateNormal];
//        [_rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
//           make.right.equalTo(self).offset(-48);
//        }];
//        _rightTitleLabel.hidden = NO;
//    }else{
//        img = ICON_FONT_IMG(22, @"\U0000e68a",[UIColor themeGray1]);
//        UIImage *searImg = ICON_FONT_IMG(24, @"\U0000e675",[UIColor themeGray1]);
//        [_rightButton setImage:searImg forState:UIControlStateNormal];
//        [_rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
//           make.right.equalTo(self).offset(-18);
//        }];
//        _rightTitleLabel.hidden = YES;
//    }

}

-(void)rightBtnClick:(id)sender{
    if(self.type == FHMapSimpleNavbarTypeDrawLine){
     
        if (self.rightActionBlock) {
            self.rightActionBlock(FHMapSimpleNavbarTypeDrawLine);
        }
    }else{
        
        NSMutableDictionary *tracerParamsClick = [NSMutableDictionary new];
        tracerParamsClick[@"page_type"] = @"map_search_detail";
        tracerParamsClick[@"tab_name"] = self.houseType == FHHouseTypeSecondHandHouse ? @"old_tab" : @"new_tab";
        [FHUserTracker writeEvent:@"click_search" params:tracerParamsClick];
        
        
        NSMutableDictionary *tracerParams = [NSMutableDictionary new];
        tracerParams[@"enter_type"] = @"click";
        tracerParams[@"element_from"] = @"map_search";
        tracerParams[@"enter_from"] = @"map_search";
        
        NSMutableDictionary *infos = [NSMutableDictionary new];
        infos[@"house_type"] = @(self.houseType);
        infos[@"tracer"] = tracerParams;
        infos[@"from_home"] = @(1);
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://house_search"] userInfo:userInfo];
    }
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
    
    [_rightTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.right.equalTo(self).offset(-18);
         make.centerY.mas_equalTo(self.rightButton);
         make.size.mas_equalTo(CGSizeMake(30, 20));
     }];
    _rightTitleLabel.hidden = YES;
    
}

-(void)setType:(FHMapSimpleNavbarType)type
{
    if (_type == type) {
        return;
    }
    _rightTitleLabel.hidden = YES;

    _type = type;
    _isShowCircle = NO;

    UIImage *img = nil;
    if(type == FHMapSimpleNavbarTypeClose){
        img = ICON_FONT_IMG(24, @"\U0000e673",[UIColor themeGray1]);
        _rightTitleLabel.hidden = YES;
    }else if(type == FHMapSimpleNavbarTypeDrawLine){
        img = ICON_FONT_IMG(24, @"\U0000e673",[UIColor themeGray1]);
        [_rightButton setImage:[UIImage imageNamed:@"draw_line_btn"] forState:UIControlStateNormal];
        [_rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
           make.right.equalTo(self).offset(-48);
        }];
        _rightTitleLabel.hidden = NO;
        _isShowCircle = YES;
    }else{
        img = ICON_FONT_IMG(22, @"\U0000e68a",[UIColor themeGray1]);
        UIImage *searImg = ICON_FONT_IMG(24, @"\U0000e675",[UIColor themeGray1]);
        [_rightButton setImage:searImg forState:UIControlStateNormal];
        [_rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
           make.right.equalTo(self).offset(-18);
        }];
        
        _rightTitleLabel.hidden = YES;
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.y > ([UIDevice btd_isIPhoneXSeries] ? 80 : 60)) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
