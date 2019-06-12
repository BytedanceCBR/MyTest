//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>

@class FHCommunityDetailViewController;


@interface FHCommunityDetailViewModel : NSObject
- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController tableView:(UITableView *)tableView;

- (void)requestData;
@end