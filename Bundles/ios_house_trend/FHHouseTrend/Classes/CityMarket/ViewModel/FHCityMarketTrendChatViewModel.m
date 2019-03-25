//
//  FHCityMarketTrendChatViewModel.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketTrendChatViewModel.h"

@implementation FHCityMarketTrendChatViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self mockup];
    }
    return self;
}

-(void)mockup {
    self.unitLabel = @"万元/平";
    self.title = @"二手房 房价趋势";
    NSDictionary* item = @{
                           @"name": @"挂牌均单价",
                           @"color": @"bebebe",
                           };
    NSDictionary* item1 = @{
                            @"name": @"成交均单价",
                            @"color": @"ff5869",
                            };
    self.model = @[item, item1];
}
@end
