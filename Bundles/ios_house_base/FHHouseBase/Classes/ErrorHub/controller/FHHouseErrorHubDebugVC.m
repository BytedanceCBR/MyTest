//
//  FHHouseErrorHubDebugVC.m
//  FHHouseBase
//
//  Created by liuyu on 2020/4/16.
//

#import "FHHouseErrorHubDebugVC.h"
#import "FHErrorHubDataReadWrite.h"
#import "Masonry.h"
#import "UIDevice+BTDAdditions.h"
#import "FHHouseErrorHubManager.h"
#import "TTBaseMacro.h"
#import "ToastManager.h"

@interface FHHouseErrorHubDebugVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableDictionary *dataSource;
@property (nonatomic, strong) NSArray *keyArr;
@property (nonatomic, weak) UITableView *errorTab;
@property(nonatomic, strong) TTRouteParamObj *paramObj;
@end

@implementation FHHouseErrorHubDebugVC

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _paramObj = paramObj;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @{}.mutableCopy;
    [self initUI];
    [self.errorTab registerClass:[FHHouseErrorHubCell class] forCellReuseIdentifier:@"FHHouseErrorHubCell"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.dataSource[@"host_error"] = [FHErrorHubDataReadWrite getLocalErrorDataWithType:FHErrorHubTypeRequest];
        self.dataSource[@"buryingpoint_error"] = [FHErrorHubDataReadWrite getLocalErrorDataWithType:FHErrorHubTypeBuryingPoint];
        self.dataSource[@"custom_error"] = [FHErrorHubDataReadWrite getLocalErrorDataWithType:FHErrorHubTypeCustom];
        self.keyArr = @[@"host_error",@"buryingpoint_error",@"custom_error"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.errorTab reloadData];
        });
    });
    
}

- (void)initUI {
    [self.errorTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view).offset([UIDevice btd_isIPhoneXSeries]?84:64);
        //        make.bottom.equalTo(self.view).offset([UIDevice btd_isIPhoneXSeries]?-80:-64);
    }];
    [self setupDefaultNavBar:YES];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(becktToPop)];
    self.navigationItem.leftBarButtonItem = backItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"save 现场" style:UIBarButtonItemStylePlain target:self action:@selector(saveConfigAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UISwitch *switchs = [[UISwitch alloc]init];
    switchs.on = [self errorHubSwitch];
    [switchs addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = switchs;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds    设置响应时间
    lpgr.delegate = self;
    [self.errorTab addGestureRecognizer:lpgr];
    
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer  //长按响应函数
{
    if (gestureRecognizer.state  == UIGestureRecognizerStateEnded ) {
        CGPoint p = [gestureRecognizer locationInView:self.errorTab ];
        NSIndexPath *indexPath = [self.errorTab indexPathForRowAtPoint:p];//获取响应的长按的indexpath
        if (indexPath == nil){
        }else {
            [self shareErrorJsonIsRequest:indexPath.section == 0 index:indexPath];
        }
    }
}

- (void)shareErrorJsonIsRequest:(BOOL)isRquest index:(NSIndexPath *)indexPath {
    NSDictionary *shareDic = self.dataSource[self.keyArr[indexPath.section]][indexPath.row];
    [FHErrorHubDataReadWrite addLogWithData:shareDic logType:FHErrorHubTypeShare];
    NSString *path = [FHErrorHubDataReadWrite localDataPathWithType:FHErrorHubTypeShare];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSArray *items = [NSArray arrayWithObjects:url, nil];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToFacebook,
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage,
                                    UIActivityTypeMail,
                                    UIActivityTypePrint,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo];
    activityViewController.excludedActivityTypes = excludedActivities;
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)becktToPop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveConfigAction {
    [[FHHouseErrorHubManager sharedInstance] saveConfigAndSettings];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataArr = self.dataSource[self.keyArr[section]];
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[self.keyArr[indexPath.section]][indexPath.row];
    FHHouseErrorHubCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHHouseErrorHubCell"];
    cell.content = dic [@"name"];
    cell.errorMessage = dic[@"error_info"];
    cell.title = dic[@"currentTime"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.dataSource[self.keyArr[indexPath.section]][indexPath.row];
    NSString *copyString = @"";
    if (indexPath.section == 0) {
        copyString = [NSString stringWithFormat:@"接口名:%@ ,错误码:%@，logid:%@", dic [@"name"],dic[@"error_info"],dic[@"httpStatus"][@"x-tt-logid"]];
    }else {
        copyString = [NSString stringWithFormat:@"错误名:%@ ,错误信息:%@", dic [@"name"],dic[@"error_info"]];
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = copyString;
    [[ToastManager manager] showToast:@"已将信息复制到剪切板"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keyArr.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dic = self.dataSource[self.keyArr[indexPath.section]][indexPath.row];
        FHErrorHubType type;
        if (indexPath.section == 0) {
            type = FHErrorHubTypeRequest;
        }else if (indexPath.section == 1) {
            type = FHErrorHubTypeBuryingPoint;
        }else {
            type = FHErrorHubTypeCustom;
        }
        NSMutableArray *dataArr = [self.dataSource[self.keyArr[indexPath.section]] mutableCopy];
        [dataArr removeObject:dic];
        self.dataSource[self.keyArr[indexPath.section]] = dataArr;
        [self.errorTab reloadData];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [FHErrorHubDataReadWrite removeLogWithData:dic logType:type];
        });
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) wself = self;
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSDictionary *dic = self.dataSource[self.keyArr[indexPath.section]][indexPath.row];
        FHErrorHubType type;
        if (indexPath.section == 0) {
            type = FHErrorHubTypeRequest;
        }else if (indexPath.section == 1) {
            type = FHErrorHubTypeBuryingPoint;
        }else {
            type = FHErrorHubTypeCustom;
        }
        NSMutableArray *dataArr = [self.dataSource[self.keyArr[indexPath.section]] mutableCopy];
        [dataArr removeObject:dic];
        self.dataSource[self.keyArr[indexPath.section]] = dataArr;
        [self.errorTab reloadData];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [FHErrorHubDataReadWrite removeLogWithData:dic logType:type];
        });
    }];
    
    action.backgroundColor = [UIColor colorWithHexStr:@"ed5a65"];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[action]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];//创建一个视图
    headerView.backgroundColor = [UIColor colorWithHexStr:@"2d2e36"];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    headerLabel.textColor = [UIColor whiteColor];
    if (section == 0) {
        headerLabel.text = @"核心接口错误";
    }else if(section == 1) {
        headerLabel.text = @"核心埋点错误" ;
    }else {
        headerLabel.text = @"自定义错误" ;
    }
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableView *)errorTab {
    if (!_errorTab) {
        UITableView *errorTab = [[UITableView alloc]init];
        errorTab.dataSource = self;
        errorTab.delegate = self;
        errorTab.sectionIndexColor = [UIColor whiteColor];
        errorTab.sectionIndexBackgroundColor = [UIColor colorWithHexStr:@"c04851"];
        [self.view addSubview:errorTab];
        _errorTab = errorTab;
    }
    return  _errorTab;
}

