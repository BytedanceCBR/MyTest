//
//  ArticleMomentDiggManager.m
//  Article
//
//  Created by Dianwei on 14-5-27.
//
//

#import "ArticleMomentDiggManager.h"
#import "TTNetworkManager.h"
#import "ArticleURLSetting.h"
#import "SSUserModel.h"
#import <TTAccountBusiness.h>
#import "NSDictionary+TTAdditions.h"
#import "TTMomentProfileBaseView.h"
#import "FRActionDataService.h"

@interface ArticleMomentDiggManager()
@property(nonatomic, assign, readwrite, getter = isLoading)BOOL loading;
@property(nonatomic, retain)NSMutableOrderedSet *userSet;
@property(nonatomic, assign) BOOL isMoment; //是否为动态.
@end

@implementation ArticleMomentDiggManager

- (void)dealloc
{
    self.userSet = nil;
    self.ID = nil;
}

- (instancetype)initWithMomentID:(NSString*)tMomentID
{
    self = [self init];
    if(self)
    {
        self.isMoment = YES;
        self.ID = tMomentID;
    }
    
    return self;
}

- (instancetype)initWithCommentID:(NSString*)commentID {
    self = [self init];
    if (self) {
        self.isMoment = NO;
        self.ID = commentID;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.userSet = [NSMutableOrderedSet orderedSet];
    }
    
    return self;
}

- (NSArray*)diggUsers
{
    return [_userSet array];
}

+ (void)startDiggMoment:(NSString*)momentID finishBlock:(void(^)(int newCount, NSError *error))finishBlock
{
    if(isEmptyString(momentID))
    {
        SSLog(@"momentID must not empty");
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentDiggURLString] params:@{@"id": momentID} method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        int count = 0;
        if(!error)
        {
            NSDictionary * resultDict = jsonObj;
            NSDictionary * data = [resultDict dictionaryValueForKey:@"data" defalutValue:nil];
            count = [data intValueForKey:@"digg_count" defaultValue:0];
        }
        
        if (finishBlock) {
            finishBlock(count, error);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidDiggMomentNotification object:nil userInfo:@{@"id": momentID}];
    }];
}

+ (void)undoDiggMoment:(NSString *)momentID finishBlock:(void(^)(NSError *error))finishBlock {
    if (isEmptyString(momentID)) {
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting momentCancelDiggURLString] params:@{@"id": momentID} method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

- (void)startGetDiggedUsersWithOffset:(int)offset count:(int)count finishBlock:(void(^)(NSArray *users, NSInteger totalCount, NSInteger anonymousCount, BOOL hasMore, NSError *error))finishBlock
{
    if(isEmptyString(_ID))
    {
        SSLog(@"must specify momentID");
        return;
    }
    
    NSString *url = _isMoment? [ArticleURLSetting momentDiggedUsersURLString]: [ArticleURLSetting commentDiggedUsersURLString];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:@{@"id" : _ID, @"offset": @(offset), @"count": @(count)} method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        _loading = NO;
        NSArray *users = nil;
        BOOL hasMore = YES;
        int totalCount = 0;
        
        if(!error)
        {
            NSDictionary * resultDict = [jsonObj dictionaryValueForKey:@"data" defalutValue:nil];
            NSArray * data = [resultDict arrayValueForKey:@"data" defaultValue:nil];
            
            hasMore = [resultDict integerValueForKey:@"has_more" defaultValue:0] !=0 ? YES : NO;
            totalCount = [resultDict intValueForKey:@"total_count" defaultValue:0];
            users = [SSUserModel usersWithArray:data];
            
            _anonymousCount = [resultDict integerValueForKey:@"anonymous_count" defaultValue:0];
            
            if (!_isMoment) { //评论情况
                [GET_SERVICE(FRActionDataService) modelWithUniqueID:_ID type:FRActionDataModelTypeComment].diggCount = totalCount;
            }
        }
        
        [self insertDiggUsers:users atFirst:NO];
        if(finishBlock)
        {
            finishBlock(users, totalCount, _anonymousCount, hasMore, error);
        }
    }];
    
    _loading = YES;
}


- (void)insertDiggUsers:(NSArray*)users atFirst:(BOOL)isFirst
{
    for(SSUserBaseModel *user in users)
    {
        if([_userSet containsObject:user])
        {
            [_userSet replaceObjectAtIndex:[_userSet indexOfObject:user] withObject:user];
        }
        else
        {
            if (isFirst) {
                [_userSet insertObject:user atIndex:0];
            } else {
                [_userSet addObject:user];
            }
        }
    }
}

@end
