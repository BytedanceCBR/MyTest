//
//  TTCategoryBadgeNumberManager.m
//  Article
//
//  Created by 王霖 on 2017/6/5.
//
//

#import "TTCategoryBadgeNumberManager.h"
#import "TTCategoryDefine.h"
#import "ArticleBadgeManager.h"
#import "TTSettingMineTabManager.h"

#pragma mark - TTCategoryBadgeNumberModel

@interface TTCategoryBadgeNumberModel : NSObject

@property (nonatomic, copy) NSString * categoryID;
@property (nonatomic, assign) BOOL hasNotifyPoint;
@property (nonatomic, assign) NSUInteger notifyNumber;

@end

@implementation TTCategoryBadgeNumberModel

- (instancetype)initWithCategoryID:(NSString *)categoryID {
    self = [super init];
    if (self) {
        _categoryID = categoryID.copy;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[TTCategoryBadgeNumberModel class]]) {
        return NO;
    }
    return [self.categoryID isEqual:[(TTCategoryBadgeNumberModel*)object categoryID]];
}

- (NSUInteger)hash {
    return self.categoryID.hash;
}

@end

#pragma mark - TTCategoryBadgeNumberManager

@interface TTCategoryBadgeNumberManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, TTCategoryBadgeNumberModel *> * badgeNumberModels;

@end

@implementation TTCategoryBadgeNumberManager

#pragma mark -- Life cycle

+ (instancetype)sharedManager {
    static TTCategoryBadgeNumberManager * _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _badgeNumberModels = @{}.mutableCopy;
        [self addNotification];
    }
    return self;
}

- (void)dealloc {
    [self removeNotification];
}

#pragma mark -- Notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveBadgeMangerChangedNotification:)
                                                 name:kArticleBadgeManagerRefreshedNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receiveBadgeMangerChangedNotification:(NSNotification *)notification {
    [self updateNotifyBadgeNumberOfCategoryID:kTTFollowCategoryID
                                  withBadgeNumber:0];
}

#pragma mark -- Public

- (void)updateNotifyPointOfCategoryID:(NSString *)categoryID withClean:(BOOL)clean {
    TTCategoryBadgeNumberModel * model = [self getOrGenerateCategoryBadgeNumberModelWithCategoryID:categoryID];
    model.hasNotifyPoint = !clean;
    if (model
        && self.delegate
        && [self.delegate respondsToSelector:@selector(categoryBadgeNumberDidChange:categoryID:hasNotifyPoint:badgeNumber:)]) {
        [self.delegate categoryBadgeNumberDidChange:self
                                         categoryID:model.categoryID
                                     hasNotifyPoint:model.hasNotifyPoint
                                        badgeNumber:model.notifyNumber];
    }
}

- (void)updateNotifyBadgeNumberOfCategoryID:(NSString *)categoryID withShow:(BOOL)isShow
{
    
    TTCategoryBadgeNumberModel * modelCategory = [self.badgeNumberModels objectForKey:categoryID];
    if (modelCategory)
    {
        modelCategory.hasNotifyPoint = isShow;
        [self.badgeNumberModels setValue:modelCategory forKey:categoryID];
    }else
    {
        TTCategoryBadgeNumberModel * model = [[TTCategoryBadgeNumberModel alloc] initWithCategoryID:categoryID];
        model.hasNotifyPoint = isShow;
        [self.badgeNumberModels setValue:model forKey:categoryID];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCategoryRefresh" object:nil userInfo:nil];
}

- (void)updateNotifyBadgeNumberOfCategoryID:(NSString *)categoryID withBadgeNumber:(NSUInteger)badgeNumber {
    TTCategoryBadgeNumberModel * model = [self getOrGenerateCategoryBadgeNumberModelWithCategoryID:categoryID];
    model.notifyNumber = badgeNumber;
    if (model
        && self.delegate
        && [self.delegate respondsToSelector:@selector(categoryBadgeNumberDidChange:categoryID:hasNotifyPoint:badgeNumber:)]) {
        [self.delegate categoryBadgeNumberDidChange:self
                                         categoryID:model.categoryID
                                     hasNotifyPoint:model.hasNotifyPoint
                                        badgeNumber:model.notifyNumber];
    }
}

- (NSUInteger)badgeNumberOfCategoryID:(NSString *)categoryID {
    if (isEmptyString(categoryID)) {
        return 0;
    }
    TTCategoryBadgeNumberModel * model = [self.badgeNumberModels objectForKey:categoryID];
    return model.notifyNumber;
}

- (BOOL)hasNotifyPointOfCategoryID:(NSString *)categoryID {
    if (isEmptyString(categoryID)) {
        return NO;
    }
    TTCategoryBadgeNumberModel * model = [self.badgeNumberModels objectForKey:categoryID];
    if ([model.categoryID isEqualToString:kTTFollowCategoryID]) {
        return model.hasNotifyPoint;

    }else {
        return model.hasNotifyPoint;
    }
}

- (TTCategoryBadgeNumberModel *)getOrGenerateCategoryBadgeNumberModelWithCategoryID:(NSString *)categoryID {
    if (isEmptyString(categoryID)) {
        return nil;
    }
    TTCategoryBadgeNumberModel * model = [self.badgeNumberModels objectForKey:categoryID];
    if (nil == model) {
        model = [[TTCategoryBadgeNumberModel alloc] initWithCategoryID:categoryID];
        [self.badgeNumberModels setValue:model forKey:categoryID];
    }
    return model;
}

- (BOOL)isFollowCategoryNeedShowMessageBadgeNumber {
    BOOL isFollowChannelMessageEnable = [SSCommonLogic followChannelMessageEnable];
    
    if (_delegate
        && [_delegate respondsToSelector:@selector(isCategoryInFirstScreen:withCategoryID:)]
        && isFollowChannelMessageEnable) {
        //关注频道在首屏 + setting接口下发关注频道需要显示消息 + 关注频道冷启动完成
        return [_delegate isCategoryInFirstScreen:self withCategoryID:kTTFollowCategoryID];
    }else {
        return NO;
    }
}

@end
