//
//  ExploreSubscribeDataListManager.m
//  Article
//
//  Created by Huaqing Luo on 21/11/14.
//
//

#import "ExploreSubscribeDataListManager.h"
#import "ExploreSubscribeLocalListManager.h"
#import "ExploreEntryManager.h"


@interface ExploreSubscribeDataListManager()
<
TTAccountMulticastProtocol
>
@property(nonatomic, strong)            ExploreSubscribeFetchRemoteListManager * fetchRemoteEntriesManager;
@property(nonatomic, strong)            ExploreSubscribeLocalListManager * localManager;
@property(nonatomic, strong)            ExploreSubscribeFetchRemoteListManager * fetchRemoteHasNewUpdatesIndicatorManager;

@property(nonatomic, copy)              NSString * currentItemsVersion;
@property(nonatomic, strong, readwrite) NSArray * items;
// @property(nonatomic, assign, readwrite) BOOL isLoading;

@end

@implementation ExploreSubscribeDataListManager

@synthesize items = _items;
@synthesize isLoading;

static ExploreSubscribeDataListManager * dataManager;

+ (ExploreSubscribeDataListManager *)shareManager;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[ExploreSubscribeDataListManager alloc] init];
    });
    return dataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.fetchRemoteEntriesManager = [[ExploreSubscribeFetchRemoteListManager alloc] init];
        self.fetchRemoteHasNewUpdatesIndicatorManager = [[ExploreSubscribeFetchRemoteListManager alloc] init];
        self.localManager = [[ExploreSubscribeLocalListManager alloc] init];
        self.currentItemsVersion = self.localManager.currentItemsVersion;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSubscribeOrUnsubscribeNotification:) name:kEntrySubscribeStatusChangedNotification object:nil];

        [TTAccount addMulticastDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (BOOL)isLoading
{
    return self.fetchRemoteEntriesManager.isLoading;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self removeAllItems];
    [self cancelAllOperations];
    
    [self fetchEntriesFromLocal:NO fromRemote:YES];
}

- (void)setItems:(NSArray *)items
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _items = items;
    });
}

- (void)receiveSubscribeOrUnsubscribeNotification:(NSNotification *)notification
{
    ExploreEntry * item = [notification.userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    if (item.managedObjectContext)
    {
        if ([item.subscribed boolValue])
        {
            [self insertItemAtHead:item];
            [self notifyHasNewUpdates];
        }
        else
        {
            [self removeItem:item];
        }
    }
}

- (void)insertItemAtHead:(ExploreEntry *)item
{
    if (!item.managedObjectContext) {
        return;
    }
    for (ExploreEntry * entry in self.items)
    {
        if ([entry.entryID isEqualToString:item.entryID])
        {
            return;
        }
    }
    
    NSMutableArray * mutableItems = [NSMutableArray arrayWithCapacity:1 + [_items count]];
    [mutableItems addObject:item];
    [mutableItems addObjectsFromArray:_items];
    
    self.items = mutableItems;
    [self notifyFetchFinished];
    
    self.localManager.items = mutableItems;
    [self.localManager saveLocalData];
}

- (void)removeItem:(ExploreEntry *)item
{
    if (!item.managedObjectContext) {
        return;
    }
    if ([_items count] > 0)
    {
        NSMutableArray * mutableItems = [NSMutableArray arrayWithCapacity:[_items count] - 1];
        
        for (ExploreEntry *entry in _items)
        {
            if (![item.entryID isEqualToString:entry.entryID])
            {
                [mutableItems addObject:entry];
            }
        }
        
        self.items = mutableItems;
        [self notifyFetchFinished];
        
        self.localManager.items = mutableItems;
        [self.localManager saveLocalData];
    }
}

- (void)fetchEntriesFromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote
{
    if (fromLocal)
    {
        [self.localManager startFetchLocalItems];
        if (self.localManager.itemsDirtyFlag)
        {
            self.items = self.localManager.items;
            self.localManager.itemsDirtyFlag = NO;
        }
        
        [self notifyFetchFinished];
    }
    
    if (fromRemote)
    {
        if (self.fetchRemoteEntriesManager.isLoading)
        {
            [self.fetchRemoteEntriesManager cancelAllOperations];
        }
        
        __weak ExploreSubscribeDataListManager * weakSelf = self;
        self.fetchRemoteEntriesManager.finishBlock = ^(NSError * error) {
            if (!error)
            {
                if (weakSelf.fetchRemoteEntriesManager.getNewItemsIndicator)
                {
                    weakSelf.currentItemsVersion = weakSelf.fetchRemoteEntriesManager.currentItemsVersion;
                    weakSelf.items = weakSelf.fetchRemoteEntriesManager.items;
                    [weakSelf saveRemoteDataToLocal];
                }
            }
            [weakSelf notifyFetchFinished];
        };
        
        [self.fetchRemoteEntriesManager startFetchRemoteDataWithRequestType:FullEntriesRequest lastRequestVersion:self.currentItemsVersion hasNewUpdates:self.hasNewUpdatesIndicator];
    }
}

//- (void)fetchHasNewUpdatesIndicator
//{
//    if (self.fetchRemoteHasNewUpdatesIndicatorManager.isLoading)
//    {
//        [self.fetchRemoteHasNewUpdatesIndicatorManager cancelAllOperations];
//    }
//
//    __weak ExploreSubscribeDataListManager * weakSelf = self;
//    self.fetchRemoteHasNewUpdatesIndicatorManager.finishBlock = ^(NSError * error) {
//        if (!error) {
//            if (weakSelf.fetchRemoteHasNewUpdatesIndicatorManager.hasNewUpdatesIndicator)
//            {
//                weakSelf.hasNewUpdatesIndicator = YES;
//                weakSelf.fetchRemoteHasNewUpdatesIndicatorManager.hasNewUpdatesIndicator = NO;
//                [weakSelf notifyHasNewUpdates];
//            }
//        }
//    };
//
//    [self.fetchRemoteHasNewUpdatesIndicatorManager startFetchRemoteDataWithRequestType:HasNewUpdatesIndicatorRequest lastRequestVersion:self.currentItemsVersion hasNewUpdates:self.hasNewUpdatesIndicator];
//}

// Only called after getting the remote data successfully
- (void)saveRemoteDataToLocal
{
    self.localManager.currentItemsVersion = self.fetchRemoteEntriesManager.currentItemsVersion;
    self.localManager.items = self.fetchRemoteEntriesManager.items;
    [self.localManager saveLocalData];
}

- (void)removeAllItems
{
    self.items = nil;
    self.currentItemsVersion = @"";
    
    self.localManager.currentItemsVersion = @"";
    self.localManager.items = nil;
    [self.localManager saveLocalData];
}

- (void)cancelAllOperations
{
    [self.fetchRemoteEntriesManager cancelAllOperations];
}

- (void)notifyFetchFinished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreSubscribeFetchFinishedNotification object:self];
    });
}

- (void)notifyHasNewUpdates
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreSubscribeHasNewUpdatesNotification object:self];
//    });
}

@end
