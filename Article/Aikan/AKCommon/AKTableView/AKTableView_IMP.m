//
//  AKTableView_IMP.m
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "AKTableView_IMP.h"

@implementation AKTableView_IMP

#pragma mark - UITableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView.numberOfSectionsBlock ? tableView.numberOfSectionsBlock(tableView) : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableView.numberOfRowsBlock ? tableView.numberOfRowsBlock(tableView, section) : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.heightForRowBlock ? tableView.heightForRowBlock(tableView, indexPath) : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.cellForRowBlock ? tableView.cellForRowBlock(tableView, indexPath) : [UITableViewCell new];
}

// to be added

#pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.didSelectBlock) {
        tableView.didSelectBlock(tableView, indexPath);
    }
}

// to be added

@end
