//
//  FHAreaItemSectionPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHAreaItemSectionPlaceHolder.h"
#import "FHCityMarketAreaItemCell.h"
#import "FHCityAreaItemHeaderView.h"
@interface FHAreaItemSectionPlaceHolder ()
@property (nonatomic, strong) FHCityAreaItemHeaderView* headerView;
@end

@implementation FHAreaItemSectionPlaceHolder

- (BOOL)isDisplayData {
    return YES;
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    return 5;
}

- (void)registerCellToTableView:(nonnull UITableView *)tableView {
    [tableView registerClass:[FHCityMarketAreaItemCell class] forCellReuseIdentifier:@"areaItem"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FHCityMarketAreaItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"areaItem" forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 93;
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_headerView == nil) {
        self.headerView = [[FHCityAreaItemHeaderView alloc] init];
    }
    return _headerView;
}

@end
