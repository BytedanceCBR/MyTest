//
//  FHPostUGCProgressView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/20.
//

#import "FHPostUGCProgressView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTForumPostThreadStatusCell.h"
#import "TTForumPostThreadStatusViewModel.h"
#import "TTPostThreadCenter.h"
#import "TTAccountManager.h"
#import "UIImageView+BDWebImage.h"
#import "TTThemedUploadingStatusCellProgressBar.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHUserTracker.h"

@interface FHPostUGCProgressView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign)   CGFloat       ugc_viewHeight;
// 存放当前发帖数据模型
@property (nonatomic, weak)     TTForumPostThreadStatusViewModel       *statusViewModel;
@property (nonatomic, strong)   UITableView       *tableView;

@property (nonatomic, strong)     NSMutableDictionary       *houseShowTracerDic;

@end

@implementation FHPostUGCProgressView

+ (instancetype)sharedInstance {
    static FHPostUGCProgressView *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[FHPostUGCProgressView alloc] initWithFrame:CGRectZero];
    }
    return _sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.houseShowTracerDic = [NSMutableDictionary new];
        [self setupData];
        [self setupUI];
        __weak typeof(self) weakSelf = self;
        self.statusViewModel.statusChangeBlk = ^{
            [weakSelf updateStatus];
        };
        [self updateStatus];
    }
    return self;
}

- (CGFloat)viewHeight {
    return _ugc_viewHeight;
}

- (void)setupData {
    self.statusViewModel = [TTForumPostThreadStatusViewModel sharedInstance_tt];
    if (self.statusViewModel.followTaskStatusModels.count > 0) {
        _ugc_viewHeight = 40 * self.statusViewModel.followTaskStatusModels.count;
    } else {
        _ugc_viewHeight = 0;
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.ugc_viewHeight);
}

- (void)updatePostData {
    [self setupData];
    self.hidden = _ugc_viewHeight <= 0;
    if (_ugc_viewHeight > 0) {
        [self.tableView reloadData];
    }
}

- (void)setupUI {
    [self configTableView];
    [self addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    [_tableView registerClass:[FHPostUGCProgressCell class] forCellReuseIdentifier:@"FHPostUGCProgressCell"];
    _tableView.frame = self.frame;
}

- (void)updateStatus {
    if (self.statusViewModel.followTaskStatusModels.count > 0) {
        _ugc_viewHeight = 40 * self.statusViewModel.followTaskStatusModels.count;
    } else {
        _ugc_viewHeight = 0;
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.ugc_viewHeight);
    self.tableView.frame = self.frame;
    if (self.refreshViewBlk) {
        self.refreshViewBlk();
    }
    [self.tableView reloadData];
}

// 删除发送失败的任务
//- (void)deleteErrorTasks {
//    if (self.statusViewModel.followTaskStatusModels.count > 0) {
//        TTPostThreadTaskStatusModel *statusModel = [self.statusViewModel.followTaskStatusModels firstObject];
//        if (statusModel.status == TTPostTaskStatusFailed) {
//            [[TTPostThreadCenter sharedInstance_tt] removeTaskForFakeThreadID:statusModel.fakeThreadId concernID:statusModel.concernID];
//        }
//    }
//}

// tableView
- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 40;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statusViewModel.followTaskStatusModels.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHPostUGCProgressCell *cell = (FHPostUGCProgressCell *)[tableView dequeueReusableCellWithIdentifier:@"FHPostUGCProgressCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.statusViewModel.followTaskStatusModels.count) {
        id data = self.statusViewModel.followTaskStatusModels[row];
        [cell refreshWithData:data];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.statusViewModel.followTaskStatusModels.count) {
        TTPostThreadTaskStatusModel* cellModel = self.statusViewModel.followTaskStatusModels[indexPath.row];
        NSString *recordKey = [NSString stringWithFormat:@"%lld",cellModel.fakeThreadId];
        if (recordKey.length > 0) {
            if (!self.houseShowTracerDic[recordKey]) {
                // 埋点
                self.houseShowTracerDic[recordKey] = @(YES);
                [self addHouseShowLog:indexPath];
            }
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
}

#pragma mark - Tracer

-(void)addHouseShowLog:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.statusViewModel.followTaskStatusModels.count) {
        return;
    }
    TTPostThreadTaskStatusModel* cellModel = self.statusViewModel.followTaskStatusModels[indexPath.row];
    
    if (!cellModel) {
        return;
    }
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_type"] = @"publish_failed_toast";
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"card_type"] = @"left";
    
    [FHUserTracker writeEvent:@"element_show" params:tracerDict];
}

@end


// FHPostUGCProgressCell

