//
//  FHHouseErrorHubDebugVC.m
//  FHHouseBase
//
//  Created by liuyu on 2020/4/16.
//

#import "FHHouseErrorHubDebugVC.h"
#import "FHHouseErrorHubManager.h"
#import "Masonry.h"
#import "UIDevice+BTDAdditions.h"
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
    self.keyArr = @[@"host_error",@"buryingpoint_error",@"custom_error"];
    self.dataSource[@"host_error"] = [[FHHouseErrorHubManager sharedInstance] getLocalErrorDataWithType:FHErrorHubTypeRequest];
    self.dataSource[@"buryingpoint_error"] = [[FHHouseErrorHubManager sharedInstance] getLocalErrorDataWithType:FHErrorHubTypeBuryingPoint];
    self.dataSource[@"custom_error"] = [[FHHouseErrorHubManager sharedInstance] getLocalErrorDataWithType:FHErrorHubTypeCustom];
    [self.errorTab registerClass:[FHHouseErrorHubCell class] forCellReuseIdentifier:@"FHHouseErrorHubCell"];
    [self initUI];
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
    [[FHHouseErrorHubManager sharedInstance] addLogWithData:shareDic logType:FHErrorHubTypeShare];
    NSString *path = [[FHHouseErrorHubManager sharedInstance] localDataPathWithType:FHErrorHubTypeShare];
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
    if (indexPath.section == 0) {
        cell.title = @"核心接口错误" ;
    }else if(indexPath.section == 1) {
        cell.title = @"核心埋点错误" ;
    }else {
        cell.title = @"自定义错误" ;
    }
    cell.content = dic [@"name"];
    cell.errorMessage = dic[@"error_info"];
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
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.keyArr.count;
}

- (UITableView *)errorTab {
    if (!_errorTab) {
        UITableView *errorTab = [[UITableView alloc]init];
        errorTab.dataSource = self;
        errorTab.delegate = self;
        [self.view addSubview:errorTab];
        _errorTab = errorTab;
    }
    return  _errorTab;
}

@end

@interface FHHouseErrorHubCell ()
@property (weak, nonatomic) UILabel *titleLable;
@property (weak, nonatomic) UILabel *contentLabel;
@property (weak, nonatomic) UILabel *errorLabel;
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
        titleLable.font = [UIFont systemFontOfSize:18];
        titleLable.textColor = [UIColor blackColor];
        [self.contentView addSubview:titleLable];
        _titleLable = titleLable;
    }
    return _titleLable;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.font = [UIFont systemFontOfSize:15];
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
        errorLabel.font = [UIFont systemFontOfSize:15];
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
@end
