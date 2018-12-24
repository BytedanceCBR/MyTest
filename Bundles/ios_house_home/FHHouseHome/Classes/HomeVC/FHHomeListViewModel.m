//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeListViewModel.h"
#import "FHHomeMainTableViewDataSource.h"
#import "FHHomeConfigManager.h"

@interface FHHomeListViewModel()

@property (nonatomic, strong) UITableView *tableViewV;

@property (nonatomic, strong) FHHomeMainTableViewDataSource *dataSource;

@property (nonatomic, strong) FHHomeViewController *homeViewController;

@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC
{
    self = [super init];
    if (self) {
        self.tableViewV = tableView;
        self.homeViewController = homeVC;
        self.dataSource = [FHHomeMainTableViewDataSource new];

        self.tableViewV.delegate = self.dataSource;
        self.tableViewV.dataSource = self.dataSource;
    }
    return self;
}


- (void)reloadHomeListTable
{
    JSONModel *model = [FHHomeConfigManager sharedInstance].currentDataModel;
    if (model) {
        self.dataSource.modelsArray = @[model];
    }
    [self.tableViewV reloadData];
}


@end
