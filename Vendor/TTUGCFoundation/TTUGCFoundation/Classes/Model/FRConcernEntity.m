//
//  FRConcernEntity.m
//  Article
//
//  Created by 王霖 on 15/11/2.
//
//

#import "FRConcernEntity.h"
#import "FRCarEntity.h"
#import "FRGameEntity.h"
#import "FRColumnEntity.h"
#import "FRMovieEntity.h"
#import <TTBaseLib/JSONAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>

NSString *const FRConcernEntityCareStateChangeNotification = @"FRConcernEntityCareStateChangeNotification";

NSString *const FRConcernEntityCareStateChangeConcernIDKey = @"FRConcernEntityCareStateChangeConcernIDKey";
NSString *const FRConcernEntityCareStateChangeConcernStateKey = @"FRConcernEntityCareStateChangeConcernStateKey";
NSString *const FRConcernEntityCareStateChangeUserInfoKey = @"FRConcernEntityCareStateChangeUserInfoKey";


NSString * const FRNeedUpdateConcernEntityCareStateNotification = @"FRNeedUpdateConcernEntityCareStateNotification";

NSString * const FRNeedUpdateConcernEntityConcernIDKey = @"FRNeedUpdateConcernEntityConcernIDKey";
NSString * const FRNeedUpdateConcernEntityConcernStateKey = @"FRNeedUpdateConcernEntityConcernStateKey";
NSString * const FRNeedUpdateConcernEntityCareUserInfoKey = @"FRNeedUpdateConcernEntityCareUserInfoKey";



static NSMapTable *concernMaptable;

@implementation FRConcernEntity

- (instancetype)init {
    return [self initWithConcernItemStruct:nil];
}

- (instancetype)initWithConcernItemStruct:(FRConcernItemStructModel *)item {
    self = [super init];
    if (self) {
        self.concern_id = item.concern_id;
        self.name = item.name;
        self.new_thread_count = item.new_thread_count;
        self.avatar_url = item.avatar_url;
        self.concern_count = item.concern_count.longLongValue;
        self.discuss_count = item.discuss_count.longLongValue;
        self.newly = item.newly.intValue > 0? YES:NO;
        self.concern_time = item.concern_time.longLongValue;
        self.managing = item.managing.intValue > 0? YES:NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConcernCareState:) name:FRNeedUpdateConcernEntityCareStateNotification object:nil];
    }
    return self;
}

- (instancetype)initWithConcernStruct:(FRConcernStructModel *)item {
    self = [super init];
    if (self) {
        self.concern_id = item.concern_id;
        self.name = item.name;
        self.new_thread_count = 0;
        self.avatar_url = item.avatar_url;
        self.concern_count = item.concern_count.longLongValue;
        self.discuss_count = item.discuss_count.longLongValue;
        self.newly = NO;
        self.concern_time = item.concern_time.longLongValue;
        self.managing = NO;
        self.share_url = item.share_url;
        self.introdution_url = item.introdution_url;
        self.desc = item.desc;
        self.desc_rich_span = item.desc_rich_span;
        self.type = item.type;
        if (!isEmptyString(item.extra)) {
            self.headInfo = [self generateHeadInfoWithDictionary:[NSString tt_objectWithJSONString:item.extra error:nil]];
        }
        self.share_data = item.share_data;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConcernCareState:) name:FRNeedUpdateConcernEntityCareStateNotification object:nil];
    }
    return self;
}

