//
//  FHHomeMoreIconViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/12/2.
//

#import "FHHomeMoreIconViewController.h"
#import "TTRoute.h"
#import <FHBaseTableView.h>
#import <FHConfigModel.h>
#import "FHHomeCellHelper.h"
#import <FHHomeEntrancesCell.h>
#import "FHEnvContext.h"
#import "UIColor+Theme.h"
#import "UIViewController+Track.h"

@interface FHHomeMoreIconViewController ()<TTRouteInitializeProtocol,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView* contentTableView;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间

@end

@implementation FHHomeMoreIconViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj: paramObj];
    if (self) {
        self.contentTableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.ttTrackStayEnable = YES;
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
    self.contentTableView.scrollEnabled = NO;
    
    [self setupConstrains];
    
    [self.contentTableView registerClass:[FHHomeEntrancesCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeEntrancesCell class])];
    
    [self sendGoDetailTrace];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.contentTableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self sendStayPageTrace];
    [self tt_resetStayTime];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self sendStayPageTrace];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}


- (void)sendGoDetailTrace
{
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHConfigDataOpDataItemsModel> * opDataArray = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    NSMutableDictionary *paramsTrace = [NSMutableDictionary new];
    [paramsTrace setValue:@"maintab" forKey:@"enter_from"];
    [paramsTrace setValue:@"tools_box" forKey:@"page_type"];
    NSMutableString *opDataIdStr = [NSMutableString new];
    BOOL isFirst = YES;
    for (FHConfigDataOpDataItemsModel * model in opDataArray) {
        if (isFirst && model.id) {
            [opDataIdStr appendString:model.id];
        }else
        {
            if (model.id) {
                [opDataIdStr appendString:[NSString stringWithFormat:@"_%@",model.id]];
            }
        }
        isFirst = NO;
    }
    [paramsTrace setValue:opDataIdStr forKey:@"tools_name"];
    [FHEnvContext recordEvent:paramsTrace andEventKey:@"go_detail"];
}

- (void)sendStayPageTrace
{
    FHConfigDataModel *configData = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSArray<FHConfigDataOpDataItemsModel> * opDataArray = (NSArray<FHConfigDataOpDataItemsModel> *)configData.toolboxData.items;
    
    NSMutableDictionary *paramsTrace = [NSMutableDictionary new];
    [paramsTrace setValue:@"maintab" forKey:@"enter_from"];
    [paramsTrace setValue:@"tools_box" forKey:@"page_type"];
    
    NSMutableString *opDataIdStr = [NSMutableString new];
    BOOL isFirst = YES;
    for (FHConfigDataOpDataItemsModel * model in opDataArray) {
        if (isFirst && model.id) {
            [opDataIdStr appendString:model.id];
        }else
        {
            if (model.id) {
                [opDataIdStr appendString:[NSString stringWithFormat:@"_%@",model.id]];
            }
        }
        isFirst = NO;
    }
    [paramsTrace setValue:opDataIdStr forKey:@"tools_name"];
    
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    paramsTrace[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHEnvContext recordEvent:paramsTrace andEventKey:@"stay_page"];
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
    [FHHomeCellHelper fillFHHomeEntrancesCell:cell withModel:opData withTraceParams:@{@"enter_from":@"tools_box"}];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FHHomeEntrancesCell rowHeight] * 12;
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
