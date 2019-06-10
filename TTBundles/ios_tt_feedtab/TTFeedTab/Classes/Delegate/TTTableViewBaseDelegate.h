//
//  TTTableViewBaseDelegate.h
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import <Foundation/Foundation.h>

@interface TTTableViewBaseDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong, readonly) NSMutableArray *dataSource;
@property (nonatomic, strong, readonly) UITableView *tableView;

- (void)updateTableView:(UITableView *)tableView dataSource:(NSArray *)dataSource;

@end
