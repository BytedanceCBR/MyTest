//
//  FHHouseRealtorDetailController.m
//  Pods
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseRealtorDetailController.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHHouseRealtorDetailViewModel.h"
#import "Masonry.h"
#import "UIDevice+BTDAdditions.h"
#import "FHHouseRealtorDetailRgcTabView.h"
@interface FHHouseRealtorDetailController ()
@property (strong, nonatomic) FHHouseRealtorDetailViewModel *viewModel;
@end

@implementation FHHouseRealtorDetailController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self createTracerDic:paramObj.allParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createUI];
//    [self createModel];
}

- (void)createUI {
//    CGFloat statusBarHeight =  ((![[UIApplication sharedApplication] isStatusBarHidden]) ? [[UIApplication sharedApplication] statusBarFrame].size.height : ([UIDevice btd_isIPhoneXSeries]?44.f:20.f));
//       //获取导航栏的rect
//    CGRect navRect = self.navigationController.navigationBar.frame;
//    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsMake(statusBarHeight+navRect.size.height, 0, 0, 0));
//    }];
//    [self setupDefaultNavBar:YES];
//    self.title = @"经纪人主页";
}

- (void)createModel {
//    _viewModel = [[FHHouseRealtorDetailViewModel alloc]initWithController:self tableView:self.tableview];
//    _view
    
}

- (void)createTracerDic:(NSDictionary *)dic {
    
}

- (FHHouseRealtorDetailHeaderView *)header {
    if (!_header) {
        _header = [[FHHouseRealtorDetailHeaderView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,425)];
    }
    return _header;
}


@end
