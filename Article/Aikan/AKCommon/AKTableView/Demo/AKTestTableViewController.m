//
//  AKTestTableViewController.m
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "AKTestTableViewController.h"
#import "AKTableView.h"
#import "AKTribeFeedTableViewModel.h"

@interface AKTestTableViewController () <TTRouteInitializeProtocol>

@property (nonatomic, strong) AKTableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSArray<id> *> *serviceDatasourceArray;

@end

@implementation AKTestTableViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"test_ak_tb");
}

- (void)dealloc
{
    LOGD(@"-----[AKTestTableViewController] instance deallocated-----");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    return [super initWithRouteParamObj:paramObj];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *tableArray = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    AKTestTableViewCellModel *model0 = [[AKTestTableViewCellModel alloc] init];
    AKTestTableViewCellModel *model1 = [[AKTestTableViewCellModel alloc] init];
    AKTestTableViewCellModel *model2 = [[AKTestTableViewCellModel alloc] init];
    AKTestTableViewCellModel *model3 = [[AKTestTableViewCellModel alloc] init];
    [array addObject:model0];
    [array addObject:model1];
    [array addObject:model2];
    [array addObject:model3];
    [tableArray addObject:array];
    
    self.serviceDatasourceArray = tableArray;
    
    self.tableView = [[AKTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    // 设置viewModel
    self.tableView.tableViewModel = [AKTribeFeedTableViewModel instanceServeForTableView:self.tableView withDatasource:self.serviceDatasourceArray extra:nil];
    
    // 提供tableView代理实现
    [self.tableView.tableViewModel registerIMP];
    
    [self.view addSubview:self.tableView];
    
    // 通过刷新数据源reload ui
    WeakSelf;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *array = [NSMutableArray array];
        AKTestTableViewCellModel *model0 = [[AKTestTableViewCellModel alloc] init];
        AKTestTableViewCellModel *model1 = [[AKTestTableViewCellModel alloc] init];
        AKTestTableViewCellModel *model2 = [[AKTestTableViewCellModel alloc] init];
        AKTestTableViewCellModel *model3 = [[AKTestTableViewCellModel alloc] init];
        [array addObject:model0];
        [array addObject:model1];
        [array addObject:model2];
        [array addObject:model3];

        [self.serviceDatasourceArray replaceObjectAtIndex:0 withObject:array];
        
        [wself.tableView.tableViewModel updateDatasource:self.serviceDatasourceArray];

    });
}

@end
