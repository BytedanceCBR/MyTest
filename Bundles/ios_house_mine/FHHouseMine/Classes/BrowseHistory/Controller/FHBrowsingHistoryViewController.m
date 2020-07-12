//
//  FHBrowsingHistoryViewController.m
//  BDSSOAuthSDK-BDSSOAuthSDK
//
//  Created by wangxinyu on 2020/7/10.
//

#import "FHBrowsingHistoryViewController.h"
#import "FHSuggestionCollectionView.h"
#import "SSNavigationBar.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import "TTDeviceHelper.h"
#import "HMSegmentedControl.h"

@interface FHBrowsingHistoryViewController ()

@property (nonatomic, strong) FHSuggestionCollectionView *collectionView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong)     HMSegmentedControl *segmentControl;

@end

@implementation FHBrowsingHistoryViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    self.title = @"浏览历史";
    [self setupDefaultNavBar:NO];
    
}



- (void) setupUI {
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(naviHeight);
        make.height.mas_equalTo(44);
    }];
    [self setupSegmentedControl];
    
}

-(NSArray *)getSegmentTitles {
    NSArray *items = @[@"二手房", @"新房", @"租房", @"小区"];
    return items;
}

- (void)setupSegmentedControl {
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
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(5, 0, 5, 0);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 20.0f;
    _segmentControl.selectionIndicatorHeight = 4.0f;
    _segmentControl.selectionIndicatorCornerRadius = 2.0f;
    _segmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, -3, 0);
    _segmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    [_segmentControl setBackgroundColor:[UIColor clearColor]];
    [self.topView addSubview:_segmentControl];
    NSInteger count = _segmentControl.sectionTitles.count;
    float tabMargin = ([UIScreen mainScreen].bounds.size.width - (count - 1) * 32 - count * 36 - 18) / 2;
    [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_topView);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(tabMargin);
        make.right.mas_equalTo(-tabMargin);
    }];
}

@end
