//
//  TTCertificationConditionViewController.m
//  Article
//
//  Created by wangdi on 2017/5/17.
//
//

#import "TTCertificationConditionViewController.h"
#import "SSThemed.h"
#import "TTCertificationConst.h"

@interface TTCertificationConditionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) SSThemedButton *questionButton;
@end

@implementation TTCertificationConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubview];
    [TTTrackerWrapper eventV3:@"certificate_pre_identity" params:nil];
}

- (void)questionButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCertificationPressQuestionsEntranceNotification object:nil];
}

- (SSThemedTableView *)tableView
{
    if(!_tableView) {
        CGFloat top = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
        _tableView = [[SSThemedTableView alloc] init];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
        _tableView.allowsSelection = YES;
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)setDataArray:(NSArray<TTCertificationConditionModel *> *)dataArray
{
    _dataArray = dataArray;
    [self.tableView reloadData];
}

- (void)setupSubview
{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.questionButton];
    TTCertificationConditionHeaderView *headerView = [[TTCertificationConditionHeaderView alloc] init];
    headerView.height = [TTDeviceUIUtils tt_newPadding:56];
    self.tableView.tableHeaderView = headerView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    TTCertificationConditionCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell) {
        cell = [[TTCertificationConditionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.model = self.dataArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTCertificationConditionModel *model = self.dataArray[indexPath.row];
    if([self.delegate respondsToSelector:@selector(didSelectedWithType:)]) {
        [self.delegate didSelectedWithType:model.type];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  [TTDeviceUIUtils tt_newPadding:76];
}

- (SSThemedButton *)questionButton {
    if (!_questionButton) {
        _questionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _questionButton.width = [TTDeviceUIUtils tt_newPadding:70];
        _questionButton.height = [TTDeviceUIUtils tt_newPadding:20];
        _questionButton.centerX = self.view.centerX;
        _questionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        _questionButton.bottom = self.view.bottom - [TTDeviceUIUtils tt_newPadding:10] - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
        _questionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
        [_questionButton setTitle:@"常见问题" forState:UIControlStateNormal];
        _questionButton.titleColorThemeKey = kColorText6;
        _questionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [_questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionButton;
}

@end
