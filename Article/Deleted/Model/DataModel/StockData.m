//
//  StockData.m
//  
//
//  Created by 王双华 on 16/5/5.
//
//

#import "StockData.h"
#import "NSDictionary+TTAdditions.h"

@implementation StockData

@synthesize shouldStopUpdate;
@synthesize shouldReloadCell;

//+ (NSEntityDescription*)entityDescriptionInManager:(SSModelManager *)manager
//{
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:manager];
//    return entityDescription;
//}
//
//+ (NSString*)entityName
//{
//    return @"StockData";
//}
//
//+ (NSArray*)primaryKeys
//{
//    return @[@"uniqueID"];
//}

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"changeAmount",
                       @"changeScale",
                       @"lastUpdateTime",
                       @"refreshInterval",
                       @"refreshUrl",
                       @"schemaUrl",
                       @"stockID",
                       @"stockName",
                       @"stockPrice",
                       @"stockStatus",
                       @"tradingStatus",
                       ];
    }
    return properties;
}

+ (NSDictionary *)keyMapping {
    static NSDictionary *properties = nil;
    if (!properties) {
        properties = @{
                       @"changeAmount":@"change_amount",
                       @"changeScale":@"change_scale",
                       @"lastUpdateTime":@"last_update_time",
                       @"refreshInterval":@"refresh_interval",
                       @"refreshUrl":@"refresh_url",
                       @"stockID":@"stock_id",
                       @"stockName":@"stock_name",
                       @"stockPrice":@"stock_price",
                       @"stockStatus":@"stock_status",
                       @"tradingStatus":@"trading_status",
                       @"schemaUrl":@"url",
                       };
    }
    return properties;
}

- (void)updateWithDataContentObj:(NSDictionary *)content {
    if (![content isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *stockID = [content stringValueForKey:@"stock_id" defaultValue:nil];
    if ([self.stockID isEqualToString:stockID]) {
        self.stockName = [content stringValueForKey:@"stock_name" defaultValue:nil];
        self.stockPrice = [content stringValueForKey:@"stock_price" defaultValue:nil];
        self.stockStatus = [NSNumber numberWithInt:[content intValueForKey:@"stock_status" defaultValue:0]];
        self.changeAmount = [content stringValueForKey:@"change_amount" defaultValue:nil];
        self.changeScale = [content stringValueForKey:@"change_scale" defaultValue:nil];
        self.tradingStatus = [content stringValueForKey:@"trading_status" defaultValue:nil];
        self.refreshInterval = [NSNumber numberWithInt:[content intValueForKey:@"refresh_interval" defaultValue:0]];
        self.refreshUrl = [content stringValueForKey:@"refresh_url" defaultValue:nil];
        self.schemaUrl = [content stringValueForKey:@"url" defaultValue:nil];
        NSNumber *lastUpdateTime = [NSNumber numberWithLong:[content longValueForKey:@"last_update_time" defaultValue:0]];
        if ([self.lastUpdateTime isEqualToNumber:lastUpdateTime]) {
            self.shouldStopUpdate = YES;
        }
        else{
            self.lastUpdateTime = lastUpdateTime;
            self.shouldStopUpdate = NO;
        }
    }
//    if ([self hasChanges]) {
//        [[SSModelManager sharedManager] save:nil];
//    }
    [self save];
}


@end
