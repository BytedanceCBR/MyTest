//
//  FHFloorTimeLineViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorTimeLineViewController.h"

@interface FHFloorTimeLineViewController ()

@property (nonatomic , strong) UITableView *timeLineListTable;

@end

@implementation FHFloorTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航条为黑色
    [self refreshContentOffset:CGPointMake(0, 500)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // Do any additional setup after loading the view.
    
    [self setUpTimeLineListTable];
}

- (void)setUpTimeLineListTable
{
    _timeLineListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _timeLineListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _timeLineListTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _timeLineListTable.estimatedRowHeight = UITableViewAutomaticDimension;
        _timeLineListTable.estimatedSectionFooterHeight = 0;
        _timeLineListTable.estimatedSectionHeaderHeight = 0;
    }
    [_timeLineListTable setBackgroundColor:[UIColor redColor]];
    
    [_timeLineListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo([self getBottomBar].mas_top);
    }];
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