- (void)switchAction:(UISwitch *)switchs {
    [[NSUserDefaults standardUserDefaults] setBool:switchs.on forKey:@"_errorHubSwitch"];
}

- (BOOL)errorHubSwitch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"_errorHubSwitch"];
}


@end

@interface FHHouseErrorHubCell ()
@property (weak, nonatomic) UILabel *titleLable;
@property (weak, nonatomic) UILabel *contentLabel;
@property (weak, nonatomic) UILabel *errorLabel;
@property (weak, nonatomic) UILabel *timeLab;

@end

@implementation FHHouseErrorHubCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(10);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.titleLable);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.titleLable.mas_bottom).offset(5);
    }];
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(5);
    }];
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        UILabel *titleLable = [[UILabel alloc]init];
        titleLable.font = [UIFont systemFontOfSize:12];
        titleLable.textColor = [UIColor blackColor];
        [self.contentView addSubview:titleLable];
        _titleLable = titleLable;
    }
    return _titleLable;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        UILabel *timeLab = [[UILabel alloc]init];
        timeLab.font = [UIFont systemFontOfSize:12];
        timeLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:timeLab];
        _timeLab = timeLab;
    }
    return _timeLab;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.font = [UIFont systemFontOfSize:12];
        contentLabel.textColor = [UIColor blackColor];
        contentLabel.numberOfLines = 0;
        [self.contentView addSubview:contentLabel];
        _contentLabel = contentLabel;
    }
    return _contentLabel;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        UILabel *errorLabel = [[UILabel alloc]init];
        errorLabel.font = [UIFont systemFontOfSize:12];
        errorLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:errorLabel];
        _errorLabel = errorLabel;
    }
    return _errorLabel;
}

- (void)setTitle:(NSString *)title {
    self.titleLable.text = title;
}

- (void)setContent:(NSString *)content {
    self.contentLabel.text = content;
}

- (void)setErrorMessage:(NSString *)errorMessage {
    if (isEmptyString(errorMessage)) {
        self.errorLabel.text = @"-1";
    }else {
        self.errorLabel.text = errorMessage;
    }
}

- (void)setCurrentTime:(NSString *)currentTime {
    self.timeLab.text = currentTime;
}
@end