- (instancetype)initWithConcernInfo:(NSDictionary *)concernInfo {
    self = [super init];
    if (self) {
        self.concern_id = [concernInfo valueForKey:@"concern_id"];
        self.name = [concernInfo valueForKey:@"name"];
        self.new_thread_count = 0;
        self.avatar_url = [concernInfo valueForKey:@"avatar_url"];
        self.concern_count = [[concernInfo valueForKey:@"concern_count"] longLongValue];
        self.discuss_count = [[concernInfo valueForKey:@"discuss_count"] longLongValue];
        self.newly = NO;
        self.concern_time = [[concernInfo valueForKey:@"concern_time"] longLongValue];
        self.share_url = [concernInfo valueForKey:@"share_url"];
        self.introdution_url = [concernInfo valueForKey:@"introdution_url"];
        self.managing = NO;
        self.desc = [concernInfo valueForKey:@"desc"];;
        self.desc_rich_span = [concernInfo valueForKey:@"desc_rich_span"];;
        self.type = [[concernInfo valueForKey:@"type"] integerValue];
        NSString * extra = [concernInfo valueForKey:@"extra"];
        if (!isEmptyString(extra)) {
            self.headInfo = [self generateHeadInfoWithDictionary:[NSString tt_objectWithJSONString:extra error:nil]];
        }
        NSDictionary * shareDataDictionary = [concernInfo valueForKey:@"share_data"];
        if ([shareDataDictionary isKindOfClass:[NSDictionary class]]) {
            self.share_data = [[FRShareStructModel alloc] initWithDictionary:shareDataDictionary error:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConcernCareState:) name:FRNeedUpdateConcernEntityCareStateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateWithConcernItemStruct:(FRConcernItemStructModel *)item {
    self.name = item.name;
    self.new_thread_count = item.new_thread_count;
    self.avatar_url = item.avatar_url;
    self.concern_count = item.concern_count.longLongValue;
    self.discuss_count = item.discuss_count.longLongValue;
    self.newly = item.newly.intValue > 0? YES:NO;
    self.concern_time = item.concern_time.longLongValue;
    self.managing = item.managing.intValue > 0? YES: NO;
}

- (void)updateWithConcernStruct:(FRConcernStructModel *)item {
    self.name = item.name;
    self.avatar_url = item.avatar_url;
    self.concern_count = item.concern_count.longLongValue;
    self.discuss_count = item.discuss_count.longLongValue;
    self.concern_time = item.concern_time.longLongValue;
    self.share_url = item.share_url;
    self.introdution_url = item.introdution_url;
    self.desc = item.desc;
    self.desc_rich_span = item.desc_rich_span;
    self.type = item.type;
    if (!isEmptyString(item.extra)) {
        self.headInfo = [self generateHeadInfoWithDictionary:[NSString tt_objectWithJSONString:item.extra error:nil]];
    }
    self.share_data = item.share_data;
}

- (void)updateWithConcernInfo:(NSDictionary *)concernInfo {
    self.name = concernInfo[@"name"];
    self.avatar_url = concernInfo[@"avatar_url"];
    self.concern_count = [concernInfo[@"concern_count"] longLongValue];
    self.discuss_count = [concernInfo[@"discuss_count"] longLongValue];
    self.concern_time = [concernInfo[@"concern_time"] longLongValue];
    self.share_url = concernInfo[@"share_url"];
    self.introdution_url = concernInfo[@"introdution_url"];
    self.desc = [concernInfo valueForKey:@"desc"];
    self.desc_rich_span = [concernInfo valueForKey:@"desc_rich_span"];
    self.type = [[concernInfo valueForKey:@"type"] integerValue];
    NSString * extra = [concernInfo valueForKey:@"extra"];
    if (!isEmptyString(extra)) {
        self.headInfo = [self generateHeadInfoWithDictionary:[NSString tt_objectWithJSONString:extra error:nil]];
    }
    NSDictionary * shareDataDictionary = [concernInfo valueForKey:@"share_data"];
    if ([shareDataDictionary isKindOfClass:[NSDictionary class]]) {
        self.share_data = [[FRShareStructModel alloc] initWithDictionary:shareDataDictionary error:nil];
    }
}

+ (FRConcernEntity *)getConcernEntityWithConcernId:(NSString *)concern_id {
    if ([concern_id longLongValue] == 0) {
        return nil;
    }
    FRConcernEntity *entity = [concernMaptable objectForKey:concern_id];
    
    return entity;
}

+ (FRConcernEntity *)genConcernEntityWithConcernItemStruct:(FRConcernItemStructModel *)model needUpdate:(BOOL)needUpdate {
    [FRConcernEntity initConcernTable];
    FRConcernEntity *entity = [concernMaptable objectForKey:model.concern_id];
    if (entity) {
        if (needUpdate) {
            [entity updateWithConcernItemStruct:model];
        }
        return entity;
    }
    
    entity = [[FRConcernEntity alloc] initWithConcernItemStruct:model];
    [concernMaptable setObject:entity forKey:model.concern_id];
    
    return entity;
}

+ (FRConcernEntity *)genConcernEntityWithConcernStruct:(FRConcernStructModel *)model needUpdate:(BOOL)needUpdate {
    [FRConcernEntity initConcernTable];
    FRConcernEntity *entity = [concernMaptable objectForKey:model.concern_id];
    if (entity) {
        if (needUpdate) {
            [entity updateWithConcernStruct:model];
        }
        return entity;
    }
    entity = [[FRConcernEntity alloc] initWithConcernStruct:model];
    [concernMaptable setObject:entity forKey:model.concern_id];
    return entity;
}

+ (FRConcernEntity *)genConcernEntityWithConcernInfo:(NSDictionary *)concernInfo needUpdate:(BOOL)needUpdate {
    [FRConcernEntity initConcernTable];
    NSString *concernId = [concernInfo valueForKey:@"concern_id"];
    if (concernInfo.count == 0 || isEmptyString(concernId)) {
        return nil;
    }
    FRConcernEntity *entity = [concernMaptable objectForKey:concernId];
    if (entity) {
        if (needUpdate) {
            [entity updateWithConcernInfo:concernInfo];
        }
        return entity;
    }
    entity = [[FRConcernEntity alloc] initWithConcernInfo:concernInfo];
    [concernMaptable setObject:entity forKey:concernId];
    return entity;
}

+ (void)initConcernTable
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        concernMaptable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
}

#pragma mark - Notification
- (void)updateConcernCareState:(NSNotification *)notification {
    NSString * cid = [[notification userInfo] objectForKey:FRNeedUpdateConcernEntityConcernIDKey];
    if (![cid isEqualToString:_concern_id]) {
        return;
    }
    
    BOOL state = [[[notification userInfo] objectForKey:FRNeedUpdateConcernEntityConcernStateKey] boolValue];
    if (state) {
        self.concern_count ++;
        self.concern_time = [[NSDate date] timeIntervalSince1970] * 1000;
    }else {
        if (self.concern_count > 0) {
            self.concern_count --;
        }
        self.concern_time = 0;
    }
    
    //更新好实体状态，通知外部
    NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfoDic setObject:[[notification userInfo] objectForKey:FRNeedUpdateConcernEntityConcernIDKey] forKey:FRConcernEntityCareStateChangeConcernIDKey];
    [userInfoDic setObject:[[notification userInfo] objectForKey:FRNeedUpdateConcernEntityConcernStateKey] forKey:FRConcernEntityCareStateChangeConcernStateKey];
    if ([[notification userInfo] objectForKey:FRNeedUpdateConcernEntityCareUserInfoKey]) {
        [userInfoDic setObject:[[notification userInfo] objectForKey:FRNeedUpdateConcernEntityCareUserInfoKey] forKey:FRConcernEntityCareStateChangeUserInfoKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRConcernEntityCareStateChangeNotification object:nil userInfo:userInfoDic.copy];
}

#pragma mark - Utils

- (id)generateHeadInfoWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    switch (self.type) {
        case FRInnerForumTypeCar:{
            FRCarEntity * carEntity = [[FRCarEntity alloc] initWithDictionary:dictionary error:nil];
            return carEntity;
        }
        case FRInnerForumTypeGame:{
            FRGameEntity * gameEntity = [[FRGameEntity alloc] initWithDictionary:dictionary error:nil];
            return gameEntity;
        }
        case FRInnerForumTypeColumn:{
            FRColumnEntity * columnEntity = [[FRColumnEntity alloc] initWithDictionary:dictionary error:nil];
            return columnEntity;
        }
        case FRInnerForumTypeMovie:{
            FRMovieEntity * movieEntity = [[FRMovieEntity alloc] initWithDictionary:dictionary error:nil];
            return movieEntity;
        }
        default:
            return nil;
    }
}

@end
