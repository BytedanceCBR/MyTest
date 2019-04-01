//
//  FHAreaItemSectionPlaceHolder.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHAreaItemSectionPlaceHolder.h"
#import "FHCityMarketAreaItemCell.h"
#import "FHCityAreaItemHeaderView.h"
#import "FHCityMarketDetailResponseModel.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "ReactiveObjC.h"
#import "TTRoute.h"
@interface FHAreaItemSectionPlaceHolder ()
@end

@implementation FHAreaItemSectionPlaceHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.headerViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)isDisplayData {
    return YES;
}

- (NSUInteger)numberOfSection {
    return [_hotList count];
}

- (NSUInteger)numberOfRowInSection:(NSUInteger)section {
    if ([_hotList count] > section - self.sectionOffset) {
        NSArray* items = _hotList[section - self.sectionOffset].items;
        return [items count] > 5 ? 5 : [items count];
    } else {
        return 0;
    }
}

- (void)registerCellToTableView:(nonnull UITableView *)tableView {
    [tableView registerClass:[FHCityMarketAreaItemCell class] forCellReuseIdentifier:@"areaItem"];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FHCityMarketAreaItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"areaItem" forIndexPath:indexPath];

    if ([_hotList count] > indexPath.section - self.sectionOffset && [_hotList[indexPath.section - self.sectionOffset].items count] > indexPath.row) {
        FHCityMarketDetailResponseDataHotListItemsModel* model = _hotList[indexPath.section - self.sectionOffset].items[indexPath.row];
        cell.titleLabel.text = model.neighborhoodName;
        cell.priceLabel.text = model.averagePrice;
        cell.countLabel.text = model.houseCount;
        cell.numberLabel.text = [@(indexPath.row + 1) stringValue];
        cell.numberIconView.backgroundColor = [self colorForNumberBgAtIndex:indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 93;
}

- (nonnull UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FHCityAreaItemHeaderView* result = _headerViews[@(section)];
    if (result == nil) {
        result = [[FHCityAreaItemHeaderView alloc] init];

        if ([_hotList count] > section - self.sectionOffset) {
            FHCityMarketDetailResponseDataHotListModel* model = _hotList[section - self.sectionOffset];
            result.nameLabel.text = model.title;
            @weakify(self);
            [[result.openMore rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                [self jumpToListPage:section - self.sectionOffset];
            }];
        }
        _headerViews[@(section)] = result;
        
    }
    return result;
}

-(UIColor*)colorForNumberBgAtIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return [UIColor colorWithHexString:@"ff5200"];
            break;
        case 1:
            return [UIColor colorWithHexString:@"ff661b"];
            break;
        case 2:
            return [UIColor colorWithHexString:@"ff7b00"];
            break;
        default:
            return [UIColor colorWithHexString:@"999999"];
            break;
    }
}

-(void)jumpToListPage:(NSInteger)index {
    FHCityMarketDetailResponseDataHotListModel* model = _hotList[index];
    TTRouteUserInfo* info = [[TTRouteUserInfo alloc] initWithInfo:@{
                                                                    @"model": model,
                                                                    @"title": @"城市行情"
                                                                    }];
    NSURL* url = [NSURL URLWithString:@"sslocal://city_market_hot_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:info];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_hotList count] > indexPath.section - self.sectionOffset && [_hotList[indexPath.section - self.sectionOffset].items count] > indexPath.row) {
        FHCityMarketDetailResponseDataHotListItemsModel* model = _hotList[indexPath.section - self.sectionOffset].items[indexPath.row];
        NSURL* url = [NSURL URLWithString:model.openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
}

- (void)traceCellDisplayAtIndexPath:(NSIndexPath*)indexPath {

}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

@end
