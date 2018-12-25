//
//  FHHomeListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/22.
//

#import "FHHomeListViewModel.h"
#import "FHHomeMainTableViewDataSource.h"
#import "FHHomeConfigManager.h"
#import "FHHomeSectionHeader.h"
#import "FHEnvContext.h"

@interface FHHomeListViewModel()

@property (nonatomic, strong) UITableView *tableViewV;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, strong) FHHomeMainTableViewDataSource *dataSource;

@property (nonatomic, strong) FHHomeViewController *homeViewController;

@property (nonatomic, strong) FHHomeSectionHeader *categoryView;

@end

@implementation FHHomeListViewModel

- (instancetype)initWithViewController:(UITableView *)tableView andViewController:(FHHomeViewController *)homeVC
{
    self = [super init];
    if (self) {
        self.categoryView = [FHHomeSectionHeader new];
        self.tableViewV = tableView;
        self.homeViewController = homeVC;
        self.dataSource = [FHHomeMainTableViewDataSource new];
        self.dataSource.categoryView = self.categoryView;
        self.dataSource.showPlaceHolder = YES;
        self.tableViewV.delegate = self.dataSource;
        self.tableViewV.dataSource = self.dataSource;

        self.tableViewV.hasMore = YES;
        
        // 下拉刷新，修改tabbar条和请求数据
        [self.tableViewV tt_addDefaultPullUpLoadMoreWithHandler:^{
            
        }];
        
        [self.tableViewV tt_addDefaultPullDownRefreshWithHandler:^{
            
        }];
    }
    return self;
}


- (void)reloadHomeListTable
{
//    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
//    if (!dataModel) {
//        dataModel = [[FHEnvContext sharedInstance] getConfigFromLocal];
//    }
    [self.tableViewV reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//    if (self.dataModel) {
//        self.dataSource.modelsArray = @[dataModel];
//    }
}


@end
