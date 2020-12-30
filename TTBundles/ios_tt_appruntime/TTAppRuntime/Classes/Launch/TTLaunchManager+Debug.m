//
//  TTLaunchManager+Debug.m
//  TTAppRuntime
//
//  Created by wangzhizhou on 2020/12/1.
//
#if INHOUSE

#import "TTLaunchManager+Debug.h"
#import <ByteDanceKit.h>
#import <ReactiveObjC.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@implementation TTLaunchTaskInfo
@end

@implementation TTLaunchTaskDebugInfo
@end

@implementation TTLaunchManager(Debug)
- (NSArray<TTLaunchTaskDebugInfo *> *)launchTasksDebugInfo {
    return [[self.lauchGroupsDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *  _Nonnull key1, NSNumber *  _Nonnull key2) {
        if(key1.integerValue < key2.integerValue) {
            return NSOrderedAscending;
        } else if (key1.integerValue == key2.integerValue) {
            return NSOrderedSame;
        } else {
            return  NSOrderedDescending;
        }
    }] btd_map:^id _Nullable(NSNumber *  _Nonnull key) {
        TTLaunchTaskDebugInfo *launchTaskInfo = [TTLaunchTaskDebugInfo new];
        launchTaskInfo.taskType = (FHTaskType)(key.integerValue);
        launchTaskInfo.taskTypeName = [self taskTypeToString:launchTaskInfo.taskType];
        id tasks = self.lauchGroupsDict[key];
        if([tasks isKindOfClass:NSArray.class]) {
            launchTaskInfo.priorityTasks = [tasks btd_compactMap:^TTLaunchTaskInfo * _Nullable(NSValue * _Nonnull taskValue) {
                task_header_info taskHeaderInfo;
                [taskValue getValue:&taskHeaderInfo];
                NSString *taskName = [NSString stringWithCString:taskHeaderInfo.name encoding:NSUTF8StringEncoding];
                Class taskClass = NSClassFromString(taskName);
                if (![taskClass isSubclassOfClass:[TTStartupTask class]]) {
                    return nil;
                }
                TTStartupTask *taskInstance = [[taskClass alloc] init];
                
                TTLaunchTaskInfo *taskInfo = [TTLaunchTaskInfo new];
                taskInfo.name = taskName;
                taskInfo.type = taskHeaderInfo.type;
                taskInfo.priority = taskHeaderInfo.priority;
                taskInfo.taskInstance = taskInstance;
                
                return taskInfo;
            }];
        }
        return  launchTaskInfo;
    }];
}
@end

#pragma mark - 调试信息UI页面展示


@interface TTLaunchManagerDebugInfoCell : UITableViewCell
+ (NSString *)reuseIdentifier;
- (void)configWithTaskInfo:(TTLaunchTaskInfo *)task;
@end

@interface TTLaunchManagerDebugInfoCell()
@property (nonatomic, strong) UILabel *taskNameLabel;
@end

@implementation TTLaunchManagerDebugInfoCell
- (UILabel *)taskNameLabel {
    if(!_taskNameLabel) {
        _taskNameLabel = [UILabel new];
        _taskNameLabel.font = [UIFont themeFontRegular:14];
        _taskNameLabel.textColor = [UIColor themeGray1];
        _taskNameLabel.numberOfLines = 0;
    }
    return _taskNameLabel;
}
+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.taskNameLabel];
        [self.taskNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}
- (void)configWithTaskInfo:(TTLaunchTaskInfo *)taskInfo {
    NSString *des = [NSString stringWithFormat:@"%@ 优先级: %@",
                               taskInfo.name, @(taskInfo.priority)];
    
    if(taskInfo.taskInstance.isConcurrent) {
        des = [des stringByAppendingString:@" 并发"];
    }
    if(taskInfo.taskInstance.isResident) {
        des = [des stringByAppendingString:@" 常驻"];
    }
    if(taskInfo.taskInstance.isNormal) {
        des = [des stringByAppendingString:@" 正常"];
    }
    
    self.taskNameLabel.text = des;
}
@end
@interface TTLaunchManagerDebugInfoViewController()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray<TTLaunchTaskDebugInfo *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation TTLaunchManagerDebugInfoViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super init]) {
        // 初始化参数区
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"启动任务实例初始化顺序";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:TTLaunchManagerDebugInfoCell.class forCellReuseIdentifier:[TTLaunchManagerDebugInfoCell reuseIdentifier]];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
    }];
    
    self.dataSource = [[TTLaunchManager sharedInstance] launchTasksDebugInfo];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TTLaunchTaskDebugInfo *taskGroup = self.dataSource[section];
    return taskGroup.priorityTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTLaunchManagerDebugInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[TTLaunchManagerDebugInfoCell reuseIdentifier] forIndexPath:indexPath];
    TTLaunchTaskInfo *taskInfo = self.dataSource[indexPath.section].priorityTasks[indexPath.row];
    [cell configWithTaskInfo:taskInfo];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    TTLaunchTaskDebugInfo *taskGroup = self.dataSource[section];
    return [taskGroup.taskTypeName stringByAppendingFormat:@"(枚举值: %@)", @(taskGroup.taskType)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end

#endif