@interface FHPostUGCProgressCell ()

@property (nonatomic, strong)   UIImageView       *iconView;
@property (nonatomic, strong)   UILabel       *stateLabel;
@property (nonatomic, strong)   UIButton       *retryBtn;
@property (nonatomic, strong)   UIButton       *delBtn;
@property (nonatomic, strong)   TTThemedUploadingStatusCellProgressBar       *progressBar;
@property (nonatomic, copy) TTPostThreadTaskProgressBlock progressBlock;
@property (nonatomic, weak)     TTPostThreadTaskStatusModel       *statusModel;

@end

@implementation FHPostUGCProgressCell

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[TTPostThreadTaskStatusModel class]]) {
        return;
    }
    self.currentData = data;
    self.statusModel = data;
    
    TTPostThreadTaskStatusModel *model = self.currentData;
    if ([model isKindOfClass:[TTPostThreadTaskStatusModel class]]) {
        if (self.progressBlock) {
            [_statusModel removeProgressBlock:self.progressBlock];
        }
        
        WeakSelf;
        self.progressBlock = ^(CGFloat progress){
            StrongSelf;
            [self.progressBar setProgress:progress animated:YES];
        };
        [_statusModel addProgressBlock:self.progressBlock];
        
        [self.progressBar setProgress:_statusModel.uploadingProgress animated:NO];
        
        if (self.statusModel.status == TTPostTaskStatusFailed) {
            self.stateLabel.text = @"发布失败";
            [self.progressBar setForegroundColorThemeKey:@"grey4"];
            self.retryBtn.hidden = NO;
            self.delBtn.hidden = NO;
        } else {
            self.stateLabel.text = @"正在发布...";
            [self.progressBar setForegroundColorThemeKey:@"red1"];
            self.retryBtn.hidden = YES;
            self.delBtn.hidden = YES;
        }
    }
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.iconView = [[UIImageView alloc] init];
    _iconView.layer.cornerRadius = 14;
    _iconView.clipsToBounds = YES;
    NSString *avatarUrl = [TTAccountManager avatarURLString];
    [_iconView bd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    [self.contentView addSubview:_iconView];
    
    self.stateLabel = [self labelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    self.stateLabel.text = @"正在发布...";
    [self.contentView addSubview:_stateLabel];
    
    self.retryBtn = [[UIButton alloc] init];
    [_retryBtn setImage:[UIImage imageNamed:@"fh_ugc_refresh_normal"] forState:UIControlStateNormal];
    [_retryBtn addTarget:self action:@selector(retryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_retryBtn];
    
    self.delBtn = [[UIButton alloc] init];
    [_delBtn setImage:[UIImage imageNamed:@"fh_ugc_close_normal"] forState:UIControlStateNormal];
    [_delBtn addTarget:self action:@selector(delBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_delBtn];
    
    self.progressBar = [[TTThemedUploadingStatusCellProgressBar alloc] initWithFrame:CGRectMake(0, 39, [UIScreen mainScreen].bounds.size.width, 1)];
    [self.progressBar setForegroundColorThemeKey:@"red1"];
    [self.contentView addSubview:self.progressBar];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(28);
        make.centerY.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).offset(6);
        make.bottom.mas_equalTo(self.contentView).offset(-6);
    }];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.iconView.mas_right).offset(8);
        make.right.mas_equalTo(self.retryBtn.mas_left).offset(5);
        make.height.mas_equalTo(22);
    }];
    [self.delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.delBtn.mas_left).offset(-15);
        make.width.height.mas_equalTo(24);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

// event
- (void)retryBtnClick {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"element_from"] = @"publish_failed_toast";
    tracerDict[@"page_type"] = @"my_join_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"card_type"] = @"left";
    tracerDict[@"click_position"] = @"try_again_publish";
    
    [FHUserTracker writeEvent:@"feed_publish_try_again" params:tracerDict];
    // 无网络判断
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
     [[TTPostThreadCenter sharedInstance_tt] resentThreadForFakeThreadID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
}

- (void)delBtnClick {
    if (self.statusModel) {
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[@"element_from"] = @"publish_failed_toast";
        tracerDict[@"page_type"] = @"my_join_list";
        tracerDict[@"enter_from"] = @"neighborhood_tab";
        tracerDict[@"card_type"] = @"left";
        tracerDict[@"click_position"] = @"delete_publish";
        
        [FHUserTracker writeEvent:@"feed_publish_delete" params:tracerDict];
        
        [[TTPostThreadCenter sharedInstance_tt] removeTaskForFakeThreadID:self.statusModel.fakeThreadId concernID:self.statusModel.concernID];
    }
}

@end
