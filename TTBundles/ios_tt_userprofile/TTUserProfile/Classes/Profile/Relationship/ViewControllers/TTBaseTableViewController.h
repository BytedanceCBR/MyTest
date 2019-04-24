//
//  TTBaseTableViewController.h
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "SSThemed.h"
#import "TTBaseThemedViewController.h"


@interface TTBaseTableViewController : TTBaseThemedViewController
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong, readonly) SSThemedTableView *tableView;

/**
 *  重新刷新tableview
 */
- (void)reload;

- (UIEdgeInsets)tableViewOriginalContentInset;
- (UITableViewStyle)tableViewStyle; // default is UITableViewStylePlain
- (UITableViewCellSeparatorStyle)tableViewSeparatorStyle; // default is separatorStyle UITableViewCellSeparatorStyleSingleNone
+ (CGFloat)insetLeftOfSeparator;  // default is 15.f
+ (CGFloat)insetRightOfSeparator; // default is 0.f
@end
