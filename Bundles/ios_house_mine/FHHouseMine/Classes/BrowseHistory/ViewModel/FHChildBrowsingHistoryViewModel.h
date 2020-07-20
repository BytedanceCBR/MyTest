//
//  FHChildBrowsingHistoryViewModel.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import <Foundation/Foundation.h>
#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHChildBrowsingHistoryViewModel : NSObject

- (instancetype)initWithViewController:(FHChildBrowsingHistoryViewController *)viewController tableView:(UITableView *)tableView emptyView:(FHBrowsingHistoryEmptyView *)emptyView;

- (void)requestData:(BOOL)isHead;
- (void)updateEnterLog;
@property (nonatomic, assign) FHHouseType houseType;

@end

NS_ASSUME_NONNULL_END
