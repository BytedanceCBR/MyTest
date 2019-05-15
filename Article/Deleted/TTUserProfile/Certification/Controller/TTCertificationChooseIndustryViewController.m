//
//  TTCertificationChooseIndustryViewController.m
//  Article
//
//  Created by wangdi on 2017/5/19.
//
//

#import "TTCertificationChooseIndustryViewController.h"
#import "SSThemed.h"

@interface TTCertificationChooseIndustryHeaderView : SSThemedView

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *bottomLine;
@end

@implementation TTCertificationChooseIndustryHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine1;
    [self addSubview:bottomLine];
    self.bottomLine = bottomLine;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.width = self.width - self.titleLabel.left - [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
    self.titleLabel.top = (self.height - self.titleLabel.height) * 0.5;
    
    self.bottomLine.left = [TTDeviceUIUtils tt_newPadding:15];
    self.bottomLine.width = self.width;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
}

@end

@interface TTCertificationChooseIndustryCell : SSThemedTableViewCell

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation TTCertificationChooseIndustryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.textColorThemeKey = kColorText2;
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine1;
    [self.contentView addSubview:bottomLine];
    self.bottomLine = bottomLine;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.width = self.width - self.titleLabel.left - [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
    self.titleLabel.top = (self.height - self.titleLabel.height) * 0.5;
    
    self.bottomLine.left = [TTDeviceUIUtils tt_newPadding:15];
    self.bottomLine.width = self.width;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
}

@end

@interface TTCertificationChooseIndustryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SSThemedTableView *tableView;

@end

@implementation TTCertificationChooseIndustryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"选择行业";
    [self setupSubview];
    [self themedChange];
}

- (SSThemedTableView *)tableView
{
    if(!_tableView) {
        CGFloat top = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
        _tableView = [[SSThemedTableView alloc] init];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColorThemeKey = kColorBackground4;

    }
    return _tableView;
}

- (void)setupSubview
{
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TTGetCertificationDataIndustryResponseModel *industry = self.dataArray[section];
    return industry.content.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TTCertificationChooseIndustryHeaderView *headerView = [[TTCertificationChooseIndustryHeaderView alloc] init];
    TTGetCertificationDataIndustryResponseModel *industry = self.dataArray[section];
    headerView.titleLabel.text = industry.title;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [TTDeviceUIUtils tt_newPadding:47];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";

    TTCertificationChooseIndustryCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell) {
        cell = [[TTCertificationChooseIndustryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    TTGetCertificationDataIndustryResponseModel *industry = self.dataArray[indexPath.section];
    NSString *title = industry.content[indexPath.row];
    cell.titleLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TTDeviceUIUtils tt_newPadding:47];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTGetCertificationDataIndustryResponseModel *industry = self.dataArray[indexPath.section];
    NSString *title = industry.content[indexPath.row];
    if(self.chooseIndustryBlock) {
        self.chooseIndustryBlock(title);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    }
}

@end
