//
//  TTSettingMineTabManager.m
//  Article
//
//  Created by Dianwei on 14-9-26.
//
//

#import "TTSettingMineTabManager.h"
#import "ArticleURLSetting.h"
#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabEntry.h"
#import "ArticleBadgeManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNetworkManager.h"
#import "NSStringAdditions.h"
#import "NetworkUtilities.h"
#import "SDWebImageCompat.h"
#import "TTNewFollowingManager.h"
#import "AKMinePhotoCarouselEntry.h"
#import "AKTaskSettingHelper.h"
static NSString *const kTTSettingMineTabSectionsKey  = @"mine_tab_settings.plist";

@interface TTSettingMineTabManager()
<
TTAccountMulticastProtocol
>

@property (nonatomic, strong) NSArray<TTSettingMineTabGroup *> *sections;
@property (nonatomic, strong) NSArray<TTSettingMineTabGroup *> *visibleSections;
@property (nonatomic, strong) NSDictionary<NSString*, TTSettingMineTabEntry*> *entries;
@property (nonatomic, strong) NSDictionary *cachedMineTabConfig;
@property (nonatomic, assign) BOOL hadDisplayedADRegisterEntrance;

@end

@implementation TTSettingMineTabManager

- (void)dealloc
{
    [TTAccount addMulticastDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[kTTSettingMineTabSectionsKey stringCachePath]]) {
            @try {
                _sections = [NSKeyedUnarchiver unarchiveObjectWithFile:[kTTSettingMineTabSectionsKey stringCachePath]];
            } @catch (NSException *exception) {
                _sections = nil;
                [[NSFileManager defaultManager] removeItemAtPath:[kTTSettingMineTabSectionsKey stringCachePath] error:nil];
            }
            _entries = [NSDictionary dictionary];
            [self buildDictionary];
        }
        
        [TTAccount addMulticastDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark -- Configuration

- (NSDictionary<NSString*, TTSettingMineTabEntry*> *)entries {
    if(SSIsEmptyDictionary(_entries)) {
        NSArray *types = @[
                           @(TTSettingMineTabEntyTypeFeedBack),//用户反馈
                           @(TTSettingMineTabEntyTypeSettings)//设置
                           ];
        
        NSMutableDictionary *entries = [NSMutableDictionary dictionary];
        [types enumerateObjectsUsingBlock:^(id _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop){
            TTSettingMineTabEntry *entry = [TTSettingMineTabEntry initWithEntryType:[type integerValue]];
            if(entry && !isEmptyString(entry.key)) {
                [entries setValue:entry forKey:entry.key];
            }
        }];
        _entries = entries.copy;
    }
    
    return _entries;
}

- (NSArray<TTSettingMineTabGroup *> *)sections {
    if(SSIsEmptyArray(_sections)) {
        [self buildLocalSections];
    }
    
    return _sections;
}

#pragma mark -- Public Method

- (void)startGetMineTabConfiguration {
    //pm（徐璐冉）说iPad不需要服务端控制
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting functionExtensionURLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if(!error) {
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary * data = [jsonObj tt_dictionaryValueForKey:@"data"];
                self.cachedMineTabConfig = data;
                [self buildMineTabGroups:data];
                [self reloadSectionsIfNeeded];
                [self saveMineTabGroups];
                [self rebuildshVisibleSections];
                dispatch_main_async_safe(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kArticleBadgeManagerRefreshedNotification object:self userInfo:nil];
                })
            }
        }
    }];
}

- (void)rebuildshVisibleSections
{
    NSMutableArray *array = [NSMutableArray array];
    BOOL display = [[AKTaskSettingHelper shareInstance] isEnableShowTaskEntrance];
    [self.sections enumerateObjectsUsingBlock:^(TTSettingMineTabGroup * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *enties = [NSMutableArray array];
        [obj1.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj2.akTaskSwitch && !display) {
            } else {
                [enties addObject:obj2];
            }
        }];
        TTSettingMineTabGroup *section = [[TTSettingMineTabGroup alloc] initWithArray:enties];
        section.key = obj1.key;
        section.shouldBeDisplayed = obj1.shouldBeDisplayed;
        if (enties.count > 0) {
            [array addObject:section];
        }
    }];
    _visibleSections = array;
}

