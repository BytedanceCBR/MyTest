//
//  TTBaseTableViewController.m
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "TTBaseTableViewController.h"



@interface TTBaseTableViewController ()
@property (nonatomic, strong, readwrite) SSThemedTableView *tableView;
@end

@implementation TTBaseTableViewController
- (instancetype)init {
    return [self initWithRouteParamObj:nil];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if ((self = [super initWithRouteParamObj:paramObj])) {
    }
    return self;
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat toleranceHeight = ([self tableViewStyle] == UITableViewStyleGrouped) ? 0.001 : 0;
    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds style:[self tableViewStyle]];
    self.tableView.backgroundColorThemeKey = kColorBackground3;
    self.tableView.scrollsToTop = YES;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 0, toleranceHeight)];
    self.tableView.tableFooterView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 0, toleranceHeight)];
    self.tableView.sectionHeaderHeight = 0.f;
    self.tableView.sectionFooterHeight = 0.f;
    self.tableView.estimatedSectionHeaderHeight = 0.f;
    self.tableView.estimatedSectionFooterHeight = 0.f;
    self.tableView.separatorStyle = [self tableViewSeparatorStyle];
    self.tableView.separatorColor = SSGetThemedColorWithKey(kColorLine1);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, [self.class insetLeftOfSeparator], 0, [self.class insetRightOfSeparator]);
    self.tableView.contentInset = [self tableViewOriginalContentInset];
    [self.view addSubview:self.tableView];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    [self.tableView setContentInset:[self tableViewOriginalContentInset]];
    [self.tableView setFrame:self.view.bounds];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.tableView setFrame:self.view.bounds];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];

    self.tableView.contentInset = [self tableViewOriginalContentInset];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.tableView.separatorColor = SSGetThemedColorWithKey(kColorLine1);
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *aView = [SSThemedView new];
    aView.backgroundColor = [UIColor clearColor];
    return aView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *aView = [SSThemedView new];
    aView.backgroundColor = [UIColor clearColor];
    return aView;
}

#pragma mark - public methods

- (void)reload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UIEdgeInsets)tableViewOriginalContentInset {
    return UIEdgeInsetsMake([self navigationBarHeight], 0, 0, 0);
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}

- (UITableViewCellSeparatorStyle)tableViewSeparatorStyle {
    return UITableViewCellSeparatorStyleNone;
}

#pragma mark - class methods

+ (CGFloat)insetLeftOfSeparator {
    return [TTDeviceUIUtils tt_padding:30.f/2];
}

+ (CGFloat)insetRightOfSeparator {
    return 0.f;
}
@end
