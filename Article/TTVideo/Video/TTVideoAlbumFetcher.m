//
//  TTVideoAlbumFetcher.m
//  Article
//
//  Created by 刘廷勇 on 16/1/13.
//
//

#import "TTVideoAlbumFetcher.h"
#import <TTNetworkManager.h>
#import "Article.h"

#import "CommonURLSetting.h"

@interface TTVideoAlbumFetcher ()

@end

@implementation TTVideoAlbumFetcher

+ (void)startFetchWithURL:(NSString *)url completion:(TTAlbumFetchCompletion)completion
{
    NSString *requestURL = [NSString stringWithFormat:@"%@%@", [CommonURLSetting baseURL], url];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:requestURL params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error) {
            NSArray *albums = [jsonObj valueForKey:@"data"];
            if ([albums isKindOfClass:[NSArray class]]) {
                NSArray *albumArticles = [self albumArticlesWithArr:albums];
                completion(albumArticles, error);
            }
        } else {
            completion(nil, error);
        }
    }];
}

+ (NSArray *)albumArticlesWithArr:(NSArray *)arr
{
    NSMutableArray *albumArticles = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSDictionary * dict in arr) {
        
        NSMutableDictionary * mutDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        id groupID = dict[@"group_id"];
        if (groupID) {
            groupID = [NSString stringWithFormat:@"%@", groupID];
        }
        NSNumber * gID = [NSNumber numberWithLongLong:[groupID longLongValue]];
        if ([gID longLongValue] == 0) {
            continue;
        }
        [mutDict setValue:gID forKey:@"uniqueID"];
        id itemID = dict[@"item_id"];
        if (itemID) {
            [mutDict setValue:[NSString stringWithFormat:@"%@", itemID] forKey:@"item_id"];
            [mutDict setValue:[NSString stringWithFormat:@"%@", itemID] forKey:@"itemID"];
        }
        
        if (![[dict allKeys] containsObject:@"video_detail_info"]) {
            mutDict[@"video_detail_info"] = @{@"" : @""};
        }
        
        NSMutableDictionary * containerDict = [NSMutableDictionary dictionaryWithCapacity:10];
        
        Article *tArticle = [Article objectWithDictionary:mutDict];
        [tArticle save];
        
        if (tArticle != nil) {
            [containerDict setValue:tArticle forKey:@"article"];
//            if ([[dict allKeys] containsObject:@"outer_schema"] || [[dict allKeys] containsObject:@"open_page_url"]) {
//                NSMutableDictionary * actions = [NSMutableDictionary dictionaryWithCapacity:10];
//                [actions setValue:[dict objectForKey:@"outer_schema"] forKey:@"outer_schema"];
//                [actions setValue:[dict objectForKey:@"open_page_url"] forKey:@"open_page_url"];
//                [containerDict setValue:actions forKey:@"actions"];
//            }
        }
        
//        if ([[dict allKeys] containsObject:@"tags"]) {
//            [containerDict setValue:dict[@"tags"] forKey:@"tags"];
//        }
        
        if ([containerDict count] > 0) {
            [albumArticles addObject:containerDict];
        }
    }
    
    if ([albumArticles count] > 0) {
        return albumArticles;
    }
    return nil;
}

@end
