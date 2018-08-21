//
//  FRConcernListEntity.m
//  Article
//
//  Created by 王霖 on 15/11/4.
//
//

#import "FRConcernListEntity.h"
#import "FRConcernEntity.h"
#import "FRApiModel.h"

@implementation FRConcernListEntity

- (instancetype)initWithConcernItemStructModel:(FRConcernItemStructModel *)concernItemStructModel {
    self = [super init];
    if (self) {
        self.open_url = concernItemStructModel.open_url;
        self.sub_title = concernItemStructModel.sub_title;
        self.concernEntity = [FRConcernEntity genConcernEntityWithConcernItemStruct:concernItemStructModel needUpdate:YES];
    }
    return self;
}

- (instancetype)init {
    return [self initWithConcernItemStructModel:nil];
}

+ (FRConcernListEntity *)getConcernListEntityWithConcernId:(NSString *)concern_id {
    if ([concern_id longLongValue] == 0) {
        return nil;
    }
    FRConcernEntity *cEntity = [FRConcernEntity getConcernEntityWithConcernId:concern_id];
    if (cEntity == nil) {
        return nil;
    }
    FRConcernListEntity *cListEntity = [[FRConcernListEntity alloc] init];
    cListEntity.concernEntity = cEntity;
    cListEntity.open_url = nil;
    cListEntity.sub_title = nil;
    return cListEntity;
}

@end
