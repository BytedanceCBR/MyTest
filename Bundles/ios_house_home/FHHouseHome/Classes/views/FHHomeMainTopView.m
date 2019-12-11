//
//  FHHomeMainTopView.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainTopView.h"
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
#import <FHHouseType.h>
#import <FHHomeCellHelper.h>

static const float kSegementedOneWidth = 50;
static const float kSegementedMainTopHeight = 44;
static const float kSegementedMainPadingBottom = 10;

@interface FHHomeMainTopView()

@property (nonatomic, strong) UIView *topBackCityContainer;
@property (nonatomic, strong) SSThemedImageView *backgroundImageView;
@property (nonatomic, strong) UIButton * changeCountryBtn;
@property (nonatomic, strong) UILabel * countryLabel;
@property (nonatomic, strong) UIImageView * cityImageButtonLeftIcon;

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
        self.backgroundColor = [UIColor themeHomeColor];
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
    
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchBtn setImage:[UIImage imageNamed:@"home_right_searchbtn"] forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _searchBtn.hidden = YES;
    [self addSubview:_searchBtn];
    
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        [self showUnValibleCity];
    }];
}

- (void)setupSetmentedControl {
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:[self getSegmentTitles]];
    
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontSemibold:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(9, 10, 0, 10);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 20.0f;
    _segmentControl.selectionIndicatorHeight = 4.0f;
    _segmentControl.selectionIndicatorCornerRadius = 2.0f;
    _segmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    //_segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];
    [_segmentControl setBackgroundColor:[UIColor themeHomeColor]];
    
    __weak typeof(self) weakSelf = self;
    _segmentControl.indexChangeBlock = ^(NSInteger index) {
        if (weakSelf.indexChangeBlock) {
            weakSelf.indexChangeBlock(index);
        }
    };
    
    _segmentControl.indexRepeatBlock = ^(NSInteger index) {
        
    };
    
    [self.topBackCityContainer addSubview:_segmentControl];
    
    [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topBackCityContainer);
        make.height.mas_equalTo(kSegementedMainTopHeight);
        if (self.changeCountryBtn) {
            make.centerY.equalTo(self.changeCountryBtn).offset(-2);
        }else
        {
            make.bottom.mas_equalTo(8);
        }
        make.width.mas_equalTo(118);
    }];
    
    
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        if (self.segmentControl) {
            make.centerY.equalTo(self.segmentControl).offset(2);
        }else
        {
            make.bottom.mas_equalTo(8);
        }
        make.width.height.mas_equalTo(24);
    }];
}

- (void)setUpHouseSegmentedControl
{
    
    NSArray *titlesArray = [FHHomeCellHelper matchHouseSegmentedTitleArray];
    if (!titlesArray && [titlesArray count] == 0) {
        return;
    }
    
    NSNumber *userSelectType = [[FHEnvContext sharedInstance].generalBizConfig getUserSelectTypeDiskCache];
    NSInteger indexValue = 0;
    NSArray *houstTypeList = [[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList;
    
    if ([houstTypeList containsObject:userSelectType]) {
        indexValue = [houstTypeList indexOfObject:userSelectType];
        NSNumber *numberType = [houstTypeList objectAtIndex:indexValue];
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
    _houseSegmentControl.segmentEdgeInset = UIEdgeInsetsMake(5, 0, 5, 0);
    _houseSegmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _houseSegmentControl.selectionIndicatorWidth = 20.0f;
    _houseSegmentControl.selectionIndicatorHeight = 4.0f;
    _houseSegmentControl.hidden = YES;
    _houseSegmentControl.selectionIndicatorCornerRadius = 2.0f;
    _houseSegmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, -3, 0);
    _houseSegmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    [_houseSegmentControl setBackgroundColor:[UIColor themeHomeColor]];

    //    _segmentControl.selectionIndicatorImage = [UIImage imageNamed:@"fh_ugc_segment_selected"];
    
    __weak typeof(self) weakSelf = self;
    _houseSegmentControl.indexChangeBlock = ^(NSInteger index) {
        if (weakSelf.indexHouseChangeBlock) {
            weakSelf.indexHouseChangeBlock(index);
        }
    };
    
    _houseSegmentControl.indexRepeatBlock = ^(NSInteger index) {
        
    };
    
    [self.topBackCityContainer addSubview:_houseSegmentControl];
    
    [_houseSegmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topBackCityContainer);
        make.height.mas_equalTo(kSegementedMainTopHeight);
        if (self.changeCountryBtn) {
            make.centerY.equalTo(self.changeCountryBtn).offset(-2);
        }else
        {
            make.bottom.mas_equalTo(8);
        }
        make.width.mas_equalTo((kSegementedOneWidth + 20) * titlesArray.count);
    }];
    
    [self updateSegementedTitles:titlesArray andSelectIndex:indexValue];
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
    
    [_houseSegmentControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topBackCityContainer);
        make.height.mas_equalTo(kSegementedMainTopHeight);
        if (self.changeCountryBtn) {
            make.centerY.equalTo(self.changeCountryBtn).offset(-2);
        }else
        {
            make.bottom.mas_equalTo(8);
        }
        make.width.mas_equalTo((kSegementedOneWidth + 15) * titles.count - ([TTDeviceHelper isScreenWidthLarge320] ? 0 : 20));
    }];
    
    _searchBtn.hidden = YES;
}

