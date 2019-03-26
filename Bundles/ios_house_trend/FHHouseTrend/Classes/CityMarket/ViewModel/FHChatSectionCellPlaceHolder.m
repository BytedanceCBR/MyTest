//
//  FHChatSectionCellPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHChatSectionCellPlaceHolder.h"
#import "FHCityMarketTrendChatCellTableViewCell.h"

@implementation FHChatSectionCellPlaceHolder



- (BOOL)isDisplayData {
    return YES;
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    return 1;
}

- (void)registerCellToTableView:(nonnull UITableView *)tableView {
    [tableView registerClass:[FHCityMarketTrendChatCellTableViewCell class] forCellReuseIdentifier:@"chart"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FHCityMarketTrendChatCellTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"chart" forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 382;  //366 + 16;
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}



@end
