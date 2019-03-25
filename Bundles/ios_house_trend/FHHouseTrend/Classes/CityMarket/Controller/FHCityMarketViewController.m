//
//  FHCityMarketViewController.m
//  FHHouseTrend
//
//  Created by 春晖 on 2019/3/19.
//

#import "FHCityMarketViewController.h"
#import "FHNavBarView.h"
#import "FHCityMarketHeaderView.h"
#import <Masonry.h>
#import "RXCollection.h"
#import "FHCityMarketHeaderPropertyItemView.h"
#import "FHCityMarketHeaderPropertyBar.h"
#import "FHCityMarketTrendChatView.h"
#import "FHCityMarketTrendChatViewModel.h"
#import "ReactiveObjC.h"
#import "FHCityMarketRecommendHeaderView.h"

@interface FHCityMarketViewController () 

@property (nonatomic, strong) FHCityMarketHeaderView* headerView;
@property (nonatomic, strong) FHCityMarketTrendChatView* chatView;
@property (nonatomic, strong) FHCityMarketTrendChatViewModel* chatViewModel;
@end

@implementation FHCityMarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initHeaderView];
    [self initNavBar];
    FHCityMarketRecommendHeaderView* headerView = [[FHCityMarketRecommendHeaderView alloc] init]; //174
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(174);
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(_chatView.mas_bottom);
    }];


    [self bindChatViewModel];
}

-(void)initNavBar {
    [self setupDefaultNavBar:NO];
//    self.customNavBarView.leftBtn.hidden = [self leftActionHidden];
    self.customNavBarView.title.text = @"城市行情";
    self.customNavBarView.title.textColor = [UIColor whiteColor];
    [self.customNavBarView cleanStyle:YES];
}

-(void)initHeaderView {
    self.headerView = [[FHCityMarketHeaderView alloc] init];
    [self.view addSubview:_headerView];
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.view);
        make.height.mas_equalTo(259);
        make.width.mas_equalTo(self.view);
    }];
    NSArray* items = [@[@1,@2,@3] rx_mapWithBlock:^id(id each) {
        FHCityMarketHeaderPropertyItemView* item = [[FHCityMarketHeaderPropertyItemView alloc] init];
        return item;
    }];
    [_headerView.propertyBar setPropertyItem:items];

    self.chatView = [[FHCityMarketTrendChatView alloc] init];
    [self.view addSubview:_chatView];
    [_chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(382);
        make.width.mas_equalTo(self.view);
        make.top.mas_equalTo(_headerView.mas_bottom);
        make.left.mas_equalTo(self.view);
    }];
}

-(void)bindChatViewModel {
    _chatViewModel = [[FHCityMarketTrendChatViewModel alloc] init];
    RAC(_chatView.titleLable, text) = RACObserve(_chatViewModel, title);
    RAC(_chatView.banner.unitLabel, text) = RACObserve(_chatViewModel, unitLabel);
    RAC(_chatView.banner, items) = [RACObserve(_chatViewModel, model) map:^id _Nullable(id  _Nullable value) {
        NSArray* theDatas = value;
        NSArray* result = [theDatas rx_mapWithBlock:^id(id each) {
            NSDictionary* it = each;
            FHCityMarketTrendChatViewInfoItem* item = [[FHCityMarketTrendChatViewInfoItem alloc] init];
            item.name = it[@"name"];
            item.color = it[@"color"];
            return item;
        }];
        return result;
    }];
    RAC(_chatView, categorys) = RACObserve(_chatViewModel, categorySelections);
    _chatViewModel.categorySelections = @[@"全部", @"鼓楼", @"四个字的"];
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
