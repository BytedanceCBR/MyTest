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
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initTableView];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)initTableView {
    if (!_tableView) {
        _tableView = [[FHHorizontalTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor themeGray7];
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
        }
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.scrollEnabled = NO;
    }
}
@end
