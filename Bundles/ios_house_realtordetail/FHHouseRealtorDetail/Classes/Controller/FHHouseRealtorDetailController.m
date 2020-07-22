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
@interface FHHouseRealtorDetailController ()
@property (strong, nonatomic) FHHouseRealtorDetailViewModel *viewModel;
@end

@implementation FHHouseRealtorDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createModel];
    [self createTracerDic];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_viewModel.isRequest) {
        [_viewModel requestData:YES first:YES];
        _viewModel.isRequest = YES;
    }
}

- (void)createModel {
    NSMutableDictionary *dic = self.realtorInfo.mutableCopy;
    [dic setObject:self.tabName forKey:@"tab_name"];
    _viewModel = [[FHHouseRealtorDetailViewModel alloc]initWithController:self tableView:self.tableView realtorInfo:dic tracerDic:self.tracerDict];
}

- (void)createTracerDic {
    NSMutableDictionary *dic = self.tracerDict.mutableCopy;
}


@end
