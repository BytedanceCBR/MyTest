//
// Created by zhulijun on 2019-07-17.
//

#import <Foundation/Foundation.h>
#import "FHCommunityList.h"
#import "FHUGCCommunityListViewController.h"

@class FHUGCCommunityListViewController;
@class FHUGCCommunityCategoryView;

@interface FHUGCCommunityListViewModel : NSObject
- (instancetype)initWithTableView:(UITableView *)tableView
                     categoryView:(FHUGCCommunityCategoryView *)categoryView
               districtTitleLabel:(UILabel *)districtTitleLabel
                       controller:(FHUGCCommunityListViewController *)viewController
                         listType:(FHCommunityListType)listType;

- (void)retryLoadData;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)viewDidAppear;

- (void)viewDidDisappear;

@end
