//
//  FHHomeViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHHomeViewController.h"
#import "FHHomeListViewModel.h"
#import "ArticleListNotifyBarView.h"
#import "FHEnvContext.h"
#import "FHHomeCellHelper.h"
#import "FHHomeConfigManager.h"
#import "TTBaseMacro.h"

static CGFloat const kShowTipViewHeight = 32;

static CGFloat const kSectionHeaderHeight = 38;




@interface FHHomeViewController ()

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) FHHomeListViewModel *homeListViewModel;

@property (nonatomic, assign) BOOL isClickTab;

@property (nonatomic, assign) ArticleListNotifyBarView * notifyBar;

@end

@implementation FHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if (@available(iOS 7.0, *)) {
        self.mainTableView.estimatedSectionFooterHeight = 0;
        self.mainTableView.estimatedSectionHeaderHeight = 0;
        self.mainTableView.estimatedRowHeight = 0;
    } else {
        // Fallback on earlier versions
    }

    self.mainTableView.sectionFooterHeight = 0;
    self.mainTableView.sectionHeaderHeight = 0;
    self.mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 0.1)]; //to do:设置header0.1，防止系统自动设置高度
    self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 0.1)]; //to do:设置header0.1，防止系统自动设置高度

    [self.view addSubview:self.mainTableView];

    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [FHHomeCellHelper registerCells:self.mainTableView];
    
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];

    WeakSelf;
    [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
     StrongSelf;
        //过滤多余刷新
      if (configDataModel == [[FHEnvContext sharedInstance] getConfigFromCache]) {
         return ;
      }
      [self reloadFHHomeHeaderCell];
    }];
    
    self.homeListViewModel = [[FHHomeListViewModel alloc] initWithViewController:self.mainTableView andViewController:self];
    
    // Do any additional setup after loading the view.
}

- (void)willAppear
{
    NSLog(@"is connectd = %d",[FHEnvContext isNetworkConnected]);
}

- (void)didAppear
{
    
}

- (void)willDisappear
{
    
}

- (void)didDisappear
{
    
}

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom
{
//    self.ttContentInset = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
//    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
//    tableView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
}

- (void)pullAndRefresh
{
    
}


- (void)reloadFHHomeHeaderCell
{
    [self.homeListViewModel reloadHomeListTable];
}

- (BOOL)tt_hasValidateData
{
    return YES;
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
