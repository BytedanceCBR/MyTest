//
//  FHCommuteConfigViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/21.
//

#import "FHCommuteConfigViewController.h"
#import "FHCommuteFilterView.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTRoute/TTRoute.h>
#import "FHCommutePOISearchViewController.h"
#import <AMapSearchKit/AMapCommonObj.h>
#import <FHCommonUI/ToastManager.h>
#import "FHCommuteManager.h"
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHUserTrackerDefine.h>

#define BANNER_HEIGHT SCREEN_WIDTH*(224/375.0)
#define INPUT_BG_HEIGHT 46
@interface FHCommuteConfigViewController ()<FHCommutePOISearchDelegate>

@property(nonatomic , strong) UIImageView *topBanner;
@property(nonatomic , strong) UIButton *backButton;
@property(nonatomic , strong) UILabel *bannerTitleLabel;
@property(nonatomic , strong) UILabel *bannerSubtitleLabel;
@property(nonatomic , strong) FHCommuteFilterView *filterView;
@property(nonatomic , strong) UIView *inputBgView;
@property(nonatomic , strong) UILabel *inputLabel;
@property(nonatomic , strong) AMapAOI *choosePOI;
@property(nonatomic , strong) NSString *chooseLocation;

@end

@implementation FHCommuteConfigViewController


-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSHashTable *table= paramObj.allParams[COMMUTE_CONFIG_DELEGATE];
        if (table) {
            self.delegate = UNWRAP_WEAK(table);
        }
    }
    return self;
    
}

-(UILabel *)label:(UIFont *)font text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.text = text;
    
    return label;
}

-(void)initBanners
{
    _topBanner = [[UIImageView alloc]initWithImage:SYS_IMG(@"commute_banner.jpg")];
    
    _bannerTitleLabel = [self label:[UIFont themeFontMedium:32] text:@"通勤找房"];
    _bannerSubtitleLabel = [self label:[UIFont themeFontRegular:14] text:@"更好的生活从缩短通勤开始"];
    
    [self.view addSubview:_topBanner];
    [self.view addSubview:_bannerTitleLabel];
    [self.view addSubview:_bannerSubtitleLabel];
    
}

-(void)initInputTip
{
 
    _inputBgView = [[UIView alloc] init];
    CALayer *clayer = [CALayer layer];
    clayer.frame = CGRectMake(0, 0, SCREEN_WIDTH - 2*HOR_MARGIN, INPUT_BG_HEIGHT);
    clayer.backgroundColor = [[UIColor whiteColor]CGColor];
    clayer.cornerRadius = 4;
    clayer.masksToBounds = YES;
    
    CALayer *slayer = [CALayer layer];
    slayer.frame = clayer.frame;
    slayer.backgroundColor = [[UIColor whiteColor] CGColor];
    slayer.shadowColor = [[UIColor blackColor]CGColor];
    slayer.shadowRadius = 5;
    slayer.shadowOpacity = 0.1;
    slayer.shadowOffset = CGSizeMake(2, 6);

    [_inputBgView.layer addSublayer:slayer];
    [_inputBgView.layer addSublayer:clayer];
    
    _inputLabel = [[UILabel alloc] init];
    _inputLabel.font = [UIFont themeFontRegular:14];
    _inputLabel.textColor = [UIColor themeGray4];
    _inputLabel.backgroundColor = [UIColor clearColor];
    _inputLabel.text = @"请输入公司地址";
    
    [_inputBgView addSubview:_inputLabel];
    
    [self.view addSubview:_inputBgView];
    
 
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInputAction:)];
    [_inputBgView addGestureRecognizer:gesture];
    
}

