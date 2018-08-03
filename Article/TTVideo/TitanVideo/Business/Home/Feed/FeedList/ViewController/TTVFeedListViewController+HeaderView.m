//
//  TTVFeedListViewController+HeaderView.m
//  Article
//
//  Created by panxiang on 2017/3/28.
//
//

#import "TTVFeedListViewController+HeaderView.h"
#import "TTVFeedListViewControllerPrivate.h"
#import "NewsListLogicManager.h"
#import "TTSubEntranceManager.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "NewsBaseDelegate.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTTopBar.h"
#import "TTDeviceHelper.h"
#import <objc/runtime.h>
#import "ExploreCellHelper.h"

@interface TTVFeedListViewController () <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIView * customListHeader;

@end

@implementation TTVFeedListViewController (HeaderView)

- (void)setListHeader:(UIView *)headerView
{
    self.customListHeader = headerView;
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = headerView;
}

- (void)setCustomListHeader:(UIView *)customListHeader {
    objc_setAssociatedObject(self, @selector(customListHeader), customListHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)customListHeader {
    return objc_getAssociatedObject(self, @selector(customListHeader));
}

- (BOOL)needShowCitySelectBar
{
    if ([self.categoryID isEqualToString:kTTNewsLocalCategoryID] &&
        [NewsListLogicManager needShowCitySelectionBar]) {
        return YES;
    }

    return NO;
}

- (BOOL)needShowSubEntranceBar
{
    NSArray *array = [TTSubEntranceManager subEntranceObjArrayForCategory:self.categoryID concernID:nil];
    if (array.count > 0) {
        return YES;
    }

    return NO;
}

- (BOOL)needShowPGCBar
{
    if (![TTDeviceHelper isPadDevice] && [self.categoryID isEqualToString:kTTVideoCategoryID]) {
        return YES;
    }
    return NO;
}

- (void)refreshHeaderView{
    self.customListHeader = nil;

    if ([self needShowSubEntranceBar]) {
        [self refreshSubEntranceBar];
        if (!self.view.window) {
            /// 如果还没有加到父view上，就设置下offset
            dispatch_async(dispatch_get_main_queue(), ^{
                self.tableView.contentOffset = CGPointMake(0, self.subEntranceBar.height - self.tableView.contentInset.top);
            });
        }
    }
    else {
        if (self.tableView.tableHeaderView != nil) {
            self.tableView.tableHeaderView = nil;
        }
    }
}

- (void)updateCustomTopOffset {

    if ([self needShowSubEntranceBar]) {
        self.tableView.customTopOffset = self.subEntranceBar.height;
    }
    else if ([self needShowPGCBar]) {
        //这里customTopOffset已经在pgcBar被设置为header的时候更新，只为了跳过最后的else，防止恢复为0
    }
    else {
        self.tableView.customTopOffset = 0;
    }
}

- (void)refreshSubEntranceBar
{
    if (!self.subEntranceBar) {
        self.subEntranceBar = [[TTSubEntranceBar alloc] initWithFrame:CGRectMake(0, self.ttContentInset.top, self.view.width, 30.f)];
    }
    NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:self.categoryID concernID:nil];
    [self.subEntranceBar refreshWithData:subEntranceObjArray];

    if (subEntranceObjArray.count > 0) {
        self.tableView.tableHeaderView = self.subEntranceBar;
    } else {
        if (nil != self.customListHeader) {
            self.tableView.tableFooterView = self.customListHeader;
        }else if (self.tableView.tableHeaderView != nil && self.tableView.tableHeaderView.frame.size.height > 1) {
            // Why is there extra padding at the top of my UITableView with style UITableViewStyleGrouped in iOS7 (http://stackoverflow.com/a/18938763/3811614)
            self.tableView.tableHeaderView = nil;//[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0.01f)];
        }
    }
}

#pragma mark - 停靠

- (void)dockHeaderViewBar
{
    CGFloat barH = self.tableView.tableHeaderView.height;
    if (barH > 1 && self.tableView.pullDownView.state == PULL_REFRESH_STATE_INIT) {
        CGFloat contentOffsetY = self.tableView.contentOffset.y;
        CGFloat topInset = self.tableView.contentInset.top;
        if (contentOffsetY < barH - topInset) {
            if (self.isHeaderViewBarVisible) {
                if (contentOffsetY < barH/3 - topInset) {
                    [self.tableView setContentOffset:CGPointMake(0, - self.tableView.contentInset.top) animated:YES];
                } else {
                    [self.tableView setContentOffset:CGPointMake(0, barH - self.tableView.contentInset.top) animated:YES];
                    self.isHeaderViewBarVisible = NO;
                }
            } else {
                if (contentOffsetY > barH*2/3 - topInset) {
                    [self.tableView setContentOffset:CGPointMake(0, barH - self.tableView.contentInset.top) animated:YES];
                } else {
                    [self.tableView setContentOffset:CGPointMake(0, - self.tableView.contentInset.top) animated:YES];
                    self.isHeaderViewBarVisible = YES;
                }
            }
        } else {
            self.isHeaderViewBarVisible = NO;
        }
    }
}

@end
