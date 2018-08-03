//
//  WDDetailNatantRelatedEntity.h
//  Article
//
//  Created by 延晋 张 on 2016/10/25.
//
//

#import <Foundation/Foundation.h>

@class WDOrderedItemStructModel;

@interface WDDetailNatantRelatedEntity : NSObject

@property (nonatomic, readonly, strong, nullable) NSString *title;
@property (nonatomic, readonly, strong, nullable) NSString *schema;
@property (nonatomic, readonly, strong, nullable) NSString *typeName;
@property (nonatomic, readonly, strong, nullable) NSNumber *typeDayColor;
@property (nonatomic, readonly, strong, nullable) NSNumber *typeNightColor;
@property (nonatomic, readonly, strong, nullable) NSString *groupId;
@property (nonatomic, readonly, strong, nullable) NSString *itemId;
@property (nonatomic, readonly, strong, nullable) NSString *impressionID;
@property (nonatomic, readonly, strong, nullable) NSString *aggrType;
@property (nonatomic, readonly, strong, nullable) NSString *link;
@property (nonatomic, readonly, strong, nullable) NSString *word;

- (nonnull instancetype)initWithRelatedStructModel:(nonnull WDOrderedItemStructModel *)structModel;

@end