-(void)showInputAction:(id)sender
{
    [self addClickSearchLog];
    FHCommutePOISearchViewController *controller = [[FHCommutePOISearchViewController alloc] init];
    controller.sugDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initBanners];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:SYS_IMG(@"nav_back_arrow_white") forState:UIControlStateNormal];
    [_backButton addTarget:self
                    action:@selector(backAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    _filterView = [[FHCommuteFilterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200) insets:UIEdgeInsetsMake(57, 0, 10, 0) type:FHCommuteTypeDrive];
    __weak typeof(self) wself = self;
    _filterView.chooseBlock = ^(NSString * _Nonnull time, FHCommuteType type) {
        if (wself.chooseLocation.length == 0) {
            SHOW_TOAST(@"请选择目的地");
            return ;
        }
        [wself startSearch:time type:type];                
    };
    
    [self.view addSubview:_filterView];
    
    [self initInputTip];
    
    [self initConstraints];
    
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    NSString *destLocation = manager.destLocation;
    if (destLocation.length > 0) {
        _inputLabel.text = destLocation;
    }
    [_filterView updateType:manager.commuteType time:manager.duration];
    
    [self addGoDetailLog];
}


-(void)initConstraints
{
    CGFloat topMargin = 20;
    if (@available(iOS 11.0 , *)) {
        topMargin += [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;
    }
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(topMargin);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [_topBanner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(BANNER_HEIGHT);
    }];
    
    [_bannerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_lessThanOrEqualTo(self.view).offset(-HOR_MARGIN);
        make.top.mas_equalTo(topMargin + 64);
        make.height.mas_equalTo(45);
    }];
    
    [_bannerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(self.bannerTitleLabel.mas_bottom).offset(0);
        make.right.mas_lessThanOrEqualTo(self.view).offset(-HOR_MARGIN);
        make.height.mas_equalTo(20);
    }];
    
    
    [_filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topBanner.mas_bottom);
    }];
    
    
    [_inputBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_equalTo(self.view).offset(-HOR_MARGIN);
        make.top.mas_equalTo(_topBanner.mas_bottom).offset(-10);
        make.height.mas_equalTo(INPUT_BG_HEIGHT);
    }];
    
    [_inputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.centerY.mas_equalTo(self.inputBgView);
    }];
}


-(void)userChoosePoi:(AMapAOI *)poi inViewController:(UIViewController *)viewController
{
    self.inputLabel.text = poi.name;
    [viewController.navigationController popViewControllerAnimated:YES];
    self.chooseLocation = poi.name;
}

-(void)userCanced:(FHCommutePOISearchViewController *)viewController
{
    [viewController.navigationController popViewControllerAnimated:YES];
}


-(void)startSearch:(NSString *)duration type:(FHCommuteType)type
{
    FHCommuteManager *manager = [FHCommuteManager sharedInstance];
    manager.duration = duration;
    manager.commuteType = type;
    manager.destLocation = self.chooseLocation;
    [manager sync];
    
    if ([self.delegate respondsToSelector:@selector(commuteWithDest:type:duration:inController:)]) {
        [self.delegate commuteWithDest:self.chooseLocation type:type duration:duration inController:self];
    }else{        
        [self.navigationController popViewControllerAnimated:YES ];
    }
    
    [self addStartSearchLog];
}

-(NSString *)pageType
{
    return @"commuter_detail";
}
#pragma mark - tracker
-(void)addGoDetailLog
{
    /*
     "1.event_type:house_app2c_v2
     2.page_type:commuter_detail(通勤选项页）
     3.enter_from:renting(从租房icon进入),rent_list（从修改进入）
     4.element_from:commuter_info（从租房icon进入），be_null（从修改进入）
     5.origin_from:commuter（通勤找房）
     6. origin_search_id"
     */
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param addEntriesFromDictionary:[self.tracerModel logDict]];
    param[UT_PAGE_TYPE] = [self pageType];
    TRACK_EVENT(UT_GO_DETAIL, param);
}

-(void)addStartSearchLog
{
    /*
     "1. event_type：house_app2c_v2
     2. page_type：commuter_detail(通勤选项页）
     3. house_type：rent(租房)
     4. query_type：mutiple(多种搜索方式混合）
     5. enter_query：be_null
     5. search_query：
     6. search_id
     7. origin_from:commuter(通勤找房）
     8. origin_search_id"
     */
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = [self pageType];
    param[UT_HOUSE_TYPE] = @"rent";
    param[@"query_type"] = @"mutiple";
    param[@"enter_query"] = UT_BE_NULL;
    param[UT_SEARCH_ID] = @"be_null";
    param[@"search_query"] = self.chooseLocation ?:UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom?:UT_BE_NULL;
    param[UT_ORIGIN_SEARCH_ID] = self.tracerModel.originSearchId?:UT_BE_NULL;

    
    TRACK_EVENT(@"house_search", param);
    
}

-(void)addClickSearchLog
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = [self pageType];
    param[UT_ORIGIN_SEARCH_ID] = self.tracerModel.originSearchId?:UT_BE_NULL;
    param[UT_ORIGIN_FROM] = self.tracerModel.originFrom?:@"commuter";
    param[@"selected_word"] = self.chooseLocation?:UT_BE_NULL;
    
    TRACK_EVENT(@"click_house_search", param);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

NSString *const COMMUTE_CONFIG_DELEGATE = @"_COMMUTE_CONFIG_DELEGATE_";
