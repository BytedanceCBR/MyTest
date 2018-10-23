//
//  TTFriendRelationService.m
//  Article
//
//  Created by lipeilun on 2017/12/12.
//

#import "TTFriendRelationService.h"
#import "TTFriendRelationEntity.h"
#import <pthread/pthread.h>
#import <NSObject+TTAdditions.h>
#import <TTBaseMacro.h>
#import <TTAccountManager.h>

@interface TTFriendRelationService() {
    pthread_mutex_t lock;
}
@property (nonatomic, strong) NSMutableDictionary<NSString *, TTFriendRelationEntity *> *relationsTable;
@end

@implementation TTFriendRelationService

- (void)dealloc {
    pthread_mutex_destroy(&lock);
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TTFriendRelationService *service;
    dispatch_once(&onceToken, ^{
        service = [TTFriendRelationService new];
    });
    return service;
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&lock, NULL);
        
        _relationsTable = [NSMutableDictionary dictionaryWithCapacity:100];
        [self preloadAllEntitiesFromDB];
    }
    return self;
}

- (void)preloadAllEntitiesFromDB {
    pthread_mutex_lock(&lock);
    for (TTFriendRelationEntity *entity in [TTFriendRelationEntity objectsWithQuery:nil]) {
        _relationsTable[entity.userID] = entity;
    }
    pthread_mutex_unlock(&lock);
}

- (TTFriendRelationEntity *)entityWithUnknownDataUserID:(NSString *)uid {
    if (isEmptyString(uid)) {
        return nil;
    }
    
    pthread_mutex_lock(&lock);
    TTFriendRelationEntity *entity = _relationsTable[uid];
    pthread_mutex_unlock(&lock);
    return entity;
}


- (TTFriendRelationEntity *)entityWithKnownDataUserID:(NSString *)uid certainFollowing:(BOOL)isFollowing {
    if (isEmptyString(uid)) {
        return nil;
    }
    
    pthread_mutex_lock(&lock);
    TTFriendRelationEntity *entity = _relationsTable[uid];
    if (entity) {
        pthread_mutex_unlock(&lock);
        entity.isFollowing = isFollowing;
        return entity;
    } else {
        //未关注的也先存储
        entity = [TTFriendRelationEntity objectForPrimaryKey:uid];
        if (!entity) {
            entity = [TTFriendRelationEntity new];
            entity.userID = uid;
            entity.isFollowing = isFollowing;
            [entity save];
        }
        
        _relationsTable[uid] = entity;
        pthread_mutex_unlock(&lock);
        entity.isFollowing = isFollowing;
        return entity;
    }
}

- (TTFriendRelationQueryResult)queryFollowingStateUser:(NSString *)uid {
    if (isEmptyString(uid)) {
        return TTFriendRelationQueryResultUnknown;
    }
    
    if ([uid isEqualToString:[TTAccountManager userID]]) {
        return TTFriendRelationQueryResultSelf;
    }
    
    pthread_mutex_lock(&lock);
    TTFriendRelationEntity *entity = _relationsTable[uid];
    pthread_mutex_unlock(&lock);
    if (entity) {
        return entity.isFollowing ? TTFriendRelationQueryResultTrue : TTFriendRelationQueryResultFalse;
    }
    
    return TTFriendRelationQueryResultUnknown;
}

#pragma mark - private

@end
