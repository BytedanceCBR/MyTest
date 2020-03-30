//
//  FHHomeTopCitySwitchView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/3/24.
//

#import "FHHomeTopCitySwitchView.h"
#import "UIColor+Expanded.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "FHEnvContext.h"
#import "SSThemed.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import "UIButton+TTAdditions.h"
#import "TTRoute.h"
#import "UIImageView+BDWebImage.h"
#import "FHHomeConfigManager.h"
#import "FHHouseType.h"
#import "FHHomeCellHelper.h"
#import "UIImage+FIconFont.h"
#import "TTDeviceHelper.h"
#import "FHPopupViewManager.h"
#import "FHHouseBridgeManager.h"
@interface FHHomeTopCitySwitchView()
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *switchBtn;
@property (nonatomic,strong) UIButton *closeBtn;
@end

@implementation FHHomeTopCitySwitchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor themeHomeColor];
        //        [self setupCityButton];
        [self setupSubviews];
    }
    
    return self;
}

- (void)setupSubviews
{
    ///背景图，支持下发
    _bgView = [[UIView alloc] init];
    _bgView.clipsToBounds = YES;
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 10;
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self addSubview:_bgView];
    [_bgView setFrame:CGRectMake(15, 0.0f, MAIN_SCREEN_WIDTH - 30, self.frame.size.height)];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont themeFontRegular:14];
    _titleLabel.textColor = [UIColor themeGray3];
    [_bgView addSubview:_titleLabel];
    [_titleLabel setFrame:CGRectMake(10, 6, 240, 30)];
    
    
    _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
   [_switchBtn addTarget:self action:@selector(switchBtnClick) forControlEvents:UIControlEventTouchUpInside];
   _switchBtn.hitTestEdgeInsets =  UIEdgeInsetsMake(-5, -5, -5, -5);
    _switchBtn.layer.masksToBounds = YES;
    _switchBtn.layer.cornerRadius = 13;
    _switchBtn.backgroundColor = [UIColor themeOrange4];
    [_switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   [self.bgView addSubview:_switchBtn];
    
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:ICON_FONT_IMG(24,@"\U0000e673",[UIColor whiteColor]) forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.hitTestEdgeInsets =  UIEdgeInsetsMake(-5, -5, -5, -5);
    [self.bgView addSubview:_closeBtn];
    [_closeBtn setFrame:CGRectMake(self.bgView.frame.size.width - 16 - 10, 13, 16, 16)];
//    [_closeBtn setBackgroundColor:[UIColor redColor]];
    
    
    [self updateFrames];
}


- (void)updateFrames
{
    
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 14 : 10;
    NSString *stringTitle =@"定位显示你在";
    if (configData.citySwitch.cityName) {
        NSString *stringPosition = [NSString stringWithFormat:@" \"%@\"",configData.citySwitch.cityName];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:stringTitle attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont themeFontSemibold:fontSize]}];
        
        NSAttributedString *attrPosString = [[NSAttributedString alloc] initWithString:stringPosition attributes:@{NSForegroundColorAttributeName:[UIColor themeOrange4],NSFontAttributeName:[UIFont themeFontSemibold:fontSize]}];
        [attrString appendAttributedString:attrPosString];
        _titleLabel.attributedText =attrString;
        
        
        NSString *switchString = [NSString stringWithFormat:@"切换到%@",configData.citySwitch.cityName];
        CGFloat btnWidht = switchString.length * 15;
        [_switchBtn.titleLabel setFont:[UIFont themeFontSemibold:12]];
        if (configData.citySwitch.cityName && configData.citySwitch.cityName.length > 5) {
            [_switchBtn setTitle:@"切换" forState:UIControlStateNormal];
            btnWidht = 40;
        }else
        {
            [_switchBtn setTitle:switchString forState:UIControlStateNormal];
        }
        [_switchBtn setFrame:CGRectMake(self.bgView.frame.size.width - 36 - btnWidht, 8, btnWidht, 26)];
    }
}

- (void)switchBtnClick
{
    [self removeFromSuperview];
    
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    [[FHPopupViewManager shared] outerPopupViewHide];
    if (configData.citySwitch.openUrl) {
        [FHEnvContext sharedInstance].refreshConfigRequestType = @"switch_alert";
        
        [FHEnvContext sharedInstance].isRefreshFromAlertCitySwitch = YES;
        [FHEnvContext openSwitchCityURL:configData.citySwitch.openUrl completion:^(BOOL isSuccess) {
            // 进历史
            if (isSuccess) {
                [[[FHHouseBridgeManager sharedInstance] cityListModelBridge] switchCityByOpenUrlSuccess];
            }
        }];
        NSDictionary *params = @{@"click_type":@"switch",
                                 @"enter_from":@"default"};
        [FHEnvContext recordEvent:params andEventKey:@"city_click"];
    }
    [self sendTraceClick:YES];
}

- (void)closeBtnClick
{
    [self removeFromSuperview];
    [self sendTraceClick:NO];
}

- (void)sendTraceClick:(BOOL)isConfirm
{
   NSMutableDictionary *popTraceParams = [NSMutableDictionary new];
   [popTraceParams setValue:@"maintab" forKey:@"page_type"];
   [popTraceParams setValue:@"city_switch" forKey:@"popup_name"];
   [popTraceParams setValue:isConfirm ? @"confirm" : @"close" forKey:@"click_position"];
   [FHEnvContext recordEvent:popTraceParams andEventKey:@"popup_click"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
