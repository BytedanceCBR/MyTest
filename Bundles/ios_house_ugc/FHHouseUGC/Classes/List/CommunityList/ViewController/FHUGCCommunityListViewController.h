//
// Created by zhulijun on 2019-07-17.
//

#import "FHBaseViewController.h"
#import "FHUGCCommunityDistrictTabCell.h"
#import "FHCommunityList.h"

@class FHUGCScialGroupDataModel;

@protocol FHUGCCommunityChooseDelegate <NSObject>

@optional
- (void)selectedItem:(FHUGCScialGroupDataModel *)item;

@end

@interface FHUGCCommunityListViewController : FHBaseViewController
@property(nonatomic, strong) FHErrorView *errorView;
@property(nonatomic, assign) FHUGCCommunityDistrictId defaultSelectDistrictTab;

- (void)onItemSelected:(FHUGCScialGroupDataModel *)item indexPath:(NSIndexPath *)indexPath;
@end
