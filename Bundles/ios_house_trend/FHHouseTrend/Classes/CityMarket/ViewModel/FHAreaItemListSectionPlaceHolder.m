//
//  FHAreaItemListSectionPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/27.
//

#import "FHAreaItemListSectionPlaceHolder.h"
#import "FHCityMarketDetailResponseModel.h"
#import "FHCityAreaItemListHeaderView.h"

@implementation FHAreaItemListSectionPlaceHolder
- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    if ([self.hotList count] > section - self.sectionOffset) {
        NSArray* items = self.hotList[section - self.sectionOffset].items;
        return [items count];
    } else {
        return 0;
    }
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FHCityAreaItemListHeaderView* result = self.headerViews[@(section)];
    if (result == nil) {
        result = [[FHCityAreaItemListHeaderView alloc] init];
        self.headerViews[@(section)] = result;
    }
    return result;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33;
}

@end
