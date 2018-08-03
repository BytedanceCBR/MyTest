//
//  FRForumEntity.m
//  Forum
//
//  Created by zhaopengwei on 15/5/10.
//
//

#import "FRForumEntity.h"
#import "FRApiModel.h"

static NSMapTable *forumMaptable;

extern NSString *const kForumLikeStatusChangeNotification;
extern NSString *const kForumLikeStatusChangeForumIDKey;
extern NSString *const kForumLikeStatusChangeForumLikeKey;


@implementation FRForumEntity

+ (FRForumEntity *)getForumEntityWithForumId:(int64_t)forum_id
{
    if (forum_id == 0) {
        return nil;
    }
    NSNumber *key = [NSNumber numberWithLongLong:forum_id];
    FRForumEntity *entity = [forumMaptable objectForKey:key];
    
    return entity;
}

+ (FRForumEntity *)genForumEntityWithConcernForumStruct:(FRConcernForumStructModel *)model needUpdate:(BOOL)needUpdate
{
    [FRForumEntity initForumTable];
    NSNumber *key = model.forum_id;
    FRForumEntity *item = [forumMaptable objectForKey:key];
    if (item) {
        if (needUpdate) {
            [item updateWithConcernForum:model];
        }
        return item;
    }
    
    FRForumEntity *result = [[FRForumEntity alloc] initWithForumConcernForumStruct:model];
    [forumMaptable setObject:result forKey:key];
    
    return result;
    
}

+ (FRForumEntity *)genForumWithForumStruct:(FRForumStructModel *)model needUpdate:(BOOL)needUpdate
{
    [FRForumEntity initForumTable];
    
    NSNumber *key = model.forum_id;
    FRForumEntity *item = [forumMaptable objectForKey:key];
    if (item) {
        if (needUpdate) {
            [item updateWithForum:model];
        }
        return item;
    }
    
    FRForumEntity *result = [[FRForumEntity alloc] initWithForumStruct:model];
    [forumMaptable setObject:result forKey:key];
    
    return result;
}

+ (FRForumEntity *)genForumWithForumItemStruct:(FRForumItemStructModel *)model needUpdate:(BOOL)needUpdate
{
    [FRForumEntity initForumTable];
    
    NSNumber *key = model.forum_id;
    FRForumEntity *item = [forumMaptable objectForKey:key];
    if (item) {
        if (needUpdate) {
            [item updateWithForumItem:model];
        }
        return item;
    }
    
    FRForumEntity *result = [[FRForumEntity alloc] initWithForumItemStruct:model];
    [forumMaptable setObject:result forKey:key];
    
    return result;
}

+ (void)initForumTable
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        forumMaptable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _forum_id = 0;
        _forum_name = @"";
        _schema = @"";
        _onlookers_count = 0;
        _avatar_url = @"";
        _talk_count = 0;
        _like_time = 0;
        _forum_hot_header = @"";
        _desc = @"";
        _status = 0;
        _banner_url = @"";
        _follower_count = 0;
        _participant_count = 0;
        _share_url = @"";
        _introdution_url = @"";
        _article_count = 0;
        _read_count = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveForumLikeChangedNotification:) name:kForumLikeStatusChangeNotification object:nil];
    }
    
    return self;
}

- (instancetype)initWithForumConcernForumStruct:(FRConcernForumStructModel *)item
{
    self = [self init];
    if (self) {
        _forum_id = item.forum_id.longLongValue;
        _forum_name = item.forum_name;
        _showEtStatus = item.show_et_status.unsignedIntegerValue;
    }
    
    return self;

}

- (instancetype)initWithForumStruct:(FRForumStructModel *)item
{
    self = [self init];
    if (self) {
        _forum_id = item.forum_id.longLongValue;
        _forum_name = item.forum_name;
        _schema = item.schema;
        _onlookers_count = item.onlookers_count.longLongValue;
        _avatar_url = item.avatar_url;
        _talk_count = item.talk_count.longLongValue;
        _desc = item.desc;
        _status = item.status.longLongValue;
        _banner_url = item.banner_url;
        _follower_count = item.follower_count.longLongValue;
        _participant_count = item.participant_count.longLongValue;
        _share_url = item.share_url;
        _introdution_url = item.introdution_url;
        _like_time = item.like_time.longLongValue;
        _showEtStatus = item.show_et_status.unsignedIntegerValue;
        _article_count = item.article_count.longLongValue;
        _forum_type_flags = item.forum_type_flags.unsignedIntegerValue;
    }
    
    return self;
}

- (instancetype)initWithForumItemStruct:(FRForumItemStructModel *)item
{
    self = [self init];
    if (self) {
        _forum_id = item.forum_id.longLongValue;
        _forum_name = item.forum_name;
        _schema = item.schema;
        _onlookers_count = item.onlookers_count.longLongValue;
        _avatar_url = item.avatar_url;
        _talk_count = item.talk_count.longLongValue;
        _forum_hot_header = item.forum_hot_header;
        _like_time = item.like_time.longLongValue;
        _banner_url = item.banner_url;
    }
    
    return self;
}

- (void)updateWithForumItem:(FRForumItemStructModel *)item
{
    _forum_name = item.forum_name;
    _schema = item.schema;
    _onlookers_count = item.onlookers_count.longLongValue;
    _avatar_url = item.avatar_url;
    _banner_url = item.banner_url;
    _talk_count = item.talk_count.longLongValue;
    _forum_hot_header = item.forum_hot_header;
    _like_time = item.like_time.longLongValue;
}

- (void)updateWithConcernForum:(FRConcernForumStructModel *)item
{
    _forum_name = item.forum_name;
    _showEtStatus = item.show_et_status.unsignedIntegerValue;
}


- (void)updateWithForum:(FRForumStructModel *)item
{
    _forum_name = item.forum_name;
    _schema = item.schema;
    _onlookers_count = item.onlookers_count.longLongValue;
    _avatar_url = item.avatar_url;
    _talk_count = item.talk_count.longLongValue;
    _desc = item.desc;
    _status = item.status.longLongValue;
    _banner_url = item.banner_url;
    _follower_count = item.follower_count.longLongValue;
    _participant_count = item.participant_count.longLongValue;
    _share_url = item.share_url;
    _introdution_url = item.introdution_url;
    _like_time = item.like_time.longLongValue;
    _showEtStatus = item.show_et_status.unsignedIntegerValue;
    _article_count = item.article_count.longLongValue;
}

- (void)receiveForumLikeChangedNotification:(NSNotification *)notification
{
    long long fid = 0;
    @try {
        //此处为了兼容老代码， 预防类型不同造成的问题
        fid = [[[notification userInfo] objectForKey:kForumLikeStatusChangeForumIDKey] longLongValue];
    }
    @catch (NSException *exception) {
        fid = 0;
    }
    @finally {
        
    }
    if (fid == 0 || fid != self.forum_id) {
        return;
    }
    BOOL isLiked = [[[notification userInfo] objectForKey:kForumLikeStatusChangeForumLikeKey] boolValue];
    if (isLiked) {
        if (self.like_time > 0) {
            return;
        }
        else {
            self.like_time = [[NSDate date] timeIntervalSince1970];
            self.onlookers_count = self.onlookers_count + 1;
        }
    }
    else {
        if (self.like_time == 0) {
            return;
        }
        else {
            self.like_time = 0;
            self.onlookers_count = MAX(0, self.onlookers_count - 1);
        }
    }
}


@end