- (void)saveMineTabGroups {
    if(!SSIsEmptyArray(self.sections) && ![TTDeviceHelper isPadDevice]) {
        [NSKeyedArchiver archiveRootObject:self.sections toFile:[kTTSettingMineTabSectionsKey stringCachePath]];
    }
}

- (TTSettingMineTabEntry *)getEntryForType:(TTSettingMineTabEntyType)type {
    TTSettingMineTabEntry *entry = [self.entries objectForKey:[[self class] keyForType:type]];
    return entry;
}

- (void)setEntry:(TTSettingMineTabEntry *)entry ForType:(TTSettingMineTabEntyType)type {
    if (entry && [entry isKindOfClass:[TTSettingMineTabEntry class]]) {
        NSMutableDictionary *newEntries= [NSMutableDictionary dictionaryWithDictionary:self.entries];
        NSString *key = [[self class] keyForType:type];
        if (entry && !isEmptyString(key)) {
            [newEntries setValue:entry forKey:key];
        }
        self.entries = newEntries;
    }
}
- (BOOL)reloadSectionsIfNeeded {
//    //本地索引新建，忽略iPhone，因为完全云端可配
//    if (![TTDeviceHelper isPadDevice]) {
//        return YES;
//    }
    
    NSMutableArray<TTSettingMineTabEntry *> *deleteKeys = [NSMutableArray array];
    __block BOOL needReload = NO;
    
    [self.entries enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TTSettingMineTabEntry * _Nonnull entry, BOOL * _Nonnull stop) {
         BOOL wasDisplayed = entry.shouldBeDisplayed;
         // 可动态变更的项需要重新加载
         if(entry.update) {
             if (entry.update()) {
                 if (entry && wasDisplayed && !entry.shouldBeDisplayed) {
                     [deleteKeys addObject:entry];
                 }
                 
                 needReload = YES;
             }
         } else {
             if (entry.isModified) {
                 needReload = YES;
                 entry.modified = NO;
             }
         }
     }];
    
    // 有减项时，全部重新加载；否则只加载有变化的项
    if (needReload) {
        if (deleteKeys.count > 0) {
            [deleteKeys enumerateObjectsUsingBlock:^(TTSettingMineTabEntry * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
                [self removeEntry:entry];
            }];
        }
    }
    
    return needReload;
}

- (void)refreshPrivateLetterEntry:(BOOL)enabled{
    if(![TTDeviceHelper isPadDevice]){
        if(self.cachedMineTabConfig){
            [self buildMineTabGroups:self.cachedMineTabConfig];
        }
    }
    else{
        [self buildLocalSections];
    }
    
    if(!enabled){
        [self removeEntry:[self getEntryForType:TTSettingMineTabEntyTypePrivateLetter]];
    }
    
    [self reloadSectionsIfNeeded];
    [self saveMineTabGroups];
    
    dispatch_main_async_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTSettingMineTabManagerRefreshedNotification object:self userInfo:nil];
    })

}

#pragma mark -- Private Method

- (void)buildDictionary {
    if (!SSIsEmptyArray(_sections)) {
        NSMutableDictionary<NSString*, TTSettingMineTabEntry*> *entries = [NSMutableDictionary dictionary];
        [_sections enumerateObjectsUsingBlock:^(TTSettingMineTabGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
            [group.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop) {
                if (entry && !isEmptyString(entry.key) && [entry isKindOfClass:[TTSettingMineTabEntry class]]) {
                    [TTSettingMineTabEntry setBlockForEntry:(TTSettingMineTabEntry *)entry];
                    [entries setValue:(TTSettingMineTabEntry*)entry forKey:entry.key];
                    
                    if ([entry.key isEqualToString:@"bd"]) { // 广告合作
                        self.hadDisplayedADRegisterEntrance = YES;
                    }
                }
            }];
        }];
        _entries = [entries copy];
    }
}

