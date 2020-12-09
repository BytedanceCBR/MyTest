//
//  FHPersonalHomePageManager.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageManager.h"
#import "FHCommonDefines.h"
#import "UIViewAdditions.h"


@interface FHPersonalHomePageManager ()
@property(nonatomic,weak) FHPersonalHomePageProfileInfoView *profileInfoView;
@property(nonatomic,weak) UIScrollView *scrollView;
@property(nonatomic,weak) FHNavBarView *navBar;
@property(nonatomic,assign) BOOL scrollViewScrollEnable;
@property(nonatomic,assign) BOOL tableViewScrollEnable;
@property(nonatomic,weak) FHPersonalHomePageTabListModel *tabListModel;
@property(nonatomic,assign) BOOL isFeedError;
@end

@implementation FHPersonalHomePageManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static FHPersonalHomePageManager *defaultManager;
    dispatch_once(&onceToken, ^{
        defaultManager = [[FHPersonalHomePageManager alloc] init];
        defaultManager.feedListVCArray = [NSMutableArray array];
    });
    return defaultManager;
}

-(void)reset {
    self.userId = @"";
    self.isFeedError = NO;
    self.scrollViewScrollEnable = YES;
    self.tableViewScrollEnable = NO;
    self.viewController = nil;
    self.feedViewController = nil;
    self.tabListModel = nil;
    self.feedErrorArray = nil;
}

-(void)updateProfileInfoWithMdoel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel tabListWithMdoel:(FHPersonalHomePageTabListModel *)tabListModel {
    self.tabListModel = tabListModel;
    
    [self.profileInfoView updateWithModel:profileInfoModel isVerifyShow:[tabListModel.data.isVerifyShow boolValue]];
    CGFloat profileInfoViewHeight = [self.profileInfoView viewHeight];
    self.profileInfoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, profileInfoViewHeight);
    
    CGFloat feedViewControllerHeight = SCREEN_HEIGHT - self.navBar.height;
    self.feedViewController.view.frame = CGRectMake(0, profileInfoViewHeight, SCREEN_WIDTH, feedViewControllerHeight);
    
    [self initFeedStatus:tabListModel.data.tabList.count];
    
    [self.feedViewController updateWithHeaderViewMdoel:tabListModel];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, profileInfoViewHeight + feedViewControllerHeight);
}


- (void)initFeedStatus:(NSInteger)count {
    NSMutableArray *feedErrorArray = [NSMutableArray array];
    for(NSInteger i = 0;i < count;i++) {
        [feedErrorArray addObject:@(YES)];
    }
    self.feedErrorArray = feedErrorArray;
}

-(void)scrollViewScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat tabListOffset = [self tabListOffset];
    CGFloat backViewOffset = 120 - self.navBar.height;
    

    if(offset > tabListOffset) {
        scrollView.contentOffset = CGPointMake(0, tabListOffset);
        self.scrollViewScrollEnable = self.isFeedError;
        self.tableViewScrollEnable = !self.isFeedError;
    } else if(!self.scrollViewScrollEnable) {
        scrollView.contentOffset = CGPointMake(0, tabListOffset);
    }
    
    offset = self.scrollView.contentOffset.y;
    if(offset < 0) {
        CGFloat shadowViewHeight = 160;
        self.profileInfoView.shadowView.transform = CGAffineTransformMakeScale(1 + offset/(-shadowViewHeight), 1 + offset/(-shadowViewHeight));
        CGRect frame = self.profileInfoView.shadowView.frame;
        frame.origin.y = offset;
        self.profileInfoView.shadowView.frame = frame;
    }
    
    if(offset < 0) {
        self.navBar.bgView.alpha = 0;
        self.navBar.title.alpha = 0;
    } else if(offset <= backViewOffset) {
        self.navBar.bgView.alpha = offset / backViewOffset;
        self.navBar.title.alpha = offset / backViewOffset;
    } else {
        self.navBar.bgView.alpha = 1;
        self.navBar.title.alpha = 1;
    }
}

-(void)tableViewScroll:(UIScrollView *)scrollView {
    if(!self.tableViewScrollEnable) {
        scrollView.contentOffset = CGPointZero;
    }
    CGFloat offset = scrollView.contentOffset.y;
    if(offset < 0){
        scrollView.contentOffset = CGPointZero;
        [self scrollsToTop];
    }
}

-(CGFloat)tabListOffset {
    return self.profileInfoView.viewHeight - self.navBar.height;
}

-(FHNavBarView *)navBar {
    return self.viewController.customNavBarView;
}

-(FHPersonalHomePageProfileInfoView *)profileInfoView {
    return self.viewController.profileInfoView;
}

-(UIScrollView *)scrollView {
    return self.viewController.scrollView;
}

-(BOOL)isFeedError {
    if(self.currentIndex >= 0 && self.currentIndex < self.feedErrorArray.count) {
        NSNumber *isError = self.feedErrorArray[self.currentIndex];
        return [isError boolValue];
    }
    return YES;
}

-(void)scrollsToTop {
    self.scrollViewScrollEnable = YES;
    self.tableViewScrollEnable = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        for(FHPersonalHomePageFeedListViewController *feedVC in self.feedListVCArray) {
            [feedVC.tableView setContentOffset:CGPointZero animated:NO];
        }
    });
}

@end
