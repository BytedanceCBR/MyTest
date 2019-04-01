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
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHSearchHouseModel.h"
#import "BDWebImage.h"
#import "TTRoute.h"
#import "FHCityMarketRecommendFooterView.h"

@interface FHCityMarketRecommendSectionPlaceHolder ()
@property (nonatomic, strong) FHCityMarketRecommendHeaderView* headerView;
@property (nonatomic, strong) FHCityMarketRecommendViewModel* recommendViewModel;
@property (nonatomic, strong) FHCityMarketRecommendFooterView* footerView;
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

-(instancetype)initWithViewModel:(FHCityMarketRecommendViewModel*)viewModel {
    self = [super init];
    if (self) {
        _recommendViewModel = viewModel;
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
    FHSearchHouseDataModel* model = [_recommendViewModel currentData];
    if (model != nil && [model.items count] > indexPath.row) {
        FHSearchHouseDataItemsModel* item = model.items[indexPath.row];
        FHSearchHouseDataItemsHouseImageModel* imageModel = item.houseImage.firstObject;
        if (imageModel != nil && !isEmptyString(imageModel.url)) {
            [cell.houseIconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
        }
        cell.titleLabel.text = item.displayTitle;
        cell.subTitleLabel.text = item.displaySubtitle;
        cell.priceLabel.text = item.displayPrice;
        cell.oldPriceLabel.attributedText = [self getOldPriceAttribute:item.originPrice];
        cell.priceChangeLabel.attributedText = [self getPriceChangeAttribute:item.bottomText];
        [cell setIndex:indexPath.row];
    }
    return cell;
}

-(NSAttributedString*)getOldPriceAttribute:(NSString*)text {
    if (text == nil) {
        return nil;
    } else {
        return [[NSAttributedString alloc]
                initWithString:text
                attributes:@{
                             NSForegroundColorAttributeName: [UIColor colorWithHexString:@"999999"],
                             NSFontAttributeName: [UIFont themeFontRegular:12],
                             NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle],
                             }];
    }
}

-(NSAttributedString*)getPriceChangeAttribute:(NSArray<FHSearchHouseDataItemsModelBottomText*>*)texts {
    NSArray<NSAttributedString*>* items = [texts rx_mapWithBlock:^id(FHSearchHouseDataItemsModelBottomText* each) {
        return [[NSAttributedString alloc]
                initWithString:each.text
                attributes:@{
                             NSForegroundColorAttributeName: [UIColor colorWithHexString:each.color],
                             NSFontAttributeName: [UIFont themeFontRegular:12],
                             }];
    }];
    NSMutableAttributedString* result = [[NSMutableAttributedString alloc] init];
    [items enumerateObjectsUsingBlock:^(NSAttributedString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result appendAttributedString:obj];
    }];
    return result;
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
//        RAC(_headerView.titleLabel, text) = RACObserve(_recommendViewModel, title);
        RAC(_headerView.questionLabel, text) = RACObserve(_recommendViewModel, question);
        RAC(_headerView.answerLabel, text) = RACObserve(_recommendViewModel, answoer);
        [RACObserve(_headerView.segment, selectedSegmentIndex) subscribeNext:^(id  _Nullable x) {
            [_recommendViewModel onCategoryChange:[x integerValue]];
        }];
    }
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28 + 69 + 77;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHSearchHouseDataModel* model = [_recommendViewModel currentData];
    if (model != nil && [model.items count] > indexPath.row) {
        FHSearchHouseDataItemsModel* item = model.items[indexPath.row];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@", item.hid];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }
}

- (void)traceCellDisplayAtIndexPath:(NSIndexPath*)indexPath {
    NSIndexPath* indexPathWithOffset = [self indexPathWithOffset:indexPath];
    if (![self.traceCache containsObject:indexPathWithOffset]) {
        
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_footerView == nil) {
        self.footerView = [[FHCityMarketRecommendFooterView alloc] init];
        RAC(_footerView.textLabel, text) = RACObserve(_recommendViewModel, footerTitle);
        [_footerView.clickBtn addTarget:self action:@selector(onClickMore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 37;
}

-(void)onClickMore:(id)sender {
    NSURL* url = [NSURL URLWithString:self.recommendViewModel.openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

@end
