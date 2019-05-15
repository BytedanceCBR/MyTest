//
//  ExploreMixedListBaseView+HeaderView.m
//  Article
//
//  Created by Chen Hong on 16/5/27.
//
//

#import "ExploreMixedListBaseView+HeaderView.h"
#import "NewsListLogicManager.h"
#import "TTCategoryDefine.h"
#import "TTSubEntranceManager.h"
#import "TTCategorySelectorView.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "ArticleCitySelectView.h"
#import "ArticleCityViewController.h"

#import "TTExploreMainViewController.h"
#import "NewsBaseDelegate.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTTopBar.h"
#import "TTDeviceHelper.h"
#import <objc/runtime.h>
#import "TTSubEntranceBar.h"

@interface ExploreMixedListBaseView () <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIView * customListHeader;

@end

@implementation ExploreMixedListBaseView (HeaderView)

- (void)setListHeader:(UIView *)headerView
{
    self.customListHeader = headerView;
    self.listView.tableHeaderView = nil;
    self.listView.tableHeaderView = headerView;
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
    // add by zjing 去掉bar以fix contentOffset
    return NO;

//    NSArray *array = [TTSubEntranceManager subEntranceObjArrayForCategory:self.categoryID concernID:self.concernID];
//    if (array.count > 0 && [TTSubEntranceManager subEntranceTypeForCategory:self.categoryID] == SubEntranceTypeHead && ![self.categoryID isEqualToString:@"__all__"]) {
//        return YES;
//    }
//    
//    return NO;
}

- (BOOL)needShowPGCBar
{
    if (![TTDeviceHelper isPadDevice] && [self.categoryID isEqualToString:kTTVideoCategoryID] && self.isInVideoTab) {
        return YES;
    }
    return NO;
}

- (void)updateCustomTopOffset {
    if ([self needShowSubEntranceBar]) {
        self.listView.customTopOffset = self.subEntranceBar.height;
    }
    else if ([self needShowCitySelectBar]) {
        
        if ([self tt_hasValidateData]) {
            self.listView.customTopOffset = self.citySelectView.height;
        }
        else
            self.listView.customTopOffset = 0;
    }
    else if ([self needShowPGCBar]) {
        //这里customTopOffset已经在pgcBar被设置为header的时候更新，只为了跳过最后的else，防止恢复为0
    }
    else {
        self.listView.customTopOffset = 0;
    }
}

- (void)refreshHeaderViewShowSearchBar:(BOOL) showSearchBar {
    self.customListHeader = nil;
    if ([self needShowCitySelectBar]) {
        if (!self.citySelectView) {
            self.citySelectView = [[ArticleCitySelectView alloc] initWithFrame:CGRectMake(0, self.ttContentInset.top, self.width, ArticleCitySelectViewHeight)];
            [self.citySelectView.citySelectButton addTarget:self action:@selector(citySelectViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        self.listView.tableHeaderView = self.citySelectView;
    }
    else if ([self needShowSubEntranceBar]) {
//        [self refreshSubEntranceBar];
//        if (!self.window || !showSearchBar) {
//            /// 如果还没有加到父view上，就设置下offset
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.listView.contentOffset = CGPointMake(0, self.subEntranceBar.height - self.listView.contentInset.top);
//            });
//        }
    }
    else {
        if (self.listView.tableHeaderView != nil) {
            
            self.listView.tableHeaderView = nil;
        }
    }
}

- (void)refreshSubEntranceBar
{
    if (!self.subEntranceBar) {
        self.subEntranceBar = [[TTSubEntranceBar alloc] initWithFrame:CGRectMake(0, self.ttContentInset.top, self.width, ArticleCitySelectViewHeight)];
    }
    NSArray *subEntranceObjArray = [TTSubEntranceManager subEntranceObjArrayForCategory:self.categoryID concernID:self.concernID];
    [self.subEntranceBar refreshWithData:subEntranceObjArray];
    
    if (subEntranceObjArray.count > 0 && [TTSubEntranceManager subEntranceTypeForCategory:self.categoryID] == SubEntranceTypeHead && ![self.categoryID isEqualToString:@"__all__"]) {
//        self.listView.tableHeaderView = self.subEntranceBar;
        self.listView.tableHeaderView = nil;
        self.listView.estimatedSectionHeaderHeight = 0;
    } else {
        if (nil != self.customListHeader) {
            self.listView.tableFooterView = self.customListHeader;
        }else if (self.listView.tableHeaderView != nil && self.listView.tableHeaderView.frame.size.height > 1) {
            // Why is there extra padding at the top of my UITableView with style UITableViewStyleGrouped in iOS7 (http://stackoverflow.com/a/18938763/3811614)
            self.listView.tableHeaderView = nil;//[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.listView.bounds.size.width, 0.01f)];
        }
    }
}

- (void)citySelectViewClicked:(id)sender
{
    wrapperTrackEvent(@"category_nav", @"select_city_enter");
    if ([TTDeviceHelper isPadDevice]) {
        ArticleCityViewController *controller = [[ArticleCityViewController alloc] init];
        self.padCitySelectPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
        self.padCitySelectPopover.popoverContentSize = CGSizeMake(320, 480);
        self.padCitySelectPopover.delegate = self;
        [self.padCitySelectPopover presentPopoverFromRect:CGRectMake(self.width/2, 20, 0, 0) inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else {
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor: self];
        ArticleCityViewController *controller = [[ArticleCityViewController alloc] init];
        [nav pushViewController:controller animated:YES];
    }
}

- (void)chooseCity:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *categoryID = userInfo[@"categoryID"];
    if (!isEmptyString(categoryID) && [categoryID isEqualToString:self.categoryID]) {
        [self citySelectViewClicked:nil];
    }
}

- (void)dismissCityPopoverAnimated:(BOOL)animated {
    if (self.padCitySelectPopover.isPopoverVisible) {
        [self.padCitySelectPopover dismissPopoverAnimated:animated];
        self.padCitySelectPopover = nil;
    }
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.padCitySelectPopover = nil;
}

#pragma mark - 停靠

- (void)dockHeaderViewBar
{
    CGFloat barH = self.listView.tableHeaderView.height;
    if (barH > 1 && self.listView.pullDownView.state == PULL_REFRESH_STATE_INIT) {
        CGFloat contentOffsetY = self.listView.contentOffset.y;
        CGFloat topInset = self.listView.contentInset.top;
        if (contentOffsetY < barH - topInset) {
            if (self.isHeaderViewBarVisible) {
                if (contentOffsetY < barH/3 - topInset) {
                    [self.listView setContentOffset:CGPointMake(0, - self.listView.contentInset.top) animated:YES];
                } else {
                    [self.listView setContentOffset:CGPointMake(0, barH - self.listView.contentInset.top) animated:YES];
                    self.isHeaderViewBarVisible = NO;
                }
            } else {
                if (contentOffsetY > barH*2/3 - topInset) {
                    [self.listView setContentOffset:CGPointMake(0, barH - self.listView.contentInset.top) animated:YES];
                } else {
                    [self.listView setContentOffset:CGPointMake(0, - self.listView.contentInset.top) animated:YES];
                    self.isHeaderViewBarVisible = YES;
                }
            }
        } else {
            self.isHeaderViewBarVisible = NO;
        }
    }
}

@end