- (void)buildLocalSections {
    NSArray *types = @[
                       @(TTSettingMineTabGroupTypeSettings)//设置
                       ];
    
    NSMutableArray *groups = [NSMutableArray array];
    [types enumerateObjectsUsingBlock:^(id _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop){
        TTSettingMineTabGroup *group = [TTSettingMineTabGroup initWithGroupType:[type integerValue]];
        if(group && group.shouldBeDisplayed) {
            [groups addObject:group];
        }
    }];
    _sections = groups.copy;
}

- (BOOL)insertEntry:(TTSettingMineTabEntry *)entry atIndexPath:(NSIndexPath *)indexPath
{
    if (!entry || isEmptyString(entry.key) ||!entry.shouldBeDisplayed || !indexPath || !self.sections ||!self.entries) {
        return NO;
    }
    
    if ([self.entries objectForKey:entry.key]) {
        return NO;
    }

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section > [self.sections count]) {
        return NO;
    } else if (section == [self.sections count]) {
        if (row == 0) {
            NSMutableDictionary *entriesDict = [NSMutableDictionary dictionaryWithDictionary:self.entries];
            if (entry && !isEmptyString(entry.key)) {
                [entriesDict setValue:entry forKey:entry.key];
            }
            self.entries = [entriesDict copy];
            
            NSArray *array = [NSArray arrayWithObject:entry];
            TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] initWithArray:array];
            
            NSMutableArray<TTSettingMineTabGroup *> *sections = [NSMutableArray arrayWithArray:self.sections];
            if (group) {
                [sections addObject:group];
            }
            self.sections = [sections copy];
            
            [self saveMineTabGroups];
            
            return YES;
        }
    }
    TTSettingMineTabGroup *group = self.sections[section];
    if (!group.items || row > [group.items count]) {
        return NO;
    }
    
    TTSettingMineTabEntry *currentEntry = (TTSettingMineTabEntry *)[group.items objectAtIndex:row];
    if (![currentEntry.key isEqualToString:entry.key] && entry && !isEmptyString(entry.key)) {
        [group.items insertObject:entry atIndex:row];
        NSMutableDictionary *entriesDict = [NSMutableDictionary dictionaryWithDictionary:self.entries];
        [entriesDict setValue:entry forKey:entry.key];
        self.entries = [entriesDict copy];
        
        [self saveMineTabGroups];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)removeEntry:(TTSettingMineTabEntry *)entry
{
    if (!entry || isEmptyString(entry.key) || !self.sections || !self.entries) {
        return NO;
    }
    
    if (![self.entries objectForKey:entry.key]) {
        return NO;
    }
    for (TTSettingMineTabGroup *group in self.sections) {
        if ([group.items containsObject:entry]) {
            [group.items removeObject:entry];
            if (group.items.count == 0) {
                NSMutableArray<TTSettingMineTabGroup *> *sections = [NSMutableArray arrayWithArray:self.sections];
                [sections removeObject:group];
                self.sections = [sections copy];
            }
            NSMutableDictionary *entriesDict = [NSMutableDictionary dictionaryWithDictionary:self.entries];
            [entriesDict removeObjectForKey:entry.key];
            self.entries = [entriesDict copy];
            
            [self saveMineTabGroups];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)buildMineTabGroups:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSArray *sections = [dict tt_arrayValueForKey:@"section"];
    
    __block NSMutableArray *entriesArray = [NSMutableArray array];
    __block NSMutableDictionary *entriesDict = [NSMutableDictionary dictionary];
    
//    TTSettingMineTabGroup *iPhoneTopFunctionGroup = [TTSettingMineTabGroup initWithGroupType:TTSettingMineTabGroupTypeiPhoneTopFuction];
//    if (iPhoneTopFunctionGroup && iPhoneTopFunctionGroup.shouldBeDisplayed && !SSIsEmptyArray(iPhoneTopFunctionGroup.items)) {
//        [entriesArray addObject:iPhoneTopFunctionGroup];
//        [iPhoneTopFunctionGroup.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[TTSettingMineTabEntry class]] && !isEmptyString(obj.key)) {
//                [entriesDict setValue:obj forKey:obj.key];
//            }
//        }];
//    }
//
//    TTSettingMineTabGroup *iPadTopFunctionGroup = [TTSettingMineTabGroup initWithGroupType:TTSettingMineTabGroupTypeiPadTopFuction];
//    if (iPadTopFunctionGroup && iPadTopFunctionGroup.shouldBeDisplayed && !SSIsEmptyArray(iPadTopFunctionGroup.items)) {
//        [entriesArray addObject:iPadTopFunctionGroup];
//        [iPadTopFunctionGroup.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[TTSettingMineTabEntry class]] && !isEmptyString(obj.key)) {
//                [entriesDict setValue:obj forKey:obj.key];
//            }
//        }];
//    }
    NSArray *slidePhotos = [dict tt_arrayValueForKey:@"slide_card"];
    if (slidePhotos.count > 0) {
        AKMinePhotoCarouselEntry *entry = [[AKMinePhotoCarouselEntry alloc] initWithArray:slidePhotos];
        NSMutableArray<TTSettingGeneralEntry *> *entries = [NSMutableArray arrayWithObject:entry];
        TTSettingMineTabGroup *group = [TTSettingMineTabGroup initWithGroupType:TTSettingMineTabGroupTypePhotoCarousel];
        group.items = entries;
        if (group.items.count > 0) {
            [entriesArray addObject:group];
        }
    }
    
    self.hadDisplayedADRegisterEntrance = NO;
    [sections enumerateObjectsUsingBlock:^(id  _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([section isKindOfClass:[NSArray class]]) {
            NSMutableArray *entries = [NSMutableArray array];
            [section enumerateObjectsUsingBlock:^(id  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] initWithDictionary:item];
                    if (entry && !isEmptyString(entry.key) && entry.shouldBeDisplayed) {
                        [entries addObject:entry];
                        [entriesDict setValue:entry forKey:entry.key];
                        
                        if ([entry.key isEqualToString:@"bd"]) { // 广告合作
                            self.hadDisplayedADRegisterEntrance = YES;
                        }
                    }
                }
            }];
            TTSettingMineTabGroup *group = [[TTSettingMineTabGroup alloc] initWithArray:entries];
            if (group) {
                [entriesArray addObject:group];
            }
        }
    }];
    
    self.sections = entriesArray.copy;
    self.entries = entriesDict.copy;
    
}

