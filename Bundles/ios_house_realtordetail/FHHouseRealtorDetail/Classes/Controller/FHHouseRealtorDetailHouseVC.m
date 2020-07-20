//
//  FHHouseRealtorDetailHouseVC.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHHouseRealtorDetailHouseVC.h"
#import "FHHouseRealtorDetailHouseViewModel.h"
@interface FHHouseRealtorDetailHouseVC ()
@property (strong, nonatomic) FHHouseRealtorDetailHouseViewModel *viewModel;
@end

@implementation FHHouseRealtorDetailHouseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createModel];
}

- (void)createModel {
    NSMutableDictionary *dic = self.realtorInfo.mutableCopy;
    [dic setObject:self.tabName forKey:@"tab_name"];
    _viewModel = [[FHHouseRealtorDetailHouseViewModel alloc]initWithController:self tableView:self.tableView realtorInfo:dic tracerDic:self.tracerDict];
}
@end
