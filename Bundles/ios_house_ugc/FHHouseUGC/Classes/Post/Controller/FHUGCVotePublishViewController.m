//
//  FHUGCVotePublishViewController.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import "FHUGCVotePublishViewController.h"
#import "FHUGCVoteViewModel.h"
#import "SSNavigationBar.h"
#import <WDDefines.h>
#import <FHCommonDefines.h>

@interface FHUGCVotePublishViewController()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FHUGCVoteViewModel *viewModel;

@end

@implementation FHUGCVotePublishViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 配置导航条
    [self configNavigation];
    // 添加tableView
    [self.view addSubview:self.tableView];
    // 初始化配置工作
    [self.viewModel reloadTableView];
}

- (void)configNavigation {
    [self setupDefaultNavBar:YES];
    // 标题
    [self setTitle:@"投票"];
    
    // 取消按钮
    TTNavigationBarItemContainerView *leftBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft withTitle:NSLocalizedString(@"取消", nil) target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:leftBarItem]];
    
    // 发布按钮
    TTNavigationBarItemContainerView *rightBarItem = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:NSLocalizedString(@"发布", nil) target:self action:@selector(publishAction:)];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:rightBarItem]];
}

- (void)cancelAction: (UIButton *)cancelBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publishAction: (UIButton *)publishBtn {
    // TODO: 发布内容
    [self.viewModel publish];
}

- (FHUGCVoteViewModel *)viewModel {
    if(!_viewModel) {
        _viewModel = [[FHUGCVoteViewModel alloc] initWithTableView:self.tableView ViewController:self];
    }
    return _viewModel;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, SCREEN_WIDTH, self.view.bounds.size.height - kNavigationBarHeight) style:UITableViewStyleGrouped];
        _tableView.bounces = NO;
    }
    return _tableView;
}

@end
                      
                      
