//
//  FHCityMarketRecommendViewModel.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/28.
//

#import "FHCityMarketRecommendViewModel.h"
#import "FHCityMarketDetailResponseModel.h"
@interface FHCityMarketRecommendViewModel ()

@end

@implementation FHCityMarketRecommendViewModel

- (void)setSpecialOldHouseList:(NSArray<FHCityMarketDetailResponseDataSpecialOldHouseListModel *> *)specialOldHouseList {
    [self willChangeValueForKey:@"specialOldHouseList"];
    _specialOldHouseList = specialOldHouseList;
    [self resetDatas];
    [self didChangeValueForKey:@"specialOldHouseList"];
}

-(void)resetDatas {
    self.selectedIndex = 0;
    self.title = _specialOldHouseList[_selectedIndex].title;
    self.question = _specialOldHouseList[_selectedIndex].questionText;
    self.answoer = _specialOldHouseList[_selectedIndex].answerText;
}

-(void)requestData {

}

@end
