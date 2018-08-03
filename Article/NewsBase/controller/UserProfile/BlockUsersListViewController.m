//
//  BlockUsersListViewController.m
//  Article
//
//  Created by Huaqing Luo on 8/3/15.
//
//

#import "BlockUsersListViewController.h"
#import "SSNavigationBar.h"
#import "BlockUsersListView.h"

@interface BlockUsersListViewController ()

@property (nonatomic, strong) BlockUsersListView * contentView;

@end

@implementation BlockUsersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:@"黑名单"];
    
    self.contentView = [[BlockUsersListView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_contentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_contentView didAppear];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark -- Action

- (void)backButtonClicked:(id)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
