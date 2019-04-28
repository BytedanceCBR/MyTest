//
//  ExploreMixedListBaseView+LastRead.m
//  Article
//
//  Created by 王双华 on 16/7/26.
//
//


#import "ExploreMixedListBaseView+LastRead.h"
#import "LastRead.h"
#import "ExploreListIItemDefine.h"
#import "ExploreFetchListManager.h"

@implementation ExploreMixedListBaseView (LastRead)
//将userdefault中的behot_time记录到model中，
- (void)insertLastReadToTopWithOrderIndex:(NSNumber *)orderIndex lastReadDate:(NSDate *)lastReadDate refreshDate:(NSDate *)refreshDate  shouldShowRefreshButton:(BOOL)show
{
    NSMutableDictionary *orderData = [[NSMutableDictionary alloc] initWithCapacity:10];
    orderIndex = @([orderIndex doubleValue] + kExploreMixedListBaseViewLastReadIncreaseInterval);//上次看到这的
    [orderData setValue:@(ExploreOrderedDataCellTypeLastRead) forKey:@"cell_type"];
    [orderData setValue:orderIndex forKey:@"orderIndex"];
    NSNumber *behotTime = @([orderIndex doubleValue] / 1000.0);
    [orderData setValue:behotTime forKey:@"behot_time"];
    NSString *uniqueID = [self getUniqueIDForLastRead];
    NSString *categoryID = self.categoryID;
    
    if (isEmptyString(categoryID)) {
        categoryID = @"";
    }

    [orderData setValue:categoryID forKey:@"categoryID"];
    NSString *concernID = self.concernID;
    if (isEmptyString(concernID)) {
        concernID = @"";
    }
    
    [orderData setValue:concernID forKey:@"concernID"];
    [orderData setValue:@(self.listType) forKey:@"listType"];
    [orderData setValue:@(self.listLocation) forKey:@"listLocation"];
    [orderData setValue:uniqueID forKey:@"uniqueID"];

    [orderData setValue:@(show) forKey:@"showRefresh"];
    [orderData setValue:lastReadDate forKey:@"lastDate"];
    [orderData setValue:refreshDate forKey:@"refreshDate"];
    if (uniqueID) {
        [self.fetchListManager insertObjectFromDict:orderData listType:ExploreOrderedDataListTypeCategory];
    }
}

- (NSString *)getUniqueIDForLastRead
{
    NSString *primaryID = !isEmptyString(self.categoryID) ? self.categoryID : self.concernID;
    NSUInteger uniqueID = primaryID.hash - self.isInVideoTab * 100;
    //ExploreOriginalData里的uniqueID为int_64,此处为unsigined int_64,可能超出范围
    if (uniqueID < 10000){//hash值应该会很大，这里只是保护
        uniqueID = primaryID.hash;
    }
    else{
        uniqueID = uniqueID / 100;
    }
    
    NSString *result = [NSString stringWithFormat:@"%lu",uniqueID];
    return result;
}

@end
