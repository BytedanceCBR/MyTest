//
//  FHCityMarketRecommendViewModel.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/28.
//

#import "FHCityMarketRecommendViewModel.h"
#import "FHCityMarketDetailResponseModel.h"
#import "FHHouseSearcher.h"
#import "extobjc.h"
@interface FHCityMarketRecommendViewModel ()
@property (nonatomic, strong) NSMutableDictionary<NSString*, FHSearchHouseDataModel*>* dataCache;
@end

@implementation FHCityMarketRecommendViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataCache = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return self;
}

- (void)setSpecialOldHouseList:(NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel *> *)specialOldHouseList {
    [self willChangeValueForKey:@"specialOldHouseList"];
    _specialOldHouseList = specialOldHouseList;
    [self resetDatas];
    [self requestData];
    [self didChangeValueForKey:@"specialOldHouseList"];
}

-(void)resetDatas {
    self.selectedIndex = 0;
    self.title = _specialOldHouseList[_selectedIndex].title;
    self.question = _specialOldHouseList[_selectedIndex].questionText;
    self.answoer = _specialOldHouseList[_selectedIndex].answerText;
}

-(void)onCategoryChange:(NSInteger)categoryIndex {
    if (categoryIndex >= [_specialOldHouseList count]) {
        NSAssert(NO, @"category索引越界");
        return;
    }
    self.selectedIndex = categoryIndex;
    self.title = _specialOldHouseList[_selectedIndex].title;
    self.question = _specialOldHouseList[_selectedIndex].questionText;
    self.answoer = _specialOldHouseList[_selectedIndex].answerText;
//    [_listener onDataArrived];
}

-(void)requestData {
    [self.specialOldHouseList enumerateObjectsUsingBlock:^(FHCityMarketDetailResponseDataSpecialOldHouseListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary* param = @{@"order_by[]": @"10"};
        @weakify(self);
        [FHHouseSearcher houseSearchWithQuery:@"house_type=2" param:param offset:0 needCommonParams:YES callback:^(NSError * _Nullable error, FHSearchHouseDataModel * _Nullable model) {
            @strongify(self);
            if (error == nil) {
                self.dataCache[obj.title] = model;
            } else {
                FHSearchHouseDataModel* theModel = [[FHSearchHouseDataModel alloc] init];
                self.dataCache[obj.title] = theModel;
            }
            [self notifyDataArrived];
        }];
    }];

}

-(FHSearchHouseDataModel*)currentData {
    NSString* category = [self categoryNameOfindex:_selectedIndex];
    if (category != nil) {
        return _dataCache[category];
    } else {
        NSAssert(NO, @"数据缺失");
        return nil;
    }
}

-(NSString*)categoryNameOfindex:(NSUInteger)index {
    if ([_specialOldHouseList count] > index) {
        return _specialOldHouseList[index].title;
    }
    return nil;
}


-(void)notifyDataArrived {
    if ([_dataCache count] == [_specialOldHouseList count]) {
        NSLog(@"notifyDataArrived");
        [_listener onDataArrived];
    }
}

@end