- (void)searchBtnClick
{
    NSMutableDictionary *tracerParams = [NSMutableDictionary new];
    tracerParams[@"enter_type"] = @"click";
    tracerParams[@"element_from"] = @"maintab_search";
    tracerParams[@"enter_from"] = @"maintab";
    tracerParams[@"origin_from"] = @"maintab_search";

    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"house_type"] = @(FHHouseTypeSecondHandHouse);
    infos[@"tracer"] = tracerParams;
    infos[@"from_home"] = @(1);
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://house_search"] userInfo:userInfo];
}

- (void)showUnValibleCity
{
    [self updateContainerCity:[FHEnvContext isCurrentCityNormalOpen]];
}

- (void)updateContainerCity:(BOOL)isOpen
{
    if (self.topBackCityContainer) {
        [self.topBackCityContainer removeFromSuperview];
        self.topBackCityContainer = nil;
    }
    
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (self.topBackCityContainer) {
        [self.topBackCityContainer removeFromSuperview];
        self.topBackCityContainer = nil;
    }
    
    self.topBackCityContainer = [[UIView alloc] init];
    [self.backgroundImageView addSubview:self.topBackCityContainer];
    [self.backgroundImageView bringSubviewToFront:self.topBackCityContainer];
    
    [self.topBackCityContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backgroundImageView);
    }];
    if (dataModel.cityAvailability.backgroundColor) {
        [self.topBackCityContainer setBackgroundColor:[UIColor colorWithHexString:dataModel.cityAvailability.backgroundColor]];
    }
    [self.topBackCityContainer setBackgroundColor:[UIColor themeHomeColor]];

    
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
    cityLabel.textColor = [UIColor themeGray1];
    cityLabel.text = dataModel.currentCityName;
    cityLabel.font = [UIFont themeFontSemibold:14];
    
    UIButton *citySwichButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeCountryBtn = citySwichButton;
    [self.topBackCityContainer addSubview:citySwichButton];
    //    citySwichButton.layer.cornerRadius = 20;
    //    citySwichButton.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
    //    citySwichButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    //    citySwichButton.layer.shadowRadius = 6.f;
    //    citySwichButton.layer.shadowOpacity = 1.f;
    [citySwichButton.titleLabel setFont:[UIFont themeFontRegular:14]];
    citySwichButton.backgroundColor = [UIColor clearColor];
    [citySwichButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topBackCityContainer).offset(10);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.topBackCityContainer.mas_bottom).offset(-6);
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
        make.left.equalTo(citySwichButton).offset(0);
        make.height.mas_equalTo(24);
        make.centerY.equalTo(citySwichButton);
        make.width.mas_equalTo(24);
    }];
    
    [citySwichButton addSubview:cityLabel];
    [cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imageButtonLeftIcon.mas_right).offset(2);
        make.height.mas_equalTo(21);
        make.centerY.mas_equalTo(imageButtonLeftIcon);
    }];
    
    if (!isOpen) {
        UIImageView *imageRightView = [UIImageView new];
        [self.topBackCityContainer addSubview:imageRightView];
        imageRightView.layer.opacity = 0.3;
        
        [imageRightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.topBackCityContainer).offset(0);
            make.height.mas_equalTo(52);
            make.bottom.equalTo(self.topBackCityContainer.mas_bottom).offset(0);
            make.width.mas_equalTo(108);
        }];
        
        
        UILabel *topTipForCityLabel = [UILabel new];
        topTipForCityLabel.text = @"找房服务即将开通，敬请期待";
        topTipForCityLabel.font = [UIFont themeFontRegular:tipsFontSize];
        topTipForCityLabel.textColor = [UIColor tt_themedColorForKey:@"grey3"];
        [self.topBackCityContainer addSubview:topTipForCityLabel];
        
        [topTipForCityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.topBackCityContainer);
            make.height.mas_equalTo(20);
            make.centerY.equalTo(citySwichButton);
            make.width.mas_equalTo(183);
        }];
        
        if (dataModel.cityAvailability.iconImage.url) {
            [imageRightView bd_setImageWithURL:[NSURL URLWithString:dataModel.cityAvailability.iconImage.url]];
        }
    }else
    {
        [self setupSetmentedControl];
        [self setUpHouseSegmentedControl];
    }
    
}

- (NSArray *)getSegmentTitles {
    return @[@"推荐", @"发现"];
}

@end
