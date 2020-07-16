//
//  FHHouseRealtorDetailBaseViewController.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHHouseRealtorDetailBaseViewController.h"
#import "FHBaseTableView.h"
#import "Masonry.h"

@interface FHHouseRealtorDetailBaseViewController ()

@end

@implementation FHHouseRealtorDetailBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    self.tableView.backgroundColor = [UIColor redColor];
}

- (void)initTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

@end
