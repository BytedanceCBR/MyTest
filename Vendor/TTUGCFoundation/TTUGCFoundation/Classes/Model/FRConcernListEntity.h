//
//  FRConcernListEntity.h
//  Article
//
//  Created by 王霖 on 15/11/4.
//
//

#import "FRBaseEntity.h"

@class FRConcernEntity;
@class FRConcernItemStructModel;
@interface FRConcernListEntity : FRBaseEntity

@property(nonatomic, strong)FRConcernEntity *concernEntity;
@property(nonatomic, strong)NSString *open_url;
@property(nonatomic, strong)NSString *sub_title;

- (instancetype)initWithConcernItemStructModel:(FRConcernItemStructModel *)concernItemStructModel NS_DESIGNATED_INITIALIZER;

+ (FRConcernListEntity *)getConcernListEntityWithConcernId:(NSString *)concern_id;

@end