- (void)buildExtraMineTabGroups
{
    TTSettingMineTabEntry *followEntry = [TTSettingMineTabEntry initWithEntryType:TTSettingMineTabEntyTypeMyFollow];
    if (followEntry.shouldBeDisplayed) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [[TTSettingMineTabEntry class] setBlockForEntry:followEntry];
        [self insertEntry:followEntry atIndexPath:indexPath];
    } else {
        [self removeEntry:followEntry];
    }
    [self rebuildshVisibleSections];
}


#pragma mark -- Helper

+ (NSString *)keyForType:(TTSettingMineTabEntyType)type {
    static NSDictionary *entryKeyTypeDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        entryKeyTypeDict = @{
                               @(TTSettingMineTabEntyTypeiPhoneTopFunction)     : @"iPhone_top_function",
                               
                               @(TTSettingMineTabEntyTypeiPadNightMode)         : @"iPad_night_mode",
                               @(TTSettingMineTabEntyTypeiPadFavor)             : @"iPad_favor",
                               @(TTSettingMineTabEntyTypeiPadHistory)           : @"iPad_history",

                               @(TTSettingMineTabEntyTypeMyFollow)              : @"my_follow",
                               
                               @(TTSettingMineTabEntyTypeWorkLibrary)           : @"pgc",
                               @(TTSettingMineTabEntyTypePrivateLetter)         : @"private_letter",
                               
                               @(TTSettingMineTabEntyTypeTTMall)                : @"mall",
                               
                               @(TTSettingMineTabEntyTypeGossip)                : @"gossip",
                               @(TTSettingMineTabEntyTypeFeedBack)              : @"feedback",
                               @(TTSettingMineTabEntyTypeSettings)              : @"config",
                               };
    });
    
    return [entryKeyTypeDict objectForKey:@(type)];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self startGetMineTabConfiguration];
}

#pragma mark - Notification

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //切换到前台时刷新我的tab下动态下发的入口及飘红飘，判断登陆状态
    dispatch_main_async_safe(^{
        [self startGetMineTabConfiguration];
    });
}

@end
