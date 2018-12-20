//
//  FHFilterNodeModel.m
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "FHFilterNodeModel.h"

@implementation FHFilterNodeModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isEmpty = 0;
        self.isNoLimit = 0;
        self.rate = 1;
    }
    return self;
}

@end

@implementation FHFilterNodeModelConverter

+ (FHFilterNodeModel *)convertDictToModel:(NSDictionary *)dict {
    FHFilterNodeModel* model = [[FHFilterNodeModel alloc] init];
    model.label = dict[@"text"];
    model.isSupportMulti = dict[@"support_multi"];
    model.key = dict[@"type"];
    NSArray* children = dict[@"options"];
    NSMutableArray* options = [[NSMutableArray alloc] init];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFilterNodeModel* result = [FHFilterNodeModelConverter convertDictToModel:obj
                                                               withIsSupportMulti:model.isSupportMulti];
        [options addObject:result];
    }];
    model.children = options;
    return model;
}

+ (FHFilterNodeModel *)convertDictToModel:(NSDictionary *)dict
                       withIsSupportMulti:(BOOL) isSupportMulti {
    FHFilterNodeModel* model = [[FHFilterNodeModel alloc] init];
    model.label = dict[@"text"];
    model.isSupportMulti = isSupportMulti;
    NSNumber* number = dict[@"is_empty"];
    if (number != nil) {
        model.isEmpty = [number integerValue];
    }
    number = dict[@"is_no_limit"];
    if (number != nil) {
        model.isNoLimit = [number integerValue];
    }
    model.key = dict[@"type"];
    model.value = dict[@"value"];
    number = dict[@"rate"];
    if (number != nil) {
        model.rate = [number integerValue];
    }
    NSArray* children = dict[@"options"];
    NSMutableArray* options = [[NSMutableArray alloc] init];
    [children enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHFilterNodeModel* result = [FHFilterNodeModelConverter convertDictToModel:obj
                                                                withIsSupportMulti:model.isSupportMulti];
        [options addObject:result];
    }];
    model.children = options;
    return model;
}


@end
