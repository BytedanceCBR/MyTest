//
//  TTFeedHistoryViewModel.m
//  Article
//
//  Created by fengyadong on 16/11/24.
//
//

#import "TTFeedHistoryViewModel.h"
#import "TTFeedFavoriteHistoryHeader.h"
#import "ArticleURLSetting.h"
#import "TTNetworkManager.h"
#import "TTHistoryEntryGroup.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TTFeedHistoryViewModel ()

@property (nonatomic, assign) TTHistoryType historyType;
@property (nonatomic, copy)   NSArray *allItems;

@end

@implementation TTFeedHistoryViewModel

- (instancetype)initWithDelegate:(id<TTFeedContainerViewModelDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        _deletingGroups = [NSMutableSet set];
    }
    return self;
}

- (void)deleteItemsClearAll:(BOOL)clearAll historyType:(TTHistoryType)historyType finishBlock:(void(^)(NSError *error, id jsonObj))finishBlock {
    
    NSDictionary *postParams = [self generateParamsClearAll:clearAll historyType:historyType];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting deleteHistoryURLString] params:postParams method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        finishBlock(error,jsonObj);
    }];
}

- (NSDictionary *)generateParamsClearAll:(BOOL)clearAll  historyType:(TTHistoryType)historyType {
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    [dataParams setValue:historyType == TTHistoryTypeRead ? @"read" : @"push" forKey:@"history_type"];
    
    [dataParams setValue:@(clearAll) forKey:@"clear_all"];
    
    NSMutableArray *deletingArray = [NSMutableArray array];
    
    for (TTHistoryEntryGroup *group in self.deletingGroups) {
        NSMutableDictionary *deletingGroup = [NSMutableDictionary dictionary];
        [deletingGroup setValue:@(group.dateIdentifier) forKey:@"date"];
        [deletingGroup setValue:@(group.isDeleting) forKey:@"clear"];
        NSMutableArray *deletingGroupIDs = [NSMutableArray array];
        for (ExploreOrderedData *deletingItem in group.deletingItems) {
            [deletingGroupIDs addObject:@([deletingItem.uniqueID longLongValue])];
        }
        [deletingGroup setValue:[deletingGroupIDs copy] forKey:@"group_ids"];
        NSMutableArray *excludeGroupIDs = [NSMutableArray array];
        for (ExploreOrderedData *excludeItem in group.excludeItems) {
            NSMutableDictionary *excludeDict = [NSMutableDictionary dictionary];
            [excludeDict setValue:@([excludeItem.uniqueID longLongValue]) forKey:@"group_id"];
            [excludeDict setValue:@(excludeItem.behotTime) forKey:@"behot_time"];
            [excludeGroupIDs addObject:[excludeDict copy]];
        }
        [deletingGroup setValue:[excludeGroupIDs copy] forKey:@"exclude_group_ids"];
        
        [deletingArray addObject:[deletingGroup copy]];
    }
    
    [dataParams setValue:deletingArray forKey:@"data"];
    
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[dataParams copy] options:kNilOptions error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    
    if (!error) {
        [postParams setValue:jsonString forKey:@"data"];
    }
    
    return [postParams copy];
}

- (NSString *)headerTextForGroup:(TTHistoryEntryGroup *)group {
//修改方案服务端下发模板文案，客户端填充内容
//    NSTimeInterval inteval = [[NSDate date] timeIntervalSince1970];
//    long long currentDayInterval = llroundl(inteval / (60 * 60 * 24));
//    long long historyDayInterval = group.dateIdentifier;
//    NSString *dateString = @"";
//    if (currentDayInterval == historyDayInterval) {
//        dateString = @"今天";
//    } else if (currentDayInterval - historyDayInterval == 1) {
//        dateString = @"昨天";
//    } else if (currentDayInterval - historyDayInterval > 1) {
//        dateString = [NSString stringWithFormat:@"%lld天前",currentDayInterval - historyDayInterval];
//    }
//    
//    NSString *actionString = type == TTHistoryTypeRead ? @"阅读" : @"推送";
//    
//    NSString *headerText = [NSString stringWithFormat:@"%@%@了%lld篇文章", dateString,actionString, group.totalCount];
    
    NSString *templateText = group.headerText;
    NSString *headerText = [templateText stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%lld", group.totalCount]];
    return headerText;
}

- (void)deleteItem:(ExploreOrderedData *)orderedData
{
    //orderedData isNotInterested
    NSMutableArray *newItems = [[NSMutableArray alloc] init];
    for (ExploreOrderedData *data in self.allItems) {
        if (![orderedData.uniqueID isEqualToString:data.uniqueID]) {
            [newItems addObject:data];
        }
    }
    self.allItems = newItems;
}

@end
