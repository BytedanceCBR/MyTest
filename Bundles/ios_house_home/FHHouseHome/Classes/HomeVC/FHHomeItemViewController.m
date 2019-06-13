//
//  FHHomeItemViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/6/12.
//

#import "FHHomeItemViewController.h"
#import <FHRefreshCustomFooter.h>
#import <TTBaseMacro.h>
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <UIScrollView+Refresh.h>

@interface FHHomeItemViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSInteger itemCount;

@end

@implementation FHHomeItemViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageTitleViewToTop) name:@"headerViewToTop" object:nil];
    
    [self.view addSubview:self.tableView];
    
    _itemCount = 30;
    
    WeakSelf;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        StrongSelf;
        if ([FHEnvContext isNetworkConnected]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.itemCount += 30;
                    [self.tableView reloadData];
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView finishPullUpWithSuccess:YES];
                });
            });
        }else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView finishPullUpWithSuccess:YES];
                });
            });
            [self.tableView.mj_footer endRefreshing];
            [[ToastManager manager] showToast:@"网络异常"];
        }
    }];
    
    self.tableView.mj_footer = self.refreshFooter;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pageTitleViewToTop {
    self.tableView.contentOffset = CGPointZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 滚动时发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FHHomeSubTableViewDidScroll" object:scrollView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell_2";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row];
    return cell;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}


@end

