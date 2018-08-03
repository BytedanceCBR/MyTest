//
//  WDQuestionTagEntity.h
//  Article
//
//  Created by 延晋 张 on 2016/10/24.
//
//

#import "TTEntityBase.h"
#import "WDDefines.h"

@interface WDQuestionTagEntity : TTEntityBase

@property (nonatomic, copy) NSString *concernID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *schema;

- (instancetype)initWithModel:(WDConcernTagStructModel *)structModel;

+ (NSArray<WDQuestionTagEntity *> *)genTagEntitiesWithTagStructModels:(NSArray<WDConcernTagStructModel *> *)structModels;

+ (NSArray<NSDictionary *> *)genTagEntityDicsWithTagStructModels:(NSArray<WDConcernTagStructModel *> *)structModels;

@end
