//
//  FHHomeMainTopView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainTopView.h"
#import <HMSegmentedControl.h>
#import "UIColor+Expanded.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import <FHEnvContext.h>
#import <SSThemed.h>
#import <Masonry.h>
#import <TTDeviceHelper.h>
#import <UIButton+TTAdditions.h>
#import <TTRoute.h>
#import <UIImageView+BDWebImage.h>
#import "FHHomeConfigManager.h"

@interface FHHomeMainTopView()

@property(nonatomic,strong)HMSegmentedControl *segmentControl;
@property (nonatomic, strong) UIView *topUnAvalibleCityContainer;
@property (nonatomic, strong) SSThemedImageView *backgroundImageView;
@property(nonatomic, strong) UIButton * changeCountryBtn;
@property(nonatomic, strong) UILabel * countryLabel;
@property(nonatomic, strong) UIImageView * cityImageButtonLeftIcon;

@end

@implementation FHHomeMainTopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        //        [self setupCityButton];
        [self setupSubviews];
    }
    
    return self;
}

- (void)setupSubviews
{
    ///背景图，支持下发
    _backgroundImageView = [[SSThemedImageView alloc] init];
    _backgroundImageView.clipsToBounds = YES;
    [self addSubview:_backgroundImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    self.backgroundImageView.layer.zPosition = -1;
    self.backgroundImageView.userInteractionEnabled = YES;
    
    [self setupCityButton];
    
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        [self showUnValibleCity];
    }];
}

- (void)setupCityButton
{
    UIButton *citySwichButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeCountryBtn = citySwichButton;
    [self addSubview:citySwichButton];
    citySwichButton.layer.cornerRadius = 20;
    citySwichButton.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
    citySwichButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    citySwichButton.layer.shadowRadius = 6.f;
    citySwichButton.layer.shadowOpacity = 1.f;
    [citySwichButton.titleLabel setFont:[UIFont themeFontRegular:14]];
    citySwichButton.backgroundColor = [UIColor whiteColor];
    NSString *text = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    [citySwichButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.mas_bottom).offset(-12);
    }];
    
    [[[citySwichButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x){
         [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance jumpCountryList:self.viewController];
    }];
    
    UIImageView *imageButtonLeftIcon = [UIImageView new];
    [citySwichButton addSubview:imageButtonLeftIcon];
    self.cityImageButtonLeftIcon = imageButtonLeftIcon;
    //    [imageButtonLeftIcon setImage:[UIImage imageNamed:@"combined-shape-1"]];
    [imageButtonLeftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(citySwichButton).offset(14);
        make.height.mas_equalTo(18);
        make.centerY.equalTo(citySwichButton);
        make.width.mas_equalTo(18);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont themeFontRegular:14];
    label.textColor = [UIColor themeGray1];
    label.numberOfLines = 1;
    label.text = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    self.countryLabel = label;
    [self addSubview:self.countryLabel];
    
    [self.countryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageButtonLeftIcon.mas_right).offset(2);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(label.text.length * 14);
        make.right.mas_equalTo(citySwichButton.mas_right).offset(-14);
    }];
    
    [self.countryLabel sizeToFit];
}

- (void)setupSetmentedControl {
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:[self getSegmentTitles]];
    
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray3]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 24.0f;
    _segmentControl.selectionIndicatorHeight = 12.0f;
    _segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];
    
    [self addSubview:_segmentControl];
    
    __weak typeof(self) weakSelf = self;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
    };
    
    _segmentControl.indexRepeatBlock = ^(NSInteger index) {
    };
}

