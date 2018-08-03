//
//  ArticleSaveRemoteOperation.m
//  Article
//
//  Created by Dianwei on 12-11-18.
//
//

#import "ArticleSaveRemoteOperation.h"
#import "ListDataHeader.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"

#import "ExploreFetchListDefines.h"
#import "NSObject+TTAdditions.h"

@import CoreSpotlight;

@implementation ArticleSaveRemoteOperation

- (void)execute:(NSMutableDictionary *)operationContext
{
    if ([operationContext objectForKey:kExploreFetchListConditionKey][kExploreFetchListSilentFetchFromRemoteKey]) {
        [self executeNext:operationContext];
        return;
    }
    
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [[operationContext objectForKey:kExploreFetchListConditionKey] objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListSaveRemoteOperationBeginTimeStampKey];

    NSArray *objectsToBeSaved = [operationContext objectForKey:@"objectsToBeSaved"];
    
    if (objectsToBeSaved.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL supportSpotlightSearch = [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0;
            NSMutableArray * searchableItems = [NSMutableArray array];

            [objectsToBeSaved enumerateObjectsUsingBlock:^(ExploreOrderedData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //[obj save];
                
                //先对文章做 CoreSpotlight--nic
                if (supportSpotlightSearch) {
                    if ([obj.originalData isKindOfClass:[Article class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:@"Article"];
#pragma clang diagnostic pop
                        attributeSet.title = [[obj article] title];
                        attributeSet.contentDescription = [[obj article] abstract];
                        
                        NSString *detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%lld", obj.article.uniqueID];
                        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:detailURL domainIdentifier:@"Article" attributeSet:attributeSet];
#pragma clang diagnostic pop
                        
                        [searchableItems addObject:item];
                    }
                }
            }];
            
            if (supportSpotlightSearch) {
                if (searchableItems.count > 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                    CSSearchableIndex * def = [CSSearchableIndex defaultSearchableIndex];
#pragma clang diagnostic pop
                    //这里是添加index ，还要定期删除哦 deleteSearchableItemsWithDomainIdentifiers
                    [def indexSearchableItems:searchableItems completionHandler:nil];
                }
            }
        });
    }
    
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListSaveRemoteOperationEndTimeStampKey];
    [self executeNext:operationContext];
}

@end
