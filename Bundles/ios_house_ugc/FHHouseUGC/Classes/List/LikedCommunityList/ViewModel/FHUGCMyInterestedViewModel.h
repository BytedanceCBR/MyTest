//
//  FHUGCMyInterestedViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/13.
//

#import <Foundation/Foundation.h>
#import "FHUGCMyInterestedController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCMyInterestedViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCMyInterestedController *)viewController;

- (void)requestData:(BOOL)isHead;

- (void)viewWillAppear;
- (void)viewWillDisappear;

@end

NS_ASSUME_NONNULL_END
