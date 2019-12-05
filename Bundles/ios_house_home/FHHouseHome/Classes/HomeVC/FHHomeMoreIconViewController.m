//
//  FHHomeMoreIconViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/12/2.
//

#import "FHHomeMoreIconViewController.h"
#import <TTRoute.h>
#import <FHBaseTableView.h>
#import <FHConfigModel.h>
#import <FHHomeCellHelper.h>
#import <FHHomeEntrancesCell.h>
#import <FHEnvContext.h>
#import <UIColor+Theme.h>
@interface FHHomeMoreIconViewController ()<TTRouteInitializeProtocol,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView* contentTableView;
@end

@implementation FHHomeMoreIconViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj: paramObj];
    if (self) {
        self.contentTableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDefaultNavBar:NO];
    
    self.customNavBarView.title.text = @"工具箱";
    
    self.contentTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.contentTableView];
    [self.contentTableView setBackgroundColor:[UIColor themeGray8]];
    [self.view setBackgroundColor:[UIColor themeGray8]];

    
    [self setupConstrains];
    
    [self.contentTableView registerClass:[FHHomeEntrancesCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeEntrancesCell class])];
}

- (void)setupConstrains
{
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if(@available(iOS 11.0 , *)){
        safeInsets = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
    }
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        if (@available(iOS 11.0 , *)) {
            make.top.mas_equalTo(44.f + (safeInsets.top == 0 ? 20 : safeInsets.top));
        } else {
            make.top.mas_equalTo(65);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass([FHHomeEntrancesCell class]);
    FHHomeEntrancesCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHConfigDataOpDataModel *opData = [FHConfigDataOpDataModel new];
    opData.items = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    [cell.contentView setBackgroundColor:[UIColor themeGray8]];
    [FHHomeCellHelper fillFHHomeEntrancesCell:cell withModel:opData];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FHHomeEntrancesCell rowHeight];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
