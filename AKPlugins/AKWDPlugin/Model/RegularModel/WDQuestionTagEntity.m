//
//  WDQuestionTagEntity.m
//  Article
//
//  Created by 延晋 张 on 2016/10/24.
//
//

#import "WDQuestionTagEntity.h"
#import "WDDataBaseManager.h"
#import "WDDefines.h"

@implementation WDQuestionTagEntity

#pragma mark -- GYModelObject

+ (NSString *)dbName
{
    return [WDDataBaseManager wenDaDBName];
}

+ (NSString *)primaryKey
{
    return @"concernID";
}

+ (NSArray *)persistentProperties {
    
    static NSArray *properties = nil;
    if (!properties) {
        
        NSMutableArray *multiArray = [[NSMutableArray alloc] init];
        if ([super persistentProperties] && [super persistentProperties].count > 0) {
            [multiArray addObjectsFromArray:[super persistentProperties]];
        }
        [multiArray addObjectsFromArray:@[
                                          @"concernID",
                                          @"name",
                                          @"schema"
                                          ]];
        
        properties = multiArray;
    }
    return properties;
}

+ (GYCacheLevel)cacheLevel {
    return GYCacheLevelResident;
}

#pragma mark -- self
- (instancetype)initWithModel:(WDConcernTagStructModel *)structModel
{
    if (self = [super init]) {
        [self updateTagEntityWithTagStructModel:structModel];
    }
    return self;
}


- (void)updateTagEntityWithTagStructModel:(WDConcernTagStructModel *)structModel
{
    self.name = structModel.name;
    self.schema = structModel.schema;
    self.concernID = structModel.concern_id;
}

+ (NSArray<NSDictionary *> *)genTagEntityDicsWithTagStructModels:(NSArray<WDConcernTagStructModel *> *)structModels
{
    NSMutableArray *tagEntityDics = @[].mutableCopy;
    for (WDConcernTagStructModel *structModel in structModels) {
        @try {
            NSDictionary *entityDic = [structModel toDictionary];
            [tagEntityDics addObject:entityDic];
        }
        @catch (NSException *exception) {
            // nothing to do...
        }
    }
    return [tagEntityDics copy];
}

+ (NSArray<WDQuestionTagEntity *> *)genTagEntitiesWithTagStructModels:(NSArray<WDConcernTagStructModel *> *)structModels
{
    NSMutableArray *tagEntities = @[].mutableCopy;
    for (WDConcernTagStructModel *structModel in structModels) {
        WDQuestionTagEntity *entity = [[WDQuestionTagEntity alloc] initWithModel:structModel];
        [tagEntities addObject:entity];
    }
    return [tagEntities copy];
}

- (BOOL)isEqual:(id)object
{
    if(object == self)
    {
        return YES;
    }
    
    if([object isKindOfClass:[WDQuestionTagEntity class]])
    {
        return ([self hash] == [object hash]);
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.name hash] ^ [self.concernID hash];
}

@end
