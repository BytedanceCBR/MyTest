//
//  FHCityMarketRecommendSectionPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketRecommendSectionPlaceHolder.h"
#import "FHCityMarketRecommendHeaderView.h"
#import "FHCityMarketRecomandHouseCell.h"

@interface FHCityMarketRecommendSectionPlaceHolder ()
@property (nonatomic, strong) FHCityMarketRecommendHeaderView* headerView;
@end


@implementation FHCityMarketRecommendSectionPlaceHolder

- (BOOL)isDisplayData {
    return YES;
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    return 1;
}

- (void)registerCellToTableView:(nonnull UITableView *)tableView {
    [tableView registerClass:[FHCityMarketRecomandHouseCell class] forCellReuseIdentifier:@"recommend"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FHCityMarketRecomandHouseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"recommend" forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 122;
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_headerView == nil) {
        _headerView = [[FHCityMarketRecommendHeaderView alloc] init];
    }
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28 + 69 + 77;
}

@end
