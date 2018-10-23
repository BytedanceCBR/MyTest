//
//  FRGroupEntity.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/28.
//
//

#import "FRGroupEntity.h"
#import "FRApiModel.h"
@implementation FRGroupEntity


+ (FRGroupEntity *)genFromStruct:(FRGroupStructModel *)model
{
    if (!model) {
        return nil;
    }
    FRGroupEntity * entity = [[FRGroupEntity alloc] init];
    entity.group_id = [model.group_id longLongValue];
    entity.title = model.title;
    entity.thumb_url = model.thumb_url;
    entity.media_type = model.media_type;
    entity.open_url = model.open_url;
    return entity;
}

@end
