//
//  FRActionDataService.m
//  Article
//
//  Created by 柴淞 on 17/10/24.
//
//

#import "FRActionDataService.h"
#import "TTEntityBase.h"
#import "EXTKeyPathCoding.h"

@interface FRActionDataModel : TTEntityBase<FRActionDataProtocol>

@property (nonatomic, strong) NSString * primaryID;
@property (atomic, assign) BOOL needSave;

@end

@implementation FRActionDataModel
@synthesize uniqueID = _uniqueID;
@synthesize repostCount = _repostCount;
@synthesize diggCount = _diggCount;
@synthesize readCount = _readCount;
@synthesize commentCount = _commentCount;
@synthesize articleLikeCount = _articleLikeCount;

@synthesize hasRead = _hasRead;
@synthesize hasDigg = _hasDigg;
@synthesize hasDelete = _hasDelete;
@synthesize modelType = _modelType;
@synthesize showOrigin = _showOrigin;
@synthesize articleHasLike = _articleHasLike;

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSString *)primaryKey {
    return @"primaryID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        FRActionDataModel *tmpModel = nil;
        properties = @[
                        @keypath(tmpModel, primaryID),
                        @keypath(tmpModel, uniqueID),
                        
                        @keypath(tmpModel, repostCount),
                        @keypath(tmpModel, diggCount),
                        @keypath(tmpModel, readCount),
                        @keypath(tmpModel, commentCount),
                        
                        @keypath(tmpModel, hasRead),
                        @keypath(tmpModel, hasDigg),
                        @keypath(tmpModel, hasDelete),
                        @keypath(tmpModel, showOrigin),
                         
                        @keypath(tmpModel, articleLikeCount),
                        @keypath(tmpModel, articleHasLike),
                         
                        @keypath(tmpModel, modelType),
                        
                        ];
    }
    return properties;
}

- (BOOL)isEqual:(FRActionDataModel *)object {
    return [object isKindOfClass:[FRActionDataModel class]] && [self.uniqueID isEqualToString:object.uniqueID];
}

- (NSUInteger)hash {
    return [self.uniqueID hash];
}

- (void)setDiggCount:(NSUInteger)diggCount {
    if (_diggCount != diggCount) {
        _diggCount = diggCount;
        [self trySave];
    }
}

- (void)setCommentCount:(NSUInteger)commentCount {
    if (_commentCount != commentCount) {
        _commentCount = commentCount;
        [self trySave];
    }
}

- (void)setReadCount:(NSUInteger)readCount {
    if (_readCount != readCount) {
        _readCount = readCount;
        [self trySave];
    }
}

- (void)setRepostCount:(NSUInteger)repostCount {
    if (_repostCount != repostCount) {
        _repostCount = repostCount;
        [self trySave];
    }
}

- (void)setArticleLikeCount:(NSUInteger)articleLikeCount {
    if (_articleLikeCount != articleLikeCount) {
        _articleLikeCount = articleLikeCount;
        [self trySave];
    }
}

- (void)setHasDigg:(BOOL)hasDigg {
    if (_hasDigg != hasDigg) {
        _hasDigg = hasDigg;
        [self trySave];
    }
}

- (void)setHasDelete:(BOOL)hasDelete {
    if (_hasDelete != hasDelete) {
        _hasDelete = hasDelete;
        [self trySave];
    }
}

- (void)setHasRead:(BOOL)hasRead {
    if (_hasRead != hasRead) {
        _hasRead = hasRead;
        [self trySave];
    }
}

- (void)setShowOrigin:(BOOL)showOrigin {
    if (_showOrigin != showOrigin) {
        _showOrigin = showOrigin;
        [self trySave];
    }
}

- (void)setArticleHasLike:(BOOL)articleHasLike {
    if (_articleHasLike != articleHasLike) {
        _articleHasLike = articleHasLike;
        [self trySave];
    }
}

- (void)trySave {
    if (self.needSave) {
        return;
    }
    self.needSave = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (self.needSave) {
            self.needSave = NO;
            [self save];
        }
    });
}
@end

@implementation FRActionDataService {
    NSMutableDictionary<NSString *, NSMutableArray<FRActionDataModel *> *> *_cacheDictionary;
    NSLock *_lock;
}

+ (FRActionDataService *)sharedInstance {
    return [[FRActionDataService alloc] init];
}

- (void)onServiceInit {
    _cacheDictionary = [NSMutableDictionary new];
    _lock = [[NSLock alloc] init];
}

- (id<FRActionDataProtocol>)modelWithUniqueID:(NSString *)uniqueID {
    return [self modelWithUniqueID:uniqueID type:FRActionDataModelTypeUnknow];
}

- (id<FRActionDataProtocol>)modelWithUniqueID:(NSString *)uniqueID type:(FRActionDataModelType)type {
    if (uniqueID == nil) {
        return nil;
    }
    if ([uniqueID isKindOfClass:[NSNumber class]]) {
        uniqueID = [NSString stringWithFormat:@"%@", uniqueID];
    }
    if ([uniqueID isEqualToString:@""] || [uniqueID isEqualToString:@"0"]) {
        return nil;
    }
    NSString *primaryKey = [NSString stringWithFormat:@"%d-%@", type, uniqueID];
    
    FRActionDataModel *result = nil;
    [_lock lock];
    NSMutableArray<FRActionDataModel *> *cacheResults = [_cacheDictionary objectForKey:uniqueID];
    
    if (cacheResults) {
        if (cacheResults.count == 1) {
            FRActionDataModel *model = [cacheResults firstObject];
            if (model.modelType == FRActionDataModelTypeUnknow
                || type == FRActionDataModelTypeUnknow
                || model.modelType == type) {
                result = model;
            }
        } else {
            for (FRActionDataModel *model in cacheResults) {
                if (model.modelType == type) {
                    result = model;
                    break;
                }
            }
        }
    } else {
        cacheResults = [NSMutableArray arrayWithCapacity:1];
        [_cacheDictionary setObject:cacheResults forKey:uniqueID];
    }
    
    if (result) {
        [_lock unlock];
    } else {
        NSArray *results = [FRActionDataModel objectsWithQuery:@{@"uniqueID" : uniqueID}];
        if (results.count == 1) { //该id数据库只1个
            FRActionDataModel *model = [results firstObject];
            if (model.modelType == FRActionDataModelTypeUnknow
                || type == FRActionDataModelTypeUnknow
                || model.modelType == type) {
                result = model;
            }
        } else {
            for (FRActionDataModel *model in results) {
                if (model.modelType == type) {
                    result = model;
                    break;
                }
            }
        }
        
        if (result == nil) {
            result = [[FRActionDataModel alloc] init];
            result.uniqueID = uniqueID;
            result.modelType = type;
            result.primaryID = primaryKey;
        }
        
        [cacheResults addObject:result];
        [_lock unlock];
    }
    
    if (type != FRActionDataModelTypeUnknow
        && result.modelType == FRActionDataModelTypeUnknow) { //本次如果传入真实的type，则数据库纠正下
        result.modelType = type;
    }
    
    return result;
}
@end
