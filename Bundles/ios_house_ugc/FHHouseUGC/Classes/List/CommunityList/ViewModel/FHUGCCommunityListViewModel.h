//
// Created by zhulijun on 2019-07-17.
//

#import <Foundation/Foundation.h>
#import "FHCommunityList.h"
#import "FHUGCCommunityListViewController.h"

@class FHUGCCommunityListViewController;
@class FHUGCCommunityCategoryView;

@interface FHUGCCommunityListViewModel : NSObject
@property(nonatomic,copy) NSDictionary* tracerDict;
- (instancetype)initWithTableView:(UITableView *)tableView
                     categoryView:(FHUGCCommunityCategoryView *)categoryView
               districtTitleLabel:(UILabel *)districtTitleLabel
                       controller:(FHUGCCommunityListViewController *)viewController
                         listType:(FHCommunityListType)listType;

- (void)addEnterCategoryLog;

- (void)addStayCategoryLog:(NSTimeInterval)stayTime;

- (void)retryLoadData;

- (void)viewWillDidLoad;

@end
