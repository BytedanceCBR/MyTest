//
//  TSVShortVideoOriginalData.m
//  Article
//
//  Created by 王双华 on 2017/5/24.
//
//

#import "TSVShortVideoOriginalData.h"
#import "FriendDataManager.h"
#import "TTBlockManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreMixListDefine.h"
#import "TTUGCDefine.h"
#import <TTAccountBusiness.h>
//#import "Thread.h"

extern NSString *const kTTEditUserInfoDidFinishNotificationName;

NSString * const kTSVShortVideoDeleteNotification = @"kTSVShortVideoDeleteNotification";
NSString * const kTSVShortVideoDeleteUserInfoKeyGroupID = @"kTSVShortVideoDeleteUserInfoKeyGroupID";

@implementation TSVShortVideoOriginalData

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"primaryID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"uniqueID",
                       @"originalDict",
                       @"userRepined",
                       @"primaryID",
                       ];
    }
    return properties;
}

+ (NSString *)primaryIDByUniqueID:(int64_t)uniqueID
                         listType:(NSUInteger)listType
{
    return [NSString stringWithFormat:@"%lld%lu", uniqueID, listType];
}

- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    TSVShortVideoOriginalData *other = (TSVShortVideoOriginalData *)object;
    
    if (![self.primaryID isEqualToString:other.primaryID]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
     return [self.primaryID hash];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    [super updateWithDictionary:dictionary];
    
    self.originalDict = dictionary;
    
    NSInteger listType = [dictionary tt_integerValueForKey:@"listType"];
    self.primaryID = [TSVShortVideoOriginalData primaryIDByUniqueID:self.uniqueID listType:listType];
    
    NSError *error = nil;
    self.shortVideo = [[TTShortVideoModel alloc] initWithDictionary:self.originalDict error:&error];
    self.shortVideo.shortVideoOriginalData = self;
    NSAssert(!error, @"short video 构造失败");
    
    self.userRepined = self.shortVideo.userRepin;
    
    
    
    [self.shortVideo save];
}

- (TTShortVideoModel *)shortVideo
{
    if (!_shortVideo) {
        NSError *error = nil;
        _shortVideo = [[TTShortVideoModel alloc] initWithDictionary:self.originalDict error:&error];
        _shortVideo.shortVideoOriginalData = self;
        NSAssert(!error, @"short video 构造失败");
    }
    return _shortVideo;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserveNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeObserveNotification];
}

- (NSSet * _Nullable)orderedData {
    NSString * uniqueIDStr = [NSString stringWithFormat:@"%lld", self.uniqueID];
    NSArray *objs = [ExploreOrderedData objectsWithQuery:@{@"uniqueID":uniqueIDStr}];
    if (objs.count > 0) {
        return [NSSet setWithArray:objs];
    }else {
        return nil;
    }
}

#pragma make - Notification
- (void)addObserveNotification { 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dislikeNotification:) name:@"TSVShortVideoDislikeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCellNotification:) name:@"TSVShortVideoDeleteCellNotification" object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shortVideoforwardSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editUserInfoDidFinish:) name:kTTEditUserInfoDidFinishNotificationName object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dislikeNotification:(NSNotification *)notify
{
    NSString * groupID = notify.userInfo[@"group_id"];
    NSString * ad_id = notify.userInfo[@"ad_id"];
    NSString * groupIDOfSelf = self.shortVideo.groupID;
    NSString * adIDOfSelf = [NSString stringWithFormat:@"%@", self.shortVideo.raw_ad_data[@"id"]];
    if (!isEmptyString(groupID) && [groupID isEqualToString:groupIDOfSelf]) {
        if ([self.orderedData count] > 0) {
            [self.orderedData enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                self.notInterested = @(YES);
                [self save];
            }];
        }
    } else if (!isEmptyString(ad_id) && [adIDOfSelf isEqualToString:ad_id]) {
        if ([self.orderedData count] > 0) {
            [self.orderedData enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                self.notInterested = @(YES);
                [self save];
            }];
        }
    }
}

- (void)deleteCellNotification:(NSNotification *)notify
{
    NSArray * groupIDArray = notify.userInfo[@"group_id_array"];
    WeakSelf;
    [groupIDArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *groupID = (NSString *)obj;
            NSString * groupIDOfSelf = self.shortVideo.groupID;
            if (!isEmptyString(groupID) && [groupID isEqualToString:groupIDOfSelf]) {
                if ([self.orderedData count] > 0) {
                    __block NSMutableDictionary * userInfo = @{}.mutableCopy;
                    [self.orderedData enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                            [userInfo setValue:@(0) forKey:kExploreMixListShouldSendDislikeKey];
                            [userInfo setValue:obj forKey:kExploreMixListNotInterestItemKey];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
                        }
                    }];
                }
            }
        }
    }];
}

//- (void)shortVideoforwardSuccess:(NSNotification *)notify
//{
//    if ([notify.userInfo[@"repostOperationItemType"] integerValue] == TTRepostOperationItemTypeShortVideo && [notify.userInfo[@"repostOperationItemID"] isEqualToString:self.shortVideo.itemID]) {
//        NSInteger count = self.shortVideo.forwardCount + 1;
//        self.shortVideo.forwardCount = count;
//
//        [self.shortVideo save];
//    } else if ([[notify.userInfo tt_stringValueForKey:@"repost_fw_id"] isEqualToString:self.shortVideo.itemID] ) {
//        self.shortVideo.forwardCount = self.shortVideo.forwardCount + 1;
//        [self.shortVideo save];
//    }
//}

- (void)editUserInfoDidFinish:(NSNotification *)notification {
    if ([self.shortVideo.author.userID isEqualToString:[TTAccountManager userID]]) {
        NSString * screenName = self.shortVideo.author.name;
        if (![screenName isEqualToString:[TTAccountManager userName]]) {
            self.shortVideo.author.name = [TTAccountManager userName];
            [self.shortVideo save];
        }
        
        if (![self.shortVideo.author.avatarURL isEqualToString:[TTAccountManager avatarURLString]]) {
            self.shortVideo.author.avatarURL = [TTAccountManager avatarURLString];
            [self.shortVideo save];
        }
    }
}

@end


