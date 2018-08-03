//
//  TTTableViewBaseDelegate.m
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTTableViewBaseDelegate.h"

@interface TTTableViewBaseDelegate ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation TTTableViewBaseDelegate

- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = [NSMutableArray array];
    }
    
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}

- (void)updateTableView:(UITableView *)tableView dataSource:(NSArray *)dataSource
{
    self.dataSource = [NSMutableArray arrayWithArray:dataSource];
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentOffset = CGPointZero;
    [self.tableView reloadData];
    self.tableView.tableHeaderView = nil;
    self.tableView.tableFooterView = nil;
}

@end
