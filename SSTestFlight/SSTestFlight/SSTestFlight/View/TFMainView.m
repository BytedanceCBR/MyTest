//
//  TFMainView.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-27.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFMainView.h"
#import "TFRegistViewController.h"
#import "TFManager.h"
#import "SSTitleBarView.h"
#import "UIColorAdditions.h"
#import "TFAppInfosModel.h"
#import "TFFetchInfoManager.h"
#import "SSButton.h"
#import "TFAPPInfoCell.h"
#import "TFDetailViewController.h"

typedef enum EmptyViewType{
    EmptyViewTypeWaitVerify,
    EmptyViewTypeNoListData,
    EmptyViewTypeEmailUnMatch,
    EmptyViewTypeNoNetConnected,
    EmptyViewTypeServerError,
    EmptyViewTypeOtherError
    
}EmptyViewType;

@interface TFMainView()<UITableViewDataSource, UITableViewDelegate, TFAPPInfoCellDelegate>
@property(nonatomic, retain)SSTitleBarView * titleBar;
@property(nonatomic, retain)UIView * emptyView;
@property(nonatomic, retain)UILabel * emptyViewLabel;
@property(nonatomic, retain)UIButton * emptyRegistButton;
@property(nonatomic, retain)UITableView * listView;
@property(nonatomic, retain)NSMutableArray * appInfos;

@end

@implementation TFMainView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.emptyRegistButton = nil;
    self.appInfos = nil;
    self.titleBar = nil;
    self.listView = nil;
    self.emptyView = nil;
    self.emptyViewLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        self.appInfos = [NSMutableArray arrayWithCapacity:40];
        
        self.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        
        self.titleBar = [[[SSTitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [SSTitleBarView titleBarHeight])] autorelease];
        [self addSubview:_titleBar];
        [_titleBar setTitleText:@"ByteDance内测"];
        
        SSButton * refreshButton = [SSButton buttonWithSSButtonType:SSButtonTypeRefresh];
        [refreshButton addTarget:self action:@selector(refreshButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _titleBar.rightView = refreshButton;

        
        self.listView = [[[UITableView alloc] initWithFrame:[self frameForListView]] autorelease];
        _listView.backgroundColor = [UIColor clearColor];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.delegate = self;
        _listView.dataSource = self;
        [self addSubview:_listView];
        
        self.emptyView = [[[UIView alloc] initWithFrame:[self frameForListView]] autorelease];
        _emptyView.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        self.emptyViewLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _emptyViewLabel.numberOfLines = 1;
        _emptyViewLabel.frame = CGRectMake(0, 0, [self frameForListView].size.width, 100);
        _emptyViewLabel.textAlignment = UITextAlignmentCenter;
        [_emptyViewLabel setText:@"加载中..."];
        _emptyViewLabel.textColor = [UIColor colorWithHexString:@"666666"];
        _emptyViewLabel.backgroundColor = [UIColor clearColor];
        _emptyViewLabel.font = [UIFont systemFontOfSize:18.f];
        [_emptyView addSubview:_emptyViewLabel];
        _emptyViewLabel.center = CGPointMake(_emptyView.frame.size.width / 2.f, _emptyView.frame.size.height / 2.);
        
        self.emptyRegistButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyRegistButton.hidden = YES;
        _emptyRegistButton.backgroundColor = [UIColor redColor];
        [_emptyRegistButton setTitle:@"重新注册/登录" forState:UIControlStateNormal];
        [_emptyRegistButton sizeToFit];
        _emptyRegistButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
        [_emptyRegistButton addTarget:self action:@selector(registButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _emptyRegistButton.frame = CGRectMake((_emptyView.frame.size.width - _emptyRegistButton.frame.size.width) / 2.f, CGRectGetMaxY(_emptyViewLabel.frame) + 20, 120, 44);
        [_emptyView addSubview:_emptyRegistButton];
        [self addSubview:_emptyView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchDone:) name:kFetchInfoDoneNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFail:) name:kFetchInfoFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    if (!isEmptyString([TFManager testFlightAccountEmail]) && !isEmptyString([TFManager testFlightAccountIdentifier]) && [_appInfos count] > 0) {
        [self loadDataFromRemote];
    }
}

- (void)refreshButtonClicked
{
    [self fetchOrShowList];
}

- (void)registButtonClicked
{
    [self showRegistViewController];
}

- (void)fetchFail:(NSNotification *)notification
{
    NSLog(@"fail notification %@", notification);
    NSString * errorType = [[notification userInfo] objectForKey:kErrorType];
    if ([errorType isEqualToString:vWaitVerifyType]) {
        [self showEmptyView:EmptyViewTypeWaitVerify];
    }
    else if([errorType isEqualToString:vEmailUnmatch]) {
        [self showEmptyView:EmptyViewTypeEmailUnMatch];
    }
    else if([errorType isEqualToString:kNoNetConnectError]) {
        [self showEmptyView:EmptyViewTypeNoNetConnected];
    }
    else if ([errorType isEqualToString:kServerError]) {
        [self showEmptyView:EmptyViewTypeServerError];
    }
    else {
        [self showEmptyView:EmptyViewTypeOtherError];
    }
}

- (void)fetchDone:(NSNotification *)notification
{
    [self loadDataFromLocal];
    [self tableViewReLoad];
}

- (void)fetchOrShowList
{
    if (isEmptyString([TFManager testFlightAccountEmail]) || isEmptyString([TFManager testFlightAccountIdentifier])) {
        [self showRegistViewController];
    }
    else {
        [self loadDataFromLocal];
        [self tableViewReLoad];
        [self loadDataFromRemote];
    }

}

- (void)didAppear
{
    [super didAppear];
    [self fetchOrShowList];
}

- (void)willAppear
{
    [super willAppear];
//    [self tableViewReLoad];
}

- (void)tableViewReLoad
{
    [_listView reloadData];
    if ([_appInfos count] > 0) {
        [self hideEmptyView];
    }
//    else {
//        [self showEmptyView:EmptyViewTypeNoListData];
//    }
}

- (void)loadDataFromLocal
{
    NSArray * ary = [TFManager tfAppInfosModels];
    if ([ary count] > 0) {
        [_appInfos removeAllObjects];
        [_appInfos addObjectsFromArray:ary];
    }
}

- (void)loadDataFromRemote
{
    [[TFFetchInfoManager shareManager] startFetchInfos:[TFManager testFlightAccountEmail] identity:[TFManager testFlightAccountIdentifier] isRegister:NO];
}

#pragma mark -- frame

- (CGRect)frameForListView
{
    CGRect rect = CGRectMake(0, CGRectGetMaxY(_titleBar.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(_titleBar.frame));
    return rect;
}

#pragma mark -- delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_appInfos count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_appInfos count]) {
        return [TFAPPInfoCell heightForCellWithModel:[_appInfos objectAtIndex:indexPath.row] cellWidth:self.frame.size.width];
    }
    else {
        return 10;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * modelCellIndentifier = @"modelCellIndentifier";
    static NSString * modelCellErrorIndentifier = @"modelCellErrorIndentifier";
    if (indexPath.row < [_appInfos count]) {
        TFAPPInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:modelCellIndentifier];
        if (!cell) {
            cell = [[[TFAPPInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:modelCellIndentifier] autorelease];
            cell.delegate = self;
        }
        [cell setAppInfosModel:[_appInfos objectAtIndex:indexPath.row] modelIndex:indexPath.row];
        return cell;
    }
    else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:modelCellErrorIndentifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
        }
        return cell;
    }
}

