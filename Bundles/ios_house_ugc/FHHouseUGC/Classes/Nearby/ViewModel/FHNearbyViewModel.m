//
//  FHNearbyViewModel.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHNearbyViewModel.h"

@interface FHNearbyViewModel ()

@property(nonatomic, weak) FHNearbyViewController *viewController;

@end

@implementation FHNearbyViewModel

- (instancetype)initWithController:(FHNearbyViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;

        __weak typeof(self) weakSelf = self;
        self.viewController.headerView.progressView.refreshViewBlk = ^{
            [weakSelf updateJoinProgressView];
        };
    }
    
    return self;
}

// 更新发帖进度视图
- (void)updateJoinProgressView {
    CGRect frame = self.viewController.headerView.frame;
    frame.size.height = self.viewController.headerView.progressView.viewHeight;
    self.viewController.headerView.frame = frame;
    
    self.viewController.feedVC.tableHeaderView = self.viewController.headerView;
}

@end
