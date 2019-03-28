//
//  FHCityMarketRecommendSectionPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketRecommendSectionPlaceHolder.h"
#import "FHCityMarketRecommendHeaderView.h"
#import "FHCityMarketRecomandHouseCell.h"
#import "FHCityMarketDetailResponseModel.h"
#import "RXCollection.h"
#import "FHCityMarketRecommendViewModel.h"
#import "ReactiveObjC.h"
@interface FHCityMarketRecommendSectionPlaceHolder ()
@property (nonatomic, strong) FHCityMarketRecommendHeaderView* headerView;
@property (nonatomic, strong) FHCityMarketRecommendViewModel* recommendViewModel;
@end


@implementation FHCityMarketRecommendSectionPlaceHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recommendViewModel = [[FHCityMarketRecommendViewModel alloc] init];
        RAC(_recommendViewModel, specialOldHouseList) = RACObserve(self, specialOldHouseList);
    }
    return self;
}

- (BOOL)isDisplayData {
    return _specialOldHouseList != nil;
}

- (NSUInteger)numberOfSection {
    if ([_specialOldHouseList count] != 0) {
        return 1;
    } else {
        return 0;
    }
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    return 3;
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
        [_headerView.segment removeAllSegments];
        NSArray* segmentTitles = [self.specialOldHouseList rx_mapWithBlock:^id(FHCityMarketDetailResponseDataSpecialOldHouseListModel* each) {
            return each.title;
        }];
        [segmentTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.headerView.segment insertSegmentWithTitle:obj atIndex:idx animated:NO];
        }];
        _headerView.segment.selectedSegmentIndex = 0;
        RAC(_headerView.titleLabel, text) = RACObserve(_recommendViewModel, title);
        RAC(_headerView.questionLabel, text) = RACObserve(_recommendViewModel, question);
        RAC(_headerView.answerLabel, text) = RACObserve(_recommendViewModel, answoer);
    }
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28 + 69 + 77;
}

@end
