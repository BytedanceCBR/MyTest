//
//  FHMapSearchHouseListViewController.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchHouseListViewController.h"
#import <Masonry/Masonry.h>
#import "FHMapSearchModel.h"
#import "FHHouseAreaHeaderView.h"
#import "Bubble-Swift.h"

@interface FHMapSearchHouseListViewController ()

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHHouseAreaHeaderView *headerView;

@end

@implementation FHMapSearchHouseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (@available(iOS 11.0, *)) {
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    _headerView = [[FHHouseAreaHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 88)];
    [self.view addSubview:_tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self.view);
    }];
    
    self.viewModel = [[FHMapSearchHouseListViewModel alloc] init];
    [self.viewModel registerCells:self.tableView];
    self.viewModel.headerView = _headerView;
    self.viewModel.listController = self;
    
}

-(void)showWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor
{
    self.view.top = self.view.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top = self.view.height/3;
    }];
    
    [self.parentViewController.view addSubview:self.view];
    [self.viewModel showWithHouseData:data neighbor:neighbor];
}

-(CGFloat)minTop
{
    return self.view.superview.height - self.view.height;
}

-(BOOL)canMoveup
{
    return self.view.top - 0.01 > [self minTop];
}

-(void)moveTop:(CGFloat)top
{
    CGFloat minTop = [self minTop];
    top = MAX(minTop, top);
    if (top + 0.1 < self.view.top && top == minTop ) {
        //move to topest
        if (self.moveToTop) {
            self.moveToTop();
        }
    }
    self.view.top = top;
}

-(void)dismiss
{
    [self.viewModel dismiss];
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