#pragma mark -- private
- (void)showRegistViewController
{
    TFRegistViewController * registViewController = [[TFRegistViewController alloc] init];
    [[SSCommon topViewControllerFor:self].navigationController presentModalViewController:registViewController animated:YES];
    [registViewController release];
}

- (void)showMessage:(NSString *)msg
{
    
}

- (void)showEmptyView:(EmptyViewType)type
{
    _emptyRegistButton.hidden = NO;
    switch (type) {
        case EmptyViewTypeWaitVerify:
            _emptyViewLabel.text = @"账号等待审核中";
            _emptyRegistButton.hidden = YES;
            break;
        case EmptyViewTypeNoListData:
            _emptyViewLabel.text = @"暂无可安装应用";
            _emptyRegistButton.hidden = YES;
            break;
        case EmptyViewTypeEmailUnMatch:
            _emptyViewLabel.text = @"Email与设备不匹配, 请重试";
            break;
        case EmptyViewTypeNoNetConnected:
        {
            _emptyViewLabel.text = @"没有网络连接";
            _emptyRegistButton.hidden = YES;
        }
            break;
        case EmptyViewTypeServerError:
        {
            _emptyViewLabel.text = @"服务繁忙，请稍后重试";
            _emptyRegistButton.hidden = YES;
        }
            break;
        case EmptyViewTypeOtherError:
            _emptyViewLabel.text = @"请重新注册";
            break;
        default:
            _emptyRegistButton.hidden = YES;
            break;
    }
    _emptyView.hidden = NO;
}

- (void)hideEmptyView
{
    _emptyView.hidden = YES;
}

#pragma mark -- TFAPPInfoCellDelegate

- (void)tableViewCellDidSelectedBackgroundButton:(TFAPPInfoCell *)cell selectedModel:(TFAppInfosModel *)model selectedIndex:(NSUInteger)index
{
//    TFDetailViewController * controller = [[TFDetailViewController alloc] initWithTFAppInfosModel:model infoIndex:index];
//    UIViewController * navController = [SSCommon topViewControllerFor:self];
//    if ([navController isKindOfClass:[UINavigationController class]]) {
//        [((UINavigationController *)navController) pushViewController:controller animated:YES];
//    }
//    else {
//        [navController.navigationController pushViewController:controller animated:YES];
//    }
//    [controller release];
}

@end
