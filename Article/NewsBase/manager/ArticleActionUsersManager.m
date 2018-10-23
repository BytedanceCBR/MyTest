//
//  ArticleActionUsersManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-23.
//
//

#import "ArticleActionUsersManager.h"
#import "SSHttpOperation.h"
#import "NetworkUtilities.h"
#import "CommonURLSetting.h"
#import "SSOperationManager.h"
#import "ArticleFriend.h"

#define requestCount 20

@interface ArticleActionUsersManager()
@property(nonatomic, assign)BOOL loading;
@property(nonatomic, assign, readwrite)BOOL hasMore;
@property(nonatomic, assign)NSUInteger offset;
@property(nonatomic, retain, readwrite)NSMutableArray * actionUsers;
@property(nonatomic, retain)NSMutableSet * actionUserIDs; // user for remove repeat
@property(nonatomic, retain)Article * article;
@property(nonatomic, retain)SSHttpOperation * fetchRequest;
@property(nonatomic, assign)ArticleActionUsersManagerActionType actionType;
@end

@implementation ArticleActionUsersManager

- (void)dealloc
{
    [_fetchRequest cancelAndClearDelegate];
    self.fetchRequest = nil;
    self.actionUsers = nil;
    self.actionUserIDs = nil;
    self.article = nil;
}

- (void)resetData
{
    _hasMore = YES;
    _loading = NO;
    self.article = nil;
    _offset = 0;
    
    [_actionUsers removeAllObjects];
    if (_actionUsers == nil) {
        self.actionUsers = [NSMutableArray arrayWithCapacity:100];
    }
    
    [_actionUserIDs removeAllObjects];
    if (_actionUserIDs == nil) {
        self.actionUserIDs = [NSMutableSet setWithCapacity:100];
    }
}

- (void)fetchByArticle:(Article *)article actionType:(ArticleActionUsersManagerActionType)type
{
    if (!TTNetworkConnected() || article.uniqueID == 0) {
        return;
    }
    
    if (_loading) {
        return;
    }
    
    [self resetData];
    
    self.actionType = type;
    self.article = article;
    
    [self loadMore];

}

- (void)loadMore
{
    if (_article.uniqueID == 0 || !TTNetworkConnected()) {
        return;
    }
    
    if (_loading) {
        return;
    }
    
    if (!_hasMore) {
        return;
    }
    
    [_fetchRequest cancelAndClearDelegate];
    self.fetchRequest = nil;
    
    NSMutableDictionary * parameterDict = [NSMutableDictionary dictionaryWithCapacity:10];
    [parameterDict setValue:@(requestCount) forKey:@"count"];
    [parameterDict setValue:[@(_article.uniqueID) stringValue] forKey:@"group_id"];
    [parameterDict setValue:_article.itemID forKey:@"item_id"];
    [parameterDict setValue:_article.aggrType forKey:@"aggr_type"];
    [parameterDict setValue:@(_offset) forKey:@"offset"];
  
    NSString * typeStr = nil;
    switch (_actionType) {
        case ArticleActionUsersManagerActionTypeDig:
            typeStr = @"digg";
            break;
        case ArticleActionUsersManagerActionTypeFavorite:
            typeStr = @"favorite";
            break;
        default:
            break;
    }
    [parameterDict setValue:typeStr forKey:@"action"];
    
    self.fetchRequest = [SSHttpOperation httpOperationWithURLString:[CommonURLSetting actionUsersURLString] getParameter:parameterDict];
    [_fetchRequest setQueuePriority:NSOperationQueuePriorityHigh];
    [_fetchRequest setFinishTarget:self selector:@selector(operation:finishedResult:error:userInfo:)];
    [SSOperationManager addOperation:_fetchRequest];

}
- (void)operation:(SSHttpOperation*)operation finishedResult:(NSDictionary*)result error:(NSError*)error userInfo:(id)userInfo
{
    if (_fetchRequest == operation) {
        if(!error){
            _hasMore = [[(NSDictionary *)[result objectForKey:@"result"] objectForKey:@"has_more"] boolValue];
            NSArray *data = [(NSDictionary *)[result objectForKey:@"result"] objectForKey:@"data"];
            for (NSDictionary * dict in data) {

                NSString * uID = nil;
                if ([[dict allKeys] containsObject:@"user_id"]) {
                    uID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"user_id"]];
                }
                if (uID && ![_actionUserIDs containsObject:uID]) {
                    ArticleFriend * model = [[ArticleFriend alloc] initWithDictionary:dict];
                    [_actionUsers addObject:model];
                    
                    [_actionUserIDs addObject:uID];
                }
            }

            _offset += requestCount;
        }
        
        _loading = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(actionUsersManagerRequestFinished:)]) {
            [_delegate actionUsersManagerRequestFinished:self];
        }

    }
    
}


@end
