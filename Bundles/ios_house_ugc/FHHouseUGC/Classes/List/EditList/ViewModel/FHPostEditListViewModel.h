// FHPostEditListViewModel.h
//

#import <Foundation/Foundation.h>

@class TTHttpTask;
@class FHPostEditListController;


@interface FHPostEditListViewModel : NSObject

@property (nonatomic, assign) int64_t tid; //帖子ID--必须
- (instancetype)initWithController:(FHPostEditListController *)viewController tableView:(UITableView *)tableView;

- (void)startLoadData;
- (void)loadMore;

@end
