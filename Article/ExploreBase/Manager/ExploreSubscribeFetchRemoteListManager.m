//
//  ExploreSubscribeFetchListManager.m
//  Article
//
//  Created by Huaqing Luo on 19/11/14.
//
//

#import "ExploreSubscribeFetchRemoteListManager.h"
#import "ExploreFetchListDefines.h"
#import "ExploreEntry.h"
#import "ExploreEntryManager.h"

@interface ExploreSubscribeFetchRemoteListManager()<SSDataOperationDelegate>

@property(nonatomic, strong)SubscribeEntryGetRemoteDataOperation * remoteOp;
@property(nonatomic, assign, readwrite) BOOL getNewItemsIndicator;
@property(nonatomic, strong, readwrite) NSArray * items;
@property(nonatomic, copy, readwrite) NSString * currentItemsVersion;

@property (nonatomic, assign, readwrite) BOOL isLoading;

@end

@implementation ExploreSubscribeFetchRemoteListManager

/*
@synthesize hasNewItemsIndicator = _hasNewItemsIndicator;
@synthesize items = _items;
*/

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hasNewUpdatesIndicator = NO;
        self.getNewItemsIndicator = NO;
        self.isLoading = NO;
        self.currentItemsVersion = @"";
        
        self.remoteOp = [[SubscribeEntryGetRemoteDataOperation alloc] init];
        self.remoteOp.opDelegate = self;
        [self addOperation:self.remoteOp];
    }
    
    return  self;
}

- (void)startFetchRemoteDataWithRequestType:(SubscribeEntryRemoteRequestType)requestType lastRequestVersion:(NSString *)lastRequestVersion hasNewUpdates:(BOOL)hasNewUpdates
{
    self.isLoading = YES;
    self.remoteOp.lastRequestVersion = lastRequestVersion;
    self.remoteOp.requestType = requestType;
    self.remoteOp.hasNewUpdatesIndicator = hasNewUpdates;
    
    NSMutableDictionary *context = [[NSMutableDictionary alloc] init];
    [self startExecute:context];
}

- (void)updateItemsWithDataArray:(NSArray *)dataArray
{
    //self.items = [ExploreEntry entitiesInManager:[SSModelManager sharedManager] withDataArray:dataArray];
    self.items = [[ExploreEntryManager sharedManager] insertEntryByDicts:dataArray save:YES];
}

- (void)cancelAllOperations
{
    [super cancelAllOperations];
    self.isLoading = NO;
}

#pragma mark - SSDataOperationDelegate
- (void)dataOperation:(SSDataOperation *)op increaseData:(NSArray *)increaseData error:(NSError *)error userInfo:(NSDictionary *)userInfo
{
    if (!error)
    {
        id remoteDict = [(NSDictionary *)userInfo objectForKey:kExploreFetchListResponseRemoteDataKey];
        if ([remoteDict isKindOfClass:[NSDictionary class]])
        {
            id remoteData = [remoteDict objectForKey:@"data"];
            if ([remoteData isKindOfClass:[NSDictionary class]])
            {
                switch (((SubscribeEntryGetRemoteDataOperation *)op).requestType) {
                    case HasNewUpdatesIndicatorRequest:
                        self.hasNewUpdatesIndicator = [remoteData tt_boolValueForKey:@"tip_new"];
                        break;
                    case FullEntriesRequest:
                        self.getNewItemsIndicator = [remoteData tt_boolValueForKey:@"refresh"];
                        if (self.getNewItemsIndicator)
                        {
                            self.currentItemsVersion = [remoteData tt_stringValueForKey:@"version"];
                            NSArray * dataArray = [remoteData tt_arrayValueForKey:@"data"];
                            [self updateItemsWithDataArray:dataArray];
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    
    if (self.finishBlock)
    {
        self.finishBlock(error);
    }
    
    self.isLoading = NO;
}
@end
