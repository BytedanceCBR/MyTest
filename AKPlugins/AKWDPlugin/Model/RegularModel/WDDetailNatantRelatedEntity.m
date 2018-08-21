//
//  WDDetailNatantRelatedEntity.m
//  Article
//
//  Created by 延晋 张 on 2016/10/25.
//
//

#import "WDDetailNatantRelatedEntity.h"
#import "WDDefines.h"

@interface WDDetailNatantRelatedEntity ()

@property (nonatomic, strong, nullable) NSString *title;
@property (nonatomic, strong, nullable) NSString *schema;
@property (nonatomic, strong, nullable) NSString *typeName;
@property (nonatomic, strong, nullable) NSNumber *typeDayColor;
@property (nonatomic, strong, nullable) NSNumber *typeNightColor;
@property (nonatomic, strong, nullable) NSString *groupId;
@property (nonatomic, strong, nullable) NSString *itemId;
@property (nonatomic, strong, nullable) NSString *impressionID;
@property (nonatomic, strong, nullable) NSString *aggrType;
@property (nonatomic, strong, nullable) NSString *link;
@property (nonatomic, strong, nullable) NSString *word;

@end

@implementation WDDetailNatantRelatedEntity

- (nonnull instancetype)initWithRelatedStructModel:(nonnull WDOrderedItemStructModel *)structModel
{
    if (self = [super init]) {
        _title = structModel.title;
        _schema = structModel.open_page_url;
        _typeName = structModel.type_name;
        _impressionID = structModel.impr_id;
        _itemId = [structModel.item_id stringValue];
        _groupId = [structModel.group_id stringValue];
        _aggrType = structModel.aggr_type;
        _link = structModel.link;
        _word = structModel.word;
    }
    return self;
}

@end
