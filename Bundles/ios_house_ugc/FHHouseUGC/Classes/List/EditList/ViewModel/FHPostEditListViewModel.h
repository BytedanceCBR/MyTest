// FHPostEditListViewModel.h
//

#import <Foundation/Foundation.h>

@class TTHttpTask;
@class FHPostEditListController;


@interface FHPostEditListViewModel : NSObject

- (instancetype)initWithController:(FHPostEditListController *)viewController tableView:(UITableView *)tableView;

- (void)startLoadData;
- (void)loadMore;

@end
