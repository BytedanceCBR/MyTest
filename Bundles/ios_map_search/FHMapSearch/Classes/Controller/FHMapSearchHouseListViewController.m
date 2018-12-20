//
//  FHMapSearchHouseListViewController.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchHouseListViewController.h"
#import <Masonry/Masonry.h>
#import <MJRefresh.h>
#import <UIViewAdditions.h>
#import "FHMapSearchModel.h"
#import "FHHouseAreaHeaderView.h"
#import "UIColor+Theme.h"
#import "FHErrorMaskView.h"


@interface FHMapSearchHouseListViewController ()

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHHouseAreaHeaderView *headerView;
@property(nonatomic , strong) FHErrorMaskView *maskView;

@end

@implementation FHMapSearchHouseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    _headerView = [[FHHouseAreaHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 87)];
    [self.view addSubview:_tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self.view);
    }];
    
    _maskView = [[FHErrorMaskView alloc]init];
    [self.view addSubview:_maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
//        make.top.left.right.mas_equalTo(self.view);
//        make.height.mas_equalTo([[UIScreen mainScreen] bounds].size.height*2/3);
    }];
    
    self.viewModel = [[FHMapSearchHouseListViewModel alloc] initWithController:self tableView:self.tableView];
    self.viewModel.headerView = _headerView;
    self.viewModel.maskView = _maskView;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UIEdgeInsets inset = UIEdgeInsetsZero;
        inset.bottom = [[UIApplication sharedApplication]keyWindow].safeAreaInsets.bottom;
        self.tableView.contentInset = inset;
    }
}

-(void)resetScrollViewInsetsAndOffsets
{
    self.tableView.contentOffset = CGPointZero;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11.0 , *)) {
        inset.bottom = [[UIApplication sharedApplication]keyWindow].safeAreaInsets.bottom;
    }
    if (self.tableView.mj_footer) {
        inset.bottom += self.tableView.mj_footer.height;
    }
    self.tableView.contentInset = inset;
   
}

-(void)showNeighborHouses:(FHMapSearchDataListModel *)neighbor bubble:(FHMapSearchBubbleModel *)bubble
{
    if (self.view.hidden) {
        self.view.top = self.view.superview.height;
    }
    self.view.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top =  floor(self.view.superview.height/3);
    }];

    [self.viewModel updateWithHouseData:nil neighbor:neighbor bubble:bubble];
}

-(void)showWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor  bubble:(FHMapSearchBubbleModel *)bubble
{
    if (self.view.hidden) {
        self.view.top = self.view.superview.height;
    }
    self.view.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.top = floor(self.view.superview.height/3);
    }];
    
    [self.parentViewController.view addSubview:self.view];
    [self.viewModel updateWithHouseData:data neighbor:neighbor bubble:bubble];
}

-(CGFloat)initialTop
{
    return floor(self.view.superview.height/3);
}

-(CGFloat)minTop
{
    return self.view.superview.height - self.view.height;
}

-(BOOL)canMoveup
{
    return (self.view.top - 0.01) > [self minTop];
}

-(void)moveTop:(CGFloat)top
{
    CGFloat minTop = [self minTop];
    top = MAX(minTop, top);
    if (((top + 0.1) < self.view.top) && (top == minTop) ) {
        //move to topest
        if (self.moveToTop) {
            self.moveToTop();
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.view.top = top;
    }];
    
    if (self.movingBlock) {
        self.movingBlock(top);
    }
}

-(void)dismiss
{
    [self.viewModel dismiss];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear:animated];
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