- (void)showUnValibleCity
{
    
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (dataModel.cityAvailability && [dataModel.cityAvailability.enable respondsToSelector:@selector(boolValue)] &&[dataModel.cityAvailability.enable boolValue] == false) {
        
        if (self.topUnAvalibleCityContainer) {
            [self.topUnAvalibleCityContainer removeFromSuperview];
            self.topUnAvalibleCityContainer = nil;
        }
        
        self.topUnAvalibleCityContainer = [[UIView alloc] init];
        [self.backgroundImageView addSubview:self.topUnAvalibleCityContainer];
        [self.backgroundImageView bringSubviewToFront:self.topUnAvalibleCityContainer];
        
        [self.topUnAvalibleCityContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.backgroundImageView);
        }];
        if (dataModel.cityAvailability.backgroundColor) {
            [self.topUnAvalibleCityContainer setBackgroundColor:[UIColor colorWithHexString:dataModel.cityAvailability.backgroundColor]];
        }
        
        CGFloat padingTop = 8;
        if ([TTDeviceHelper isIPhoneXSeries]) {
            padingTop = 20;
        }
        BOOL isLarge320 = [TTDeviceHelper isScreenWidthLarge320];
        CGFloat tipsFontSize = 14.0;
        CGFloat leftOffset = 14;
        // 适配小屏幕
        if (!isLarge320) {
            leftOffset = 10;
            tipsFontSize = 12;
        }
        CGFloat widthOffset = leftOffset * 2;
        UILabel *cityLabel = [[UILabel alloc] init];
        cityLabel.textColor = [UIColor tt_themedColorForKey:@"grey1"];
        cityLabel.text = dataModel.currentCityName;
        cityLabel.font = [UIFont themeFontRegular:14];
        
        UIButton *citySwichButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topUnAvalibleCityContainer addSubview:citySwichButton];
        citySwichButton.layer.cornerRadius = 20;
        citySwichButton.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
        citySwichButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        citySwichButton.layer.shadowRadius = 6.f;
        citySwichButton.layer.shadowOpacity = 1.f;
        [citySwichButton.titleLabel setFont:[UIFont themeFontRegular:14]];
        citySwichButton.backgroundColor = [UIColor whiteColor];
        [citySwichButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topUnAvalibleCityContainer).offset(20);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.topUnAvalibleCityContainer.mas_bottom).offset(-12);
            make.width.mas_equalTo(dataModel.currentCityName.length * 14 + 24 + widthOffset); // button width
        }];
        [citySwichButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 22, 0, 0)];
        [citySwichButton addTarget:self withActionBlock:^{
            NSURL *url = [[NSURL alloc] initWithString:@"sslocal://city_list"];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:NULL];
        } forControlEvent:UIControlEventTouchUpInside];
        
        UIImageView *imageButtonLeftIcon = [UIImageView new];
        [citySwichButton addSubview:imageButtonLeftIcon];
        [imageButtonLeftIcon setImage:[UIImage imageNamed:@"combined-shape-1"]];
        [imageButtonLeftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(citySwichButton).offset(leftOffset);
            make.height.mas_equalTo(18);
            make.centerY.equalTo(citySwichButton);
            make.width.mas_equalTo(18);
        }];
        
        [citySwichButton addSubview:cityLabel];
        [cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imageButtonLeftIcon.mas_right).offset(2);
            make.height.mas_equalTo(21);
            make.centerY.mas_equalTo(imageButtonLeftIcon);
        }];
        
        UIImageView *imageRightView = [UIImageView new];
        [self.topUnAvalibleCityContainer addSubview:imageRightView];
        imageRightView.layer.opacity = 0.3;
        
        [imageRightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.topUnAvalibleCityContainer).offset(0);
            make.height.mas_equalTo(52);
            make.bottom.equalTo(self.topUnAvalibleCityContainer.mas_bottom).offset(0);
            make.width.mas_equalTo(108);
        }];
        
        
        UILabel *topTipForCityLabel = [UILabel new];
        topTipForCityLabel.text = @"找房服务即将开通，敬请期待";
        topTipForCityLabel.font = [UIFont themeFontRegular:tipsFontSize];
        topTipForCityLabel.textColor = [UIColor tt_themedColorForKey:@"grey3"];
        [self.topUnAvalibleCityContainer addSubview:topTipForCityLabel];
        
        [topTipForCityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(citySwichButton.mas_right).offset(10);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(citySwichButton);
            make.width.mas_equalTo(183);
        }];
        
        
        if (dataModel.cityAvailability.iconImage.url) {
            [imageRightView bd_setImageWithURL:[NSURL URLWithString:dataModel.cityAvailability.iconImage.url]];
        }
        
    }else
    {
        if (self.topUnAvalibleCityContainer) {
            [self.topUnAvalibleCityContainer removeFromSuperview];
            self.topUnAvalibleCityContainer = nil;
        }
    }
}

- (NSArray *)getSegmentTitles {
    return @[@"首页", @"发现"];
}

@end
