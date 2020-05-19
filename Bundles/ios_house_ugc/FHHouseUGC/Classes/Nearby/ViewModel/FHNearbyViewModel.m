//
//  FHNearbyViewModel.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHNearbyViewModel.h"
#import "FHEnvContext.h"

@interface FHNearbyViewModel ()

@property(nonatomic, weak) FHNearbyViewController *viewController;

@end

@implementation FHNearbyViewModel

- (instancetype)initWithController:(FHNearbyViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        [self updateJoinProgressView];
        
        if(![FHEnvContext isNewDiscovery]){
            //防止第一次进入headview高度不对的问题
            __weak typeof(self) weakSelf = self;
            self.viewController.headerView.progressView.refreshViewBlk = ^{
                [weakSelf updateJoinProgressView];
            };
        }
    }
    
    return self;
}

// 更新发帖进度视图
- (void)updateJoinProgressView {
    CGRect frame = self.viewController.headerView.frame;
    [self.viewController.headerView.progressView updatePostData];
    frame.size.height = self.viewController.headerViewHeight + self.viewController.headerView.progressView.viewHeight;
    self.viewController.headerView.frame = frame;
    
    self.viewController.feedVC.tableHeaderView = self.viewController.headerView;
}

@end
