//
//  FHAccountBindingViewModel.h
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class FHAccountBindingViewController;

@interface FHAccountBindingViewModel : NSObject
- (instancetype)initWithTableView:(UITableView *)tableView ;


- (void)loadData;
@end

NS_ASSUME_NONNULL_END
