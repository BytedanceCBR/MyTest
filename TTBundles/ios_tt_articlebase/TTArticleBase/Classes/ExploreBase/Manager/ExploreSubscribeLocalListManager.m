//
//  ExploreSubscribeFetchLocalListManager.m
//  Article
//
//  Created by Huaqing Luo on 21/11/14.
//
//

#import "ExploreSubscribeLocalListManager.h"
#import "SubscribeEntryGetLocalDataOperation.h"
#import "ExploreEntryManager.h"
#import "ExploreEntry.h"

#define kExploreSubscribeLocalListManagerKey @"kExploreSubscribeLocalListManagerKey"

@interface ExploreSubscribeLocalListManager()

@property(nonatomic, strong)            NSMutableArray * itemIDs;
@property(nonatomic, assign)            BOOL needFetchItems;

@end

@implementation ExploreSubscribeLocalListManager

@synthesize items = _items;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.currentItemsVersion = @"";
        self.needFetchItems = YES;
        self.itemsDirtyFlag = NO;
        [self unserializeProperties];
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    
    [self updateItemIDs];
}

- (void)updateItemIDs
{
    if (_items)
    {
        NSMutableArray * mutableItemIDs = [NSMutableArray arrayWithCapacity:[_items count]];
        for (id item in _items)
        {
            if ([item isKindOfClass:[ExploreEntry class]])
            {
                [mutableItemIDs addObject:((ExploreEntry *)item).entryID];
            }
        }
        
        self.itemIDs = mutableItemIDs;
    }
    else
    {
        self.itemIDs = nil;
    }
    
}

- (void)startFetchLocalItems
{
    if (self.needFetchItems) // 当前第一次从Local数据
    {
        _items = [[ExploreEntryManager sharedManager] entryForEntryIDs:self.itemIDs];
        self.needFetchItems = NO;
        self.itemsDirtyFlag = YES;
    }
}

- (void)saveLocalData
{
    [self serializeProperties];
}

- (void)serializeProperties
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setValue:self.itemIDs forKey:@"itemIDs"];
    [dict setValue:self.currentItemsVersion forKey:@"currentItemsVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kExploreSubscribeLocalListManagerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unserializeProperties
{
    id dict = [[NSUserDefaults standardUserDefaults] objectForKey:kExploreSubscribeLocalListManagerKey];
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        self.itemIDs = [dict objectForKey:@"itemIDs"];
        self.currentItemsVersion = [dict objectForKey:@"currentItemsVersion"];
    }
}

@end
