//
//  FHPostUGCProgressView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/20.
//

#import "FHPostUGCProgressView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTForumPostThreadStatusCell.h"
#import "TTForumPostThreadStatusViewModel.h"
#import "TTPostThreadCenter.h"

@interface FHPostUGCProgressView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign)   CGFloat       ugc_viewHeight;
// 存放当前发帖数据模型
@property (nonatomic, weak)     TTForumPostThreadStatusViewModel       *statusViewModel;
@property (nonatomic, strong)   UITableView       *tableView;

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
    // 取最新的一个
    NSLog(@"--------:1:%ld",self.statusViewModel.followTaskStatusModels.count);
    if (self.statusViewModel.followTaskStatusModels.count > 0) {
        TTPostThreadTaskStatusModel *statusModel = [self.statusViewModel.followTaskStatusModels lastObject];
        NSLog(@"-------:2:%ld",statusModel.status);
    }
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

@end


// FHPostUGCProgressCell

@interface FHPostUGCProgressCell ()

@end

@implementation FHPostUGCProgressCell

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[TTPostThreadTaskStatusModel class]]) {
        return;
    }
    self.currentData = data;
    
    TTPostThreadTaskStatusModel *model = self.currentData;
    if ([model isKindOfClass:[TTPostThreadTaskStatusModel class]]) {
//        self.titleLabel.text = model.socialGroupName;
//        self.descLabel.text = model.countText;
//        [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholder:nil];
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
    
}

@end
