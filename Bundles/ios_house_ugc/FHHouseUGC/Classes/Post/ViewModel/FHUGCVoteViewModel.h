//
//  FHUGCVoteViewModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHUGCVotePublishViewController;
@interface FHUGCVoteViewModel : NSObject
- (instancetype)initWithTableView:(UITableView *)tableView ViewController:(FHUGCVotePublishViewController *)viewController;
- (void)publish;
- (void)reloadTableView;
- (BOOL)isEditedVote;
@end

NS_ASSUME_NONNULL_END
