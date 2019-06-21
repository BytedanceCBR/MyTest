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

@interface FHPostUGCProgressView ()

@property (nonatomic, assign)   CGFloat       ugc_viewHeight;
// 存放当前发帖数据模型
@property (nonatomic, weak)     TTForumPostThreadStatusViewModel       *statusViewModel;

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
        _ugc_viewHeight = 40;
    } else {
        _ugc_viewHeight = 0;
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.ugc_viewHeight);
}

- (void)setupUI {
    
}

- (void)updateStatus {
    if (self.statusViewModel.followTaskStatusModels.count > 0) {
        _ugc_viewHeight = 40;
    } else {
        _ugc_viewHeight = 0;
    }
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.ugc_viewHeight);
    // 取最新的一个
    NSLog(@"--------:1:%ld",self.statusViewModel.followTaskStatusModels.count);
    if (self.statusViewModel.followTaskStatusModels.count > 0) {
        TTPostThreadTaskStatusModel *statusModel = [self.statusViewModel.followTaskStatusModels lastObject];
        NSLog(@"-------:2:%ld",statusModel.status);
    }
}

// 删除发送失败的任务，删除一个后会持续 调用 updateStatus
- (void)deleteErrorTasks {
    if (self.statusViewModel.followTaskStatusModels.count > 0) {
        TTPostThreadTaskStatusModel *statusModel = [self.statusViewModel.followTaskStatusModels firstObject];
        if (statusModel.status == TTPostTaskStatusFailed) {
            [[TTPostThreadCenter sharedInstance_tt] removeTaskForFakeThreadID:statusModel.fakeThreadId concernID:statusModel.concernID];
        }
    }
}

- (void)dealloc
{
    
}

@end
