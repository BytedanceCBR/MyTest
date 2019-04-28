//
//  ExploreStockCellManager.m
//  Article
//
//  Created by 王双华 on 16/4/22.
//
//

#import "ExploreStockCellManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNetworkManager.h"
#import "StockData.h"

@implementation ExploreStockCellManager

static ExploreStockCellManager *s_manager;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[ExploreStockCellManager alloc] init];
    });
    return s_manager;
}

- (void)startGetDataFromStockData:(StockData *)stockData completion:(void(^)(StockData *stockData, NSDictionary *data, NSError *error))completion{
    // 请求最新stockData数据
    NSString *dataUrl = stockData.refreshUrl;
    
    if (isEmptyString(dataUrl)) {
        NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        completion(stockData, nil, error);
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:dataUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *err, id jsonObj) {
        NSError *error;
        NSDictionary *data;
        //NSLog(@"err: %@ result: %@", err, result);
        if (!err && [jsonObj objectForKey:@"data"]) {
            NSDictionary *dataDict = [jsonObj dictionaryValueForKey:@"data" defalutValue:nil];
            [stockData updateWithDataContentObj:dataDict];
        } else {
            error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        }
        
        if (completion) {
            completion(stockData, data, error);
        }
    }];
}





@end
